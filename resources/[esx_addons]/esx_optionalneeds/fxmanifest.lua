fx_version 'adamant'

game 'gta5'

description 'ESX Optional Needs'
lua54 'yes'
version '1.0'
legacyversion '1.9.1'

shared_script '@es_extended/imports.lua'

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'server/main.lua'
}

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua'
}
