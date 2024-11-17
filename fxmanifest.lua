fx_version "cerulean"
game "gta5"

name "Paradise"
description "A Police Check Vin Script"

lua54 'yes'

client_scripts {
    'scripting/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'scripting/server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
