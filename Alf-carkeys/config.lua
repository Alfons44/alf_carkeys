Config                            = {}

Config.DrawDistance               = 100.0

Config.OpenViaButton              = true
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
    --Pos       = { x = -325.0, y = -10036, z = 29.3 },
    Size      = { x = 2.5, y = 2.5, z = 0.5 },
    Color     = { r = 0, g = 255, b = 0 },  
    Type      = 1,
  },
}