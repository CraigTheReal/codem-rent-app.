Config = {}

-- Framework beállítás: 'esx', 'esx-old', 'qb', 'qbx'
-- 'esx' = ESX Legacy (1.9.0+)
-- 'esx-old' = Régi ESX (1.2 vagy korábbi)
-- 'qb' = QBCore
-- 'qbx' = QBX-Core
Config.Framework = 'qb'

-- Notify rendszer: 'ox_lib', 'esx', 'qb', 'custom'
-- 'ox_lib' = ox_lib notify (alapértelmezett - ajánlott)
-- 'esx' = ESX notify
-- 'qb' = QBCore notify
-- 'custom' = Saját notify export (Config.CustomNotify)
-- Megjegyzés: 'codem-phone' nincs implementálva (nincs SendNotification export)
Config.NotifySystem = 'ox_lib'



Config.Locale = 'hu'
Config.Debug = false
Config.Command = 'rentv'

Config.Rental = {
    ChargeInterval = 10000,
    PlatePrefix = 'RENT',
    PlateCounter = 1,
    DefaultFuel = 100,
    VehicleDeleteDelay = 30000,
    SpawnAttempts = 10,
    SpawnCheckRadius = 3.0,
    MaxSpawnDistance = 300.0,
     EnableGhost = true,
    GhostAlpha = 100,
    
}

Config.ProgressBar = {
    RentalDuration = 3000,
    StartTripDuration = 2000,
    EndTripDuration = 1500
}

-- Discord Webhook Logging
Config.Discord = {
    Enabled = true,  -- Kapcsold be ha beallitottad a webhook-ot!
    Webhook = '',

    -- Embed beállítások
    EmbedColor = {
        rental = 3066993,    -- Kék (bérlés)
        error = 15158332,    -- Piros (hiba)
        payment = 16776960,  -- Sárga (fizetés)
    },

    -- Logolási beállítások
    LogRental = true,        -- Bérlések logolása
    LogReturn = true,        -- Visszaadások logolása
    LogPayment = false,      -- Fizetések logolása (spam lehet)
    LogPaymentFailed = true, -- Sikertelen fizetések
    LogError = true,         -- Hibák logolása


    BotName = 'Line Rental System',
    BotAvatar = 'https://cdn.discordapp.com/attachments/1445874462795890730/1445874466402865152/LINE.png?ex=693f1e07&is=693dcc87&hm=87c345af3ff91e12ba5bd0135c1ed2a755ae7963f6677f682001cb6759e656fa&',  -- IMGUR URL (pl: https://i.imgur.com/ABC123.png)

    Footer = {
        text = 'Line Rental System - Multi Framework',
        icon_url = 'https://cdn.discordapp.com/attachments/1445874462795890730/1445874466402865152/LINE.png?ex=693f1e07&is=693dcc87&hm=87c345af3ff91e12ba5bd0135c1ed2a755ae7963f6677f682001cb6759e656fa&'  
    },

    Thumbnails = {
        rental = 'https://cdn.discordapp.com/attachments/1445874462795890730/1445874466402865152/LINE.png?ex=693f1e07&is=693dcc87&hm=87c345af3ff91e12ba5bd0135c1ed2a755ae7963f6677f682001cb6759e656fa&',        
        return_vehicle = 'https://cdn.discordapp.com/attachments/1445874462795890730/1445874466402865152/LINE.png?ex=693f1e07&is=693dcc87&hm=87c345af3ff91e12ba5bd0135c1ed2a755ae7963f6677f682001cb6759e656fa&', 
        error = 'https://cdn.discordapp.com/attachments/1445874462795890730/1445874466402865152/LINE.png?ex=693f1e07&is=693dcc87&hm=87c345af3ff91e12ba5bd0135c1ed2a755ae7963f6677f682001cb6759e656fa&',        
    }
}

Config.Vehicles = {
    {
        model = 'gcscoot',
        label = 'Elektromos Motorbicikli',
        category = 'electric',
        categoryLabel = 'Elektromos',
        description = 'Gyors es kornyezetbarat elektromos motor',
        image = 'gcscoot.png',
        rentalFee = 5000,
        costPerInterval = 90,
        seats = 2,
        maxSpeed = 170,
        fuelType = 'Elektromos',
        spawnCode = 'gcscoot'
    },
    {
        model = 'serv_electricscooter',
        label = 'Elektromos Roller',
        category = 'electric',
        categoryLabel = 'Elektromos',
        description = 'Kornyezetbarat elektromos roller varosi kozlekedeshez',
        image = 'serv_electricscooter.png',
        rentalFee = 5000,
        costPerInterval = 70,
        seats = 1,
        maxSpeed = 70,
        fuelType = 'Elektromos',
        spawnCode = 'serv_electricscooter'
    }
    --{
    --    model = 'adder',
    --    label = 'Adder',
    --    category = 'sports',
    --    categoryLabel = 'Sport autok',
    --    description = 'Szupergyors sportauto',
    --    image = 'adder.png',
    --    rentalFee = 500,
    --    costPerInterval = 200,
    --    seats = 2,
    --    maxSpeed = 250,
    --    fuelType = 'Benzin',
    --    spawnCode = 'adder'
    --}
}



