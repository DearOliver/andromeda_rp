Config = {}
Config.Locale = GetConvar('esx:locale', 'fr')
Config.Visible = true

Config.Items = {
	["bread"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 200,
		remove = true,
		anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
	},
	
	["water_bottle"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}},
		remains = {item = 'empty_plastic_bottle', count = 1}
	}
}