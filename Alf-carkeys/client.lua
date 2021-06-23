-- ESX
ESX  = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

GetVehicleProperties = function(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

        vehicleProps["tyres"] = {}
        vehicleProps["windows"] = {}
        vehicleProps["doors"] = {}

        for id = 1, 7 do
            local tyreId = IsVehicleTyreBurst(vehicle, id, false)
        
            if tyreId then
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = tyreId
        
                if tyreId == false then
                    tyreId = IsVehicleTyreBurst(vehicle, id, true)
                    vehicleProps["tyres"][ #vehicleProps["tyres"]] = tyreId
                end
            else
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = false
            end
        end

        for id = 1, 13 do
            local windowId = IsVehicleWindowIntact(vehicle, id)

            if windowId ~= nil then
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = windowId
            else
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = true
            end
        end
        
        for id = 0, 5 do
            local doorId = IsVehicleDoorDamaged(vehicle, id)
        
            if doorId then
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = doorId
            else
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = false
            end
        end

        vehicleProps["engineHealth"] = GetVehicleEngineHealth(vehicle)
        vehicleProps["bodyHealth"] = GetVehicleBodyHealth(vehicle)
        vehicleProps["fuelLevel"] = GetVehicleFuelLevel(vehicle)

        vehicleProps["plate"] = GetVehicleNumberPlateText(vehicle)

        return vehicleProps
    end
end

local engine                  = {}
local HasAlreadyEnteredMarker = false
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil

local window1 = true
local window2 = true
local window3 = true
local window4 = true


RegisterNetEvent('Alf-Carkeys:OpenKeysMenu')
AddEventHandler('Alf-Carkeys:OpenKeysMenu', function()
    OpenKeysMenu()
end)

RegisterNetEvent('Alf-Carkeys:OpenCopyKeysMenu')
AddEventHandler('Alf-Carkeys:OpenCopyKeysMenu', function()
    OpenCopyKeysMenu()
end)

function OpenKeysMenu()
    ESX.UI.Menu.CloseAll()
    local playerId = PlayerId()
    ESX.TriggerServerCallback('Alf-Carkeys:getPlayersKeys', function(keys)
        local elements = {}

        for k,key in ipairs(keys) do
            if key.label == nil then
                table.insert(elements, {
                    label     = key.plate.." - "..key.state,
                    plate     = key.plate,
                    state     = key.state,
                    id        = key.id
                })
            else
                table.insert(elements, {
                    label     = key.label.. " " ..key.plate.." - "..key.state,
                    plate     = key.plate,
                    state     = key.state,
                    id        = key.id
                })
            end
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarKeys', {
            title    = 'Schlüsselsytem - Fahrzeugschlüssel',
            align    = 'top-left',
            elements = elements
        }, function(data, menu)
            menu.close()

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarKeyOptions', {
            title    = 'Fahrzeugschlüssel - ' ..data.current.label,
            align    = 'top-left',
            elements = {{label = 'Geben', value = 'giveKey'}, {label = 'Umbenennen', value = 'renameKey'}, {label = 'Name entfernen', value = 'removeKeyName'}, {label = 'Löschen', value = 'deleteKey'}}
            }, function(data2, menu2)
                menu2.close()
                    if data2.current.value == 'renameKey' then
                        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'menu1',{
                            title = ('Neuer Name (Maximal ' ..Config.RenameKeyLenght.. ' Buchstaben)')
                        },function(data3, menu)

                                local text = data3.value
                                local wordcount = 0
                                for word in ipairs(text) do
                                    wordcount = string.format("%d", word:len())
                                end

                                if text == nil then
                                    ESX.ShowNotification(_U('invalidEntry'))
                                elseif Config.RenameKeyLenght < wordcount then
                                    ESX.ShowNotification(_U('entryTooLong'))
                                else
                                    menu.close()
                                    TriggerServerEvent('Alf-Carkeys:renameKey', data.current.id, data.current.plate, text)
                                    ESX.ShowNotification(_U('renamedKey', text) )
                                end
                            end,
                            function(data, menu)
                                menu.close()
                            end)
                    elseif data2.current.value == 'removeKeyName' then
                        menu.close()
                        TriggerServerEvent('Alf-Carkeys:removeKeyName', data.current.id, data.current.plate)
                        ESX.ShowNotification(_U('removedKeyLabel'))
                    elseif data2.current.value == 'giveKey' then
                        local reciever, distance = ESX.Game.GetClosestPlayer()
                        if reciever ~= -1 and distance <= 3.0 then
                            TriggerServerEvent('Alf-Carkeys:giveKey', data.current.id, data.current.plate, GetPlayerServerId(reciever))
                            ESX.ShowNotification(_U('gaveKey', data.current.plate))
                        else
                            ESX.ShowNotification(_U('noPlayerNearYou'))
                        end
                    elseif data2.current.value == 'deleteKey' then
                        ESX.TriggerServerCallback('Alf-Carkeys:getPlayersKeys', function(keys)
                            for k,key in ipairs(keys) do
                                if data.current.id and data.current.state == "Original" then 
                                    ESX.ShowNotification(_U('CantDeleteOriginal'))
                                elseif key.state == "Kopie" or key.state == "Garagenzugriff" then
                                    TriggerServerEvent('Alf-Carkeys:deleteKey', data.current.plate, data.current.id)
                                    ESX.ShowNotification(_U('DeleteKey', data.current.plate)) 
                                end
                            end
                        end)
                    end
            end, function(data2, menu2)
                menu2.close()
            end)

        end, function(data, menu)
            menu.close()
        end)

    end)
end

function OpenCopyKeysMenu()

    ESX.UI.Menu.CloseAll()
    local playerId = PlayerId()

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarKeyMenu', {
            title    = 'Schlüsselsytem - Schlüsseldienst',
            align    = 'top-left',
            elements = {
                {label = ('Schlüssel kopieren'), value = 'copykey'},
            }
        }, function(data, menu)
            menu.close()

            if data.current.value == 'copykey' then

                ESX.TriggerServerCallback('Alf-Carkeys:getPlayersKeysOriginal', function(keys)
                    local elements = {}
            
                    for k,key in ipairs(keys) do
                        table.insert(elements, {
                            label     = key.plate.." - "..key.state,
                            plate     = key.plate
                        })
                    end
            
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarCopyKeys', {
                        title    = 'Schlüsselsytem - Schlüsseldienst',
                        align    = 'top-left',
                        elements = elements
                    }, function(data, menu)
                        menu.close()
            
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarKeyCopy', {
                        title    = 'Fahrzeugschlüssel - ' ..data.current.label,
                        align    = 'top-left',
                        elements = {{label = 'Kopieren - <span style="color: green;">$'..Config.KeyPrice..'</span>', value = 'copyKey'}}
                        }, function(data2, menu2)
                            menu2.close()
                                if data2.current.value == 'copyKey' then
                                    ESX.TriggerServerCallback('Alf-Carkeys:hasmoney', function(enoughmoney)
                                        if enoughmoney then
                                            TriggerServerEvent('Alf-Carkeys:copyKey', data.current.plate, GetPlayerServerId(PlayerId()))
                                            ESX.ShowNotification(_U('CopiedKey', data.current.plate))
                                        else
                                            ESX.ShowNotification(_U('notEnoughMoney'))
                                        end           
                                    end)
                                end
                        end, function(data2, menu2)
                            menu2.close()
                        end)
            
                    end, function(data, menu)
                        menu.close()
                    end)
            
                end)

            elseif data.current.value == 'trustedkey' then

                ESX.TriggerServerCallback('Alf-Carkeys:getPlayersKeysOriginal', function(keys)
                    local elements = {}
            
                    for k,key in ipairs(keys) do
                        table.insert(elements, {
                            label     = key.plate.." - "..key.state,
                            plate     = key.plate
                        })
                    end
            
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'trustedkeymenu', {
                        title    = 'Schlüsselsytem - Schlüsseldienst',
                        align    = 'top-left',
                        elements = elements
                    }, function(data, menu)
                        menu.close()
            
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'trustedkeymenu', {
                        title    = 'Fahrzeugschlüssel - ' ..data.current.label,
                        align    = 'top-left',
                        elements = {{label = 'Kopieren - <span style="color: green;">$'..Config.TrustedKeyPrice..'</span>', value = 'trustedkey'}}
                        }, function(data2, menu2)
                            menu2.close()
                                if data2.current.value == 'trustedkey' then
                                    ESX.TriggerServerCallback('Alf-Carkeys:hasmoney2', function(enoughmoney)
                                        if enoughmoney then
                                            TriggerServerEvent('Alf-Carkeys:copyTrustedKey', data.current.plate, GetPlayerServerId(PlayerId()))
                                            ESX.ShowNotification(_U('CopiedKey', data.current.plate))
                                        else
                                            ESX.ShowNotification(_U('notEnoughMoney'))
                                        end           
                                    end)
                                end
                        end, function(data2, menu2)
                            menu2.close()
                        end)
            
                    end, function(data, menu)
                        menu.close()
                    end)
                end)  
            end
        end, function(data, menu)
            menu.close()
       end)
end

function OpenTrustedCopyKeysMenu()

    ESX.UI.Menu.CloseAll()
    local playerId = PlayerId()

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarKeyMenu', {
            title    = 'Schlüsselsytem - Schlüsseldienst',
            align    = 'top-left',
            elements = {
                {label = ('Schlüssel kopieren'), value = 'copykey'},
                {label = ('Schlüssel Garagenzugriff'), value = 'trustedkey'}
            }
        }, function(data, menu)
            menu.close()

            if data.current.value == 'copykey' then

                ESX.TriggerServerCallback('Alf-Carkeys:getPlayersKeysOriginal', function(keys)
                    local elements = {}
            
                    for k,key in ipairs(keys) do
                        table.insert(elements, {
                            label     = key.plate.." - "..key.state,
                            plate     = key.plate
                        })
                    end
            
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarCopyKeys', {
                        title    = 'Schlüsselsytem - Schlüsseldienst',
                        align    = 'top-left',
                        elements = elements
                    }, function(data, menu)
                        menu.close()
            
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarKeyCopy', {
                        title    = 'Fahrzeugschlüssel - ' ..data.current.label,
                        align    = 'top-left',
                        elements = {{label = 'Kopieren - <span style="color: green;">$'..Config.KeyPrice..'</span>', value = 'copyKey'}}
                        }, function(data2, menu2)
                            menu2.close()
                                if data2.current.value == 'copyKey' then
                                    ESX.TriggerServerCallback('Alf-Carkeys:hasmoney', function(enoughmoney)
                                        if enoughmoney then
                                            TriggerServerEvent('Alf-Carkeys:copyKey', data.current.plate, GetPlayerServerId(PlayerId()))
                                            ESX.ShowNotification(_U('CopiedKey', data.current.plate))
                                        else
                                            ESX.ShowNotification(_U('notEnoughMoney'))
                                        end           
                                    end)
                                end
                        end, function(data2, menu2)
                            menu2.close()
                        end)
            
                    end, function(data, menu)
                        menu.close()
                    end)
            
                end)

            elseif data.current.value == 'trustedkey' then

                ESX.TriggerServerCallback('Alf-Carkeys:getPlayersKeysOriginal', function(keys)
                    local elements = {}
            
                    for k,key in ipairs(keys) do
                        table.insert(elements, {
                            label     = key.plate.." - "..key.state,
                            plate     = key.plate
                        })
                    end
            
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'trustedkeymenu', {
                        title    = 'Schlüsselsytem - Schlüsseldienst',
                        align    = 'top-left',
                        elements = elements
                    }, function(data, menu)
                        menu.close()
            
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'trustedkeymenu', {
                        title    = 'Fahrzeugschlüssel - ' ..data.current.label,
                        align    = 'top-left',
                        elements = {{label = 'Kopieren - <span style="color: green;">$'..Config.TrustedKeyPrice..'</span>', value = 'trustedkey'}}
                        }, function(data2, menu2)
                            menu2.close()
                                if data2.current.value == 'trustedkey' then
                                    ESX.TriggerServerCallback('Alf-Carkeys:hasmoney2', function(enoughmoney)
                                        if enoughmoney then
                                            TriggerServerEvent('Alf-Carkeys:copyTrustedKey', data.current.plate, GetPlayerServerId(PlayerId()))
                                            ESX.ShowNotification(_U('CopiedKey', data.current.plate))
                                        else
                                            ESX.ShowNotification(_U('notEnoughMoney'))
                                        end           
                                    end)
                                end
                        end, function(data2, menu2)
                            menu2.close()
                        end)
            
                    end, function(data, menu)
                        menu.close()
                    end)
                end)  
            end
        end, function(data, menu)
            menu.close()
       end)
end

function OpenChangePlateMenu()
    ESX.UI.Menu.CloseAll()

    local playerId = PlayerId()
    ESX.TriggerServerCallback('Alf-Carkeys:getPlayersKeysOriginal', function(keys)

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ChangePlateMenuOptions', {
            title    = 'Zulassungsstelle',
            align    = 'top-left',
            elements = {{label = 'Kennzeichen ändern - <span style="color: green;">$'..Config.ChangePlatePrice..'</span>', value = 'ChangePlate'}}
            }, function(data2, menu2)
                menu2.close()
                    if data2.current.value == 'ChangePlate' then
                        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 8)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0);
                            Wait(0);
                        end
                        if (GetOnscreenKeyboardResult()) then
                            local text = GetOnscreenKeyboardResult()

                            ESX.TriggerServerCallback('Alf-Carkeys:checkIfPlateExist', function(exists)
                                if exists then
                                    local text = GetOnscreenKeyboardResult()
                                    ESX.ShowNotification(_U('PlateExists', string.upper(text)))
                                else
                                    ESX.TriggerServerCallback('Alf-Carkeys:hasmoney3', function(enoughmoney)
                                        if enoughmoney then
                                            local text = GetOnscreenKeyboardResult()
                                            if text:len() < 8 then 
                                            	--print(text)
                                                local player = GetPlayerPed(-1)
                                                local OldVehicleplate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
                                                
                                                TriggerEvent('persistent-vehicles/update-vehicle', GetVehiclePedIsIn(GetPlayerPed(-1), false))
                                                --TriggerEvent('persistent-vehicles/forget-vehicle', getVehicleByPlate(OldVehicleplate))

                                                
                                                SetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false), text)
                                                
                                                local NewVehicleplate = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
                                                TriggerServerEvent('Alf-Carkeys:changePlate', OldVehicleplate, NewVehicleplate)
                                                TriggerServerEvent('Alf-Carkeys:buyPlate')


                                                

                                                Citizen.Wait(30)
                                                --local veh = getVehicleByPlate(text)
                                                Citizen.Wait(100)


                                                local vehicleProps = ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(GetPlayerPed(-1), false))
                                                TriggerServerEvent('Alf-Carkeys:changeVehicleModel', OldVehicleplate, vehicleProps)
                                                
                                                --local vehicleProps = GetVehicleProperties(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)

                                                --TriggerEvent('persistent-vehicles/register-vehicle', GetVehiclePedIsIn(GetPlayerPed(-1), false))
                                                ESX.ShowNotification(_U('PlateChanged', string.upper(text)))
                                            else
                                                ESX.ShowNotification(_U('NewPlateTooLong'))
                                            end
                                        else
                                            ESX.ShowNotification(_U('notEnoughMoney'))
                                        end
                                    end)
                                end
                            end, string.upper(text))
                        end
                    end
            end, function(data2, menu2)
                menu2.close()
            end)
    end)
end

function getVehicleByPlate(platetext)
	for k, v in pairs(ESX.Game.GetVehicles()) do
		if GetVehicleNumberPlateText(v) == platetext then
			return v
		end
	end
	return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if(IsControlJustReleased(1, 75))then
            local plr = GetPlayerPed(-1)
            if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId(plr))) and GetVehicleDoorLockStatus(GetVehiclePedIsTryingToEnter(PlayerPedId(plr))) == 4 then
                ClearPedTasks(plr)
            end
        end

        if(IsControlJustReleased(1, Config.LockButton)) then 
            DoorLock()
        end

        if(IsControlJustReleased(1, Config.MenuButton) and Config.OpenViaButton) then 
            OpenKeysMenu()
        end

    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        
            if vehicle ~= nil and vehicle ~= 0 then

            if (IsControlJustReleased(0, Config.EngineButton) or IsDisabledControlJustReleased(0, Config.EngineButton)) and GetPedInVehicleSeat(vehicle, -1) then
                toggleEngine()
                --print('received toggle')
            end

            
            if GetIsVehicleEngineRunning(GetVehiclePedIsIn(PlayerPedId())) ~= engine[vehicle] then
                --print('current veh  '.. tostring(GetVehiclePedIsIn(PlayerPedId())))
                --print('status ist nicht gleich  soll - ' .. tostring(engine[vehicle]) .. ' - ist - ' .. tostring(GetIsVehicleEngineRunning(GetVehiclePedIsIn(PlayerPedId()))) )
                SetVehicleEngineOn(vehicle, engine[vehicle], true, true)
                --print('test')
            end
        end
    end
end)

function DoorLock()
        local dict = "anim@mp_player_intmenu@key_fob@"
        
    RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(100)
        end

    -- Key : U          
        local plr = GetPlayerPed(-1)
        local plrCoords = GetEntityCoords(plr, true)

    -- Lock from Inside                    
    if(IsPedInAnyVehicle(plr, true))then
        local localVehId = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        local localVehPlate = GetVehicleNumberPlateText(localVehId)
        local xPlayer = ESX.GetPlayerData()

        ESX.TriggerServerCallback('Alf-Carkeys:checkIfJobVehicle', function(CardealVehicle)
            if CardealVehicle then
                local lockStatus = GetVehicleDoorLockStatus(localVehId)
                if lockStatus == 1 then -- unlocked
                    SetVehicleDoorsLocked(localVehId, 2)
                    PlayVehicleDoorCloseSound(localVehId, 1)
    
                    TriggerEvent('esx:showNotification', _U('VehicleLocked'))
                elseif lockStatus == 2 then -- locked
                    SetVehicleDoorsLocked(localVehId, 1)
                    PlayVehicleDoorOpenSound(localVehId, 0)
    
                    TriggerEvent('esx:showNotification', _U('VehicleUnlocked'))
		else 
		    SetVehicleDoorsLocked(localVehId, 2)
                    PlayVehicleDoorCloseSound(localVehId, 1)
                    TriggerEvent('esx:showNotification', _U('VehicleLocked'))			
                end
            else
                ESX.TriggerServerCallback('Alf-Carkeys:checkIfPlayerHasKey', function(haskey)
                    if haskey then
                        local lockStatus = GetVehicleDoorLockStatus(localVehId)
                        if lockStatus == 1 then -- unlocked
                            SetVehicleDoorsLocked(localVehId, 2)
                            PlayVehicleDoorCloseSound(localVehId, 1)
        
                            TriggerEvent('esx:showNotification', _U('VehicleLocked'))
                        elseif lockStatus == 2 then -- locked
                            SetVehicleDoorsLocked(localVehId, 1)
                            PlayVehicleDoorOpenSound(localVehId, 0)
        
                            TriggerEvent('esx:showNotification', _U('VehicleUnlocked'))
			else 
			    SetVehicleDoorsLocked(localVehId, 2)
			    PlayVehicleDoorCloseSound(localVehId, 1)
			    TriggerEvent('esx:showNotification', _U('VehicleLocked'))	
                        end
                    else
                        TriggerEvent('esx:showNotification', _U('NoKeyForVehicle')) 
                    end
                end, localVehPlate)
            --else
            --    TriggerServerEvent('Alf-Carkeys:createKey', localVehPlate)
            --    TriggerEvent('esx:showNotification', 'Du hast einen Schlüssel für das Fahrzeug: '..localVehPlate.. ' erhalten')   
            end
        end, localVehPlate, xPlayer.job.name)

    -- Lock from Outside   
    else
        local localVehId = Alf_Carkeys.GetClosestVehicleInRange(plrCoords, Config.LockRange)
        local localVehPlate = GetVehicleNumberPlateText(localVehId)
        local xPlayer = ESX.GetPlayerData()

        ESX.TriggerServerCallback('Alf-Carkeys:checkIfJobVehicle', function(CardealVehicle)
            if CardealVehicle then
                local lockStatus = GetVehicleDoorLockStatus(localVehId)

                if lockStatus == 1 then -- unlocked
                    SetVehicleDoorsLocked(localVehId, 2)
                    PlayVehicleDoorCloseSound(localVehId, 1)
                    TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)

                    TriggerEvent('esx:showNotification', _U('VehicleLocked'))
                elseif lockStatus == 2 then -- locked
                    SetVehicleDoorsLocked(localVehId, 1)
                    PlayVehicleDoorOpenSound(localVehId, 0)
                    TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)

                    TriggerEvent('esx:showNotification', _U('VehicleUnlocked'))
		else 
		    SetVehicleDoorsLocked(localVehId, 2)
                    PlayVehicleDoorCloseSound(localVehId, 1)
                    TriggerEvent('esx:showNotification', _U('VehicleLocked'))	
                end
            else
                ESX.TriggerServerCallback('Alf-Carkeys:checkIfPlayerHasKey', function(haskey)
                    if haskey then
                        local lockStatus = GetVehicleDoorLockStatus(localVehId)
                        if lockStatus == 1 then -- unlocked
                            SetVehicleDoorsLocked(localVehId, 2)
                            PlayVehicleDoorCloseSound(localVehId, 1)
                            TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
        
                            TriggerEvent('esx:showNotification', _U('VehicleLocked'))
                        elseif lockStatus == 2 then -- locked
                            SetVehicleDoorsLocked(localVehId, 1)
                            PlayVehicleDoorOpenSound(localVehId, 0)
                            TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
        
                            TriggerEvent('esx:showNotification', _U('VehicleUnlocked'))
			else 
			    SetVehicleDoorsLocked(localVehId, 2)
			    PlayVehicleDoorCloseSound(localVehId, 1)
			    TriggerEvent('esx:showNotification', _U('VehicleLocked'))	
                        end
                    else
                        TriggerEvent('esx:showNotification', _U('NoKeyForVehicle')) 
                    end
                end, localVehPlate)
            end
        end, localVehPlate, xPlayer.job.name)
    end
end

RegisterNetEvent('Alf-Carkeys:ToggleEngine')
AddEventHandler('Alf-Carkeys:ToggleEngine', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if GetIsVehicleEngineRunning(vehicle) == false then
        SetVehicleEngineOn(vehicle, true, false, true)
        TriggerServerEvent('Alf-Carkeys:server:syncVehicle', NetworkGetNetworkIdFromEntity(vehicle), true)
        engine[vehicle] = true
    else
        SetVehicleEngineOn(vehicle, false, false, true)
        TriggerServerEvent('Alf-Carkeys:server:syncVehicle', NetworkGetNetworkIdFromEntity(vehicle), false)
        engine[vehicle] = false
    end
end)

RegisterNetEvent('Alf-Carkeys:client:syncVehicle')
AddEventHandler('Alf-Carkeys:client:syncVehicle', function(vehicle, status)
  
    local veh = NetworkGetEntityFromNetworkId(vehicle)
    --print(GetVehicleNumberPlateText(veh) .. " " .. tostring(status))
	engine[veh] = status

    --print('sync von veh bekommen - ' .. tostring(veh) .. ' - ' .. tostring(status))


    --print('local ist - ' .. tostring(engine[vehicle]))
end)

RegisterNetEvent('Alf-Carkeys:client:initialSync')
AddEventHandler('Alf-Carkeys:client:initialSync', function(engineTB, status)

    for k,v in pairs(engineTB) do
        local myID = NetworkGetEntityFromNetworkId(engineTB[k])
        engine[myID] = v
    end
  
end)

function toggleEngine()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local localVehPlate = GetVehicleNumberPlateText(vehicle)
    local player = PlayerPedId()
    local xPlayer = ESX.GetPlayerData()

    ESX.TriggerServerCallback('Alf-Carkeys:checkIfJobVehicle', function(CardealVehicle)
        if CardealVehicle then
            if vehicle ~= nil and vehicle ~= 0 and getPedSeat(player, vehicle) == -1 then
                if GetIsVehicleEngineRunning(vehicle) == false then
                    SetVehicleEngineOn(vehicle, true, false, true)
                    TriggerServerEvent('Alf-Carkeys:server:syncVehicle', NetworkGetNetworkIdFromEntity(vehicle), true)
                    engine[vehicle] = true
                else
                    SetVehicleEngineOn(vehicle, false, false, true)
                    TriggerServerEvent('Alf-Carkeys:server:syncVehicle', NetworkGetNetworkIdFromEntity(vehicle), false)
                    engine[vehicle] = false
                end
            end
        else
            ESX.TriggerServerCallback('Alf-Carkeys:checkIfPlayerHasKey', function(haskey)
                if haskey then
                    if vehicle ~= nil and vehicle ~= 0 and getPedSeat(player, vehicle) == -1 then
                        if GetIsVehicleEngineRunning(vehicle) == false then
                            SetVehicleEngineOn(vehicle, true, false, true)
                            TriggerServerEvent('Alf-Carkeys:server:syncVehicle', NetworkGetNetworkIdFromEntity(vehicle), true)
                            engine[vehicle] = true
                        else
                            SetVehicleEngineOn(vehicle, false, false, true)
                            TriggerServerEvent('Alf-Carkeys:server:syncVehicle', NetworkGetNetworkIdFromEntity(vehicle), false)
                            engine[vehicle] = false
                        end
                    end
                else
                    --print("."..localVehPlate..".")
                    TriggerEvent('esx:showNotification', _U('NoKeyForVehicle')) 
                end
            end, localVehPlate)
        end
    end, localVehPlate, xPlayer.job.name)
end

AddEventHandler('Alf-Carkeys:hasEnteredMarker', function (zone)
    if zone == 'CopyKeyStore' then
        CurrentAction     = 'copykeystore'
        CurrentActionMsg = ('Drück ~INPUT_CONTEXT~ um das Menü zu öffnen')
    elseif Config.ChangePlate and zone == 'ChangePlate' then
        CurrentAction     = 'changeplate'
        CurrentActionMsg = ('Drück ~INPUT_CONTEXT~ um das Menü zu öffnen')
    end
  end)
  
AddEventHandler('Alf-Carkeys:hasExitedMarker', function (zone)
    CurrentAction = nil
    ESX.UI.Menu.CloseAll()
end)

  Citizen.CreateThread(function ()
    while true do
      Wait(1)
  
      local coords = GetEntityCoords(GetPlayerPed(-1))
  
      for k,v in pairs(Config.Zones) do
        if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
            if Config.Zones == "CopyKeyStore" then
                DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
            elseif Config.Zone == "ChangePlate" and Config.ChangePlate then
                DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
            end
        end
      end
    end
  end)
  

-- Enter / Exit marker events
Citizen.CreateThread(function ()
    while true do
      Wait(20)
  
      local coords      = GetEntityCoords(GetPlayerPed(-1))
      local isInMarker  = false
      local currentZone = nil
  
      for k,v in pairs(Config.Zones) do
        if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
          isInMarker  = true
          currentZone = k
        end
      end
  
      if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
        HasAlreadyEnteredMarker = true
        LastZone                = currentZone
        TriggerEvent('Alf-Carkeys:hasEnteredMarker', currentZone)
      end
  
      if not isInMarker and HasAlreadyEnteredMarker then
        HasAlreadyEnteredMarker = false
        TriggerEvent('Alf-Carkeys:hasExitedMarker', LastZone)
      end
    end
  end)


Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(10)
        if IsControlJustReleased(0, Config.VehicleMenu) then    
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local player = PlayerPedId()
            if IsPedInAnyVehicle(player, false) and not IsPedInAnyBoat(PlayerPedId()) then
                if getPedSeat(player, vehicle) == -1 then
                    VehicleDriverControls()
                else
                    VehiclePassengerControls()
                end
            elseif IsPedInAnyBoat(PlayerPedId()) and getPedSeat(player, vehicle) == -1 then
                BoatControls()
            end
        end
    end       
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(1)
        

        if CurrentAction == 'copykeystore' then
        	local playerPed = GetPlayerPed(-1)
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustPressed(0, 38) then
                if Config.TrustedKeys then
                    OpenTrustedCopyKeysMenu()
                else
                    OpenCopyKeysMenu()
                end
            end
        elseif CurrentAction == 'changeplate' then
        	local playerPed = GetPlayerPed(-1)
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustPressed(0, 38) then
                OpenChangePlateMenu()
            end
        end

    end       
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Zones) do
        local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
            
        SetBlipSprite (blip, v.Blip)
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, v.BlipScale)
        SetBlipColour (blip, v.BlipColor)
        SetBlipAsShortRange(blip, true)
            
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.Name)
        EndTextCommandSetBlipName(blip)
    end
end)


Alf_Carkeys                           = {}
Alf_Carkeys.GetClosestVehicleInRange = function(coords, radius)
	local vehicles        = ESX.Game.GetVehicles()
	local radius = radius
	local closestVehicle  = -1
	local coords          = coords

	if coords == nil then
		local playerPed = PlayerPedId()
		coords          = GetEntityCoords(playerPed)
	end

	if radius == nil then
		radius          = 5.0
	end

	for i=1, #vehicles, 1 do
        if GetEntityModel(vehicles[i]) ~= GetHashKey("lightbarTwoSticks") and GetEntityModel(vehicles[i]) ~= GetHashKey("longLightbar") and GetEntityModel(vehicles[i]) ~= GetHashKey("longLightbarRed") and GetEntityModel(vehicles[i]) ~= GetHashKey("fbiold")then
    		local vehicleCoords = GetEntityCoords(vehicles[i])
    		local distance      = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

    		if radius == -1 or radius > distance then
    			closestVehicle  = vehicles[i]
    			radius = distance
    		end
        end
	end

	return closestVehicle, radius
end

function getPedSeat(p, v)
	local seats = GetVehicleModelNumberOfSeats(GetEntityModel(v))
	for i = -1, seats do
		local t = GetPedInVehicleSeat(v, i)
		if (t == p) then return i end
	end
	return -2
end

function VehicleDriverControls()
    ESX.UI.Menu.CloseAll()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local player = PlayerPedId()
    local playerId = PlayerId()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'VehicleControls', {
        title    = 'Schlüsselsytem - Fahrzeug',
        align    = 'top-left',
        elements = {
            {label = ('Motor'), value = 'engine'},
            {label = ('Auf / Abschließen'), value = 'doorlock'},
            {label = ('Tür Öffnen / Schließen'), value = 'door'},
            {label = ('Fenster Öffnen / Schließen'), value = 'window'},
            {label = ('Motorhaube Öffnen / Schließen'), value = 'hood'},
            {label = ('Kofferraum Öffnen / Schließen'), value = 'trunk'},
        }
    }, function(data, menu)

        if data.current.value == 'engine' then
            toggleEngine()
        elseif data.current.value == 'doorlock' then
            DoorLock()
        elseif data.current.value == 'hood' then
            if getPedSeat(player, vehicle) == -1 then
                if GetVehicleDoorAngleRatio(vehicle, 4) > 0.0 then
                    SetVehicleDoorShut(vehicle, 4, false)
                else
                    SetVehicleDoorOpen(vehicle, 4, false)
                end
            end
        elseif data.current.value == 'trunk' then
            if getPedSeat(player, vehicle) == -1 then
                if GetVehicleDoorAngleRatio(vehicle, 5) > 0.0 then
                    SetVehicleDoorShut(vehicle, 5, false)
                else
                    SetVehicleDoorOpen(vehicle, 5, false)
                end
            end
        elseif data.current.value == 'door' then
            if getPedSeat(player, vehicle) == -1 then
                if GetVehicleDoorAngleRatio(vehicle, 0) > 0.0 then
                    SetVehicleDoorShut(vehicle, 0, false)
                else
                    SetVehicleDoorOpen(vehicle, 0, false)
                end
            elseif getPedSeat(player, vehicle) == 0 then
                if GetVehicleDoorAngleRatio(vehicle, 1) > 0.0 then
                    SetVehicleDoorShut(vehicle, 1, false)
                else
                    SetVehicleDoorOpen(vehicle, 1, false)
                end
            elseif getPedSeat(player, vehicle) == 1 then
                if GetVehicleDoorAngleRatio(vehicle, 2) > 0.0 then
                    SetVehicleDoorShut(vehicle, 2, false)
                else
                    SetVehicleDoorOpen(vehicle, 2, false)
                end
            elseif getPedSeat(player, vehicle) == 2 then
                if GetVehicleDoorAngleRatio(vehicle, 3) > 0.0 then
                    SetVehicleDoorShut(vehicle, 3, false)
                else
                    SetVehicleDoorOpen(vehicle, 3, false)
                end      
            elseif getPedSeat(player, vehicle) == 3 then
                if GetVehicleDoorAngleRatio(vehicle, 6) > 0.0 then
                    SetVehicleDoorShut(vehicle, 6, false)
                else
                    SetVehicleDoorOpen(vehicle, 6, false)
                end
            elseif getPedSeat(player, vehicle) == 4 then
                if GetVehicleDoorAngleRatio(vehicle, 7) > 0.0 then
                    SetVehicleDoorShut(vehicle, 7, false)
                else
                    SetVehicleDoorOpen(vehicle, 7, false)
                end                              
            end
        elseif data.current.value == 'window' then
            if getPedSeat(player, vehicle) == -1 then
                if window1 ~= true then
                    RollUpWindow(vehicle, 0)
                    window1 = true
                else
                    RollDownWindow(vehicle, 0)
                    window1 = false
                end
            elseif getPedSeat(player, vehicle) == 0 then
                if window2 ~= true then
                    RollUpWindow(vehicle, 1)
                    window2 = true
                else
                    RollDownWindow(vehicle, 1)
                    window2 = false
                end
            elseif getPedSeat(player, vehicle) == 1 then
                if window3 ~= true then
                    RollUpWindow(vehicle, 2)
                    window3 = true
                else
                    RollDownWindow(vehicle, 2)
                    window3 = false
                end
            elseif getPedSeat(player, vehicle) == 2 then
                if window4 ~= true then
                    RollUpWindow(vehicle, 3)
                    window4 = true
                else
                    RollDownWindow(vehicle, 3)
                    window4 = false
                end   
            end
        end
	end, function(data, menu)
		menu.close()
	end)
end

function VehiclePassengerControls()
    ESX.UI.Menu.CloseAll()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local player = PlayerPedId()
    local playerId = PlayerId()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'VehicleControls', {
        title    = 'Schlüsselsytem - Fahrzeug',
        align    = 'top-left',
        elements = {
            {label = ('Tür Öffnen / Schließen'), value = 'door'},
            {label = ('Fenster Öffnen / Schließen'), value = 'window'},
        }
    }, function(data, menu)

        if data.current.value == 'door' then
            if getPedSeat(player, vehicle) == -1 then
                if GetVehicleDoorAngleRatio(vehicle, 0) > 0.0 then
                    SetVehicleDoorShut(vehicle, 0, false)
                else
                    SetVehicleDoorOpen(vehicle, 0, false)
                end
            elseif getPedSeat(player, vehicle) == 0 then
                if GetVehicleDoorAngleRatio(vehicle, 1) > 0.0 then
                    SetVehicleDoorShut(vehicle, 1, false)
                else
                    SetVehicleDoorOpen(vehicle, 1, false)
                end
            elseif getPedSeat(player, vehicle) == 1 then
                if GetVehicleDoorAngleRatio(vehicle, 2) > 0.0 then
                    SetVehicleDoorShut(vehicle, 2, false)
                else
                    SetVehicleDoorOpen(vehicle, 2, false)
                end
            elseif getPedSeat(player, vehicle) == 2 then
                if GetVehicleDoorAngleRatio(vehicle, 3) > 0.0 then
                    SetVehicleDoorShut(vehicle, 3, false)
                else
                    SetVehicleDoorOpen(vehicle, 3, false)
                end      
            elseif getPedSeat(player, vehicle) == 3 then
                if GetVehicleDoorAngleRatio(vehicle, 6) > 0.0 then
                    SetVehicleDoorShut(vehicle, 6, false)
                else
                    SetVehicleDoorOpen(vehicle, 6, false)
                end
            elseif getPedSeat(player, vehicle) == 4 then
                if GetVehicleDoorAngleRatio(vehicle, 7) > 0.0 then
                    SetVehicleDoorShut(vehicle, 7, false)
                else
                    SetVehicleDoorOpen(vehicle, 7, false)
                end                              
            end
        elseif data.current.value == 'window' then
            if getPedSeat(player, vehicle) == -1 then
                if window1 ~= true then
                    RollUpWindow(vehicle, 0)
                    window1 = true
                else
                    RollDownWindow(vehicle, 0)
                    window1 = false
                end
            elseif getPedSeat(player, vehicle) == 0 then
                if window2 ~= true then
                    RollUpWindow(vehicle, 1)
                    window2 = true
                else
                    RollDownWindow(vehicle, 1)
                    window2 = false
                end
            elseif getPedSeat(player, vehicle) == 1 then
                if window3 ~= true then
                    RollUpWindow(vehicle, 2)
                    window3 = true
                else
                    RollDownWindow(vehicle, 2)
                    window3 = false
                end
            elseif getPedSeat(player, vehicle) == 2 then
                if window4 ~= true then
                    RollUpWindow(vehicle, 3)
                    window4 = true
                else
                    RollDownWindow(vehicle, 3)
                    window4 = false
                end   
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end


local anchor = false
local boat = nil

function BoatControls()
    ESX.UI.Menu.CloseAll()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local player = PlayerPedId()
    local playerId = PlayerId()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'BoatControls', {
        title    = 'Schlüsselsytem - Boot',
        align    = 'top-left',
        elements = {
            {label = ('Motor'), value = 'engine'},
            {label = ('Auf / Abschließen'), value = 'doorlock'},
            {label = ('Anker'), value = 'anchor'},
        }
    }, function(data, menu)

        if data.current.value == 'engine' then
            toggleEngine()
        elseif data.current.value == 'doorlock' then
            DoorLock()
        elseif data.current.value == 'anchor' then
            local ped = GetPlayerPed(-1)
            local boat  = GetVehiclePedIsIn(ped, true)
            if anchor == false then
                SetBoatAnchor(boat, true)
                ESX.ShowNotification("Boot ~g~geankert")
                anchor = true
            elseif anchor == true then
                SetBoatAnchor(boat, false)
                ESX.ShowNotification("Boot ~r~entankert")
                anchor = false
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

if Config.CreateKeyCommand then 
    RegisterCommand("createkey", function()
        local localVehId = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        local localVehPlate = GetVehicleNumberPlateText(localVehId)
        ESX.TriggerServerCallback('Alf-Carkeys:checkIfKeyExist', function(exists)
            if not exists then
                TriggerServerEvent('Alf-Carkeys:createKey', localVehPlate)
                TriggerEvent('esx:showNotification', _U('gotKey', localVehPlate)) 
            end
        end, localVehPlate)
    end, false)
end
