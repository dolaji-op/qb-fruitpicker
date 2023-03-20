fx_version 'cerulean'
game 'gta5'


description 'ds-fruitpicker'
version '1.0.0'


shared_scripts {
    'language.lua',
    'config.lua',
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}

escrow_ignore {
    'config.lua',
    'language.lua',
    'Items/shared-items.lua'
}

lua54 'yes'
