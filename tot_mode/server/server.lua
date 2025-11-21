
local playerModes = {}

RegisterNetEvent("tot_mode:setMode")
AddEventHandler("tot_mode:setMode", function(mode)
    local src = source
    playerModes[src] = mode
    TriggerClientEvent("tot_mode:applyMode", src, mode)
end)

AddEventHandler("playerDropped", function()
    local src = source
    playerModes[src] = nil
end)
