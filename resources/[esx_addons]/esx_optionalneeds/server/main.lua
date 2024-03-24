CreateThread(function()
	for k,v in pairs(Config.Items) do
		ESX.RegisterUsableItem(k, function(source)
			local xPlayer = ESX.GetPlayerFromId(source)
			if v.remove then
				xPlayer.removeInventoryItem(k,1)
				
				if v.remains then
					xPlayer.addInventoryItem(v.remains.item, v.remains.count)
				end
			end
			TriggerClientEvent("esx_status:add", source, "drunk", v.status)
			TriggerClientEvent('esx_basicneeds:onUse', source, v.type, v.prop, v.anim)
		end)
	end 
end)