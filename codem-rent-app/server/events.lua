local activeRentals = {}

function GetActiveRental(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    return activeRentals[xPlayer.identifier]
end

function SetActiveRental(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    activeRentals[xPlayer.identifier] = data
end

function ClearActiveRental(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    activeRentals[xPlayer.identifier] = nil
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
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

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
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

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
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local rental = GetActiveRental(src)
    if not rental then
        return
    end

    local durationSeconds = os.time() - rental.startedAt
    local durationMinutes = math.floor(durationSeconds / 60)

    DatabaseModule:endRental(rental.rentalId)

    ClearActiveRental(src)
    DatabaseModule:deleteActiveRentalByIdentifier(xPlayer.identifier)
end)

RegisterNetEvent('real_rental:server:paymentFailed', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

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
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local rental = GetActiveRental(src)
    if not rental then return end

    xPlayer.addAccountMoney('bank', rental.totalCost)
    DatabaseModule:deleteActiveRentalById(rental.rentalId)
    ClearActiveRental(src)
end)
