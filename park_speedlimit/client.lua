--[[
    park_speedlimit - Otopark / Etkinlik Alanı Hız Limiti Scripti
    - Poligon (çokgen) alan tanımlama
    - Alan içine girince hız limiti (km/s)
    - /zstart /zadd /zfinish ile alan çizme
]]

-------------------------------
--  AYARLAR
-------------------------------

local SpeedLimitKmh = 20.0

-- Tanımlı poligon bölgeler
local PolyZones = {
    {
        name = '1',
        minZ = 102.60,
        maxZ = 103.68,
        points = {
            vector2(478.71, 258.84),
            vector2(432.15, 276.35),
            vector2(413.90, 226.30),
            vector2(468.92, 209.89),
        }
    },

    {
        name = '2',
        minZ = 128.41,
        maxZ = 129.55,
        points = {
            vector2(725.76, 634.82),
            vector2(733.87, 658.30),
            vector2(653.09, 687.51),
            vector2(644.92, 664.78),
        }
    },

    { name = '3', minZ = 128.41, maxZ = 129.41, points = {
    vector2(668.76, 633.70),
    vector2(628.68, 648.09),
    vector2(625.37, 659.31),
    vector2(600.53, 652.11),
    vector2(583.77, 605.51),
    vector2(648.64, 581.98),
} },

{ name = '4', minZ = 20.85, maxZ = 48.47, points = {
    vector2(-1233.37, -612.82),
    vector2(-1233.37, -612.82),
    vector2(-1265.44, -638.19),
    vector2(-1265.43, -638.19),
    vector2(-1196.66, -719.87),
    vector2(-1196.65, -719.91),
    vector2(-1164.35, -695.90),
    vector2(-1164.35, -695.90),
} },

{ name = '5', minZ = 30.96, maxZ = 31.98, points = {
    vector2(-43.03, 6508.66),
    vector2(-48.85, 6514.01),
    vector2(-45.46, 6517.40),
    vector2(-70.15, 6542.28),
    vector2(-79.39, 6533.11),
    vector2(-96.04, 6549.77),
    vector2(-91.88, 6553.64),
    vector2(-93.71, 6555.42),
    vector2(-74.42, 6572.37),
    vector2(-67.46, 6565.17),
    vector2(-64.04, 6568.45),
    vector2(-22.82, 6526.88),
} },

{ name = '6', minZ = 31.15, maxZ = 32.15, points = {
    vector2(-11.65, 6304.23),
    vector2(-25.77, 6322.44),
    vector2(2.06, 6349.53),
    vector2(29.30, 6378.22),
    vector2(87.76, 6434.91),
    vector2(133.24, 6382.08),
    vector2(115.96, 6377.66),
    vector2(69.54, 6355.51),
    vector2(56.98, 6341.69),
} },

{ name = '7', minZ = 14.05, maxZ = 15.10, points = {
    vector2(-785.82, -2468.85),
    vector2(-736.80, -2392.41),
    vector2(-813.44, -2316.54),
    vector2(-821.12, -2330.77),
    vector2(-839.42, -2319.94),
    vector2(-836.00, -2395.77),
    vector2(-821.30, -2423.43),
    vector2(-804.82, -2460.96),
} },

{ name = '8', minZ = 5.66, maxZ = 7.04, points = {
    vector2(-881.25, -2248.47),
    vector2(-885.77, -2256.21),
    vector2(-904.36, -2244.72),
    vector2(-947.67, -2320.67),
    vector2(-900.00, -2348.44),
    vector2(-867.88, -2293.29),
    vector2(-836.03, -2311.86),
    vector2(-833.25, -2306.49),
    vector2(-854.03, -2286.62),
    vector2(-855.45, -2283.64),
    vector2(-856.03, -2280.24),
    vector2(-855.58, -2277.58),
    vector2(-854.20, -2275.57),
} },

{ name = '9', minZ = 5.57, maxZ = 6.57, points = {
    vector2(-524.98, -2136.27),
    vector2(-598.47, -2057.78),
    vector2(-592.88, -2055.22),
    vector2(-607.22, -2040.32),
    vector2(-609.93, -2046.01),
    vector2(-618.22, -2055.96),
    vector2(-654.79, -2087.75),
    vector2(-668.17, -2087.38),
    vector2(-697.19, -2092.89),
    vector2(-769.89, -2179.25),
    vector2(-764.95, -2177.42),
    vector2(-752.20, -2176.21),
    vector2(-740.98, -2178.20),
    vector2(-732.51, -2183.71),
    vector2(-709.42, -2203.63),
    vector2(-700.87, -2206.61),
    vector2(-695.02, -2206.49),
    vector2(-684.05, -2201.28),
    vector2(-674.09, -2200.71),
    vector2(-664.04, -2206.60),
    vector2(-640.29, -2225.47),
    vector2(-613.86, -2251.47),
    vector2(-599.29, -2234.34),
    vector2(-601.06, -2226.86),
} },

{ name = '10', minZ = 13.33, maxZ = 14.44, points = {
    vector2(-649.98, -2331.40),
    vector2(-641.33, -2338.81),
    vector2(-638.05, -2337.18),
    vector2(-591.59, -2377.76),
    vector2(-558.91, -2339.04),
    vector2(-614.07, -2290.46),
} },

{ name = '11', minZ = 25.56, maxZ = 26.77, points = {
    vector2(817.04, -1324.81),
    vector2(816.33, -1373.26),
    vector2(855.18, -1373.99),
    vector2(841.16, -1400.11),
    vector2(827.58, -1400.65),
    vector2(827.44, -1417.85),
    vector2(849.46, -1415.55),
    vector2(868.90, -1379.15),
    vector2(864.00, -1372.38),
    vector2(862.54, -1362.25),
    vector2(862.09, -1334.40),
    vector2(851.22, -1321.31),
    vector2(844.58, -1314.36),
    vector2(817.20, -1316.74),
} },

{ name = '12', minZ = 57.43, maxZ = 58.73, points = {
    vector2(1043.84, -765.97),
    vector2(1051.00, -768.66),
    vector2(1050.90, -796.46),
    vector2(1030.69, -796.03),
    vector2(1005.37, -764.59),
    vector2(1022.11, -750.32),
    vector2(1035.67, -761.50),
} },
}

-------------------------------
--  YARDIMCI FONKSİYONLAR
-------------------------------

local function notify(msg)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, true)
end

local function isPointInPolygon(point, polygon)
    local x, y = point.x, point.y
    local inside = false
    local j = #polygon

    for i = 1, #polygon do
        local xi, yi = polygon[i].x, polygon[i].y
        local xj, yj = polygon[j].x, polygon[j].y

        local denom = (yj - yi)
        if denom == 0.0 then denom = 0.000001 end

        local intersects = ((yi > y) ~= (yj > y))
            and (x < (xj - xi) * (y - yi) / denom + xi)

        if intersects then
            inside = not inside
        end

        j = i
    end

    return inside
end

local function isInPolyZone(coords)
    local p2 = vector2(coords.x, coords.y)

    for _, zone in ipairs(PolyZones) do
        if coords.z >= (zone.minZ - 2.0) and coords.z <= (zone.maxZ + 2.0) then
            if isPointInPolygon(p2, zone.points) then
                return true, zone
            end
        end
    end

    return false, nil
end

-------------------------------
--  ANA HIZ LİMİT LOOP'U
-------------------------------

Citizen.CreateThread(function()
    local limited = false
    local currentZoneName = nil

    while true do
        local sleep = 500
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(veh, -1) == ped then
                sleep = 150

                local coords = GetEntityCoords(veh)
                local inZone, zone = isInPolyZone(coords)

                if inZone then
                    local maxSpeed = SpeedLimitKmh / 3.6
                    SetEntityMaxSpeed(veh, maxSpeed)

                    if not limited then
                        limited = true
                        currentZoneName = zone.name
                        notify(("~y~%s alanındasın. Hız limiti: ~g~%d km/s"):format(zone.name, SpeedLimitKmh))
                    end
                else
                    if limited then
                        limited = false
                        notify("~g~Etkinlik alanından çıktın, hız limiti kaldırıldı.")
                    end

                    SetEntityMaxSpeed(veh, 1000.0)
                    currentZoneName = nil
                end
            end
        else
            if limited then
                limited = false
                currentZoneName = nil
            end
        end

        Wait(sleep)
    end
end)

-------------------------------
--  ZONE ÇİZİCİ KOMUTLARI
-------------------------------

local currentZoneDraft = nil

RegisterCommand("zstart", function(source, args)
    if currentZoneDraft then
        notify("~r~Zaten açık bir çizim var. /zfinish ile bitir.")
        return
    end

    local name = args[1] or ("zone_" .. math.random(1000, 9999))
    currentZoneDraft = {
        name = name,
        points = {},
        minZ = nil,
        maxZ = nil
    }

    notify("~g~Zone çizimi başladı: ~y~" .. name .. "~s~. Her köşede /zadd yaz.")
end, false)

RegisterCommand("zadd", function()
    if not currentZoneDraft then
        notify("~r~Önce /zstart yazmalısın.")
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    table.insert(currentZoneDraft.points, vector2(coords.x, coords.y))

    if not currentZoneDraft.minZ or coords.z < currentZoneDraft.minZ then
        currentZoneDraft.minZ = coords.z
    end
    if not currentZoneDraft.maxZ or coords.z > currentZoneDraft.maxZ then
        currentZoneDraft.maxZ = coords.z
    end

    notify(("~g~Nokta eklendi. Toplam: ~y~%d"):format(#currentZoneDraft.points))
end, false)

RegisterCommand("zfinish", function()
    if not currentZoneDraft then
        notify("~r~Çizim yok. /zstart ile başlat.")
        return
    end

    if #currentZoneDraft.points < 3 then
        notify("~r~En az 3 nokta eklemelisin.")
        return
    end

    local zMin = (currentZoneDraft.minZ or 0.0) - 0.5
    local zMax = (currentZoneDraft.maxZ or 0.0) + 0.5

    print("\n---------------- POLYZONE LUA KODU ----------------")
    print(("{ name = '%s', minZ = %.2f, maxZ = %.2f, points = {"):format(
        currentZoneDraft.name, zMin, zMax
    ))

    for _, p in ipairs(currentZoneDraft.points) do
        print(("    vector2(%.2f, %.2f),"):format(p.x, p.y))
    end

    print("} },")
    print("-------------- BUNU PolyZones TABLOSUNA YAPIŞTIR --------------\n")

    notify("~g~Zone tamamlandı! F8'den kodu kopyala.")
    currentZoneDraft = nil
end, false)

-------------------------------
--  /pos KOMUTU
-------------------------------

RegisterCommand("pos", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    print(("\nPOS -> vector3(%.2f, %.2f, %.2f) heading: %.2f\n"):format(
        coords.x, coords.y, coords.z, heading
    ))
    notify("~g~Koordinatlar F8'e yazıldı.")
end, false)
