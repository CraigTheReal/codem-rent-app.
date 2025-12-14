RegisterNetEvent('real_rental:client:tripStarted', function()
    DebugPrint('Trip started event received')
end)

RegisterNetEvent('real_rental:client:tripEnded', function()
    DebugPrint('Trip ended event received')
end)

RegisterNetEvent('real_rental:client:paymentFailed', function()
    if not currentRental or not currentRental.vehicle then return end

    local vehicle = currentRental.vehicle

    FreezeVehicle(vehicle, true)
    SetVehicleGhostMode(vehicle, true)

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent('real_rental:server:syncVehicleGhost', vehicleNetId, true)

    currentRental.tripActive = false

    local ped = PlayerPedId()
    if IsPedInVehicle(ped, vehicle, false) then
        TaskLeaveVehicle(ped, vehicle, 0)
    end

    ShowNotification(Locales[Config.Locale]['notif_trip_cancelled'], 'error')

    DebugPrint('Payment failed, vehicle frozen and ghosted')
end)

RegisterNetEvent('real_rental:client:setVehicleGhost', function(vehicleNetId, isGhost, ownerSource)
    local localSource = GetPlayerServerId(PlayerId())

    if localSource == ownerSource then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)

    if not DoesEntityExist(vehicle) then
        return
    end

    SetVehicleGhostMode(vehicle, isGhost)

    DebugPrint(string.format('Ghost mode synced for vehicle %d: %s', vehicleNetId, tostring(isGhost)))
end)
