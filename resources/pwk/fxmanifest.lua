fx_version 'adamant'

game 'gta5'
lua54 'yes'
description 'PWK Base'

version '1.0'

client_scripts {
	'scripts/**/cl_*.lua',

	"lib/RageUI/RMenu.lua",
	"lib/RageUI/menu/RageUI.lua",
	"lib/RageUI/menu/Menu.lua",
	"lib/RageUI/menu/MenuController.lua",
	"lib/RageUI/components/*.lua",
	"lib/RageUI/menu/elements/*.lua",
	"lib/RageUI/menu/items/*.lua",
	"lib/RageUI/menu/panels/*.lua",
	"lib/RageUI/menu/windows/*.lua",
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'scripts/**/sv_*.lua'
}

shared_scripts {
	'@es_extended/imports.lua',
	'scripts/**/cfg_*.lua',
}

dependencies {
	'es_extended'
}