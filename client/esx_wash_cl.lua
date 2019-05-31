local GUI          			  = {}
local hasAlreadyEnteredMarker = false
local isInWASHMarker 			  = false
local menuIsShowed   		  = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_moneywash:closeWASH')
AddEventHandler('esx_moneywash:closeWASH', function()
	SetNuiFocus(false)
	menuIsShowed = false
	SendNUIMessage({
		hideAll = true
	})
end)

RegisterNetEvent('esx_moneywash:animation')
AddEventHandler('esx_moneywash:animation', function()
	TriggerEvent("mythic_progressbar:client:progress", {
		name = "WashingMoney",
		duration = Config.WashTime * 60000,
		label = "Washing Money In Progress",
		useWhileDead = false,
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = false,
		},
		animation = {
			animDict = "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a",
			anim = "idle_a",
			flags = 63
	},
	prop = {
			model = "prop_cs_tablet",
	}
	}, function(status)
		if not status then
			
		end
	end)
end)

RegisterNUICallback('escape', function(data, cb)
  	TriggerEvent('esx_moneywash:closeWASH')
	cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
	TriggerServerEvent('esx_moneywash:deposit', data.amount)
	cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
	TriggerServerEvent('esx_moneywash:withdraw', data.amount)
	cb('ok')
end)

-- Create Blips
Citizen.CreateThread(function()
	
	for i=1, #Config.Map, 1 do
		
		local blip = AddBlipForCoord(Config.Map[i].x, Config.Map[i].y, Config.Map[i].z)
		SetBlipSprite (blip, Config.Map[i].id)
		SetBlipDisplay(blip, 4)
		SetBlipColour (blip, Config.Map[i].color)
		SetBlipScale  (blip, Config.Map[i].scale)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.Map[i].name)
		EndTextCommandSetBlipName(blip)
	end

end)

-- Render markers
Citizen.CreateThread(function()
	while true do		
		Wait(0)		
		local coords = GetEntityCoords(GetPlayerPed(-1))		
		for i=1, #Config.WASH, 1 do
			if(GetDistanceBetweenCoords(coords, Config.WASH[i].x, Config.WASH[i].y, Config.WASH[i].z, true) < Config.DrawDistance) then
				DrawMarker(Config.MarkerType, Config.WASH[i].x, Config.WASH[i].y, Config.WASH[i].z - Config.ZDiff, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end
		end
	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do		
		Wait(0)		
		local coords = GetEntityCoords(GetPlayerPed(-1))
		isInWASHMarker = false
		for i=1, #Config.WASH, 1 do
			if(GetDistanceBetweenCoords(coords, Config.WASH[i].x, Config.WASH[i].y, Config.WASH[i].z, true) < Config.ZoneSize.x / 2) then
				isInWASHMarker = true
				SetTextComponentFormat('STRING')
				AddTextComponentString(_U('press_e_wash'))
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			end
		end
		if isInWASHMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
		end
		if not isInWASHMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			SetNuiFocus(false)	
				menuIsShowed = false	
				SendNUIMessage({
					hideAll = true
			})
		end
	end
end)

-- Menu interactions
Citizen.CreateThread(function()
	while true do
	  	Wait(0)
	    if menuIsShowed then
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
				SendNUIMessage({
					click = true
				})
			end
	    else
		  	if IsControlJustReleased(0, 26) and isInWASHMarker then
		  		menuIsShowed = true
				ESX.TriggerServerCallback('esx:getPlayerData', function(data)				    
				    SendNUIMessage({
						showMenu = true,
						player   = {
							money = data.money,
							accounts = data.accounts
						}
					})
				end)
				SetNuiFocus(true)
			end
	    end
	end
end)

-- Disable Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPed = PlayerPedId(-1)

		if hasAlreadyEnteredMarker then
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
		else
			Citizen.Wait(500)
		end
	end
end)
