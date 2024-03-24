RegisterServerEvent('pwk_f5menu:useItem')
AddEventHandler('pwk_f5menu:useItem', function(item)
	local src = source
	ESX.UseItem(src, item)
end)