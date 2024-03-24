Config = {}

Config.TickTime         = 5000
Config.UpdateClientTime = 30000
Config.Locale = GetConvar('esx:locale', 'fr')

Config.Items = {
	["beer_stag_bottle"] = {
		prop = "prop_beer_pissh",
		status = 0.20,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}},
		remains = {item = 'empty_beer_bottle', count = 1}
	},

	["beer_boar_bottle"] = {
		prop = "prop_beer_pissh",
		status = 0.35,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}},
		remains = {item = 'empty_beer_bottle', count = 1}
	},
}