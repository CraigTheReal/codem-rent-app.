local activeRentals = {}

ESX.RegisterServerCallback('real_rental:server:getVehiclesAndBalance', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(nil)
        return
    end

    local bankMoney = xPlayer.getAccount('bank').money

    local response = {
        vehicles = Config.Vehicles,
        balance = bankMoney
    }
    cb(response)
end)

ESX.RegisterServerCallback('real_rental:server:rentVehicle', function(source, cb, vehicleModel)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb({success = false, message = 'Játékos nem található'})
        return
    end

    local identifier = xPlayer.identifier

    if activeRentals[identifier] then
        cb({success = false, message = Locales[Config.Locale]['notif_already_rented']})
        return
    end

    local vehicleData = nil
    for _, vehicle in pairs(Config.Vehicles) do
        if vehicle.model == vehicleModel or vehicle.spawnCode == vehicleModel then
            vehicleData = vehicle
            break
        end
    end

    if not vehicleData then
        cb({success = false, message = 'Jármű adatok nem találhatók!'})
        return
    end

    local bankMoney = xPlayer.getAccount('bank').money
    if bankMoney < vehicleData.rentalFee then
        cb({
            success = false,
            message = string.format(Locales[Config.Locale]['notif_not_enough_money'], vehicleData.rentalFee, bankMoney)
        })
        return
    end

    xPlayer.removeAccountMoney('bank', vehicleData.rentalFee)

    local plate = string.format(Locales[Config.Locale]['vehicle_plate'], Config.Rental.PlateCounter)
    Config.Rental.PlateCounter = Config.Rental.PlateCounter + 1

    local rentalId = DatabaseModule:createRental(xPlayer.identifier, vehicleData, plate)

    if not rentalId then
        xPlayer.addAccountMoney('bank', vehicleData.rentalFee)
        cb({success = false, message = 'Adatbázis hiba történt!'})
        return
    end

    activeRentals[identifier] = {
        rentalId = rentalId,
        vehicleModel = vehicleData.model,
        plate = plate,
        vehicleNetId = nil,
        startedAt = os.time(),
        totalCost = vehicleData.rentalFee,
        costPerInterval = vehicleData.costPerInterval,
        tripActive = false
    }

    cb({
        success = true,
        message = string.format(Locales[Config.Locale]['notif_rental_success'], plate),
        rentalData = {
            rentalId = rentalId,
            vehicleModel = vehicleData.spawnCode,
            plate = plate,
            rentalFee = vehicleData.rentalFee,
            costPerInterval = vehicleData.costPerInterval
        }
    })
end)

ESX.RegisterServerCallback('real_rental:server:getVehicleLocation', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(nil)
        return
    end

    local rental = activeRentals[xPlayer.identifier]

    if not rental or not rental.vehicleNetId then
        cb(nil)
        return
    end

    cb({
        netId = rental.vehicleNetId
    })
end)

ESX.RegisterServerCallback('real_rental:server:processPayment', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb({success = false, reason = 'player_not_found'})
        return
    end

    local rental = activeRentals[xPlayer.identifier]
    if not rental then
        cb({success = false, reason = 'no_rental'})
        return
    end

    local costPerInterval = rental.costPerInterval
    local bankMoney = xPlayer.getAccount('bank').money

    if bankMoney < costPerInterval then
        cb({success = false, reason = 'insufficient_funds', required = costPerInterval, current = bankMoney})
        return
    end

    xPlayer.removeAccountMoney('bank', costPerInterval)

    DatabaseModule:updateRentalCost(rental.rentalId, costPerInterval)

    rental.totalCost = rental.totalCost + costPerInterval
    activeRentals[xPlayer.identifier] = rental

    cb({success = true, newBalance = bankMoney - costPerInterval, totalCost = rental.totalCost})
end)

ESX.RegisterServerCallback('real_rental:server:getActiveRental', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(nil)
        return
    end

    local rental = activeRentals[xPlayer.identifier]
    cb(rental)
end)

ESX.RegisterServerCallback('real_rental:server:getPlayerStats', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(nil)
        return
    end

    local stats = DatabaseModule:getPlayerStats(xPlayer.identifier)
    local history = DatabaseModule:getRentalHistory(xPlayer.identifier, 5)

    cb({
        stats = stats,
        history = history
    })
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        activeRentals[xPlayer.identifier] = nil
    end
end)
