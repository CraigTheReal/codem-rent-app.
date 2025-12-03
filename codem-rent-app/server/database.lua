DatabaseModule = {
    createRental = function(self, identifier, vehicleData, plate)
        local result = MySQL.insert.await([[
            INSERT INTO line_rentals (identifier, vehicleModel, plate, rentalFee, costPerInterval, totalCost, isActive)
            VALUES (?, ?, ?, ?, ?, ?, 1)
        ]], {
            identifier,
            vehicleData.model,
            plate,
            vehicleData.rentalFee,
            vehicleData.costPerInterval,
            vehicleData.rentalFee
        })

        return result
    end,

    getActiveRental = function(self, identifier)
        local result = MySQL.query.await([[
            SELECT * FROM line_rentals
            WHERE identifier = ? AND isActive = 1
            LIMIT 1
        ]], {identifier})

        if result and #result > 0 then
            return result[1]
        end

        return nil
    end,

    updateRentalCost = function(self, rentalId, amount)
        local affectedRows = MySQL.update.await([[
            UPDATE line_rentals
            SET totalCost = totalCost + ?
            WHERE id = ?
        ]], {amount, rentalId})

        return affectedRows > 0
    end,

    endRental = function(self, rentalId)
        local rental = MySQL.query.await([[
            SELECT * FROM line_rentals WHERE id = ?
        ]], {rentalId})

        if not rental or #rental == 0 then
            return false
        end

        local rentalData = rental[1]
        local currentTimeMs = os.time() * 1000
        local durationSeconds = math.floor((currentTimeMs - rentalData.startedAt) / 1000)

        local affectedRows = MySQL.update.await([[
            UPDATE line_rentals
            SET endedAt = NOW(),
                tripDuration = ?,
                isActive = 0
            WHERE id = ?
        ]], {durationSeconds, rentalId})

        return affectedRows > 0
    end,

    deleteActiveRentalByIdentifier = function(self, identifier)
        local affectedRows = MySQL.update.await([[
            DELETE FROM line_rentals WHERE identifier = ? AND isActive = 1
        ]], {identifier})

        return affectedRows > 0
    end,

    deleteActiveRentalById = function(self, rentalId)
        local affectedRows = MySQL.update.await([[
            DELETE FROM line_rentals WHERE id = ?
        ]], {rentalId})

        return affectedRows > 0
    end,

    getRentalHistory = function(self, identifier, limit)
        limit = limit or 10

        local result = MySQL.query.await([[
            SELECT * FROM line_rentals
            WHERE identifier = ? AND isActive = 0
            ORDER BY endedAt DESC
            LIMIT ?
        ]], {identifier, limit})

        return result or {}
    end,

    getPlayerStats = function(self, identifier)
        local stats = MySQL.query.await([[
            SELECT
                COUNT(*) as totalRentals,
                COALESCE(SUM(totalCost), 0) as totalSpent,
                COALESCE(SUM(tripDuration), 0) as totalTripTime,
                COALESCE(AVG(totalCost), 0) as avgCost
            FROM line_rentals
            WHERE identifier = ? AND isActive = 0
        ]], {identifier})

        if stats and #stats > 0 then
            return stats[1]
        end

        return {
            totalRentals = 0,
            totalSpent = 0,
            totalTripTime = 0,
            avgCost = 0
        }
    end,

    cleanupStaleRentals = function(self)
        local affectedRows = MySQL.update.await([[
            DELETE FROM line_rentals
            WHERE isActive = 1 AND startedAt < DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ]])

        return affectedRows
    end
}

Citizen.CreateThread(function()
    Wait(5000)
    DatabaseModule:cleanupStaleRentals()
end)
