local isUiOpen = false
local currentMode = "freeroam"

local stats = {
    money = 0,
    drift_total = 0,
    drift_daily = 0,
    drift_weekly = 0,
    xp = 0,
    level = 1,
    pvp_kills = 0,
    pvp_deaths = 0,
    avatar_url = nil
}

local collected = {}
local leaderboard = { all = {}, daily = {}, weekly = {} }

-- Drift HUD
local drifting = false
local driftScore = 0.0
local lastDriftTime = 0

-- =======================
-- UI AÇ/KAPAT
-- =======================
local function openUI()
    if isUiOpen then return end
    isUiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        mode   = currentMode,
        stats  = stats,
        lb     = leaderboard,
        collectibles = { list = Config.Collectibles, owned = collected }
    })
    TriggerServerEvent("tot_combined:requestLeaderboards")
end

local function closeUI()
    if not isUiOpen then return end
    isUiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

CreateThread(function()
    Wait(3000)
    TriggerServerEvent("tot_combined:requestInitData")
    -- ilk girişte menüyü aç
    openUI()
end)

-- F10 toggle (57)
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 57) then
            if isUiOpen then closeUI() else openUI() end
        end
    end
end)

-- =======================
-- NUI CALLBACKS
-- =======================
RegisterNUICallback("close", function(_, cb)
    closeUI()
    cb("ok")
end)

RegisterNUICallback("selectMode", function(data, cb)
    if data.mode and Config.Modes[data.mode] then
        TriggerServerEvent("tot_combined:setMode", data.mode)
    end
    cb("ok")
end)

RegisterNUICallback("setAvatar", function(data, cb)
    if data.url then
        TriggerServerEvent("tot_combined:setAvatarUrl", data.url)
    end
    cb("ok")
end)

-- =======================
-- SERVER EVENTLERİ
-- =======================
RegisterNetEvent("tot_combined:setCurrentMode", function(mode)
    currentMode = mode
    SendNUIMessage({ action = "setMode", mode = mode })
end)

RegisterNetEvent("tot_combined:updateStats", function(p)
    stats.money        = p.money or 0
    stats.drift_total  = p.drift_total or 0
    stats.drift_daily  = p.drift_daily or 0
    stats.drift_weekly = p.drift_weekly or 0
    stats.xp           = p.xp or 0
    stats.level        = p.level or 1
    stats.pvp_kills    = p.pvp_kills or 0
    stats.pvp_deaths   = p.pvp_deaths or 0
    stats.avatar_url   = p.avatar_url

    SendNUIMessage({
        action = "updateStats",
        stats = stats
    })
end)

RegisterNetEvent("tot_combined:setCollectibleState", function(state)
    collected = state or {}
    SendNUIMessage({
        action = "collectiblesUpdate",
        collectibles = { list = Config.Collectibles, owned = collected }
    })
end)

RegisterNetEvent("tot_combined:onCollectSuccess", function(id, p)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("~b~Gizli paket topladın!~s~\n+" ..
        Config.Rewards.CollectibleMoney .. "₺, +" .. Config.Rewards.CollectibleXP .. " XP")
    EndTextCommandThefeedPostTicker(false, false)
end)

RegisterNetEvent("tot_combined:spawnAtMode", function(coords)
    if not coords then return end
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z + 0.5, false, false, false, true)
end)

RegisterNetEvent("tot_combined:givePvpLoadout", function()
    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true)
    for _, w in ipairs(Config.PvPWeapons) do
        GiveWeaponToPed(ped, w.weapon, w.ammo or 250, false, false)
    end
end)

RegisterNetEvent("tot_combined:clearWeapons", function()
    RemoveAllPedWeapons(PlayerPedId(), true)
end)

RegisterNetEvent("tot_combined:leaderboardData", function(data)
    leaderboard = data or leaderboard
    SendNUIMessage({
        action = "leaderboardUpdate",
        lb     = leaderboard
    })
end)

-- =======================
-- DRIFT HESAPLAMA + HUD
-- =======================
CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false) then
            if drifting and driftScore >= Config.Drift.MinDriftScore then
                TriggerServerEvent("tot_combined:addDriftScore", math.floor(driftScore))
            end
            drifting = false
            driftScore = 0.0
        else
            local veh = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(veh, -1) ~= ped then goto continue end

            local speed = GetEntitySpeed(veh) * 3.6
            if speed < Config.Drift.MinSpeedKmh then
                if drifting and driftScore >= Config.Drift.MinDriftScore then
                    TriggerServerEvent("tot_combined:addDriftScore", math.floor(driftScore))
                end
                drifting = false
                driftScore = 0.0
            else
                local vx, vy, vz = table.unpack(GetEntityVelocity(veh))
                local speed2D = math.sqrt(vx * vx + vy * vy)
                if speed2D > 0.1 then
                    local fx, fy, fz = table.unpack(GetEntityForwardVector(veh))
                    local dot = (fx * vx + fy * vy) / (speed2D * math.sqrt(fx * fx + fy * fy))
                    dot = math.max(-1.0, math.min(1.0, dot))
                    local angle = math.deg(math.acos(dot))

                    if angle >= Config.Drift.MinAngleDeg then
                        drifting = true
                        driftScore = driftScore + (angle * speed * Config.Drift.ScoreMultiplier * GetFrameTime())
                        lastDriftTime = GetGameTimer()
                    else
                        if drifting and driftScore >= Config.Drift.MinDriftScore then
                            TriggerServerEvent("tot_combined:addDriftScore", math.floor(driftScore))
                        end
                        drifting = false
                        driftScore = 0.0
                    end
                end
            end
        end

        ::continue::
        -- Drift HUD (üst orta)
        local now = GetGameTimer()
        if drifting or (driftScore > 0 and now - lastDriftTime < Config.Drift.HudFadeTime) then
            local alpha = 255
            if not drifting then
                local t = (now - lastDriftTime) / Config.Drift.HudFadeTime
                alpha = math.floor(255 * (1.0 - math.min(t, 1.0)))
            end

            local scoreInt = math.floor(driftScore)
            local colorR, colorG, colorB = 75, 201, 255 -- TOT MAVİ
            if scoreInt > 5000 then
                colorR, colorG, colorB = 255, 160, 80
            elseif scoreInt > 2000 then
                colorR, colorG, colorB = 140, 220, 120
            end

            SetTextFont(4)
            SetTextScale(0.6, 0.6)
            SetTextColour(colorR, colorG, colorB, alpha)
            SetTextOutline()
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(("DRIFT: ~w~%d"):format(scoreInt))
            EndTextCommandDisplayText(0.5, 0.15)
        end
    end
end)

-- =======================
-- KOLEKSİYON DÜNYADA
-- =======================
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        for _, c in ipairs(Config.Collectibles) do
            if not collected[c.id] then
                local dist = #(pCoords - c.coords)
                if dist < Config.CollectibleMarker.DrawDistance then
                    DrawMarker(1, c.coords.x, c.coords.y, c.coords.z-1.0,
                        0.0,0.0,0.0, 0.0,0.0,0.0,
                        1.0,1.0,1.0, 0,150,255,150, false,true,2,false,nil,nil,false)
                    if dist < Config.CollectibleMarker.Radius then
                        SetTextScale(0.35, 0.35)
                        SetTextFont(4)
                        SetTextProportional(1)
                        SetTextColour(255,255,255,215)
                        SetTextCentre(true)
                        BeginTextCommandDisplayText("STRING")
                        AddTextComponentSubstringPlayerName("~b~[E]~s~ "..c.label)
                        EndTextCommandDisplayText(c.coords.x, c.coords.y, c.coords.z+0.9)

                        if IsControlJustPressed(0, 38) then -- E
                            TriggerServerEvent("tot_combined:collect", c.id)
                        end
                    end
                end
            end
        end
    end
end)
