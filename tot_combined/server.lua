local players = {}

-- =======================
-- YARDIMCI
-- =======================
local function getIdentifier(src)
    local idType = Config.Identifier or "license"
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find(idType .. ":") == 1 then
            return id
        end
    end
    return GetPlayerIdentifier(src, 0)
end

local function dbFetchPlayer(identifier)
    if not Config.UseMySQL then return nil end
    local row = exports.oxmysql:singleSync("SELECT * FROM tot_players WHERE identifier = ?", {identifier})
    return row
end

local function dbSavePlayer(identifier, data)
    if not Config.UseMySQL then return end

    local jsonCollect = json.encode(data.collectibles or {})

    exports.oxmysql:executeSync([[
        INSERT INTO tot_players
        (identifier, name, mode, money, xp, level,
         drift_total, drift_daily, drift_weekly, last_daily_reset, last_weekly_reset,
         pvp_kills, pvp_deaths, collectibles, avatar_url)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ON DUPLICATE KEY UPDATE
           name = VALUES(name),
           mode = VALUES(mode),
           money = VALUES(money),
           xp = VALUES(xp),
           level = VALUES(level),
           drift_total = VALUES(drift_total),
           drift_daily = VALUES(drift_daily),
           drift_weekly = VALUES(drift_weekly),
           last_daily_reset = VALUES(last_daily_reset),
           last_weekly_reset = VALUES(last_weekly_reset),
           pvp_kills = VALUES(pvp_kills),
           pvp_deaths = VALUES(pvp_deaths),
           collectibles = VALUES(collectibles),
           avatar_url = VALUES(avatar_url)
    ]],
    {
        identifier,
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
        jsonCollect,
        data.avatar_url or nil
    })
end

local function ensurePlayer(src)
    if players[src] then return players[src] end

    local identifier = getIdentifier(src)
    local name = GetPlayerName(src) or "Unknown"

    local p = {
        identifier = identifier,
        name       = name,
        mode       = "freeroam",
        money      = 0,
        xp         = 0,
        level      = 1,
        drift_total   = 0,
        drift_daily   = 0,
        drift_weekly  = 0,
        last_daily_reset  = nil,
        last_weekly_reset = nil,
        pvp_kills   = 0,
        pvp_deaths  = 0,
        collectibles = {},
        avatar_url   = nil
    }

    if Config.UseMySQL then
        local row = dbFetchPlayer(identifier)
        if row then
            p.mode       = row.mode or "freeroam"
            p.money      = row.money or 0
            p.xp         = row.xp or 0
            p.level      = row.level or 1
            p.drift_total   = row.drift_total or 0
            p.drift_daily   = row.drift_daily or 0
            p.drift_weekly  = row.drift_weekly or 0
            p.last_daily_reset  = row.last_daily_reset
            p.last_weekly_reset = row.last_weekly_reset
            p.pvp_kills   = row.pvp_kills or 0
            p.pvp_deaths  = row.pvp_deaths or 0
            p.avatar_url  = row.avatar_url
            if row.collectibles and row.collectibles ~= "" then
                p.collectibles = json.decode(row.collectibles) or {}
            end
        end
    end

    players[src] = p
    return p
end

local function recalcLevel(p)
    local level  = 1
    local needed = 0
    local xp     = p.xp or 0

    while level < Config.XP.MaxLevel do
        needed = needed + (level * Config.XP.BasePerLevel)
        if xp < needed then break end
        level = level + 1
    end

    p.level = level
end

local function addXP(p, amount)
    p.xp = (p.xp or 0) + math.floor(amount)
    recalcLevel(p)
end

local function addMoney(p, amount)
    p.money = (p.money or 0) + math.floor(amount)
end

local function resetDailyWeeklyIfNeeded(p)
    local today  = os.date("!%Y-%m-%d")
    local year, week = os.date("!%Y"), os.date("!%V")
    local currentWeek = string.format("%s-W%s", year, week)

    if p.last_daily_reset ~= today then
        p.drift_daily = 0
        p.last_daily_reset = today
    end

    if p.last_weekly_reset ~= currentWeek then
        p.drift_weekly = 0
        p.last_weekly_reset = currentWeek
    end
end

-- =======================
-- DRIFT
-- =======================
RegisterNetEvent("tot_combined:addDriftScore", function(score)
    local src = source
    score = tonumber(score) or 0
    if score <= 0 then return end

    local p = ensurePlayer(src)
    resetDailyWeeklyIfNeeded(p)

    p.drift_total  = (p.drift_total  or 0) + score
    p.drift_daily  = (p.drift_daily  or 0) + score
    p.drift_weekly = (p.drift_weekly or 0) + score

    local money = score * Config.Rewards.DriftMoneyPerPoint
    local xp    = score * Config.Rewards.DriftXPPerPoint

    addMoney(p, money)
    addXP(p, xp)

    dbSavePlayer(p.identifier, p)
    TriggerClientEvent("tot_combined:updateStats", src, p)
end)

-- =======================
-- KOLEKSİYON
-- =======================
RegisterNetEvent("tot_combined:collect", function(id)
    local src = source
    local p   = ensurePlayer(src)

    if p.collectibles[id] then return end

    resetDailyWeeklyIfNeeded(p)

    p.collectibles[id] = true
    addMoney(p, Config.Rewards.CollectibleMoney)
    addXP(p, Config.Rewards.CollectibleXP)

    dbSavePlayer(p.identifier, p)

    TriggerClientEvent("tot_combined:onCollectSuccess", src, id, p)
    TriggerClientEvent("tot_combined:updateStats", src, p)
    TriggerClientEvent("tot_combined:setCollectibleState", src, p.collectibles)
end)

-- =======================
-- MOD SEÇİMİ
-- =======================
RegisterNetEvent("tot_combined:setMode", function(mode)
    local src = source
    local p   = ensurePlayer(src)

    if not Config.Modes[mode] then return end

    p.mode = mode
    dbSavePlayer(p.identifier, p)

    local modeCfg = Config.Modes[mode]

    if modeCfg.bucket ~= nil then
        SetPlayerRoutingBucket(src, modeCfg.bucket)
    end

    if modeCfg.giveWeapons then
        TriggerClientEvent("tot_combined:givePvpLoadout", src)
    else
        TriggerClientEvent("tot_combined:clearWeapons", src)
    end

    TriggerClientEvent("tot_combined:spawnAtMode", src, modeCfg.spawn)
    TriggerClientEvent("tot_combined:setCurrentMode", src, mode)
    TriggerClientEvent("tot_combined:updateStats", src, p)
end)

-- =======================
-- AVATAR
-- =======================
RegisterNetEvent("tot_combined:setAvatarUrl", function(url)
    local src = source
    local p   = ensurePlayer(src)

    if type(url) ~= "string" or #url > 255 then return end

    p.avatar_url = url
    dbSavePlayer(p.identifier, p)
    TriggerClientEvent("tot_combined:updateStats", src, p)
end)

-- =======================
-- İLK VERİ
-- =======================
RegisterNetEvent("tot_combined:requestInitData", function()
    local src = source
    local p   = ensurePlayer(src)

    resetDailyWeeklyIfNeeded(p)
    recalcLevel(p)
    dbSavePlayer(p.identifier, p)

    TriggerClientEvent("tot_combined:setCurrentMode", src, p.mode or "freeroam")
    TriggerClientEvent("tot_combined:updateStats", src, p)
    TriggerClientEvent("tot_combined:setCollectibleState", src, p.collectibles or {})

    TriggerEvent("tot_combined:sendLeaderboards", src)
end)

-- =======================
-- LEADERBOARD
-- =======================
local function fetchLeaderboard(column, limit)
    limit = limit or 10
    if not Config.UseMySQL then return {} end
    return exports.oxmysql:executeSync(
        ("SELECT name, %s AS score, level FROM tot_players ORDER BY %s DESC LIMIT %d"):format(column, column, limit),
        {}
    ) or {}
end

RegisterNetEvent("tot_combined:requestLeaderboards", function()
    local src = source
    TriggerEvent("tot_combined:sendLeaderboards", src)
end)

AddEventHandler("tot_combined:sendLeaderboards", function(target)
    if not Config.UseMySQL then return end

    local all   = fetchLeaderboard("drift_total", 10)
    local daily = fetchLeaderboard("drift_daily", 10)
    local week  = fetchLeaderboard("drift_weekly", 10)

    TriggerClientEvent("tot_combined:leaderboardData", target, {
        all   = all,
        daily = daily,
        weekly = week
    })
end)

-- =======================
-- PVP KILL/DEATH (baseevents)
-- =======================
AddEventHandler("baseevents:onPlayerKilled", function(victimId, killerId, _)
    if not killerId then return end

    local victim = ensurePlayer(victimId)
    local killer = ensurePlayer(killerId)

    if killer.mode ~= "pvp" or victim.mode ~= "pvp" then return end

    killer.pvp_kills  = (killer.pvp_kills or 0) + 1
    victim.pvp_deaths = (victim.pvp_deaths or 0) + 1

    addMoney(killer, Config.Rewards.PvpKillMoney)
    addXP(killer,    Config.Rewards.PvpKillXP)

    dbSavePlayer(killer.identifier, killer)
    dbSavePlayer(victim.identifier, victim)

    TriggerClientEvent("tot_combined:updateStats", killerId, killer)
    TriggerClientEvent("tot_combined:updateStats", victimId, victim)
end)

AddEventHandler("baseevents:onPlayerDied", function(victimId, _)
    local victim = ensurePlayer(victimId)
    if victim.mode ~= "pvp" then return end

    victim.pvp_deaths = (victim.pvp_deaths or 0) + 1
    dbSavePlayer(victim.identifier, victim)
    TriggerClientEvent("tot_combined:updateStats", victimId, victim)
end)

-- =======================
-- OTOMATİK MAAŞ
-- =======================
if Config.AutoPayEnabled then
    CreateThread(function()
        while true do
            Wait(Config.AutoPayInterval)
            for src, p in pairs(players) do
                addMoney(p, Config.AutoPayAmount)
                dbSavePlayer(p.identifier, p)
                TriggerClientEvent("tot_combined:updateStats", src, p)
            end
        end
    end)
end

-- =======================
-- ÇIKIŞ
-- =======================
AddEventHandler("playerDropped", function()
    local src = source
    local p = players[src]
    if p then
        dbSavePlayer(p.identifier, p)
    end
    players[src] = nil
end)
