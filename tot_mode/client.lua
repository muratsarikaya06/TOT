local hasShownOnJoin = false
local currentMode = nil

local ModeConfig = {
    freeroam = { label='Serbest Gezinme', spawn=vector4(-1037.5,-2737.8,20.17,330.0) },
    pvp      = { label='PvP',            spawn=vector4(215.76,-810.12,30.73,160.0) },
    roleplay = { label='Roleplay',       spawn=vector4(-267.0,-957.5,31.22,70.0) }
}

AddEventHandler('playerSpawned', function()
    if not hasShownOnJoin then
        hasShownOnJoin = true
        TriggerServerEvent('tot_mode:requestMode')
        SetTimeout(1000,function()
            if not currentMode then OpenTotModeUi() end
        end)
    end
end)

RegisterCommand('totmode', function()
    if IsPauseMenuActive() then return end
    OpenTotModeUi(true)
end)

RegisterKeyMapping('totmode','TOT Mod Menüsü','keyboard','F10')

RegisterNetEvent('tot_mode:syncMode', function(mode)
    currentMode = mode
end)

function OpenTotModeUi(fromKey)
    SetNuiFocus(true,true)
    SendNUIMessage({action='open',currentMode=currentMode or 'none',fromKey=fromKey or false})
end

local function CloseTotModeUi()
    SetNuiFocus(false,false)
    SendNUIMessage({action='close'})
end

local function ApplyMode(modeName)
    currentMode = modeName
    TriggerServerEvent('tot_mode:setMode',modeName)
    local cfg = ModeConfig[modeName]
    if cfg and cfg.spawn then
        local ped = PlayerPedId()
        local pos = cfg.spawn
        SetEntityCoordsNoOffset(ped,pos.x,pos.y,pos.z,false,false,false)
        SetEntityHeading(ped,pos.w or 0.0)
    end
end

RegisterNUICallback('selectMode',function(data,cb)
    local mode = data.mode
    if ModeConfig[mode] then ApplyMode(mode) end
    CloseTotModeUi()
    cb('ok')
end)

RegisterNUICallback('close',function(_,cb)
    CloseTotModeUi()
    cb('ok')
end)

exports('GetCurrentMode',function() return currentMode end)
