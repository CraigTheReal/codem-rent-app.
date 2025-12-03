Config = {}

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
    GhostAlpha = 100
}

Config.ProgressBar = {
    RentalDuration = 3000,
    StartTripDuration = 2000,
    EndTripDuration = 1500
}

Config.Discord = {
    Enabled = true,
    Webhook = 'Discord_Webhook',
    LogError = true,
    LogRental = true,
    LogReturn = true
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



