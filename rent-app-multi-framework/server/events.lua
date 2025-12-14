local activeRentals = {}

function GetActiveRental(source)
    local Player = Framework.GetPlayer(source)
    if not Player then return nil end
    local citizenid = Framework.GetPlayerIdentifier(Player)
    return activeRentals[citizenid]
end

function SetActiveRental(source, data)
    local Player = Framework.GetPlayer(source)
    if not Player then return end
    local citizenid = Framework.GetPlayerIdentifier(Player)
    activeRentals[citizenid] = data
end

function ClearActiveRental(source)
    local Player = Framework.GetPlayer(source)
    if not Player then return end
    local citizenid = Framework.GetPlayerIdentifier(Player)
    activeRentals[citizenid] = nil
end

RegisterNetEvent('real_rental:server:registerVehicle', function(vehicleNetId)
    local src = source

    local rental = GetActiveRental(src)
    if not rental then
        return
    end

    rental.vehicleNetId = vehicleNetId
    SetActiveRental(src, rental)
end)

RegisterNetEvent('real_rental:server:startTrip', function()
    local src = source
    local Player = Framework.GetPlayer(src)

    if not Player then return end

    local rental = GetActiveRental(src)
    if not rental then
        return
    end

    rental.tripActive = true
    rental.tripStartedAt = os.time()
    SetActiveRental(src, rental)

    TriggerClientEvent('real_rental:client:tripStarted', src)
end)

RegisterNetEvent('real_rental:server:endTrip', function()
    local src = source
    local Player = Framework.GetPlayer(src)

    if not Player then return end

    local rental = GetActiveRental(src)
    if not rental then
        return
    end

    rental.tripActive = false
    SetActiveRental(src, rental)

    TriggerClientEvent('real_rental:client:tripEnded', src)
end)

RegisterNetEvent('real_rental:server:returnVehicle', function()
    local src = source
    local Player = Framework.GetPlayer(src)

    if not Player then return end

    local rental = GetActiveRental(src)
    if not rental then
        return
    end

    local durationSeconds = os.time() - rental.startedAt
    local durationMinutes = math.floor(durationSeconds / 60)

    -- Discord Log: Return Vehicle
    DiscordLog.Return(src, rental.vehicleModel, rental.plate, rental.totalCost, durationSeconds)

    DatabaseModule:endRental(rental.rentalId)

    ClearActiveRental(src)
    local citizenid = Framework.GetPlayerIdentifier(Player)
    DatabaseModule:deleteActiveRentalByIdentifier(citizenid)
end)

RegisterNetEvent('real_rental:server:paymentFailed', function()
    local src = source
    local Player = Framework.GetPlayer(src)

    if not Player then return end

    local rental = GetActiveRental(src)
    if not rental then return end

    TriggerClientEvent('real_rental:client:paymentFailed', src)

    rental.tripActive = false
    SetActiveRental(src, rental)
end)

RegisterNetEvent('real_rental:server:syncVehicleGhost', function(vehicleNetId, isGhost)
    local src = source
    TriggerClientEvent('real_rental:client:setVehicleGhost', -1, vehicleNetId, isGhost, src)
end)

RegisterNetEvent('real_rental:server:ejectOccupants', function(vehicleNetId)
    local src = source

    local rental = GetActiveRental(src)
    if not rental then
        return
    end

    TriggerClientEvent('real_rental:client:ejectFromVehicle', -1, vehicleNetId, src)
end)

RegisterNetEvent('real_rental:server:cancelRental', function()
    local src = source
    local Player = Framework.GetPlayer(src)

    if not Player then return end

    local rental = GetActiveRental(src)
    if not rental then return end

    Framework.AddMoney(Player, 'bank', rental.totalCost)
    DatabaseModule:deleteActiveRentalById(rental.rentalId)
    ClearActiveRental(src)
end)
