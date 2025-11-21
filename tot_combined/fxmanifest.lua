fx_version 'cerulean'
game 'gta5'

author 'TOT Combined'
description 'TOT Hub + Mode + Stats (drift/economy/pvp/collectibles) combined base'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
