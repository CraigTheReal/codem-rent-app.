ESX = exports['es_extended']:getSharedObject()

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
end)

RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
    local src = playerId

    local activeRental = DatabaseModule:getActiveRental(xPlayer.identifier)

    if activeRental then
        DatabaseModule:deleteActiveRentalByIdentifier(xPlayer.identifier)
    end
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
end)

Citizen.CreateThread(function()
    while true do
        Wait(300)
        DatabaseModule:cleanupStaleRentals()
    end
end)
