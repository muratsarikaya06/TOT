fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'tot_combined'
author 'Murat & TOT'
description 'TOT Combined: Mod seçimi + Drift + Ekonomi + Koleksiyon + XP/Level + PvP + GTA Online tarzı HUB'
version '3.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_script 'config.lua'

client_script 'client.lua'
server_script 'server.lua'

-- opsiyonel ama tavsiye:
-- dependencies {
--     'oxmysql',
--     'baseevents'
-- }
