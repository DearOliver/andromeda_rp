local playersHealing, deadPlayers = {}, {}

local function isDeadState(src, bool)
	if not src or bool == nil then return end

	Player(src).state:set('isDead', bool, true)
end

RegisterNetEvent('pwk_death:revive')
AddEventHandler('pwk_death:revive', function(playerId)
	playerId = tonumber(playerId)
	local xPlayer = source and ESX.GetPlayerFromId(source)

	if xPlayer and xPlayer.job.name == 'ambulance' then
		local xTarget = ESX.GetPlayerFromId(playerId)
		if xTarget then
			if deadPlayers[playerId] then
				if Config_death.ReviveReward > 0 then
					xPlayer.showNotification(Config_death.Locales['revive_complete_award'] .. xTarget.name, Config_death.ReviveReward)
					xPlayer.addMoney(Config_death.ReviveReward, "Revive Reward")
					xTarget.triggerEvent('pwk_death:revive')
					isDeadState(xTarget.source, false)
				else
					xPlayer.showNotification(Config_death.Locales['revive_complete'] .. xTarget.name)
					xTarget.triggerEvent('pwk_death:revive')
					isDeadState(xTarget.source, false)
				end
				local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

				for _, xPlayer in pairs(Ambulance) do
					if xPlayer.job.name == 'ambulance' then
						xPlayer.triggerEvent('pwk_death:PlayerNotDead', playerId)
					end
				end
				deadPlayers[playerId] = nil
			else
				xPlayer.showNotification(Config_death.Locales['player_not_unconscious'])
			end
		else
			xPlayer.showNotification(Config_death.Locales['revive_fail_offline'])
		end
	end
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	local source = source
	deadPlayers[source] = 'dead'
	local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")
	isDeadState(source, true)

	for _, xPlayer in pairs(Ambulance) do
		xPlayer.triggerEvent('pwk_death:PlayerDead', source)
	end
end)

RegisterNetEvent('pwk_death:onPlayerDistress')
AddEventHandler('pwk_death:onPlayerDistress', function()
	local source = source
	local injuredPed = GetPlayerPed(source)
	local injuredCoords = GetEntityCoords(injuredPed)

	if deadPlayers[source] then
		deadPlayers[source] = 'distress'
		print("TODO : distress call to ems")
		--[[local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

		for _, xPlayer in pairs(Ambulance) do
			xPlayer.triggerEvent('pwk_death:PlayerDistressed', source, injuredCoords)
		end]]
	end
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
	local source = source
	if deadPlayers[source] then
		deadPlayers[source] = nil
		isDeadState(source, false)
	end
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	if deadPlayers[playerId] then
		deadPlayers[playerId] = nil
		isDeadState(playerId, false)
	end
end)

ESX.RegisterServerCallback('pwk_death:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config_death.OxInventory and Config_death.RemoveItemsAfterRPDeath then
		exports.ox_inventory:ClearInventory(xPlayer.source)
		return cb()
	end

	if Config_death.RemoveCashAfterRPDeath then
		if xPlayer.getMoney() > 0 then
			xPlayer.removeMoney(xPlayer.getMoney(), "Death")
		end

		if xPlayer.getAccount('black_money').money > 0 then
			xPlayer.setAccountMoney('black_money', 0, "Death")
		end
	end

	if Config_death.RemoveItemsAfterRPDeath then
		for i = 1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	if Config_death.OxInventory then return cb() end

	local playerLoadout = {}
	if Config_death.RemoveWeaponsAfterRPDeath then
		for i = 1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	else -- save weapons & restore em' since spawnmanager removes them
		for i = 1, #xPlayer.loadout, 1 do
			table.insert(playerLoadout, xPlayer.loadout[i])
		end

		-- give back wepaons after a couple of seconds
		CreateThread(function()
			Wait(5000)
			for i = 1, #playerLoadout, 1 do
				if playerLoadout[i].label ~= nil then
					xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
				end
			end
		end)
	end

	cb()
end)

if Config_death.EarlyRespawnFine then
	ESX.RegisterServerCallback('pwk_death:checkBalance', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local bankBalance = xPlayer.getAccount('bank').money

		cb(bankBalance >= Config_death.EarlyRespawnFineAmount)
	end)

	RegisterNetEvent('pwk_death:payFine')
	AddEventHandler('pwk_death:payFine', function()
		local xPlayer = ESX.GetPlayerFromId(source)
		local fineAmount = Config_death.EarlyRespawnFineAmount

		xPlayer.showNotification(Config_death.Locales['respawn_bleedout_fine_msg'] .. ESX.Math.GroupDigits(fineAmount))
		xPlayer.removeAccountMoney('bank', fineAmount, "Respawn Fine")
	end)
end

ESX.RegisterServerCallback('pwk_death:getDeadPlayers', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == "ambulance" then
		cb(deadPlayers)
	end
end)

ESX.RegisterServerCallback('pwk_death:getDeathStatus', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.scalar('SELECT is_dead FROM users WHERE identifier = ?', { xPlayer.identifier }, function(isDead)
		cb(isDead)
	end)
end)

RegisterNetEvent('pwk_death:setDeathStatus')
AddEventHandler('pwk_death:setDeathStatus', function(isDead)
	local xPlayer = ESX.GetPlayerFromId(source)

	if type(isDead) == 'boolean' then
		MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', { isDead, xPlayer.identifier })
		isDeadState(source, isDead)
	end

end)
