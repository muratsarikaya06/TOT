local playerCollected = {}  -- [identifier] = { [collectibleId] = true }

local function DebugPrint(msg)
    if Config.DebugPrint then
        print("^3[TOT Collectibles]^0 " .. tostring(msg))
    end
end

local function GetIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if id:sub(1, 8) == "license:" then
            return id
        end
    end
    return identifiers[1] or ("src:" .. tostring(src))
end

local function GetPlayerData(src)
    local identifier = GetIdentifier(src)
    if not playerCollected[identifier] then
        playerCollected[identifier] = {}
    end
    return identifier, playerCollected[identifier]
end

local function CountCollected(data)
    local c = 0
    for _, v in pairs(data) do
        if v then c = c + 1 end
    end
    return c
end

RegisterNetEvent('tot_collectibles:requestSync', function()
    local src = source
    local identifier, data = GetPlayerData(src)

    local total = CountCollected(data)
    local max   = #Config.Collectibles

    TriggerClientEvent('tot_collectibles:sync', src, data, total, max)
    DebugPrint(("Sync gönderildi %s (src %d) topladigi: %d/%d"):format(identifier, src, total, max))
end)

RegisterNetEvent('tot_collectibles:collect', function(id)
    local src = source
    local identifier, data = GetPlayerData(src)

    if data[id] then
        DebugPrint(("Oyuncu %s zaten id %s paketini toplamış."):format(identifier, tostring(id)))
        return
    end

    local collectibleConfig = nil
    for _, c in ipairs(Config.Collectibles) do
        if c.id == id then
            collectibleConfig = c
            break
        end
    end

    if not collectibleConfig then
        DebugPrint(("Geçersiz collectible id: %s (src %d)"):format(tostring(id), src))
        return
    end

    -- işaretle
    data[id] = true

    local money = Config.RewardMoney or 0
    if money > 0 then
        if Config.UseTotEconomy and Config.TotEconomyEvent and Config.TotEconomyEvent ~= '' then
            -- TOT ekonomi sistemine bağlanan event
            -- Beklenen signature: (src, amount)
            TriggerEvent(Config.TotEconomyEvent, src, money)
        else
            -- Örnek: sadece chat'e yaz
            TriggerClientEvent('chat:addMessage', src, {
                color = { 255, 200, 50 },
                multiline = true,
                args = { "TOT", ("Gizli paketi topladın! Ödül: $%s"):format(money) }
            })
        end
    end

    local total = CountCollected(data)
    local max   = #Config.Collectibles

    TriggerClientEvent('tot_collectibles:collected', src, id, total, max)

    DebugPrint(("Oyuncu %s id %s paketi topladı. Ödül: %s (Toplam: %d/%d)"):format(
        identifier, tostring(id), tostring(money), total, max
    ))
end)

AddEventHandler('playerDropped', function()
    -- istersen burada temizlik yapabilirsin
end)
