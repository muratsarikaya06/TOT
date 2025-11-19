local currentMoney = 0

RegisterNetEvent("tot_money:updateBalance", function(balance)
    currentMoney = balance or 0
end)

RegisterCommand("para", function()
    TriggerServerEvent("tot_money:requestBalance")
    Wait(300)
    TriggerEvent("chat:addMessage", {args={"KASA","Bakiyen: "..currentMoney.." ₺"}})
end)

AddEventHandler("playerSpawned", function()
    TriggerServerEvent("tot_money:requestBalance")
end)

CreateThread(function()
    Wait(3000)
    TriggerServerEvent("tot_money:requestBalance")
end)
