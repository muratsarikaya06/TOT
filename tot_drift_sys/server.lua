local function getIdentifier(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id and id:find("license:") then
            return id
        end
    end
    return "player:" .. tostring(src)
end

local function getPlayerNameSafe(src)
    local n = GetPlayerName(src)
    if not n or n == "" then
        n = "ID " .. tostring(src)
    end
    return n
end

local function ensurePlayerRow(src, cb)
    local identifier = getIdentifier(src)
    local name       = getPlayerNameSafe(src)

    MySQL.single('SELECT id FROM tot_drift_players WHERE identifier = ?', { identifier }, function(row)
        if not row then
            MySQL.insert('INSERT INTO tot_drift_players (identifier, name) VALUES (?, ?)', {
                identifier, name
            }, function()
                if cb then cb(identifier, name) end
            end)
        else
            MySQL.update('UPDATE tot_drift_players SET name = ? WHERE identifier = ?', {
                name, identifier
            })
            if cb then cb(identifier, name) end
        end
    end)
end

RegisterNetEvent('tot_drift:addScore', function(score)
    local src = source
    if type(score) ~= 'number' then return end
    score = math.floor(score)
    if score <= 0 then return end

    ensurePlayerRow(src, function(identifier, name)
        MySQL.update('UPDATE tot_drift_players SET total_points = total_points + ? WHERE identifier = ?', {
            score, identifier
        })

        MySQL.insert('INSERT INTO tot_drift_history (identifier, score) VALUES (?, ?)', {
            identifier, score
        })
    end)
end)

local function sendScoresForMode(src, mode)
    mode = mode or 'all'

    if mode == 'all' then
        MySQL.query(
            'SELECT name, total_points FROM tot_drift_players ORDER BY total_points DESC LIMIT 50',
            {},
            function(rows)
                local list = {}

                for i, row in ipairs(rows or {}) do
                    table.insert(list, {
                        id    = i,
                        name  = row.name or ("Oyuncu " .. i),
                        score = row.total_points or 0
                    })
                end

                TriggerClientEvent('tot_drift:updateScoreboard', src, list)
            end
        )
    else
        local interval
        if mode == 'day' then
            interval = '1 DAY'
        elseif mode == 'week' then
            interval = '7 DAY'
        elseif mode == 'month' then
            interval = '30 DAY'
        else
            interval = '365 DAY'
        end

        local sql = [[
            SELECT p.name, SUM(h.score) AS total
            FROM tot_drift_history h
            LEFT JOIN tot_drift_players p ON p.identifier = h.identifier
            WHERE h.created_at >= (NOW() - INTERVAL ]] .. interval .. [[)
            GROUP BY h.identifier, p.name
            ORDER BY total DESC
            LIMIT 50
        ]]

        MySQL.query(sql, {}, function(rows)
            local list = {}
            for i, row in ipairs(rows or {}) do
                table.insert(list, {
                    id    = i,
                    name  = row.name or ("Oyuncu " .. i),
                    score = row.total or 0
                })
            end

            TriggerClientEvent('tot_drift:updateScoreboard', src, list)
        end)
    end
end

RegisterNetEvent('tot_drift:requestScores', function()
    local src = source
    sendScoresForMode(src, 'all')
end)

RegisterNetEvent('tot_drift:requestScoresMode', function(mode)
    local src = source
    sendScoresForMode(src, mode)
end)

RegisterNetEvent('tot_drift:requestPlayerSummary', function()
    local src = source
    local identifier = getIdentifier(src)
    local name = getPlayerNameSafe(src)

    MySQL.single('SELECT total_points FROM tot_drift_players WHERE identifier = ?', { identifier }, function(playerRow)
        local totalDrift = (playerRow and playerRow.total_points) or 0

        local sql = [[
            SELECT
              MAX(score) AS best_score,
              COUNT(*)   AS drift_count
            FROM tot_drift_history
            WHERE identifier = ?
        ]]

        MySQL.single(sql, { identifier }, function(histRow)
            local bestScore  = (histRow and histRow.best_score) or 0
            local driftCount = (histRow and histRow.drift_count) or 0

            local summary = {
                name        = name,
                totalDrift  = math.floor(totalDrift),
                bestScore   = math.floor(bestScore),
                driftCount  = driftCount,
                kills       = 0,
                points      = 0
            }

            TriggerClientEvent('tot_drift:updatePlayerSummary', src, summary)
        end)
    end)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    ensurePlayerRow(src)
end)

AddEventHandler('playerJoining', function()
    local src = source
    ensurePlayerRow(src)
end)
