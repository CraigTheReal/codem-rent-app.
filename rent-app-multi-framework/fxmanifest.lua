fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Craig'
description 'Vehicle Rental App for mPhone V2 - Multi Framework (ESX/QB/QBX)'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/framework.lua',
    'locales/*.lua'
}

client_scripts {
    'client/utils.lua',
    'client/events.lua',
    'client/main.lua',
    'client/phone.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/callbacks.lua',
    'server/events.lua',
    'server/main.lua',
    'server/phone.lua'
}

files {
    'ui/**/*',
    'html/images/**/*'
}

dependencies {
    'oxmysql',
    'ox_lib',
    'codem-phone'
}
