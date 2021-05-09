Config                            = {}

Config.DrawDistance               = 100.0
Config.Locale                     = 'de'

Config.OpenViaButton              = true
Config.CreateKeyCommand           = true
Config.MenuButton                 = 327       -- F5
Config.VehicleMenu                = 56        -- F9

Config.EngineButton               = 20        -- Z or Y can be diffrent between German and English Layout
Config.LockButton                 = 303       -- U

Config.TrustedKeys                = false     --Enable / Disable Trusted Key Option
Config.ChangePlate                = true      --Enable / Disable Change Plate Option
Config.RenameKey                  = true      --Enable / Disable Give Key Name Option
Config.RenameKeyLenght            = 15        --Maximal count of Letters of Custom Name key

Config.KeyPrice                   = 100
Config.TrustedKeyPrice            = 150
Config.ChangePlatePrice           = 500

Config.LockRange                  = 15.0



Config.Zones = {
  CopyKeyStore = {
    Name      = 'Schlüsseldienst',
    Blip      = 186,
    BlipColor = 53,
    BlipScale = 1.0,
    Pos       = { x = 170.13, y = -1799.38, z = 28.2 },
    Size      = { x = 1.5, y = 1.5, z = 0.5 },
    Color     = { r = 0, g = 255, b = 0 },  
    Type      = 1,
  },
  ChangePlate = {
    Name      = 'Zulassungsstelle',
    Blip      = 525,
    BlipColor = 53,
    BlipScale = 0.7,
    Pos       = { x = -311.15, y = -1013.88, z = 29.3 },
    Size      = { x = 2.5, y = 2.5, z = 0.5 },
    Color     = { r = 0, g = 255, b = 0 },  
    Type      = 1,
  },
}



Locales = {}

Locales['de'] = {
  ['invalidEntry']          = 'Ungültige eingabe',
  ['entryTooLong']          = 'Deine Eingabe ist zu lang',
  ['notEnoughMoney']        = 'Du hast zu wenig Geld dabei',
  ['noPlayerNearYou']       = 'Es befindet sich kein Spieler in deiner Nähe',

  ['gotKey']                = 'Du hast einen Schlüssel für das Fahrzeug: %s erhalten',
  ['NoKeyForVehicle']       = 'Du hast keinen Schlüssel für dieses Fahrzeug',

  ['VehicleLocked']         = 'Fahrzeug ~r~abgeschlossen',
  ['VehicleUnlocked']       = 'Fahrzeug ~g~aufgeschlossen',

  ['renamedKey']            = 'Du hast deinen Schlüssel zu ~b~%s~s~ umbenannt',
  ['gaveKey']               = 'Du hast den Schlüssel mit dem Kennzeichen ~b~%s~s~ weitergegeben',
  ['CantDeleteOriginal']    = 'Du kannst keinen ~r~Originalschlüssel ~s~wegwerfen',
  ['DeleteKey']             = 'Du hast den Fahrzeugschlüssel ~b~%s~r~ weggeworfen',
  ['CopiedKey']             = 'Du hast den Schlüssel für das Fahrzeug ~b~%s~s~ kopiert',
  ['removedKeyLabel']       = 'Du hast den Namen deines Schlüssels ~r~entfernt',

  ['PlateExists']           = '~r~Das Kennzeichen ~b~%s~r~ ist bereits vergeben',
  ['PlateChanged']          = 'Du hast das Kennzeichen zu ~b~%s~s~ geändert',
  ['NewPlateTooLong']       = 'Das Nummernschild ist ~r~zu Lang~s~ (Max 8 Zeichen)',
}

Locales['en'] = {
  ['invalidEntry']          = 'Invalid entry',
  ['entryTooLong']          = 'Entry too long',
  ['notEnoughMoney']        = 'You dont have ~r~enough ~s~money',
  ['noPlayerNearYou']       = 'There is no Player near you',

  ['gotKey']                = 'You got a Key for the Vehicleplate ~b~%s',
  ['NoKeyForVehicle']       = 'You dont have a Key for this Vehicle',

  ['VehicleLocked']         = 'Vehicle ~r~locked',
  ['VehicleUnlocked']       = 'Vehicle ~g~unlocked',

  ['renamedKey']            = 'You renamed your key to ~b~%s~s~',
  ['gaveKey']               = 'You gave the key with the plate ~b~%s~s~',
  ['CantDeleteOriginal']    = 'You cant delete an ~r~Original key!',
  ['DeleteKey']             = 'You have deleted the Key for the plate ~b~%s~r~',
  ['CopiedKey']             = 'You copied the Key for the plate ~b~%s~s~',
  ['removedKeyLabel']       = 'You removed the label of the key',

  ['PlateExists']           = 'This Plate already exists',
  ['PlateChanged']          = 'You changed your Plate to ~b~%s~s~',
  ['NewPlateTooLong']       = 'Your new Plate is ~r~too long~s~ (Max 8 Letters)',
}
