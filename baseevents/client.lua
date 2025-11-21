local wasDead = false

CreateThread(function()
    while true do
        Wait(200)

        local ped = PlayerPedId()
        local isDead = IsEntityDead(ped)

        if isDead and not wasDead then
            -- Oyuncu yeni öldü
            local playerId   = PlayerId()
            local serverId   = GetPlayerServerId(playerId)
            local killerPed  = GetPedSourceOfDeath(ped)
            local killerId   = NetworkGetPlayerIndexFromPed(killerPed)
            local weaponHash = GetPedCauseOfDeath(ped)

            if killerId ~= -1 and killerId ~= playerId then
                -- Beni başka bir oyuncu öldürdü
                local killerServerId = GetPlayerServerId(killerId)
                TriggerServerEvent("baseevents:onPlayerKilled", serverId, killerServerId, weaponHash)
            else
                -- Düştüm, AI öldürdü, intihar vb.
                TriggerServerEvent("baseevents:onPlayerDied", serverId, weaponHash)
            end
        end

        wasDead = isDead
    end
end)
