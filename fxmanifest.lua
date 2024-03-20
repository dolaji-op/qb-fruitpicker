fx_version 'cerulean'
game 'gta5'


description 'ds-fruitpicker'
version '3.5'


shared_scripts {
    'language.lua',
    'config.lua',
}

client_scripts {
    '@ox_lib/init.lua',
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
