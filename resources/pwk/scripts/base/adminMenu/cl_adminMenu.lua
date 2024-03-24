local cooldown = false
local players = {}
local player = nil
local role = nil
local all_items = {}
local all_weapons = {}

local perms = {
    ['teleportation'] = false,
    ['heal'] = false,
}

local function start_cooldown(time)
    cooldown = true
    Citizen.SetTimeout(time, function()
        cooldown = false
    end)
end

local function refresh_players()
    ESX.TriggerServerCallback("pwk_adminMenu:getPlayers", function(p)
        players = p
    end)
end

local function reset_player()
    player = nil
end

local function get_all_items()
    ESX.TriggerServerCallback("pwk_adminMenu:getAllItems", function(i)
        all_items = i
    end)
end

local function get_all_weapons()
    ESX.TriggerServerCallback("pwk_adminMenu:getAllWeapons", function(w)
        all_weapons = w
    end)
end

local function set_all_perms()
    for action,_ in pairs(Config_AdminMenu.Permissions) do
        for _,allowed_group in pairs(Config_AdminMenu.Permissions[action]) do
            if role == allowed_group then
                perms[action] = true
            end
        end
    end
end

local function teleportation(target, position)
    TriggerServerEvent('pwk_adminMenu:teleportation', target, position)
end

local function revive(player)
    TriggerServerEvent('pwk_adminMenu:revive', player)
end

local function heal(player)
    TriggerServerEvent('pwk_adminMenu:heal', player)
end

local function give(player, item, count, isWeapon)
    TriggerServerEvent('pwk_adminMenu:give', player, item, count, isWeapon)
end

local function AdminMenu()
    local main_menu = RageUI.CreateMenu('Andromeda', '')
    main_menu:SetRectangleBanner(173, 86, 255, 100)
    local players_main_menu = RageUI.CreateSubMenu(main_menu, 'Andromeda', '')
    players_main_menu:SetRectangleBanner(173, 86, 255, 100)
    local player_main_menu = RageUI.CreateSubMenu(main_menu, 'Andromeda', '')
    player_main_menu:SetRectangleBanner(173, 86, 255, 100)
    local give_main_menu = RageUI.CreateSubMenu(main_menu, 'Andromeda', '')
    player_main_menu:SetRectangleBanner(173, 86, 255, 100)
    local give_items_main_menu = RageUI.CreateSubMenu(give_main_menu, 'Andromeda', '')
    player_main_menu:SetRectangleBanner(173, 86, 255, 100)
    local give_weapons_main_menu = RageUI.CreateSubMenu(give_main_menu, 'Andromeda', '')
    player_main_menu:SetRectangleBanner(173, 86, 255, 100)

    RageUI.Visible(main_menu, not RageUI.Visible(main_menu))

    while main_menu do
        Citizen.Wait(0)
        
        ------------MAIN MENU-------------
        RageUI.IsVisible(main_menu, true, true, true, function()
            reset_player()
            RageUI.Separator(string.upper(role))

            RageUI.ButtonWithStyle(Config_AdminMenu.Locales['players'], nil, {RightLabel = "👥"}, true, function(h,a,s)
                if s then
                    refresh_players()
                end
            end, players_main_menu)

        end, function()
        end)
        ----------------------------------

        ----------PLAYERS MAIN MENU--------
        RageUI.IsVisible(players_main_menu, true, true, true, function()
            reset_player()
            RageUI.Separator(string.upper(role))

            for _,p in pairs(players) do
                if p.group == 'admin' or p.group == 'modo' or p.group == 'help' then
                    RageUI.ButtonWithStyle('~p~'..p.name..'~s~', nil, {RightLabel = "[~p~"..p.source.."~s~]"}, true, function(h,a,s)
                        if s then
                            player = p
                        end
                    end, player_main_menu)
                else
                    RageUI.ButtonWithStyle(p.name, nil, {RightLabel = "[~p~"..p.source.."~s~]"}, true, function(h,a,s)
                        if s then
                            player = p
                        end
                    end, player_main_menu)
                end
            end

        end, function()
        end)
        ----------------------------------

        -------SINGLE PLAYER MENU--------
        RageUI.IsVisible(player_main_menu, true, true, true, function()

            while not player do
                Citizen.Wait(5)
            end

            RageUI.Separator(string.upper(player.name))

            RageUI.ButtonWithStyle(Config_AdminMenu.Locales['tp'], nil, {RightLabel = Config_AdminMenu.Locales['tp_to']}, perms['teleportation'], function(h,a,s)
                if s then
                    teleportation(0, player)
                end
            end)

            RageUI.ButtonWithStyle(Config_AdminMenu.Locales['tp'], nil, {RightLabel = Config_AdminMenu.Locales['tp_from']}, perms['teleportation'], function(h,a,s)
                if s then
                    teleportation(player, 0)
                end
            end)

            RageUI.ButtonWithStyle(Config_AdminMenu.Locales['revive'], nil, {}, perms['heal'], function(h,a,s)
                if s then
                    revive(player)
                end
            end)

            RageUI.ButtonWithStyle(Config_AdminMenu.Locales['heal'], nil, {}, perms['heal'], function(h,a,s)
                if s then
                    heal(player)
                end
            end)

            RageUI.ButtonWithStyle(Config_AdminMenu.Locales['give'], nil, {}, perms['give'], function(h,a,s)
                if s then
                    get_all_items()
                    get_all_weapons()
                end
            end, give_main_menu)

        end, function()
        end)
        ----------------------------------

        ----------ITEMS LIST MENU--------
        RageUI.IsVisible(give_main_menu, true, true, true, function()

            while not next(all_items) do
                Citizen.Wait(5)
            end

            RageUI.Separator(string.upper(role))

            RageUI.ButtonWithStyle(Config_AdminMenu.Locales['items'], nil, {RightLabel = nil}, true, function(h, a, s)
            end, give_items_main_menu)

            RageUI.ButtonWithStyle(Config_AdminMenu.Locales['weapons'], nil, {RightLabel = nil}, true, function(h, a, s)
            end, give_weapons_main_menu)

        end, function()
        end)

        RageUI.IsVisible(give_items_main_menu, true, true, true, function()
            RageUI.Separator(string.upper(role))
                
            for _,i in pairs(all_items) do
                RageUI.ButtonWithStyle(i.label, nil, {RightLabel = nil}, true, function(h,a,s)
                    if s then
                        local nmb_to_give = KeyboardInput(Config_AdminMenu.Locales['how_much'], "", 10)
                        give(player, i.name, nmb_to_give, false)
                    end
                end)
            end
        end)

        RageUI.IsVisible(give_weapons_main_menu, true, true, true, function()
            RageUI.Separator(string.upper(role))
                
            for _,w in pairs(all_weapons) do
                RageUI.ButtonWithStyle(w.label, nil, {RightLabel = nil}, true, function(h,a,s)
                    if s then
                        --local nmb_to_give = KeyboardInput(Config_AdminMenu.Locales['how_much'], "", 10)
                        give(player, w.name, 1, true)
                    end
                end)
            end
        end)

        ----------------------------------

        if not RageUI.Visible(main_menu) and not RageUI.Visible(players_main_menu) and not RageUI.Visible(player_main_menu) and not RageUI.Visible(give_main_menu) and not RageUI.Visible(give_items_main_menu) and not RageUI.Visible(give_weapons_main_menu) then
            main_menu = RMenu:DeleteType("main_menu", true)
        end
    end
end



RegisterCommand('admin_menu', function()
    ESX.TriggerServerCallback("pwk_adminMenu:getRole", function(r)
        if r == 'admin' or r == 'modo' or r == 'help' then
            role = r
            set_all_perms()
            AdminMenu()
        end
    end)
end, false)

RegisterKeyMapping('admin_menu', Config_AdminMenu.Locales['keymap_adminMenu'], 'keyboard', 'F4')