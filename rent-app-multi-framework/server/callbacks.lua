local activeRentals = {}

Framework.RegisterCallback('real_rental:server:getVehiclesAndBalance', function(source, cb)
    local Player = Framework.GetPlayer(source)

    if not Player then
        cb(nil)
        return
    end

    local bankMoney = Framework.GetPlayerMoney(Player, 'bank')

    local response = {
        vehicles = Config.Vehicles,
        balance = bankMoney
    }
    cb(response)
end)

Framework.RegisterCallback('real_rental:server:rentVehicle', function(source, cb, vehicleModel)
    local Player = Framework.GetPlayer(source)

    if not Player then
        cb({success = false, message = 'Játékos nem található'})
        return
    end

    local citizenid = Framework.GetPlayerIdentifier(Player)

    if activeRentals[citizenid] then
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

    local bankMoney = Framework.GetPlayerMoney(Player, 'bank')
    if bankMoney < vehicleData.rentalFee then
        cb({
            success = false,
            message = string.format(Locales[Config.Locale]['notif_not_enough_money'], vehicleData.rentalFee, bankMoney)
        })
        return
    end

    Framework.RemoveMoney(Player, 'bank', vehicleData.rentalFee)

    local plate = string.format(Locales[Config.Locale]['vehicle_plate'], Config.Rental.PlateCounter)
    Config.Rental.PlateCounter = Config.Rental.PlateCounter + 1

    local rentalId = DatabaseModule:createRental(citizenid, vehicleData, plate)

    if not rentalId then
        Framework.AddMoney(Player, 'bank', vehicleData.rentalFee)
        cb({success = false, message = 'Adatbázis hiba történt!'})
        return
    end

    activeRentals[citizenid] = {
        rentalId = rentalId,
        vehicleModel = vehicleData.model,
        plate = plate,
        vehicleNetId = nil,
        startedAt = os.time(),
        totalCost = vehicleData.rentalFee,
        costPerInterval = vehicleData.costPerInterval,
        tripActive = false
    }

   
    DiscordLog.Rental(source, vehicleData, plate, vehicleData.rentalFee)

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

Framework.RegisterCallback('real_rental:server:getVehicleLocation', function(source, cb)
    local Player = Framework.GetPlayer(source)
    if not Player then
        cb(nil)
        return
    end

    local citizenid = Framework.GetPlayerIdentifier(Player)
    local rental = activeRentals[citizenid]

    if not rental or not rental.vehicleNetId then
        cb(nil)
        return
    end

    cb({
        netId = rental.vehicleNetId
    })
end)

Framework.RegisterCallback('real_rental:server:processPayment', function(source, cb)
    local Player = Framework.GetPlayer(source)

    if not Player then
        cb({success = false, reason = 'player_not_found'})
        return
    end

    local citizenid = Framework.GetPlayerIdentifier(Player)
    local rental = activeRentals[citizenid]
    if not rental then
        cb({success = false, reason = 'no_rental'})
        return
    end

    local costPerInterval = rental.costPerInterval
    local bankMoney = Framework.GetPlayerMoney(Player, 'bank')

    if bankMoney < costPerInterval then
       
        DiscordLog.PaymentFailed(source, rental.vehicleModel, rental.plate, costPerInterval, bankMoney)

        cb({success = false, reason = 'insufficient_funds', required = costPerInterval, current = bankMoney})
        return
    end

    Framework.RemoveMoney(Player, 'bank', costPerInterval)

    DatabaseModule:updateRentalCost(rental.rentalId, costPerInterval)

    rental.totalCost = rental.totalCost + costPerInterval
    activeRentals[citizenid] = rental

    DiscordLog.Payment(source, costPerInterval, rental.vehicleModel, rental.plate)

    cb({success = true, newBalance = bankMoney - costPerInterval, totalCost = rental.totalCost})
end)

Framework.RegisterCallback('real_rental:server:getActiveRental', function(source, cb)
    local Player = Framework.GetPlayer(source)
    if not Player then
        cb(nil)
        return
    end

    local citizenid = Framework.GetPlayerIdentifier(Player)
    local rental = activeRentals[citizenid]
    cb(rental)
end)

Framework.RegisterCallback('real_rental:server:getPlayerStats', function(source, cb)
    local Player = Framework.GetPlayer(source)

    if not Player then
        cb(nil)
        return
    end

    local citizenid = Framework.GetPlayerIdentifier(Player)
    local stats = DatabaseModule:getPlayerStats(citizenid)
    local history = DatabaseModule:getRentalHistory(citizenid, 5)

    cb({
        stats = stats,
        history = history
    })
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local Player = Framework.GetPlayer(src)
    if Player then
        local citizenid = Framework.GetPlayerIdentifier(Player)
        activeRentals[citizenid] = nil
    end
end)
