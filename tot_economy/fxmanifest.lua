fx_version 'cerulean'
game 'gta5'

author 'TOT Economy'
description 'Economy system with MySQL + auto paycheck'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
