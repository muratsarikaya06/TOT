local shownIntro = false
local currentMode = nil

-- Simple config access
Config = Config or {}

-- UTIL
local function debug(msg)
    if Config.Debug then
        print(('^3[TOT_HUB]^7 %s'):format(msg))
    end
end

local function loadSavedMode()
    local saved = GetResourceKvpString("tot_hub_mode")
    if saved and saved ~= "" then
        currentMode = saved
        debug("Loaded saved mode: "..saved)
    end
end

local function saveMode(mode)
    currentMode = mode
    SetResourceKvp("tot_hub_mode", mode)
    TriggerServerEvent("tot_hub:modeChanged", mode)
    debug("Saved mode: "..mode)
end

local function applySpawnForMode(mode)
    local ped = PlayerPedId()
    local spawns = Config.Spawns[mode]
    if spawns and #spawns > 0 then
        local idx = math.random(1, #spawns)
        local pos = spawns[idx]
        SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, false, true)
        if pos.heading then
            SetEntityHeading(ped, pos.heading)
        end
    end
end

local function openHub(startAsIntro)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        intro = startAsIntro or false,
        mode = currentMode
    })
end

local function closeHub()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "close"
    })
end

-- COMMAND / KEYBIND (F10)
RegisterCommand("tot_hub", function()
    -- Toggle hub (but not the intro overlay text)
    local ped = PlayerPedId()
    if IsPauseMenuActive() then return end
    openHub(false)
end, false)

RegisterKeyMapping("tot_hub", "TOT Hub menüsü", "keyboard", "F10")

-- NUI callbacks
RegisterNUICallback("selectMode", function(data, cb)
    local mode = data.mode
    if mode ~= "freeroam" and mode ~= "pvp" and mode ~= "roleplay" then
        cb({ok = false})
        return
    end

    saveMode(mode)
    applySpawnForMode(mode)
    closeHub()
    shownIntro = true

    cb({ok = true})
end)

RegisterNUICallback("close", function(_, cb)
    closeHub()
    cb({ok = true})
end)

-- INTRO HANDLING
local function showIntroIfNeeded()
    if shownIntro then return end
    if currentMode then
        -- Already selected before, just show small toast once
        SendNUIMessage({
            action = "setModeLabel",
            mode = currentMode
        })
        return
    end
    -- First time => force intro
    openHub(true)
end

AddEventHandler("playerSpawned", function()
    -- Only on first spawn this session
    if not shownIntro and not IsScreenFadedOut() then
        Wait(1500)
        showIntroIfNeeded()
    end
end)

AddEventHandler("onResourceStart", function(resName)
    if resName == GetCurrentResourceName() then
        Wait(500)
        loadSavedMode()
    end
end)

CreateThread(function()
    -- first load
    loadSavedMode()
end)

-- Small text at top-left with current mode (optional)
CreateThread(function()
    while true do
        Wait(0)
        if Config.ShowModeText and currentMode then
            SetTextFont(4)
            SetTextScale(0.35, 0.35)
            SetTextColour(255, 255, 255, 180)
            SetTextOutline()
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("~b~TOT MODU~s~: "..(Config.ModeLabels[currentMode] or currentMode))
            EndTextCommandDisplayText(0.015, 0.015)
        end
    end
end)
