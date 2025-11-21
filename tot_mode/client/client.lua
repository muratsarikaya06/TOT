local currentMode = "none"
local menuOpen = false
local hasOpenedOnce = false   -- sadece ilk girişte otomatik açmak için

local function OpenMenu()
    if menuOpen then return end
    menuOpen = true

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = "open",
        currentMode = currentMode
    })
end

local function CloseMenu()
    if not menuOpen then return end
    menuOpen = false

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = "close"
    })
end

-- NUI: mod seçildi
RegisterNUICallback("selectMode", function(data, cb)
    if data and data.mode then
        currentMode = data.mode
        TriggerServerEvent("tot_mode:setMode", currentMode)
        print("[TOT MODE] Mod seçildi:", currentMode)
    end

    CloseMenu()
    cb({})
end)

-- (İstersen ileride NUI'den kapat butonu eklersin diye)
RegisterNUICallback("close", function(_, cb)
    CloseMenu()
    cb({})
end)

-- Sunucu mod uyguladığında (şimdilik sadece log)
RegisterNetEvent("tot_mode:applyMode", function(mode)
    currentMode = mode or currentMode
    print("[TOT MODE] Sunucudan gelen aktif mod:", currentMode)
end)

-- ✅ SUNUCUYA İLK GİRİŞTE OTOMATİK AÇILSIN
AddEventHandler("playerSpawned", function()
    if not hasOpenedOnce then
        Wait(1500)           -- spawn otursun
        hasOpenedOnce = true -- sadece bir kere açılsın
        OpenMenu()
    end
end)

-- ✅ F10 → Menü aç/kapat
RegisterCommand("totmode", function()
    if menuOpen then
        CloseMenu()
    else
        OpenMenu()
    end
end, false)

RegisterKeyMapping("totmode", "TOT Mode Menüsü", "keyboard", "F10")
