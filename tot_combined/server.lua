local Config = Config or {}
local ox = MySQL

-- ensure table
local function dbEnsure()
    ox.ready(function()
        ox.execute([[
            CREATE TABLE IF NOT EXISTS freeroam_tot_players (
                identifier      VARCHAR(64)  NOT NULL,
                name            VARCHAR(64)  DEFAULT NULL,
                mode            VARCHAR(16)  DEFAULT 'freeroam',
                money           INT          DEFAULT 0,
                xp              INT          DEFAULT 0,
                level           INT          DEFAULT 1,
                drift_total     INT          DEFAULT 0,
                drift_daily     INT          DEFAULT 0,
                drift_weekly    INT          DEFAULT 0,
                last_daily_reset  INT        DEFAULT 0,
                last_weekly_reset INT        DEFAULT 0,
                pvp_kills       INT          DEFAULT 0,
                pvp_deaths      INT          DEFAULT 0,
                collectibles    INT          DEFAULT 0,
                avatar_url      VARCHAR(255) DEFAULT NULL,
                PRIMARY KEY (identifier)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]], {})
    end)
end

dbEnsure()

local function getIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == "license:" then
            return id
        end
    end
    return GetPlayerIdentifier(src, 0)
end

-- fetch one row
local function dbFetchPlayer(identifier, cb)
    ox.single('SELECT * FROM freeroam_tot_players WHERE identifier = ?', { identifier }, function(row)
        cb(row)
    end)
end

-- save / upsert
local function dbSavePlayer(data)
    ox.execute([[
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
        data.mode or (Config.DefaultMode or 'freeroam'),
        data.money or 0,
        data.xp or 0,
        data.level or 1,
        data.drift_total or 0,
        data.drift_daily or 0,
        data.drift_weekly or 0,
        data.last_daily_reset or 0,
        data.last_weekly_reset or 0,
        data.pvp_kills or 0,
        data.pvp_deaths or 0,
        data.collectibles or 0,
        data.avatar_url or nil
    })
end

local function ensurePlayer(src, cb)
    local identifier = getIdentifier(src)
    dbFetchPlayer(identifier, function(row)
        if not row then
            row = {
                identifier = identifier,
                name = GetPlayerName(src) or "Unknown",
                mode = Config.DefaultMode or 'freeroam',
                money = Config.StartMoney or 0,
                xp = 0,
                level = 1,
                drift_total = 0,
                drift_daily = 0,
                drift_weekly = 0,
                last_daily_reset = os.time(),
                last_weekly_reset = os.time(),
                pvp_kills = 0,
                pvp_deaths = 0,
                collectibles = 0,
                avatar_url = nil
            }
            dbSavePlayer(row)
        end

        -- normalize types for client
        row.identifier = identifier
        row.name = row.name or GetPlayerName(src) or "Unknown"

        cb(row)
    end)
end

RegisterNetEvent('tot:combined:requestInit', function()
    local src = source
    ensurePlayer(src, function(data)
        TriggerClientEvent('tot:combined:init', src, data)
    end)
end)

RegisterNetEvent('tot:combined:setMode', function(mode)
    local src = source
    ensurePlayer(src, function(data)
        data.mode = mode
        dbSavePlayer(data)
        TriggerClientEvent('tot:combined:updateField', src, 'mode', mode)
    end)
end)

RegisterNetEvent('tot:combined:setAvatar', function(url)
    local src = source
    ensurePlayer(src, function(data)
        data.avatar_url = url
        dbSavePlayer(data)
        TriggerClientEvent('tot:combined:updateField', src, 'avatar_url', url)
    end)
end)

-- simple drift leaderboard callback (server-side)
lib = lib or {}
lib.callback = lib.callback or {}

-- If you use ox_lib, prefer its exports; otherwise expose our own event
RegisterNetEvent('tot:combined:getDriftTop', function(cbId)
    local src = source
    ox.query('SELECT name, drift_total FROM freeroam_tot_players ORDER BY drift_total DESC LIMIT 10', {}, function(rows)
        TriggerClientEvent('tot:combined:cb:driftTop', src, cbId, rows or {})
    end)
end)
