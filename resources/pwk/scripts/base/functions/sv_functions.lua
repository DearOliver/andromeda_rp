ESX.RegisterServerCallback('pwk_base:getInventory', function(source, cb)
	local player = ESX.GetPlayerFromId(source)
	local inventory = player.inventory
	local i = {}

	i.items = {}

	i.weightCapacity = Player(source).state.playerWeightCapacity
	i.currentWeight = 0

	for _,item in pairs(inventory) do
		if item.count > 0 then
			table.insert(i.items, item)
			i.currentWeight = i.currentWeight + item.count*item.weight
		end
	end

	i.loadout = {}
	
	MySQL.Async.fetchAll('SELECT * FROM weapons', {
	}, function(result)
		if result then
			for _,weapon in pairs(player.loadout) do
				for _,registeredWeapon in pairs(result) do
					if registeredWeapon.name == weapon.name then
						weapon.weight = registeredWeapon.weight
						i.currentWeight = i.currentWeight + weapon.weight
					end
				end
					
				table.insert(i.loadout, weapon)
			end

			i.currentWeight = math.floor(i.currentWeight*100)/100

			cb(i)
		end
	end)
end)

RegisterServerEvent('pwk_base:addItem')
AddEventHandler('pwk_base:addItem', function(player, item, count)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(player.source)



	xPlayer.addInventoryItem(item, count)
end)