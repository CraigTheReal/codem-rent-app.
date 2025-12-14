currentRental = nil
paymentThread = nil
distanceThread = nil

RegisterCommand(Config.Command, function()
    OpenRentalMenu()
end, false)

function OpenRentalMenu()
    Framework.TriggerCallback('real_rental:server:getVehiclesAndBalance', function(data)
        if not data then
            ShowNotification('Hiba tortent az adatok lekerese soran!', 'error')
            return
        end

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openMenu',
            vehicles = data.vehicles,
            categories = data.categories,
            balance = data.balance
        })
    end)
end

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('rentVehicle', function(data, cb)
    local vehicleModel = data.model

    if not vehicleModel then
        cb({success = false, message = 'Ervenytelen jarmu!'})
        return
    end

    cb({success = true})

    SetNuiFocus(false, false)
    SendNUIMessage({action = 'cleanup'})

    ShowProgressBar(Locales[Config.Locale]['progress_renting'], Config.ProgressBar.RentalDuration, false, nil, function(success)
        if not success then
            ShowNotification('Berles megszakitva!', 'error')
            return
        end

        Framework.TriggerCallback('real_rental:server:rentVehicle', function(result)
            if result.success then
                SpawnRentalVehicle(result.rentalData)
            else
                ShowNotification(result.message, 'error')
            end
        end, vehicleModel)
    end)
end)

RegisterNUICallback('getStats', function(data, cb)
    Framework.TriggerCallback('real_rental:server:getPlayerStats', function(result)
        if result then
            cb({stats = result.stats, history = result.history})
        else
            cb({stats = nil, history = nil})
        end
    end)
end)

function SpawnRentalVehicle(rentalData)
    local spawnCoords, spawnHeading = FindSpawnPosition(Config.Rental.MaxSpawnDistance)

    if not spawnCoords then
        ShowNotification(Locales[Config.Locale]['notif_spawn_failed'], 'error')
        TriggerServerEvent('real_rental:server:cancelRental')
        return
    end

    SpawnVehicle(rentalData.vehicleModel, spawnCoords, spawnHeading, rentalData.plate, function(vehicle)
        if not vehicle then
            ShowNotification(Locales[Config.Locale]['notif_spawn_failed'], 'error')
            TriggerServerEvent('real_rental:server:cancelRental')
            return
        end

        local blip = AddBlipForEntity(vehicle)
        SetBlipSprite(blip, 226)
        SetBlipColour(blip, 2)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Berelt jarmu')
        EndTextCommandSetBlipName(blip)

        currentRental = {
            vehicle = vehicle,
            plate = rentalData.plate,
            vehicleModel = rentalData.vehicleModel,
            rentalId = rentalData.rentalId,
            costPerInterval = rentalData.costPerInterval,
            tripActive = false,
            spawnCoords = spawnCoords,
            blip = blip
        }

        FreezeVehicle(vehicle, true)
        SetVehicleGhostMode(vehicle, true)

        local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
        TriggerServerEvent('real_rental:server:registerVehicle', vehicleNetId)

        TriggerServerEvent('real_rental:server:syncVehicleGhost', vehicleNetId, true)

        StartDistanceDisplay()

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = GetDistanceBetween(playerCoords, spawnCoords)
        ShowNotification(string.format(Locales[Config.Locale]['notif_vehicle_spawned'], math.floor(distance)), 'success')
    end)
end

local isNearVehicle = false

function StartTrip()
    if not currentRental or currentRental.tripActive then return end

    ShowProgressBar(Locales[Config.Locale]['progress_starting'], Config.ProgressBar.StartTripDuration, false, nil, function(success)
        if not success then return end

        TriggerServerEvent('real_rental:server:startTrip')

        FreezeVehicle(currentRental.vehicle, false)
        SetVehicleGhostMode(currentRental.vehicle, false)

        local vehicleNetId = NetworkGetNetworkIdFromEntity(currentRental.vehicle)
        TriggerServerEvent('real_rental:server:syncVehicleGhost', vehicleNetId, false)

        currentRental.tripActive = true

        StartPaymentLoop()
    end)
end

function EndTrip()
    if not currentRental or not currentRental.tripActive then return end

    local ped = PlayerPedId()
    local vehicle = currentRental.vehicle

    SetVehicleEngineOn(vehicle, false, true, true)
    SetVehicleHandbrake(vehicle, true)
    FreezeVehicle(vehicle, true)

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent('real_rental:server:ejectOccupants', vehicleNetId)

    if IsPedInVehicle(ped, vehicle, false) then
        ShowNotification('Kiszállás a járműből...', 'info')
        TaskLeaveVehicle(ped, vehicle, 0)
    end

    Citizen.CreateThread(function()
        Wait(200)

        ShowProgressBar(Locales[Config.Locale]['progress_ending'], Config.ProgressBar.EndTripDuration, false, nil, function(success)
            if not success then
                FreezeVehicle(vehicle, false)
                SetVehicleHandbrake(vehicle, false)
                return
            end

            if not currentRental then return end

            TriggerServerEvent('real_rental:server:endTrip')

            SetEntityAlpha(vehicle, Config.Rental.GhostAlpha, false)
            SetEntityVisible(vehicle, false, false)

            if currentRental.blip and DoesBlipExist(currentRental.blip) then
                RemoveBlip(currentRental.blip)
            end

            currentRental.tripActive = false
            currentRental = nil

            StopPaymentLoop()
            StopDistanceDisplay()

            TriggerServerEvent('real_rental:server:returnVehicle')
            DeleteVehicleWithDelay(vehicle, Config.Rental.VehicleDeleteDelay)

            ShowNotification('Út befejezve! Jármű ' .. math.floor(Config.Rental.VehicleDeleteDelay / 1000) .. ' mp múlva törlődik.', 'success')
        end)
    end)
end

function StartPaymentLoop()
    if paymentThread then return end

    paymentThread = Citizen.CreateThread(function()
        while currentRental and currentRental.tripActive do
            Wait(Config.Rental.ChargeInterval)

            if not currentRental or not currentRental.tripActive then
                break
            end

            local costPerInterval = currentRental.costPerInterval

            Framework.TriggerCallback('real_rental:server:processPayment', function(result)
                if not result.success then
                    if result.reason == 'insufficient_funds' then
                        TriggerServerEvent('real_rental:server:paymentFailed')
                        StopPaymentLoop()
                    end
                end
            end)
        end

        paymentThread = nil
    end)
end

function StopPaymentLoop()
    if paymentThread then
        paymentThread = nil
    end
end

function StartDistanceDisplay()
    if distanceThread then return end

    distanceThread = Citizen.CreateThread(function()
        while currentRental and currentRental.vehicle do
            if DoesEntityExist(currentRental.vehicle) then
                local ped = PlayerPedId()
                local playerCoords = GetEntityCoords(ped)
                local vehicleCoords = GetEntityCoords(currentRental.vehicle)
                local distance = GetDistanceBetween(playerCoords, vehicleCoords)

                isNearVehicle = distance < 5.0

                if distance < 300.0 and not currentRental.tripActive then
                    local textCoords = vector3(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.5)
                    DrawText3D(textCoords, distance)
                end
            end

            Wait(0)
        end

        isNearVehicle = false
        distanceThread = nil
    end)
end

function StopDistanceDisplay()
    if distanceThread then
        distanceThread = nil
    end
    isNearVehicle = false
end

RegisterNetEvent('real_rental:client:ejectFromVehicle', function(vehicleNetId, ownerSrc)
    local ped = PlayerPedId()
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)

    if DoesEntityExist(vehicle) and IsPedInVehicle(ped, vehicle, false) then
        if GetPlayerServerId(PlayerId()) ~= ownerSrc then
            TaskLeaveVehicle(ped, vehicle, 0)
            ShowNotification('A bérlő leállította az utat, kiszállítva...', 'info')
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    SetNuiFocus(false, false)
    SendNUIMessage({action = 'cleanup'})

    if currentRental and currentRental.vehicle then
        if DoesEntityExist(currentRental.vehicle) then
            DeleteEntity(currentRental.vehicle)
        end

        if currentRental.blip and DoesBlipExist(currentRental.blip) then
            RemoveBlip(currentRental.blip)
        end
    end

    StopPaymentLoop()
    StopDistanceDisplay()

    currentRental = nil
end)
