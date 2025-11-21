local collected = {}          -- bu client için toplananlar
local totalCollected = 0      -- F10 menü için istatistik
local totalAvailable = #Config.Collectibles

local function DebugPrint(msg)
    if Config.DebugPrint then
        print("^3[TOT Collectibles]^0 " .. tostring(msg))
    end
end

local function Draw3DText(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.0, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 230)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function IsCollectibleActive(icon)
    if not icon.activeHours then
        return true
    end

    local h = GetClockHours() -- oyun içi saat
    local s = icon.activeHours.start
    local f = icon.activeHours.finish

    if not s or not f then
        return true
    end

    -- normal aralık (örn. 10 - 18)
    if s <= f then
        return h >= s and h < f
    end

    -- wrap'lı aralık (örn. 22 - 4)
    return (h >= s) or (h < f)
end

local function DrawFloatingIcon(icon, time)
    local pos   = icon.coords
    local color = icon.color or { r = 255, g = 255, b = 255 }
    local scale = icon.scale or 1.0

    local bob  = math.sin(time * Config.IconBobSpeed) * Config.IconBobAmplitude
    local rotZ = (time * Config.RotationSpeed) % 360.0
    local drawZ = pos.z + Config.IconHeight + bob
    local s = 0.8 * scale

    DrawMarker(
        28,
        pos.x, pos.y, drawZ,
        0.0, 0.0, 0.0,
        0.0, 0.0, rotZ,
        s, s, s,
        color.r or 255, color.g or 255, color.b or 255, 190,
        false, true, 2, false, nil, nil, false
    )

    DrawLightWithRange(
        pos.x, pos.y, drawZ + 0.15,
        color.r or 255, color.g or 255, color.b or 255,
        4.0,
        1.1
    )

    if Config.Show3DText and icon.label then
        local extra = ""
        if icon.activeHours then
            local s = icon.activeHours.start or 0
            local f = icon.activeHours.finish or 0
            extra = (" ~c~(%02d:00-%02d:00)"):format(s, f)
        end
        Draw3DText(pos.x, pos.y, drawZ + 0.45, icon.label .. " ~c~[~y~E~c~]" .. extra)
    end
end

-- Server'dan sync
RegisterNetEvent('tot_collectibles:sync', function(serverCollected, total, max)
    collected       = serverCollected or {}
    totalCollected  = total or 0
    totalAvailable  = max or #Config.Collectibles
    DebugPrint(("Sync alındı. Toplanan: %d / %d"):format(totalCollected, totalAvailable))

    -- F10 menü (tot_menu) ile entegre etmek istersen:
    -- TriggerEvent('tot_menu:updateCollectibles', totalCollected, totalAvailable)
end)

-- Server'dan tek bir collectible toplandı
RegisterNetEvent('tot_collectibles:collected', function(id, total, max)
    collected[id]   = true
    totalCollected  = total or totalCollected
    totalAvailable  = max or totalAvailable

    -- F10 menü ile entegre:
    -- TriggerEvent('tot_menu:updateCollectibles', totalCollected, totalAvailable)
end)

-- İstersen diğer scriptlerin kullanması için export
exports('GetCollectibleStats', function()
    return totalCollected, totalAvailable
end)

CreateThread(function()
    Wait(2000)
    TriggerServerEvent('tot_collectibles:requestSync')

    while true do
        local playerPed = PlayerPedId()
        local pCoords   = GetEntityCoords(playerPed)
        local time      = GetGameTimer() / 1000.0

        local sleep = 1000

        for _, icon in ipairs(Config.Collectibles) do
            if not collected[icon.id] and IsCollectibleActive(icon) then
                local dist = #(pCoords - icon.coords)
                if dist < Config.DrawDistance then
                    sleep = 0
                    DrawFloatingIcon(icon, time)

                    if dist < 1.5 then
                        if IsControlJustPressed(0, 38) then -- E
                            TriggerServerEvent('tot_collectibles:collect', icon.id)
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)
