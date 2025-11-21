local playerTasks = {}   -- [identifier] = { date='2025-11-21', tasks = { [taskId] = {id=..., progress=0, completed=false} } }

local function getToday()
    return os.date("%Y-%m-%d")
end

local function ensurePlayerTasks(src)
    local identifier = Config.GetIdentifier(src)
    if not identifier then return nil end

    local today = getToday()
    playerTasks[identifier] = playerTasks[identifier] or {}

    -- Eğer gün değişmişse görevleri sıfırla
    if playerTasks[identifier].date ~= today then
        playerTasks[identifier] = {
            date  = today,
            tasks = {}
        }

        -- Random görev seç
        local available = {}
        for _, task in ipairs(Config.DailyTasks) do
            table.insert(available, task)
        end

        -- Basit karıştırma
        math.randomseed(os.time() + src)
        for i = #available, 2, -1 do
            local j = math.random(1, i)
            available[i], available[j] = available[j], available[i]
        end

        local tasks = {}
        local count = math.min(Config.DailyTaskCount, #available)
        for i = 1, count do
            local t = available[i]
            tasks[t.id] = {
                id        = t.id,
                type      = t.type,
                label     = t.label,
                target    = t.target,
                rewardType= t.rewardType,
                rewardVal = t.rewardValue,
                progress  = 0,
                completed = false
            }
        end

        playerTasks[identifier].tasks = tasks
    end

    return playerTasks[identifier]
end

local function sendTasksToClient(src)
    local data = ensurePlayerTasks(src)
    if not data then return end
    TriggerClientEvent('tot_daily:updateTasks', src, data.tasks, data.date)
end

-- Ödül verme
local function rewardTask(src, task)
    if task.rewardType == 'money' then
        Config.GiveMoney(src, task.rewardVal)
    elseif task.rewardType == 'case_key' then
        Config.GiveCaseKey(src, task.rewardVal)
    else
        print('[TOT_DAILY] Bilinmeyen ödül tipi: '..tostring(task.rewardType))
    end
end

-- Genel progress handler
local function addProgress(src, typeName, amount)
    local identifier = Config.GetIdentifier(src)
    if not identifier then return end

    local data = ensurePlayerTasks(src)
    if not data then return end

    local changed = false

    for _, task in pairs(data.tasks) do
        if task.type == typeName and not task.completed then
            task.progress = task.progress + amount
            if task.progress >= task.target then
                task.progress = task.target
                task.completed = true
                rewardTask(src, task)
                TriggerClientEvent('chat:addMessage', src, {
                    args = { '^2GÖREV TAMAMLANDI', task.label .. ' | Ödül verildi.' }
                })
            end
            changed = true
        end
    end

    if changed then
        sendTasksToClient(src)
    end
end

-- DRIFT puanı event'i
RegisterNetEvent('tot_daily:addDriftPoints', function(points)
    local src = source
    if type(points) ~= 'number' or points <= 0 then return end
    addProgress(src, 'drift_points', points)
end)

-- Yarış kazanma event'i
RegisterNetEvent('tot_daily:raceWon', function()
    local src = source
    addProgress(src, 'races_won', 1)
end)

-- TOT logosu bulununca çağır
RegisterNetEvent('tot_daily:totLogoFound', function()
    local src = source
    addProgress(src, 'tot_logo_found', 1)
end)

-- NPC kovalamaca tamamlanınca
RegisterNetEvent('tot_daily:npcChaseCompleted', function()
    local src = source
    addProgress(src, 'npc_chase', 1)
end)

-- Oyuncu bağlanınca/görevleri isteyince
RegisterNetEvent('tot_daily:requestTasks', function()
    local src = source
    sendTasksToClient(src)
end)

AddEventHandler('playerJoining', function()
    local src = source
    ensurePlayerTasks(src)
    sendTasksToClient(src)
end)

-- İstersen logging/debug için:
RegisterCommand('gorevdebug', function(src)
    if src == 0 then return end
    sendTasksToClient(src)
end, false)
