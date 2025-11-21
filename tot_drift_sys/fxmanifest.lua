fx_version 'cerulean'
game 'gta5'

author 'Murat & ChatGPT'
description 'TOT Drift System: Drift HUD + F10 Panel + MySQL + Profil + Ekonomi entegrasyonu'
version '2.0.0'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/style.css',
    'html/app.js'
}

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}
