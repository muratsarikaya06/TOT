Config = {}

-- ==================================
-- GENEL
-- ==================================
Config.ToggleKey     = 'F10'   -- F10 ile HUB aç/kapat
Config.UseMySQL      = true    -- oxmysql kullanılacaksa true
Config.Identifier    = "license"  -- 'license', 'steam', 'fivem' vs.

-- Otomatik maaş
Config.AutoPayEnabled   = true
Config.AutoPayInterval  = 10 * 60 * 1000   -- 10 dakika (ms)
Config.AutoPayAmount    = 5000             -- 10 dk'da 5000 ₺

-- ==================================
-- MODLAR & SPAWN NOKTALARI
-- ==================================
Config.Modes = {
    freeroam = {
        label  = "Serbest Gezinme",
        spawn  = vector3(-1037.58, -2737.88, 20.17),
        bucket = 0,         -- ana dünya
    },
    pvp = {
        label      = "PvP",
        spawn      = vector3(2045.13, 2949.54, 47.74),
        bucket     = 10,    -- ayrı dünya
        giveWeapons = true, -- PvP loadout ver
    },
    rp = {
        label  = "Roleplay",
        spawn  = vector3(-75.0, -818.9, 326.2),
        bucket = 20         -- RP dünyası
    }
}

-- PvP için verilecek silahlar
Config.PvPWeapons = {
    { weapon = `WEAPON_PISTOL`,        ammo = 250 },
    { weapon = `WEAPON_CARBINERIFLE`,  ammo = 500 },
    { weapon = `WEAPON_PUMPSHOTGUN`,   ammo = 200 },
    { weapon = `WEAPON_SMG`,           ammo = 400 },
    { weapon = `WEAPON_GRENADE`,       ammo = 10  },
}

-- ==================================
-- DRIFT AYARLARI
-- ==================================
Config.Drift = {
    MinSpeedKmh     = 30.0,
    MinAngleDeg     = 15.0,
    ScoreMultiplier = 0.15,
    MinDriftScore   = 50,
    HudFadeTime     = 1500, -- drift bittikten sonra HUD ne kadar ekranda kalsın (ms)
}

-- ==================================
-- EKONOMİ & ÖDÜLLER
-- ==================================
Config.Rewards = {
    DriftMoneyPerPoint = 0.5,  -- 1000 drift = 500 ₺
    DriftXPPerPoint    = 0.1,  -- 1000 drift = 100 XP

    CollectibleMoney   = 5000, -- her paket
    CollectibleXP      = 250,  -- her paket

    PvpKillMoney       = 1500,
    PvpKillXP          = 50,
}

-- ==================================
-- XP & LEVEL
-- ==================================
Config.XP = {
    BasePerLevel = 1000,
    MaxLevel     = 100
}

function Config.GetLevelFromXP(xp)
    local level  = 1
    local needed = 0

    while level < Config.XP.MaxLevel do
        needed = needed + (level * Config.XP.BasePerLevel)
        if xp < needed then
            break
        end
        level = level + 1
    end

    return level, (needed - xp)
end

-- ==================================
-- KOLEKSİYON PAKETLERİ (ÖRNEKLER)
-- ==================================
Config.Collectibles = {
    { id = 1,  label = "Los Santos Limanı Gizli Paket", coords = vector3(-278.18, -2434.23, 6.0) },
    { id = 2,  label = "Vinewood Tepesi Manzara Noktası", coords = vector3(708.03, 1198.01, 325.0) },
    { id = 3,  label = "Sandy Shores Uçak Hangarı", coords = vector3(1737.92, 3294.79, 41.22) },
    { id = 4,  label = "Del Perro İskelesi Altı", coords = vector3(-1850.3, -1220.5, 13.0) },
    { id = 5,  label = "Paleto Ormanı Kayalık", coords = vector3(-668.2, 5805.1, 18.6) },
    -- 6..50 arası sen ekleyebilirsin, aynı formatla devam
}

Config.CollectibleMarker = {
    DrawDistance = 30.0,
    Radius       = 2.0
}
