fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Craig'
description 'Vehicle Rental App for mPhone V2'
version '0.5.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'shared/config.lua',
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
    'es_extended',
    'oxmysql',
    'ox_lib',
    'codem-phone'
}
