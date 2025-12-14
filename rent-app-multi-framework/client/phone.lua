local appRegistered = false

CreateThread(function()
    while GetResourceState('codem-phone') ~= 'started' do
        Wait(100)
    end

    Wait(1000)

    local resourceName = GetCurrentResourceName()
    local htmlContent = LoadResourceFile(resourceName, 'ui/index.html')

    if not htmlContent then
        return
    end

    -- Replace hard-coded resource name with actual resource name
    htmlContent = htmlContent:gsub('nui://codem%-rent%-app/', 'nui://' .. resourceName .. '/')

    local success, err = exports['codem-phone']:AddCustomApp({
        identifier = 'rent-app',
        name = 'Line',
        icon = string.format('nui://%s/ui/icon.svg', resourceName),
        ui = htmlContent,
        description = 'Járművek bérlése',
        defaultApp = false,
        notification = true,
        onOpen = function()
        end,
        onClose = function()
        end
    })

    if success then
        appRegistered = true
        print(string.format('^2[%s] LINE rental app successfully registered!^7', resourceName))
    else
        print(string.format('^1[%s] Failed to register LINE rental app: %s^7', resourceName, tostring(err)))
    end
end)

RegisterNetEvent('real_rental:client:spawnFromPhone', function(rentalData)
    SpawnRentalVehicle(rentalData)
end)

RegisterNetEvent('real_rental:client:startTripFromPhone', function()
    if currentRental and not currentRental.tripActive then
        if DoesEntityExist(currentRental.vehicle) then
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            local vehicleCoords = GetEntityCoords(currentRental.vehicle)
            local distance = GetDistanceBetween(playerCoords, vehicleCoords)

            if distance < 5.0 then
                StartTrip()
            else
                ShowNotification(string.format('Túl messze vagy! Távolság: %.0fm (max 5m)', distance), 'error')
            end
        end
    end
end)

RegisterNetEvent('real_rental:client:endTripFromPhone', function()
    if currentRental and currentRental.tripActive then
        EndTrip()
    end
end)

RegisterNetEvent('real_rental:client:returnFromPhone', function()
    if currentRental then
        if DoesEntityExist(currentRental.vehicle) then
            DeleteEntity(currentRental.vehicle)
        end

        if currentRental.blip and DoesBlipExist(currentRental.blip) then
            RemoveBlip(currentRental.blip)
        end

        StopPaymentLoop()
        StopDistanceDisplay()

        TriggerServerEvent('real_rental:server:returnVehicle')

        TriggerEvent('real_rental:client:vehicleReturned')

        currentRental = nil
    end
end)

AddEventHandler('codem-phone:customApp:rent-app:getRentalStatus', function(payload, cb)
    if not currentRental then
        cb({ rental = nil })
        return
    end

    local rentalStatus = {
        hasRental = true,
        plate = currentRental.plate,
        vehicleModel = currentRental.vehicleModel,
        costPerInterval = currentRental.costPerInterval,
        tripActive = currentRental.tripActive or false,
        canStartTrip = false,
        distance = 999
    }

    if DoesEntityExist(currentRental.vehicle) then
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)
        local vehicleCoords = GetEntityCoords(currentRental.vehicle)
        local distance = GetDistanceBetween(playerCoords, vehicleCoords)

        rentalStatus.distance = math.floor(distance)
        rentalStatus.canStartTrip = distance < 5.0
    end

    cb({ rental = rentalStatus })
end)
