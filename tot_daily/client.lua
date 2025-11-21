local dailyTasks = {}
local dailyDate  = nil

-- Sunucudan görevler geldiğinde
RegisterNetEvent('tot_daily:updateTasks', function(tasks, date)
    dailyTasks = tasks or {}
    dailyDate  = date

    -- F10 menü NUI'ye gönder
    SendNUIMessage({
        action = 'tot_daily_update',
        date   = dailyDate,
        tasks  = dailyTasks
    })
end)

-- Sunucuya görevleri iste
CreateThread(function()
    Wait(5000)
    TriggerServerEvent('tot_daily:requestTasks')
end)

-- Debug için chat komutu (istersen kalsın)
RegisterCommand('gorev', function()
    if not dailyDate or not next(dailyTasks) then
        TriggerEvent('chat:addMessage', { args = { '^3GÜNLÜK GÖREVLER', 'Şu an görev bilgisi yok. Birkaç saniye sonra tekrar dene.' } })
        TriggerServerEvent('tot_daily:requestTasks')
        return
    end

    TriggerEvent('chat:addMessage', {
        args = { '^3GÜNLÜK GÖREVLER (' .. dailyDate .. ')', 'Bugünkü görevlerin:' }
    })

    for _, t in pairs(dailyTasks) do
        local status = t.completed and '^2Tamamlandı' or ('^7' .. t.progress .. '/' .. t.target)
        TriggerEvent('chat:addMessage', {
            args = { ' - ' .. t.label, status }
        })
    end
end, false)

-- TOT menü açıldığında NUI tekrar beslensin diye dışarı export
exports('ForceDailyRefresh', function()
    TriggerServerEvent('tot_daily:requestTasks')
end)
