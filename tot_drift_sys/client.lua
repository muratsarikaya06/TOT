local panelOpen   = false
local currentMode = "all"

local currentMoney = 0
local lastSummary  = nil

local driftActive       = false
local currentDrift      = 0.0
local bestDrift         = 0.0
local totalDriftScore   = 0
local chainExpiryTime   = 0
local comboMul          = 1.0
local comboStartTime    = 0
local lastCrashTime     = 0

local lastScoreForAnim  = 0
local scoreAnimUntil    = 0

local finishedScore     = 0
local finishedCombo     = 1.0
local finishedAnimStart = 0
local finishedAnimDur   = 1200

local function togglePanel()
    panelOpen = not panelOpen

    SetNuiFocus(panelOpen, panelOpen)

    SendNUIMessage({
        action = "panel",
        show   = panelOpen
    })

    if panelOpen then
        TriggerServerEvent('tot_drift:requestScoresMode', currentMode)

        TriggerServerEvent('tot_money:requestBalance')
        SendNUIMessage({
            action = "updateMoney",
            money  = currentMoney
        })

        if lastSummary then
            SendNUIMessage({
                action  = "updatePlayerSummary",
                summary = lastSummary
            })
        end
        TriggerServerEvent('tot_drift:requestPlayerSummary')
    end
end

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 57) then
            togglePanel()
        end
    end
end)

RegisterCommand('drift', function()
    togglePanel()
end, false)

RegisterNUICallback("close", function(data, cb)
    panelOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = "panel",
        show   = false
    })

    cb("ok")
end)

RegisterNUICallback("changeMode", function(data, cb)
    local mode = (data and data.mode) or "all"
    currentMode = mode
    TriggerServerEvent('tot_drift:requestScoresMode', currentMode)
    cb("ok")
end)

RegisterNetEvent("tot_drift:updateScoreboard", function(scores)
    SendNUIMessage({
        action = "updateScores",
        scores = scores
    })
end)

RegisterNetEvent("tot_drift:updatePlayerSummary", function(summary)
    lastSummary = summary or lastSummary

    if panelOpen then
        SendNUIMessage({
            action  = "updatePlayerSummary",
            summary = lastSummary
        })
    end
end)

RegisterNetEvent('tot_money:updateBalance', function(balance)
    currentMoney = balance or 0

    if panelOpen then
        SendNUIMessage({
            action = "updateMoney",
            money  = currentMoney
        })
    end
end)

CreateThread(function()
    local refreshMs = Config.ScoreboardRefreshMs or 3000
    while true do
        Wait(refreshMs)
        if panelOpen then
            TriggerServerEvent('tot_drift:requestScoresMode', currentMode)
        end
    end
end)

local function speedKmh(veh)
    return GetEntitySpeed(veh) * 3.6
end

local function driftAngleDeg(veh)
    local vel = GetEntityVelocity(veh)
    local fwd = GetEntityForwardVector(veh)

    local vX, vY = vel.x, vel.y
    local fX, fY = fwd.x, fY

    local magV = math.sqrt(vX * vX + vY * vY)
    local magF = math.sqrt(fX * fX + fY * fY)

    if magV < 1.0 or magF < 0.1 then
        return 0.0
    end

    local dot = vX * fX + vY * fY
    local cosA = dot / (magV * magF)
    cosA = math.max(-1.0, math.min(1.0, cosA))

    return math.deg(math.acos(cosA))
end

local function sendDriftToServer(score)
    TriggerServerEvent("tot_drift:addScore", math.floor(score))
end

CreateThread(function()
    while true do
        local sleep = 250

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(veh, -1) == ped then
                sleep = 0

                local kmh   = speedKmh(veh)
                local angle = driftAngleDeg(veh)
                local now   = GetGameTimer()

                local sideways = (kmh >= (Config.MinSpeedKmh or 25)
                    and angle >= (Config.MinAngleDeg or 10)
                    and angle <= (Config.MaxAngleDeg or 80))

                local crashed = false
                if driftActive then
                    if HasEntityCollidedWithAnything(veh) and kmh > 15.0 then
                        if now - lastCrashTime > 1000 then
                            crashed = true
                            lastCrashTime = now
                        end
                    end
                end

                if crashed then
                    driftActive       = false
                    currentDrift      = 0.0
                    comboMul          = 1.0
                    comboStartTime    = 0
                    chainExpiryTime   = 0
                    lastScoreForAnim  = 0
                    scoreAnimUntil    = 0

                    BeginTextCommandThefeedPost("STRING")
                    AddTextComponentSubstringPlayerName("~r~Kaza!~s~ Drift zinciri iptal edildi.")
                    EndTextCommandThefeedPostTicker(false, false)

                else
                    if sideways then
                        if not driftActive then
                            driftActive     = true
                            currentDrift    = 0.0
                            comboMul        = 1.0
                            comboStartTime  = now
                        end

                        chainExpiryTime = now + (Config.ChainTimeoutMs or 3500)

                        if comboStartTime == 0 then
                            comboStartTime = now
                        end

                        local elapsed = now - comboStartTime
                        local steps   = math.floor(elapsed / (Config.ComboStepTimeMs or 2500))
                        comboMul = 1.0 + steps * (Config.ComboStepInc or 0.25)
                        if comboMul > (Config.ComboMaxMul or 4.0) then
                            comboMul = Config.ComboMaxMul or 4.0
                        end

                        local baseMul = Config.ScoreMultiplierBase or 0.06
                        local gain = angle * (kmh / 10.0) * baseMul * comboMul
                        currentDrift = currentDrift + gain

                        if Config.ShowBestScore and currentDrift > bestDrift then
                            bestDrift = currentDrift
                        end
                    else
                        if driftActive then
                            if now > chainExpiryTime then
                                driftActive = false

                                if currentDrift >= (Config.MinDriftChainScore or 100) then
                                    local gained = math.floor(currentDrift)
                                    totalDriftScore = totalDriftScore + gained

                                    finishedScore     = gained
                                    finishedCombo     = comboMul
                                    finishedAnimStart = now

                                    sendDriftToServer(gained)

                                    BeginTextCommandThefeedPost("STRING")
                                    AddTextComponentSubstringPlayerName("~y~Drift Zinciri Bitti!~s~ Kazandığın puan: ~b~" .. gained)
                                    EndTextCommandThefeedPostTicker(false, false)
                                end

                                currentDrift     = 0.0
                                comboMul         = 1.0
                                comboStartTime   = 0
                                chainExpiryTime  = 0
                                lastScoreForAnim = 0
                                scoreAnimUntil   = 0
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        local now   = GetGameTimer()

        local showLive = false
        if driftActive then
            showLive = true
        else
            if chainExpiryTime > 0 and now <= chainExpiryTime then
                showLive = true
            end
        end

        local showFinished = false
        local finishedT = 0.0
        if finishedAnimStart > 0 then
            local elapsed = now - finishedAnimStart
            if elapsed >= 0 and elapsed <= finishedAnimDur then
                showFinished = true
                finishedT = elapsed / finishedAnimDur
            else
                finishedAnimStart = 0
            end
        end

        if showLive or showFinished then
            sleep = 0

            local baseX = 0.50
            local baseY = 0.05

            if showLive then
                local driftDisplay = math.floor(currentDrift)
                local comboDisplay = comboMul

                if driftDisplay > lastScoreForAnim then
                    lastScoreForAnim = driftDisplay
                    scoreAnimUntil   = now + 300
                end

                local baseScale   = 0.70
                local extraScale  = 0.0
                if now < scoreAnimUntil then
                    local t = (scoreAnimUntil - now) / 300.0
                    if t < 0 then t = 0 end
                    extraScale = 0.18 * math.sqrt(t)
                end
                local scoreScale = baseScale + extraScale

                SetTextFont(4)
                SetTextScale(scoreScale, scoreScale)
                SetTextColour(255, 230, 80, 255)
                SetTextCentre(true)
                SetTextOutline()
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(driftDisplay .. " pts")
                EndTextCommandDisplayText(baseX, baseY)

                local r, g, b = 120, 255, 120
                if comboDisplay >= 1.5 and comboDisplay < 2.5 then
                    r, g, b = 235, 220, 80
                elseif comboDisplay >= 2.5 and comboDisplay < 3.5 then
                    r, g, b = 255, 170, 60
                elseif comboDisplay >= 3.5 then
                    r, g, b = 255, 80, 80
                end

                SetTextFont(0)
                SetTextScale(0.45, 0.45)
                SetTextColour(r, g, b, 255)
                SetTextCentre(true)
                SetTextOutline()
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(("Çarpan: x%.2f"):format(comboDisplay))
                EndTextCommandDisplayText(baseX, baseY + 0.04)
            end

            if showFinished then
                local score  = math.floor(finishedScore)
                local combo  = finishedCombo

                local offsetY = finishedT * 0.04
                local alpha   = math.floor(255 * (1.0 - finishedT))
                if alpha < 0 then alpha = 0 end

                SetTextFont(4)
                SetTextScale(0.65, 0.65)
                SetTextColour(255, 230, 80, alpha)
                SetTextCentre(true)
                SetTextOutline()
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(score .. " pts")
                EndTextCommandDisplayText(baseX, baseY - 0.005 - offsetY)

                SetTextFont(0)
                SetTextScale(0.42, 0.42)
                SetTextColour(200, 255, 200, alpha)
                SetTextCentre(true)
                SetTextOutline()
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(("x%.2f combo"):format(combo))
                EndTextCommandDisplayText(baseX, baseY + 0.03 - offsetY)
            end
        end

        Wait(sleep)
    end
end)
