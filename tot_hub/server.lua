local playerModes = {}

RegisterNetEvent("tot_hub:modeChanged", function(mode)
    local src = source
    playerModes[src] = mode
    print(("[TOT_HUB] %s set mode to %s"):format(src, tostring(mode)))
end)

AddEventHandler("playerDropped", function()
    local src = source
    playerModes[src] = nil
end)

-- Export for other resources (drift, economy, etc.)
exports("GetPlayerMode", function(source)
    return playerModes[source]
end)
