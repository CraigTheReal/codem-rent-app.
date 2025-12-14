Framework = {}

-- Initialize Core Object based on framework
if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
    if Config.Framework == 'esx' then
        -- ESX Legacy (new)
        Framework.Core = exports['es_extended']:getSharedObject()
    else
        -- Old ESX
        Citizen.CreateThread(function()
            while Framework.Core == nil do
                TriggerEvent('esx:getSharedObject', function(obj) Framework.Core = obj end)
                Citizen.Wait(0)
            end
        end)
    end
elseif Config.Framework == 'qb' then
    Framework.Core = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'qbx' then
    Framework.Core = exports['qbx-core']:GetCoreObject()
end

function Framework.GetPlayer(source)
    if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
        return Framework.Core.GetPlayerFromId(source)
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        return Framework.Core.Functions.GetPlayer(source)
    end
    return nil
end

function Framework.GetPlayerIdentifier(Player)
    if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
        return Player.identifier
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        return Player.PlayerData.citizenid
    end
    return nil
end

function Framework.GetPlayerMoney(Player, account)
    if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
        local acc = Player.getAccount(account)
        return acc and acc.money or 0
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        if account == 'bank' then
            return Player.PlayerData.money.bank or 0
        elseif account == 'cash' then
            return Player.PlayerData.money.cash or 0
        end
    end
    return 0
end

function Framework.AddMoney(Player, account, amount)
    if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
        Player.addAccountMoney(account, amount)
        return true
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        Player.Functions.AddMoney(account, amount)
        return true
    end
    return false
end

function Framework.RemoveMoney(Player, account, amount)
    if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
        Player.removeAccountMoney(account, amount)
        return true
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        Player.Functions.RemoveMoney(account, amount)
        return true
    end
    return false
end

function Framework.RegisterCallback(name, cb)
    if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
        Framework.Core.RegisterServerCallback(name, cb)
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        Framework.Core.Functions.CreateCallback(name, cb)
    end
end

function Framework.TriggerCallback(name, cb, ...)
    if Config.Framework == 'esx' or Config.Framework == 'esx-old' then
        Framework.Core.TriggerServerCallback(name, cb, ...)
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        Framework.Core.Functions.TriggerCallback(name, cb, ...)
    end
end
