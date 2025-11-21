fx_version 'cerulean'
game 'gta5'

name 'tot_hub'
author 'Murat & ChatGPT'
description 'TOT Hub + Mode selection (Freeroam / PvP / Roleplay)'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}
