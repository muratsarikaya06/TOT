local ox = exports.oxmysql

-- Küçük helper: oyuncunun license id'sini bul
local function GetLicense(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id and id:sub(1, 7) == "license" then
            return id
        end
    end
    return GetPlayerIdentifier(src, 0)
end

----------------------------------------------------------------------
--  VERİTABANI FONKSİYONLARI
----------------------------------------------------------------------

--- oyuncu tablosunu oluştur (startta 1 kere çalışır)
local function ensureTable()
    ox:executeSync([[
        CREATE TABLE IF NOT EXISTS freeroam_tot_players (
            identifier       VARCHAR(64)  NOT NULL,
            name             VARCHAR(64)  NOT NULL,
            mode             VARCHAR(16)  NOT NULL DEFAULT 'freeroam',

            money            INT          NOT NULL DEFAULT 0,
            xp               INT          NOT NULL DEFAULT 0,
            level            INT          NOT NULL DEFAULT 1,

            drift_total      INT          NOT NULL DEFAULT 0,
            drift_daily      INT          NOT NULL DEFAULT 0,
            drift_weekly     INT          NOT NULL DEFAULT 0,
            last_daily_reset DATE         DEFAULT NULL,
            last_weekly_reset DATE        DEFAULT NULL,

            pvp_kills        INT          NOT NULL DEFAULT 0,
            pvp_deaths       INT          NOT NULL DEFAULT 0,

            collectibles     LONGTEXT     DEFAULT NULL,
            avatar_url       VARCHAR(255) DEFAULT NULL,

            PRIMARY KEY (identifier)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]})
end

--- DB'den oyuncu verisini çek
local function dbFetchPlayer(identifier)
    local row = ox:singleSync(
        'SELECT * FROM freeroam_tot_players WHERE identifier = ?',
        { identifier }
    )
    return row
end

--- DB'ye oyuncu kaydet
local function dbSavePlayer(data)
    ox:executeSync([[
        INSERT INTO freeroam_tot_players
        (identifier, name, mode, money, xp, level,
         drift_total, drift_daily, drift_weekly,
         last_daily_reset, last_weekly_reset,
         pvp_kills, pvp_deaths, collectibles, avatar_url)
        VALUES (?, ?, ?, ?, ?, ?,
                ?, ?, ?,
                ?, ?,
                ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            name             = VALUES(name),
            mode             = VALUES(mode),
            money            = VALUES(money),
            xp               = VALUES(xp),
            level            = VALUES(level),
            drift_total      = VALUES(drift_total),
            drift_daily      = VALUES(drift_daily),
            drift_weekly     = VALUES(drift_weekly),
            last_daily_reset = VALUES(last_daily_reset),
            last_weekly_reset= VALUES(last_weekly_reset),
            pvp_kills        = VALUES(pvp_kills),
            pvp_deaths       = VALUES(pvp_deaths),
            collectibles     = VALUES(collectibles),
            avatar_url       = VALUES(avatar_url)
    ]], {
        data.identifier,
        data.name or "Unknown",
        data.mode or "freeroam",

        data.money or 0,
        data.xp or 0,
        data.level or 1,

        data.drift_total or 0,
        data.drift_daily or 0,
        data.drift_weekly or 0,
        data.last_daily_reset or nil,
        data.last_weekly_reset or nil,

        data.pvp_kills or 0,
        data.pvp_deaths or 0,
        json.encode(data.collectibles or {}),
        data.avatar_url or ""
    })
end

--- Drift global leaderboard (ilk 10)
local function dbFetchLeaderboard()
    local rows = ox:querySync(
        'SELECT name, drift_total FROM freeroam_tot_players ORDER BY drift_total DESC LIMIT 10',
        {}
    )
    return rows or {}
end

----------------------------------------------------------------------
--  SUNUCU İÇİ STATE
----------------------------------------------------------------------

local players = {}

local function ensurePlayer(src)
    local identifier = GetLicense(src)
    local name = GetPlayerName(src) or "Unknown"

    local row = dbFetchPlayer(identifier)

    if row then
        -- DB'den yükle
        players[src] = {
            identifier       = identifier,
            name             = row.name,
            mode             = row.mode or "freeroam",
            money            = row.money or 0,
            xp               = row.xp or 0,
            level            = row.level or 1,
            drift_total      = row.drift_total or 0,
            drift_daily      = row.drift_daily or 0,
            drift_weekly     = row.drift_weekly or 0,
            last_daily_reset = row.last_daily_reset,
            last_weekly_reset= row.last_weekly_reset,
            pvp_kills        = row.pvp_kills or 0,
            pvp_deaths       = row.pvp_deaths or 0,
            collectibles     = json.decode(row.collectibles or "[]") or {},
            avatar_url       = row.avatar_url or ""
        }
    else
        -- Yeni oyuncu
        players[src] = {
            identifier       = identifier,
            name             = name,
            mode             = "freeroam",
            money            = 0,
            xp               = 0,
            level            = 1,
            drift_total      = 0,
            drift_daily      = 0,
            drift_weekly     = 0,
            last_daily_reset = os.date('%Y-%m-%d'),
            last_weekly_reset= os.date('%Y-%m-%d'),
            pvp_kills        = 0,
            pvp_deaths       = 0,
            collectibles     = {},
            avatar_url       = ""
        }

        dbSavePlayer(players[src])
    end

    return players[src]
end

----------------------------------------------------------------------
--  OYUNCU GİRİŞ / ÇIKIŞ
----------------------------------------------------------------------

AddEventHandler('playerJoining', function()
    local src = source
    ensurePlayer(src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    local data = players[src]
    if data then
        dbSavePlayer(data)
        players[src] = nil
    end
end)

----------------------------------------------------------------------
--  NUI EVENTLERİ (TOT HUB)
----------------------------------------------------------------------

-- Profil verisi iste
RegisterNetEvent('tot:hub:requestProfile', function()
    local src = source
    local data = ensurePlayer(src)

    local leaderboard = dbFetchLeaderboard()

    TriggerClientEvent('tot:hub:profileData', src, {
        profile     = data,
        leaderboard = leaderboard
    })
end)

-- Oyun modu değiştir
RegisterNetEvent('tot:hub:setMode', function(mode)
    local src = source
    local data = ensurePlayer(src)

    if mode ~= "freeroam" and mode ~= "pvp" and mode ~= "rp" then
        return
    end

    data.mode = mode
    dbSavePlayer(data)

    TriggerClientEvent('tot:hub:modeUpdated', src, mode)
end)

-- Avatar kaydet
RegisterNetEvent('tot:hub:setAvatar', function(url)
    local src = source
    local data = ensurePlayer(src)

    if type(url) ~= "string" then return end
    if #url > 255 then return end

    data.avatar_url = url
    dbSavePlayer(data)

    TriggerClientEvent('tot:hub:avatarUpdated', src, url)
end)

----------------------------------------------------------------------
--  KONSOL LOGU VE TABLO OLUŞTURMA
----------------------------------------------------------------------

CreateThread(function()
    ensureTable()
    print('[tot_combined] freeroam_tot_players tablosu hazır.')
end)