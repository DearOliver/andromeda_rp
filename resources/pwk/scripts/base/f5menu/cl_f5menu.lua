local inventory = {}
local weapon_index = 1
local item_index = 1
local cooldown = false

CreateThread(function()
    LocalPlayer.state:set('playerWeightCapacity', Config_functions.PlayerWeightCapacity.Base, true)
end)

local function start_cooldown(time)
    cooldown = true
    Citizen.SetTimeout(time, function()
        cooldown = false
    end)
end

local function refresh_inventory()
    ESX.TriggerServerCallback("pwk_base:getInventory", function(i)
        inventory = i
    end)
end

local function F5Menu()
    local main_menu = RageUI.CreateMenu('Andromeda', 'Menu F5')
    main_menu:SetRectangleBanner(84, 40, 127, 100)
    local inventory_main_menu = RageUI.CreateSubMenu(main_menu, 'Andromeda', 'Menu F5')
    inventory_main_menu:SetRectangleBanner(84, 40, 127, 100)

    RageUI.Visible(main_menu, not RageUI.Visible(main_menu))

    while main_menu do
        Citizen.Wait(0)
        
        ------------MAIN MENU-------------
        RageUI.IsVisible(main_menu, true, true, true, function()
            RageUI.ButtonWithStyle(Config_f5menu.Locales['inventory'], nil, {RightLabel = "🎒"}, true, function(h,a,s)
                if s then
                    refresh_inventory()
                end
            end, inventory_main_menu)

        end, function()
        end)
        ----------------------------------

        ------------INV MAIN MENU----------
        RageUI.IsVisible(inventory_main_menu, true, true, true, function()
            while inventory == nil or inventory.loadout == nil or inventory.items == nil do
                Citizen.Wait(5)
            end

            RageUI.ProgressBar(inventory.currentWeight, inventory.weightCapacity, {ProgressBackgroundColor = {R = 255, G = 255, B = 255, A = 255}, ProgressColor = {R = 84, G = 40, B = 127, A = 255}}, inventory.currentWeight..'kg', inventory.weightCapacity..'kg')

            RageUI.Separator(Config_f5menu.Locales['weapons'], 84, 40, 127, 60)

                if not next(inventory.loadout) then
                    RageUI.Separator('')
                    RageUI.Separator(Config_f5menu.Locales['empty'])
                    RageUI.Separator('')
                else
                    for _,weapon in pairs(inventory.loadout) do
                        RageUI.List(weapon.label, {"~p~Donner~s~"}, weapon_index, weapon.weight.."kg", {}, not cooldown, {
                            onListChange = function(list) weapon_index = list end,
                            onSelected = function(list)
                                --Donner
                                if list == 1 then
                                    print("GIVE")
                                end
                            end
                        })


                    end
                end

            RageUI.Separator(Config_f5menu.Locales['items'], 84, 40, 127, 60)

                if not next(inventory.items) then
                    RageUI.Separator('')
                    RageUI.Separator(Config_f5menu.Locales['empty'])
                    RageUI.Separator('')
                else
                    for _,item in pairs(inventory.items) do
                        RageUI.List(item.label, {"~p~Utiliser~s~", "~p~Donner~s~"}, item_index, "x"..item.count.. " - ".. item.weight*item.count.."kg", {}, not cooldown, {
                            onListChange = function(list) item_index = list end,
                            onSelected = function(list)
                                --Utiliser
                                if list == 1 then
                                    start_cooldown(3*1000)
                                    TriggerServerEvent('pwk_f5menu:useItem', item.name)
                                    refresh_inventory()
                                --Donner
                                elseif list == 2 then
                                    print("GIVE")
                                end
                            end
                        })
                    end
                end

        end, function()
        end)
        ----------------------------------

        if not RageUI.Visible(main_menu) and not RageUI.Visible(inventory_main_menu) then
            main_menu = RMenu:DeleteType("main_menu", true)
        end
    end    
end

RegisterCommand('f5_menu', function()
    if not LocalPlayer.state.isDead then
        F5Menu()
    end
end, false)

RegisterKeyMapping('f5_menu', Config_f5menu.Locales['keymap_f5_menu'], 'keyboard', 'F5')