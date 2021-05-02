# Alf_carkeys || ESX Car System with Copy Key function!

## Features
```
» Toggle Engine
» Engine Sync
» Lock the Vehicle
» Open the Door, Trunk, Hood
» Open the Window
» Copy Keys
» Give Keys to other Users via. Menu
» Change your Plate
```

## Requirements
```
» es_extended
» mysql-async
```

## Installation
1. Import the SQL into your Database
2. Configure the config like you want
3. Add the ServerEvent ```TriggerServerEvent('Alf-Carkeys:createKey', VehiclePlate)``` to your Scripts to Create an Key
4. Start the rescource

## Config 
Variable |  Description
------------- | -------------
OpenViaButton | Open the Key Menu with a Key false = disabled, true = enabled
MenuButton | Change the Button with that you can Open the Key Menu
VehicleMenu | Change the Button with that you can Open the Vehicle Menu
EngineButton | Change the Button with that you can toggle the Engine
LockButton | Change the Button with that you can Lock the Vehicle
TrustedKeys | Enable / Disable the Trusted Key function `Only activate, when you know what you do!`
ChangePlate | Enable / Disable the ChangePlate function
RenameKey | Enable / Disable the Key Label function
RenameKeyLenght | Set the Lenght of the of the Key Labels (Max. 50)
KeyPrice | Set the Price for Copy Keys
TrustedKeyPrice | Set the Prive for Trusted Keys
ChangePlatePrice | Set the Price to change the Plate
LockRange | Set the Range to Lock your Vehicle
Zones | Position, Blip, Marker, etc. for the CopyKeyStore and ChangePlate 

## Support

[Discord](https://discord.gg/6jsHUVMh8G) (German / English)
