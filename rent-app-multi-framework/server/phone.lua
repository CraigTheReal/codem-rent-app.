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

AddEventHandler('codem-phone:customApp:rent-app:getVehiclesAndBalance', function(source, payload, cb)
    local Player = Framework.GetPlayer(source)

    if not Player then
        cb({ success = false })
        return
    end

    local bankMoney = Framework.GetPlayerMoney(Player, 'bank')

    cb({
        success = true,
        vehicles = Config.Vehicles,
        balance = bankMoney
    })
end)

AddEventHandler('codem-phone:customApp:rent-app:rentVehicle', function(source, payload, cb)
    local vehicleModel = payload.model
    if not vehicleModel then
        cb({ success = false, message = 'Érvénytelen jármű' })
        return
    end

    local Player = Framework.GetPlayer(source)

    if not Player then
        cb({ success = false, message = 'Játékos nem található' })
        return
    end

    local citizenid = Framework.GetPlayerIdentifier(Player)

    if activeRentals[citizenid] then
        cb({ success = false, message = 'Már van aktív bérlésed!' })
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
        cb({ success = false, message = 'Jármű adatok nem találhatók!' })
        return
    end

    local bankMoney = Framework.GetPlayerMoney(Player, 'bank')
    if bankMoney < vehicleData.rentalFee then
        cb({ success = false, message = string.format('Nincs elég pénzed! Szükséges: $%d', vehicleData.rentalFee) })
        return
    end

    Framework.RemoveMoney(Player, 'bank', vehicleData.rentalFee)

    local plate = string.format('RENT%03d', Config.Rental.PlateCounter)
    Config.Rental.PlateCounter = Config.Rental.PlateCounter + 1

    local rentalId = DatabaseModule:createRental(citizenid, vehicleData, plate)

    if not rentalId then
        Framework.AddMoney(Player, 'bank', vehicleData.rentalFee)
        cb({ success = false, message = 'Adatbázis hiba történt!' })
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

    TriggerClientEvent('real_rental:client:spawnFromPhone', source, {
        rentalId = rentalId,
        vehicleModel = vehicleData.spawnCode,
        plate = plate,
        rentalFee = vehicleData.rentalFee,
        costPerInterval = vehicleData.costPerInterval
    })

    cb({ success = true, message = 'Bérlés sikeres! Rendszám: ' .. plate })
end)

AddEventHandler('codem-phone:customApp:rent-app:getActiveRental', function(source, payload, cb)
    local rental = GetActiveRental(source)

    if rental then
        cb({
            rental = {
                vehicleModel = rental.vehicleModel,
                plate = rental.plate,
                costPerInterval = rental.costPerInterval,
                hasRental = true
            }
        })
    else
        cb({ rental = nil })
    end
end)

AddEventHandler('codem-phone:customApp:rent-app:startTrip', function(source, payload, cb)
    TriggerClientEvent('real_rental:client:startTripFromPhone', source)
    cb({ success = true, message = 'Út elindítva!' })
end)

AddEventHandler('codem-phone:customApp:rent-app:endTrip', function(source, payload, cb)
    TriggerClientEvent('real_rental:client:endTripFromPhone', source)
    cb({ success = true, message = 'Út befejezve!' })
end)

AddEventHandler('codem-phone:customApp:rent-app:returnVehicle', function(source, payload, cb)
    TriggerClientEvent('real_rental:client:returnFromPhone', source)
    cb({ success = true, message = 'Jármű visszaadva!' })
end)

AddEventHandler('codem-phone:customApp:rent-app:getPlayerStats', function(source, payload, cb)
    local Player = Framework.GetPlayer(source)

    if not Player then
        cb({ success = false })
        return
    end

    local citizenid = Framework.GetPlayerIdentifier(Player)
    local stats = DatabaseModule:getPlayerStats(citizenid)
    local history = DatabaseModule:getRentalHistory(citizenid, 5)

    local formattedStats = {
        totalRentals = stats.totalRentals or 0,
        totalSpent = stats.totalSpent or 0,
        totalTripTime = stats.totalTripTime or 0,
        avgCost = stats.avgCost or 0,
        recentRentals = {}
    }

    if history then
        for _, rental in ipairs(history) do
            local vehicleLabel = rental.vehicleModel
            for _, vehicle in pairs(Config.Vehicles) do
                if vehicle.model == rental.vehicleModel or vehicle.spawnCode == rental.vehicleModel then
                    vehicleLabel = vehicle.label
                    break
                end
            end

            table.insert(formattedStats.recentRentals, {
                vehicleModel = rental.vehicleModel,
                vehicleLabel = vehicleLabel,
                plate = rental.plate,
                totalCost = rental.totalCost or 0,
                startedAt = rental.startedAt,
                endedAt = rental.endedAt
            })
        end
    end

    cb({
        success = true,
        stats = formattedStats
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
