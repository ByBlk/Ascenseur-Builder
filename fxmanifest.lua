fx_version 'cerulean'
game 'gta5'

author 'BLK'
description ''
version '1.0.0'

server_scripts {
    '@mysql-async/lib/MySQL.lua', 
    'server/*.lua'
}

client_scripts {
    'client/*.lua',
    "RageUI/RMenu.lua",
    "RageUI/menu/RageUI.lua",
    "RageUI/menu/Menu.lua",
    "RageUI/menu/MenuController.lua",
    "RageUI/components/*.lua",
    "RageUI/menu/elements/*.lua",
    "RageUI/menu/items/*.lua",
    "RageUI/menu/panels/*.lua",
    "RageUI/menu/windows/*.lua",

}

shared_scripts {
    "shared/*.lua"
}

dependencies {
    'mysql-async',  
    'es_extended'
}

