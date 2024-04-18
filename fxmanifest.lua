author "JericoFX#3512"
fx_version 'cerulean'
game "gta5"
description "Script para manejar postulaciones"

version "0.0.3"

client_script "client/main.lua"

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "shared/server.lua",
    "server/main.lua"
}

shared_scripts { '@ox_lib/init.lua', "shared/shared.lua" }

lua54 'yes'

use_fxv2_oal 'on'

is_cfxv2 'yes'

dependencies {
    '/onesync',
    "ox_lib"
}
