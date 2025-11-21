local function getIdentifier(src)
    for i=0, GetNumPlayerIdentifiers(src)-1 do
        local id = GetPlayerIdentifier(src, i)
        if id and id:find("license:") then return id end
    end
    return "player:"..src
end

local function ensureMoneyRow(src, cb)
    local identifier = getIdentifier(src)

    MySQL.single('SELECT balance FROM tot_money WHERE identifier=?',{identifier}, function(row)
        if not row then
            MySQL.insert('INSERT INTO tot_money (identifier,balance) VALUES (?,?)',
                {identifier, Config.StartingMoney or 0})
            if cb then cb(Config.StartingMoney or 0) end
        else
            if cb then cb(row.balance) end
        end
    end)
end

local function setMoney(identifier, amount)
    amount = math.max(0, math.floor(amount))
    MySQL.update('UPDATE tot_money SET balance=? WHERE identifier=?',{amount,identifier})
end

local function addMoneyByIdentifier(identifier, amount, cb)
    MySQL.single('SELECT balance FROM tot_money WHERE identifier=?',{identifier}, function(row)
        if not row then
            local new = (Config.StartingMoney or 0) + amount
            MySQL.insert('INSERT INTO tot_money (identifier,balance) VALUES (?,?)',{identifier,new})
            if cb then cb(new) end
        else
            local new = math.max(0, row.balance + amount)
            setMoney(identifier,new)
            if cb then cb(new) end
        end
    end)
end

RegisterNetEvent("tot_money:requestBalance", function()
    local src=source
    ensureMoneyRow(src,function(balance)
        TriggerClientEvent("tot_money:updateBalance",src,balance)
    end)
end)

RegisterNetEvent("tot_money:add", function(amount)
    local src=source
    local identifier=getIdentifier(src)
    addMoneyByIdentifier(identifier,amount,function(new)
        TriggerClientEvent("tot_money:updateBalance",src,new)
    end)
end)

exports("AddMoneyIdentifier",function(identifier,amount)
    addMoneyByIdentifier(identifier,amount)
end)

exports("GetMoneyIdentifier",function(identifier,cb)
    MySQL.single('SELECT balance FROM tot_money WHERE identifier=?',{identifier},
        function(row) cb(row and row.balance or 0) end)
end)

AddEventHandler("playerConnecting",function() ensureMoneyRow(source) end)
AddEventHandler("playerJoining",function() ensureMoneyRow(source) end)

if Config.AutoPayEnabled then
    CreateThread(function()
        while true do
            Wait(Config.AutoPayInterval)
            for _,pid in ipairs(GetPlayers()) do
                local s=tonumber(pid)
                local identifier=getIdentifier(s)
                addMoneyByIdentifier(identifier,Config.AutoPayAmount,function(new)
                    TriggerClientEvent("tot_money:updateBalance",s,new)
                end)
            end
        end
    end)
end
