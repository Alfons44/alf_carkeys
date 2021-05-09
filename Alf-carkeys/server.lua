ESX               = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local engine = {}

RegisterServerEvent('Alf-Carkeys:createKey')
AddEventHandler('Alf-Carkeys:createKey', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute("INSERT INTO `vehicle_keys`(`identifier`, `plate`, `state`) VALUES (@identifier,@plate,@state)", { 
        ['@identifier'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@state'] = 'Original'
    })
end)

RegisterServerEvent('Alf-Carkeys:giveKey')
AddEventHandler('Alf-Carkeys:giveKey', function(id, plate, reciever)
    local xPlayer = ESX.GetPlayerFromId(source)
    local reciever = ESX.GetPlayerFromId(reciever)
    MySQL.Async.execute("UPDATE `vehicle_keys` SET `identifier`=@recieverid WHERE identifier = @identifier AND plate = @plate AND id = @id", { 
        ['@recieverid'] = reciever.identifier,
        ['@identifier'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@id'] = id
    })
end)

RegisterServerEvent('Alf-Carkeys:createKeyForOther')
AddEventHandler('Alf-Carkeys:createKeyForOther', function(plate, reciever)
    local xPlayer = ESX.GetPlayerFromId(source)
    local reciever = ESX.GetPlayerFromId(reciever)
    MySQL.Async.execute("INSERT INTO `vehicle_keys` (`identifier`, `plate`, `state`) VALUES (@reciever,@plate,@state)", { 
        ['@reciever'] = reciever.identifier,
        ['@plate'] = plate,
        ['@state'] = 'Original'
    })
end)

RegisterServerEvent('Alf-Carkeys:renameKey')
AddEventHandler('Alf-Carkeys:renameKey', function(id, plate, text)
    local xPlayer = ESX.GetPlayerFromId(source)
    local reciever = ESX.GetPlayerFromId(reciever)
    MySQL.Async.execute("UPDATE `vehicle_keys` SET `label`= @label WHERE identifier = @identifier AND plate = @plate AND id = @id", { 
        ['@label'] = text .." - ",
        ['@identifier'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@id'] = id
    })
end)

RegisterServerEvent('Alf-Carkeys:removeKeyName')
AddEventHandler('Alf-Carkeys:removeKeyName', function(id, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local reciever = ESX.GetPlayerFromId(reciever)
    MySQL.Async.execute("UPDATE `vehicle_keys` SET `label`= NULL WHERE identifier = @identifier AND plate = @plate AND id = @id", { 
        ['@identifier'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@id'] = id
    })
end)


RegisterServerEvent('Alf-Carkeys:changePlate')
AddEventHandler('Alf-Carkeys:changePlate', function(plate, text)

    MySQL.Async.execute("UPDATE owned_vehicles SET plate=@newplate WHERE plate=@plate", { 
        ['@plate'] = plate,
        ['@newplate'] = string.upper(text)
    })

    MySQL.Async.execute("UPDATE vehicle_keys SET plate=@newplate WHERE plate=@plate", { 
        ['@plate'] = plate,
        ['@newplate'] = string.upper(text)
    })

    MySQL.Async.execute("UPDATE trunk_inventory SET plate=@newplate WHERE plate=@plate", { 
        ['@plate'] = plate,
        ['@newplate'] = string.upper(text)
    })

end)

RegisterServerEvent('Alf-Carkeys:changeVehicleModel')
AddEventHandler('Alf-Carkeys:changeVehicleModel', function(plate, vehicleProps)
    MySQL.Async.execute("UPDATE owned_vehicles SET vehicle=@vehicle, plate=@plateNew WHERE plate=@plateOld", { 
        ['@plateOld']   = plate,
        ['@plateNew']   = vehicleProps.plate,
		['@vehicle']    = json.encode(vehicleProps)
        --['@plate'] = plate,
        --['@vehicleProps1'] = json.encode(vehicleProps)
    })
end)

RegisterServerEvent('Alf-Carkeys:copyKey')
AddEventHandler('Alf-Carkeys:copyKey', function(plate, reciever)
    local reciever = ESX.GetPlayerFromId(reciever)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price   = Config.KeyPrice
    
    xPlayer.removeMoney(price)

    MySQL.Async.execute("INSERT INTO `vehicle_keys`(`identifier`, `plate`, `state`) VALUES (@identifier,@plate,@state)", { 
        ['@identifier'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@state'] = 'Kopie'
    })
end)

RegisterServerEvent('Alf-Carkeys:copyTrustedKey')
AddEventHandler('Alf-Carkeys:copyTrustedKey', function(plate, reciever)
    local reciever = ESX.GetPlayerFromId(reciever)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price   = Config.TrustedKeyPrice
    
    xPlayer.removeMoney(price)

    MySQL.Async.execute("INSERT INTO `vehicle_keys`(`identifier`, `plate`, `state`) VALUES (@identifier,@plate,@state)", { 
        ['@identifier'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@state'] = 'Garagenzugriff'
    })
end)

RegisterServerEvent('Alf-Carkeys:deleteKey')
AddEventHandler('Alf-Carkeys:deleteKey', function(plate, id)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute("DELETE FROM `vehicle_keys` WHERE identifier = @identifier AND id = @id AND plate = @plate AND state = 'Kopie' OR identifier = @identifier AND id = @id AND plate = @plate AND state = 'Garagenzugriff'", { 
        ['@identifier'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@id'] = id
    })
end)

RegisterServerEvent('Alf-Carkeys:deleteKeyAll')
AddEventHandler('Alf-Carkeys:deleteKeyAll', function(plate)

    MySQL.Async.execute("DELETE FROM `vehicle_keys` WHERE plate = @plate", { 
        ['@plate'] = plate
    })
end)

RegisterServerEvent('Alf-Carkeys:buyPlate')
AddEventHandler('Alf-Carkeys:buyPlate', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local price   = Config.ChangePlatePrice
    xPlayer.removeMoney(price)
end)

ESX.RegisterServerCallback('Alf-Carkeys:checkIfPlateExist', function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('Alf-Carkeys:checkIfPlayerHasKey', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT plate FROM vehicle_keys WHERE identifier = @identifier AND plate = @plate', {
		['@identifier'] = xPlayer.identifier,
        ['@plate'] = plate
	}, function(result)
		if result[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
	end)
end)

ESX.RegisterServerCallback('Alf-Carkeys:checkIfJobVehicle', function(source, cb, plate, job)
	MySQL.Async.fetchAll('SELECT plate FROM owned_vehicles WHERE owner=@job AND plate=@plate', {
        ['@job'] = job,
        ['@plate'] = plate
	}, function(result)
		if result[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
	end)
end)


ESX.RegisterServerCallback('Alf-Carkeys:checkIfKeyExist', function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT * FROM vehicle_keys WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('Alf-Carkeys:getPlayersKeys', function(source, cb, id, plate, state)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM vehicle_keys WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(keys)
        if keys ~= nil then
            cb(keys)
        else
            cb(nil)
        end
    end)
end)

ESX.RegisterServerCallback('Alf-Carkeys:getPlayersKeysOriginal', function(source, cb, id, plate, state)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM vehicle_keys WHERE identifier = @identifier AND state="Original"', {
        ['@identifier'] = xPlayer.identifier
    }, function(keys)
        if keys ~= nil then
            cb(keys)
        else
            cb(nil)
        end
    end)
end)

ESX.RegisterServerCallback('Alf-Carkeys:getPlayersKeysCopy', function(source, cb, id, plate, state)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM vehicle_keys WHERE identifier = @identifier AND state="Kopie"', {
        ['@identifier'] = xPlayer.identifier
    }, function(keys)
        if keys ~= nil then
            cb(keys)
        else
            cb(nil)
        end
    end)
end)

ESX.RegisterServerCallback('Alf-Carkeys:hasmoney', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price   = Config.KeyPrice

    if xPlayer.getMoney() >= price then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('Alf-Carkeys:hasmoney2', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price   = Config.TrustedKeyPrice

    if xPlayer.getMoney() >= price then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('Alf-Carkeys:hasmoney3', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price   = Config.ChangePlatePrice

    if xPlayer.getMoney() >= price then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('Alf-Carkeys:server:syncVehicle')
AddEventHandler('Alf-Carkeys:server:syncVehicle', function(vehicle, status)
    engine[vehicle] = status

    --print('engine state received - ' .. tostring(vehicle) .. ' - ' .. tostring(tostring(status)))
    
    TriggerClientEvent('Alf-Carkeys:client:syncVehicle', -1, vehicle, status)
end)

AddEventHandler('playerJoining', function(source) 
    
       TriggerClientEvent('Alf-Carkeys:client:initialSync', source, engine)
    
end)
