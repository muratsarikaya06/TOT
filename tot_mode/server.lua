local playerModes = {}

RegisterNetEvent('tot_mode:setMode', function(mode)
    local src = source
    playerModes[src] = mode
end)

AddEventHandler('playerDropped', function()
    playerModes[source] = nil
end)

RegisterNetEvent('tot_mode:requestMode', function()
    local src = source
    TriggerClientEvent('tot_mode:syncMode', src, playerModes[src])
end)
