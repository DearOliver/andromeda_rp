ESX.RegisterServerCallback('pwk_adminMenu:getRole', function(source, cb)
	local player = ESX.GetPlayerFromId(source)
	cb(player.group)
end)

ESX.RegisterServerCallback('pwk_adminMenu:getPlayers', function(source, cb)
	local players = {}
	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		table.insert(players, xPlayer)
	end

	cb(players)
end)

ESX.RegisterServerCallback('pwk_adminMenu:getAllItems', function(source, cb)
	MySQL.Async.fetchAll('SELECT * FROM items ORDER BY label ASC', {
	}, function(result)
		if result then
			cb(result)
		end
	end)
end)

ESX.RegisterServerCallback('pwk_adminMenu:getAllWeapons', function(source, cb)
	MySQL.Async.fetchAll('SELECT * FROM weapons ORDER BY label ASC', {
	}, function(result)
		if result then
			cb(result)
		end
	end)
end)

RegisterServerEvent('pwk_adminMenu:teleportation')
AddEventHandler('pwk_adminMenu:teleportation', function(target, position)
	local src = source

	if type(target) == 'number' then
		if target == 0 then
			target = GetPlayerPed(src)
		end
	else
		if target.x == nil then
			target = GetPlayerPed(target.source)
		end
	end

	if type(position) == 'number' then
		if position == 0 then
			position = GetEntityCoords(GetPlayerPed(ESX.GetPlayerFromId(src).source))
		end
	else
		if position.x == nil then
			position = GetEntityCoords(GetPlayerPed(position.source))
		end
	end

	print(target, position.x)

	SetEntityCoords(target, position.x, position.y, position.z)

	local xSelf = ESX.GetPlayerFromId(src)
	xSelf.showNotification(Config_AdminMenu.Locales['tp_notif'])
end)

RegisterServerEvent('pwk_adminMenu:heal')
AddEventHandler('pwk_adminMenu:heal', function(player)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(player.source)
	xPlayer.triggerEvent('esx_basicneeds:healPlayer')
	xPlayer.showNotification('Vous avez été soigné')
	local xSelf = ESX.GetPlayerFromId(src)
	xSelf.showNotification(Config_AdminMenu.Locales['heal_notif'])
end)

RegisterServerEvent('pwk_adminMenu:revive')
AddEventHandler('pwk_adminMenu:revive', function(player)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(player.source)
	xPlayer.triggerEvent('pwk_death:revive')
	TriggerClientEvent("esx_status:set", player.source, "drunk", 0)
	local xSelf = ESX.GetPlayerFromId(src)
	xSelf.showNotification(Config_AdminMenu.Locales['revive_notif'])
end)

RegisterServerEvent('pwk_adminMenu:give')
AddEventHandler('pwk_adminMenu:give', function(player, item, count, isWeapon)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(player.source)
	if isWeapon then
		xPlayer.addWeapon(item, count)
	else
		xPlayer.addInventoryItem(item, count)
	end
	local xSelf = ESX.GetPlayerFromId(src)
	xSelf.showNotification(Config_AdminMenu.Locales['give_notif'])
end)