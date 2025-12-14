AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
end)

-- ESX Player Loaded
if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
    RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
        local src = playerId or source
        local Player = Framework.GetPlayer(src)
        if not Player then return end

        local identifier = Framework.GetPlayerIdentifier(Player)
        local activeRental = DatabaseModule:getActiveRental(identifier)

        if activeRental then
            DatabaseModule:deleteActiveRentalByIdentifier(identifier)
        end
    end)
end

-- QB/QBX Player Loaded
if Config.Framework == 'qb' or Config.Framework == 'qbx' then
    RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
        local src = source
        local Player = Framework.GetPlayer(src)
        if not Player then return end

        local identifier = Framework.GetPlayerIdentifier(Player)
        local activeRental = DatabaseModule:getActiveRental(identifier)

        if activeRental then
            DatabaseModule:deleteActiveRentalByIdentifier(identifier)
        end
    end)
end

AddEventHandler('playerDropped', function(reason)
end)

Citizen.CreateThread(function()
    while true do
        Wait(300)
        DatabaseModule:cleanupStaleRentals()
    end
end)
