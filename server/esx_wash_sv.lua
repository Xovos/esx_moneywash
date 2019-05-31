ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_moneywash:withdraw')
AddEventHandler('esx_moneywash:withdraw', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	amount = tonumber(amount)
	local accountMoney = 0
	accountMoney = xPlayer.getAccount('black_money').money
	if amount == nil or amount <= 0 or amount > accountMoney then
		TriggerClientEvent('esx:showNotification', _source, _U('invalid_amount'))
	else
		TriggerClientEvent('esx_moneywash:closeWASH', _source)
		TriggerClientEvent('esx_moneywash:animation', _source)
		Citizen.Wait(Config.WashTime * 60000)
		TriggerClientEvent('esx:showNotification', _source, _U('wash_money') .. amount .. '~s~.')
		xPlayer.removeAccountMoney('black_money', amount)
	    xPlayer.addMoney(amount)
	end
end)
