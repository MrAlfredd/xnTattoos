local QBCore = exports['qb-core']:GetCoreObject()

-- Callbacks

QBCore.Functions.CreateCallback('SmallTattoos:GetPlayerTattoos', function(source, cb)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
		MySQL.query('SELECT tattoos FROM players WHERE citizenid = ?', {
			Player.PlayerData.citizenid
		}, function(result)
			if result[1].tattoos then
				cb(json.decode(result[1].tattoos))
			else
				cb()
			end
		end)
	else
		cb()
	end
end)

QBCore.Functions.CreateCallback('SmallTattoos:PurchaseTattoo',
	function(source, cb, tattooList, price, tattoo, tattooName)
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		if Player.Functions.GetMoney('cash') >= price then
			Player.Functions.RemoveMoney('cash', price)
			tattooList[#tattooList + 1] = tattoo
			MySQL.update('UPDATE players SET tattoos = ? WHERE citizenid = ?', {
				json.encode(tattooList),
				Player.PlayerData.citizenid
			})
			TriggerClientEvent('QBCore:Notify', src, 'You bought the ' .. tattooName .. ' tattoo for $' .. price)
			cb(true)
		else
			TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
			cb(false)
		end
	end)


RegisterNetEvent('SmallTattoos:RemoveTattoo', function(tattooList)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	MySQL.update('UPDATE players SET tattoos = ? WHERE citizenid = ?', {
		json.encode(tattooList),
		Player.PlayerData.citizenid
	})
end)
-- Exprimental stuff, not sure if this is a good thing?
if Config.Multicharacter then
	RegisterServerEvent('QBCore:Server:TriggerCallback', function(event, data)
		local src = source
		if event == 'qb-multicharacter:server:getSkin' then
			if data ~= nil then
				MySQL.query('SELECT tattoos FROM players WHERE citizenid = ?', {
					data
				}, function(result)
					if result[1] and result[1].tattoos then
						TriggerClientEvent('qb-tattoos:loadTattos', src, json.decode(result[1].tattoos))
					else
						print("Error: No tattoos found for citizenid " .. data)
					end
				end)
			end
		end
	end)
end
