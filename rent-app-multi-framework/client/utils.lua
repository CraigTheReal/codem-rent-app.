function ShowNotification(message, type, duration)
    duration = duration or 5000
    type = type or 'info'

    if Config.NotifySystem == 'codem-phone' then
        -- Codem-phone notification
        local notifyType = 'info'
        local header = 'Line Rental'

        -- Map type to appropriate header and style
        if type == 'success' then
            notifyType = 'success'
            header = 'Siker'
        elseif type == 'error' then
            notifyType = 'error'
            header = 'Hiba'
        elseif type == 'warning' then
            notifyType = 'warning'
            header = 'Figyelmeztetés'
        elseif type == 'info' then
            notifyType = 'info'
            header = 'Információ'
        end

        exports['codem-phone']:SendNotification({
            app = 'rent-app',
            header = header,
            message = message,
            timeout = duration
        })

    elseif Config.NotifySystem == 'ox_lib' then
        -- ox_lib notify (default)
        lib.notify({
            description = message,
            type = type,
            duration = duration,
            position = 'top-right'
        })

    elseif Config.NotifySystem == 'esx' then
        -- ESX notify
        if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
            Framework.Core.ShowNotification(message)
        end

    elseif Config.NotifySystem == 'qb' then
        -- QBCore notify
        if Config.Framework == 'qb' or Config.Framework == 'qbx' then
            Framework.Core.Functions.Notify(message, type, duration)
        end

    elseif Config.NotifySystem == 'custom' and Config.CustomNotify then
        -- Custom notify function
        Config.CustomNotify(message, type, duration)

    else
        -- Fallback to ox_lib
        lib.notify({
            description = message,
            type = type,
            duration = duration,
            position = 'top-right'
        })
    end
end

function DrawText3D(coords, distance)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

    if onScreen then
        local distanceNum = tostring(math.floor(distance))

        SetTextScale(0.5, 0.5)
        SetTextFont(4)
        SetTextProportional(1)
        BeginTextCommandWidth('STRING')
        AddTextComponentString(distanceNum)
        local numberWidth = EndTextCommandGetWidth(true)

        SetTextScale(0.5, 0.5)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(false)
        AddTextComponentString(distanceNum)
        DrawText(_x - (numberWidth / 2), _y)

        SetTextScale(0.45, 0.45)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 215, 0, 255)
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(false)
        AddTextComponentString('m')
        DrawText(_x + (numberWidth / 2), _y)
    end
end

function FindSpawnPosition(maxDistance, attempts)
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    attempts = attempts or Config.Rental.SpawnAttempts

    for i = 1, attempts do
        local angle = math.random(0, 360) * (math.pi / 180)
        local distance = math.random(50, math.min(150, maxDistance))

        local spawnX = playerCoords.x + math.cos(angle) * distance
        local spawnY = playerCoords.y + math.sin(angle) * distance

        local foundGround, groundZ, groundNormal = GetGroundZAndNormalFor_3dCoord(spawnX, spawnY, playerCoords.z + 100.0, false)

        if foundGround then
            local spawnCoords = vector3(spawnX, spawnY, groundZ + 1.0)

            local rayHandle = StartShapeTestRay(spawnX, spawnY, groundZ + 50.0, spawnX, spawnY, groundZ - 5.0, 1, 0, 0)
            local _, hit, _, _, materialHash = GetShapeTestResult(rayHandle)

            local isOnRoad = IsPointOnRoad(spawnX, spawnY, groundZ, 0)

            if isOnRoad and IsSpawnPointClear(spawnCoords, Config.Rental.SpawnCheckRadius) then
                return spawnCoords, math.random(0, 360) * 1.0
            end
        end

        Wait(10)
    end

    return nil, nil
end

function IsSpawnPointClear(coords, radius)
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, radius, 0, 71)
    return vehicle == 0
end

function GetDistanceBetween(coords1, coords2)
    return #(coords1 - coords2)
end

function FormatDistance(distance)
    return math.floor(distance)
end

function FormatCurrency(amount)
    return string.format(Locales[Config.Locale]['currency'], amount)
end

function FreezeVehicle(vehicle, freeze)
    if not DoesEntityExist(vehicle) then return end

    FreezeEntityPosition(vehicle, freeze)
    SetEntityInvincible(vehicle, freeze)
    SetVehicleEngineOn(vehicle, not freeze, true, true)
    SetVehicleUndriveable(vehicle, freeze)
end

function SetVehicleGhostMode(vehicle, isGhost)
    if not DoesEntityExist(vehicle) then return end

    if isGhost then
        SetEntityAlpha(vehicle, Config.Rental.GhostAlpha, false)
        SetEntityCollision(vehicle, false, false)
        SetEntityCompletelyDisableCollision(vehicle, false, false)
    else
        ResetEntityAlpha(vehicle)
        SetEntityCollision(vehicle, true, true)
    end
end

function SpawnVehicle(model, coords, heading, plate, callback)
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end

    if not HasModelLoaded(modelHash) then
        if callback then callback(nil) end
        return
    end

    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)

    if not DoesEntityExist(vehicle) then
        SetModelAsNoLongerNeeded(modelHash)
        if callback then callback(nil) end
        return
    end

    SetVehicleNumberPlateText(vehicle, plate)
    SetVehicleFuelLevel(vehicle, Config.Rental.DefaultFuel * 1.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleEngineOn(vehicle, false, true, true)

    SetModelAsNoLongerNeeded(modelHash)

    if callback then
        callback(vehicle)
    end

    return vehicle
end

function DeleteVehicleWithDelay(vehicle, delay)
    delay = delay or Config.Rental.VehicleDeleteDelay

    Citizen.CreateThread(function()
        Wait(delay)

        if DoesEntityExist(vehicle) then
            local alpha = 255
            while alpha > 0 do
                SetEntityAlpha(vehicle, alpha, false)
                alpha = alpha - 5
                Wait(50)
            end

            DeleteEntity(vehicle)
        end
    end)
end

function VectorToTable(vec)
    return {x = vec.x, y = vec.y, z = vec.z}
end

function TableToVector(tbl)
    return vector3(tbl.x, tbl.y, tbl.z)
end

function DebugPrint(message)
    if Config.Debug then
    end
end

function ShowProgressBar(label, duration, canCancel, disableControls, callback)
    if lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = canCancel or false,
        disable = disableControls or {
            car = true,
            move = false,
            combat = true
        }
    }) then
        if callback then callback(true) end
        return true
    else
        if callback then callback(false) end
        return false
    end
end
