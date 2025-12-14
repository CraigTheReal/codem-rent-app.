DiscordLog = {}


local function SendWebhook(embed)
    if not Config.Discord.Enabled or not Config.Discord.Webhook then return end
    if Config.Discord.Webhook == 'YOUR_DISCORD_WEBHOOK_URL_HERE' then return end

    local payload = {
        username = Config.Discord.BotName or 'Line Rental System',
        avatar_url = Config.Discord.BotAvatar,
        embeds = { embed }
    }

    PerformHttpRequest(Config.Discord.Webhook, function(err, text, headers)
        if err ~= 200 then
            print('^1[Discord Log] Webhook hiba: ' .. tostring(err) .. '^7')
        end
    end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end


local function GetPlayerInfo(source)
    local Player = Framework.GetPlayer(source)
    if not Player then return nil end

    local identifier = Framework.GetPlayerIdentifier(Player)
    local name = GetPlayerName(source)

    local identifiers = {
        steam = '',
        license = '',
        discord = ''
    }

    for k, v in pairs(GetPlayerIdentifiers(source)) do
        if string.find(v, 'steam:') then
            identifiers.steam = v
        elseif string.find(v, 'license:') then
            identifiers.license = v
        elseif string.find(v, 'discord:') then
            identifiers.discord = '<@' .. string.gsub(v, 'discord:', '') .. '>'
        end
    end

    return {
        source = source,
        name = name,
        identifier = identifier,
        steam = identifiers.steam,
        license = identifiers.license,
        discord = identifiers.discord
    }
end

-- Helper: Format time
local function FormatTime()
    return os.date('%Y-%m-%d %H:%M:%S')
end

function DiscordLog.Rental(source, vehicleData, plate, rentalFee)
    if not Config.Discord.LogRental then return end

    local player = GetPlayerInfo(source)
    if not player then return end

    local embed = {
        title = '🚗 Új Jármű Bérlés',
        description = string.format('**%s** bérelt egy járművet', player.name),
        color = Config.Discord.EmbedColor.rental,
        fields = {
            {
                name = '👤 Játékos Információ',
                value = string.format('**Név:** %s\n**ID:** %s\n**Discord:** %s',
                    player.name,
                    player.identifier,
                    player.discord ~= '' and player.discord or 'N/A'
                ),
                inline = true
            },
            {
                name = '🚙 Jármű Információ',
                value = string.format('**Model:** %s\n**Rendszám:** %s\n**Kategória:** %s',
                    vehicleData.label or vehicleData.model,
                    plate,
                    vehicleData.categoryLabel or 'N/A'
                ),
                inline = true
            },
            {
                name = '💰 Pénzügyi Információ',
                value = string.format('**Bérlési díj:** $%s\n**Költség/intervallum:** $%s',
                    rentalFee,
                    vehicleData.costPerInterval
                ),
                inline = false
            }
        },
        footer = Config.Discord.Footer,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
        thumbnail = {
            url = Config.Discord.Thumbnails.rental
        }
    }

    SendWebhook(embed)
end


function DiscordLog.Return(source, vehicleModel, plate, totalCost, duration)
    if not Config.Discord.LogReturn then return end

    local player = GetPlayerInfo(source)
    if not player then return end

    local minutes = math.floor(duration / 60)
    local seconds = duration % 60

    local embed = {
        title = '✅ Jármű Visszaadva',
        description = string.format('**%s** visszaadta a bérelt járművet', player.name),
        color = Config.Discord.EmbedColor.return_vehicle,
        fields = {
            {
                name = '👤 Játékos Információ',
                value = string.format('**Név:** %s\n**ID:** %s\n**Discord:** %s',
                    player.name,
                    player.identifier,
                    player.discord ~= '' and player.discord or 'N/A'
                ),
                inline = true
            },
            {
                name = '🚙 Jármű Információ',
                value = string.format('**Model:** %s\n**Rendszám:** %s',
                    vehicleModel,
                    plate
                ),
                inline = true
            },
            {
                name = '💰 Összesítés',
                value = string.format('**Teljes költség:** $%s\n**Időtartam:** %dm %ds',
                    totalCost,
                    minutes,
                    seconds
                ),
                inline = false
            }
        },
        footer = Config.Discord.Footer,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
        thumbnail = {
            url = Config.Discord.Thumbnails.return_vehicle
        }
    }

    SendWebhook(embed)
end


function DiscordLog.PaymentFailed(source, vehicleModel, plate, requiredAmount, currentBalance)
    if not Config.Discord.LogPaymentFailed then return end

    local player = GetPlayerInfo(source)
    if not player then return end

    local embed = {
        title = '⚠️ Sikertelen Fizetés',
        description = string.format('**%s** nem tudta kifizetni a bérlést', player.name),
        color = Config.Discord.EmbedColor.error,
        fields = {
            {
                name = '👤 Játékos Információ',
                value = string.format('**Név:** %s\n**ID:** %s\n**Discord:** %s',
                    player.name,
                    player.identifier,
                    player.discord ~= '' and player.discord or 'N/A'
                ),
                inline = true
            },
            {
                name = '🚙 Jármű Információ',
                value = string.format('**Model:** %s\n**Rendszám:** %s',
                    vehicleModel,
                    plate
                ),
                inline = true
            },
            {
                name = '💸 Pénzügyi Probléma',
                value = string.format('**Szükséges összeg:** $%s\n**Jelenlegi egyenleg:** $%s\n**Hiányzó:** $%s',
                    requiredAmount,
                    currentBalance,
                    requiredAmount - currentBalance
                ),
                inline = false
            }
        },
        footer = Config.Discord.Footer,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
        thumbnail = {
            url = Config.Discord.Thumbnails.error
        }
    }

    SendWebhook(embed)
end


function DiscordLog.Error(source, errorType, errorMessage, additionalData)
    if not Config.Discord.LogError then return end

    local player = source and GetPlayerInfo(source) or nil

    local playerInfo = 'N/A'
    if player then
        playerInfo = string.format('**Név:** %s\n**ID:** %s\n**Source:** %s',
            player.name,
            player.identifier,
            player.source
        )
    end

    local embed = {
        title = '❌ Rendszer Hiba',
        description = string.format('**Hiba típus:** %s', errorType),
        color = Config.Discord.EmbedColor.error,
        fields = {
            {
                name = '👤 Érintett Játékos',
                value = playerInfo,
                inline = false
            },
            {
                name = '📝 Hiba Részletek',
                value = string.format('```%s```', errorMessage),
                inline = false
            }
        },
        footer = Config.Discord.Footer,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
        thumbnail = {
            url = Config.Discord.Thumbnails.error
        }
    }

    if additionalData then
        table.insert(embed.fields, {
            name = '🔍 További Információ',
            value = string.format('```json\n%s\n```', json.encode(additionalData, {indent = true})),
            inline = false
        })
    end

    SendWebhook(embed)
end

function DiscordLog.Payment(source, amount, vehicleModel, plate)
    if not Config.Discord.LogPayment then return end

    local player = GetPlayerInfo(source)
    if not player then return end

    local embed = {
        title = '💳 Bérlési Fizetés',
        description = string.format('**%s** fizetett a bérlésért', player.name),
        color = Config.Discord.EmbedColor.payment,
        fields = {
            {
                name = '👤 Játékos',
                value = string.format('%s (%s)', player.name, player.identifier),
                inline = true
            },
            {
                name = '🚙 Jármű',
                value = string.format('%s (%s)', vehicleModel, plate),
                inline = true
            },
            {
                name = '💰 Összeg',
                value = string.format('$%s', amount),
                inline = true
            }
        },
        footer = Config.Discord.Footer,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
    }

    SendWebhook(embed)
end

print('^2[Discord Logger] Module loaded successfully^7')
