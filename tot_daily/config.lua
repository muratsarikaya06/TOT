Config = {}

-- Görevler
-- type: 'drift_points', 'races_won', 'tot_logo_found', 'npc_chase'
-- rewardType: 'money' veya istersen ileride 'item', 'case_key' vs.
Config.DailyTasks = {
    {
        id          = 'drift_10000',
        type        = 'drift_points',
        label       = '10.000 drift puanı yap',
        target      = 10000,
        rewardType  = 'money',
        rewardValue = 7500
    },
    {
        id          = 'race_win_2',
        type        = 'races_won',
        label       = '2 yarış kazan',
        target      = 2,
        rewardType  = 'money',
        rewardValue = 15000
    },
    {
        id          = 'logo_find_1',
        type        = 'tot_logo_found',
        label       = 'Haritada bir TOT logosu bul',
        target      = 1,
        rewardType  = 'case_key',
        rewardValue = 1
    },
    {
        id          = 'npc_chase_5',
        type        = 'npc_chase',
        label       = '5 NPC kovalaması tamamla',
        target      = 5,
        rewardType  = 'money',
        rewardValue = 5000
    }
}

-- Her oyuncuya günde kaç görev verelim?
Config.DailyTaskCount = 3

-- Ekonomi entegrasyonu
-- Burayı kendi tot_economy / frameworküne göre düzenleyeceksin.
Config.GiveMoney = function(src, amount)
    -- ÖRNEKLER:
    -- exports['tot_economy']:AddMoney(src, amount)
    -- exports['qb-core']:GetCoreObject().Functions.AddMoney(...)
    -- veya kendi sistemin her ne ise onu çağır.

    -- Şimdilik debug:
    print(('[TOT_DAILY] %s oyuncusuna %d₺ verildi (Config.GiveMoney içini kendine göre düzenle).'):format(src, amount))
end

-- Kasa anahtarı / item vs.
Config.GiveCaseKey = function(src, count)
    -- exports['tot_inventory']:AddItem(src, 'case_key', count)
    print(('[TOT_DAILY] %s oyuncusuna %dx kasa anahtarı verildi (Config.GiveCaseKey içini kendine göre düzenle).'):format(src, count))
end

-- Oyuncu tanımlayıcı (DB için vs.)
Config.GetIdentifier = function(src)
    -- Steam, license vs. hangisini kullanıyorsan
    -- Basit örnek:
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == "license:" then
            return id
        end
    end
    return GetPlayerIdentifier(src, 0) -- fallback
end
