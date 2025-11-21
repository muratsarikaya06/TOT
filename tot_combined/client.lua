local Config = Config or {}

local isHubOpen = false
local playerCache = {
    mode = nil,
    money = 0,
    xp = 0,
    level = 1,
    drift_total = 0,
    drift_daily = 0,
    drift_weekly = 0,
    pvp_kills = 0,
    pvp_deaths = 0,
    collectibles = 0
}

-- receive initial data from server
RegisterNetEvent('tot:combined:init', function(data)
    playerCache = data
    SendNUIMessage({
        action = 'setPlayerData',
        data = playerCache
    })
end)

-- update single stat from server
RegisterNetEvent('tot:combined:updateField', function(field, value)
    playerCache[field] = value
    SendNUIMessage({
        action = 'setField',
        field = field,
        value = value
    })
end)

-- toggle hub
RegisterCommand('tot_hub', function()
    toggleHub()
end, false)

RegisterKeyMapping('tot_hub', 'TOT Hub aç/kapat', 'keyboard', Config.ToggleKey or 'F10')

function toggleHub(forceState)
    if forceState ~= nil then
        isHubOpen = forceState
    else
        isHubOpen = not isHubOpen
    end

    SetNuiFocus(isHubOpen, isHubOpen)
    SendNUIMessage({
        action = 'setVisible',
        state = isHubOpen
    })
end

RegisterNUICallback('close', function(_, cb)
    toggleHub(false)
    cb('ok')
end)

RegisterNUICallback('changeMode', function(data, cb)
    local mode = data.mode
    if mode then
        TriggerServerEvent('tot:combined:setMode', mode)
    end
    cb('ok')
end)

RegisterNUICallback('saveAvatar', function(data, cb)
    TriggerServerEvent('tot:combined:setAvatar', data.url or '')
    cb('ok')
end)

-- request open on spawn
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('tot:combined:requestInit')
end)
