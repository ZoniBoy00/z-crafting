fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'z-crafting'
description 'Premium Crafting System for QBox'
author 'ZoniBoy00'
version '1.0.0'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/index.css',
    'ui/app.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua'
}

exports {
    'usePortableTable'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'oxmysql'
}
