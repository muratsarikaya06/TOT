-- tot_combined / client.lua
-- NUI Hub + Mod Sistemi

local uiOpen      = false
local currentMode = "freeroam"

----------------------------------------------------------------
-- NUI AÇ/KAPAT
----------------------------------------------------------------

local function openHub()
    if uiOpen then return end
    uiOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })

    -- Profil verisini iste
    TriggerServerEvent("tot_combined:requestProfile")
end

local function closeHub()
    if not uiOpen then return end
    uiOpen = false

    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

RegisterNUICallback("close", function(data, cb)
    closeHub()
    cb("ok")
end)

-- F10 ile aç/kapat
RegisterCommand("tot_hub", function()
    if uiOpen then
        closeHub()
    else
        openHub()
    end
end)

RegisterKeyMapping("tot_hub", "TÜRK OYUN TİMİ HUB", "keyboard", "F10")

----------------------------------------------------------------
-- SUNUCUDAN GELEN PROFİL / LEADERBOARD / MOD BİLDİRİMLERİ
----------------------------------------------------------------

RegisterNetEvent("tot_combined:openHub", function(profile)
    -- spawn olduğunda otomatik açmak istersen buradan openHub çağırabilirsin
    openHub()

    if profile then
        SendNUIMessage({ action = "setProfile", profile = profile })
        currentMode = profile.mode or "freeroam"
    end
end)

RegisterNetEvent("tot_combined:sendProfile", function(profile)
    if not profile then return end
    currentMode = profile.mode or "freeroam"
    SendNUIMessage({ action = "setProfile", profile = profile })
end)

RegisterNetEvent("tot_combined:sendDriftLeaderboard", function(list)
    SendNUIMessage({ action = "setDriftLeaderboard", data = list })
end)

RegisterNetEvent("tot_combined:modeUpdated", function(mode)
    currentMode = mode or "freeroam"

    SendNUIMessage({
        action = "setActiveMode",
        mode   = currentMode
    })

    applyModeEffects(currentMode)
end)

----------------------------------------------------------------
-- NUI CALLBACKLER
----------------------------------------------------------------

-- Mod seçimi (Onayla butonundan geliyor)
RegisterNUICallback("setMode", function(data, cb)
    local mode = data.mode

    if mode ~= "freeroam" and mode ~= "pvp" and mode ~= "roleplay" then
        cb({ ok = false })
        return
    end

    TriggerServerEvent("tot_combined:requestModeChange", mode)
    cb({ ok = true, mode = mode })
end)

-- Drift leaderboard isteği
RegisterNUICallback("requestDriftLeaderboard", function(_, cb)
    TriggerServerEvent("tot_combined:requestDriftLeaderboard")
    cb("ok")
end)

-- İleride avatar kaydetme, xp/istatistik, ayarlar vb. için
-- daha fazla NUI callback buraya ekleyebilirsin.

----------------------------------------------------------------
-- MOD ETKİLERİ (PvP / Freeroam / Roleplay)
----------------------------------------------------------------

function applyModeEffects(mode)
    local ped = PlayerPedId()

    -- Önce her şeyi sıfırla
    RemoveAllPedWeapons(ped, true)
    SetCanAttackFriendly(ped, false, false)
    NetworkSetFriendlyFireOption(false)

    if mode == "pvp" then
        -- PvP: silah ver, friendly fire aç
        GiveWeaponToPed(ped, WEAPON_CARBINERIFLE, 250, false, true)
        GiveWeaponToPed(ped, WEAPON_PISTOL,       150, false, true)
        GiveWeaponToPed(ped, WEAPON_KNIFE,        1,   false, true)

        SetCanAttackFriendly(ped, true, true)
        NetworkSetFriendlyFireOption(true)
    elseif mode == "freeroam" then
        -- Serbest Gezinme: İstersen araba spawn veya drift buff koy
        -- Buraya özgü efektlerini ekleyebilirsin.
    elseif mode == "roleplay" then
        -- Roleplay: PvP kapalı, sadece RP odaklı
        -- Özel anim/konum/skin sistemi buraya bağlanabilir.
    end
end

----------------------------------------------------------------
-- OYUNCU SPAWN OLDUĞUNDA HUB İÇİN TEMEL EVENT
----------------------------------------------------------------

-- Eğer baseevents kullanıyorsan:
AddEventHandler("playerSpawned", function()
    -- Sunucuya "geldim" de; o da profil yükleyip sadece veri gönderebilir
    TriggerServerEvent("tot_combined:playerJoined")
end)

-- Alternatif olarak qb/esx eventlerine bağlayabilirsin:
-- AddEventHandler("esx:playerLoaded", function() ... end)
-- AddEventHandler("QBCore:Client:OnPlayerLoaded", function() ... end)

----------------------------------------------------------------
-- DEBUG KOMUTU: Şu anki modun efektlerini tekrar uygula
----------------------------------------------------------------

RegisterCommand("tot_mode_apply", function()
    applyModeEffects(currentMode)
end)