Config = {}

-- Görünüm ayarları
Config.DrawDistance      = 80.0      -- kaç metreden görünsün
Config.IconHeight        = 0.8       -- yerden yüksekliği
Config.IconBobAmplitude  = 0.25      -- yukarı-aşağı salınım
Config.IconBobSpeed      = 1.5       -- salınım hızı
Config.RotationSpeed     = 40.0      -- derece/saniye
Config.Show3DText        = true

-- Ödül sistemi
Config.RewardMoney       = 5000      -- her paket için verilecek para
Config.RewardXP          = 0         -- ileride kullanılabilir

-- TOT ekonomi sistemine bağlama
-- true: Config.TotEconomyEvent event'i tetiklenir (server side)
-- false: sadece chat mesajı atar, para vermez (örnek davranış)
Config.UseTotEconomy     = true
Config.TotEconomyEvent   = 'tot_economy:addMoney' -- kendi ekonomi event'in (src, amount)

Config.DebugPrint        = false

-- Belirli saatlerde aktif olma sistemi
-- Eğer bir collectible içinde activeHours varsa:
-- activeHours = { start = 18, finish = 23 }  --> 18:00 - 23:00 arası aktif
-- activeHours = { start = 22, finish = 4 }   --> 22:00 - 04:00 (gece, wrap'lı)
-- Saat kontrolü oyun içi saati (GetClockHours) kullanır.
--
-- activeHours yoksa: her zaman aktif.

Config.Collectibles = {
    -- ÖRNEK: bazılarında saat kısıtı var, bazılarında yok
    { id = 1,  coords = vector3(-75.21,  -818.34, 326.17), label = "Gizli TOT Paketi #1",  color = {r=255,g=180,b=0},   scale = 1.1, activeHours = { start = 18, finish = 23 } },
    { id = 2,  coords = vector3(-425.34, 1123.12, 325.85), label = "Gizli TOT Paketi #2",  color = {r=0,g=200,b=255},   scale = 1.0, activeHours = { start = 22, finish = 4 } },
    { id = 3,  coords = vector3(215.44,  -810.21, 30.72),  label = "Gizli TOT Paketi #3",  color = {r=120,g=255,b=120}, scale = 1.0 },
    { id = 4,  coords = vector3(-1034.2, -2732.3, 20.1),   label = "Gizli TOT Paketi #4",  color = {r=255,g=100,b=160}, scale = 1.0 },
    { id = 5,  coords = vector3(1234.5,  -1300.2, 35.0),   label = "Gizli TOT Paketi #5",  color = {r=255,g=255,b=120}, scale = 1.0 },

    { id = 6,  coords = vector3(950.3,   50.1,   80.0),    label = "Gizli TOT Paketi #6",  color = {r=200,g=255,b=200}, scale = 1.0 },
    { id = 7,  coords = vector3(-500.1,  250.4,  40.0),    label = "Gizli TOT Paketi #7",  color = {r=255,g=200,b=120}, scale = 1.0 },
    { id = 8,  coords = vector3(-1500.0, 450.0,  60.0),    label = "Gizli TOT Paketi #8",  color = {r=0,g=180,b=255},   scale = 1.0 },
    { id = 9,  coords = vector3(300.0,   1200.0, 45.0),    label = "Gizli TOT Paketi #9",  color = {r=255,g=120,b=220}, scale = 1.0 },
    { id = 10, coords = vector3(600.0,   1400.0, 35.0),    label = "Gizli TOT Paketi #10", color = {r=140,g=255,b=140}, scale = 1.0 },

    { id = 11, coords = vector3(-200.0,  1600.0, 35.0),   label = "Gizli TOT Paketi #11", color = {r=255,g=180,b=0},   scale = 1.0 },
    { id = 12, coords = vector3(-600.0,  1700.0, 40.0),   label = "Gizli TOT Paketi #12", color = {r=0,g=200,b=255},   scale = 1.0 },
    { id = 13, coords = vector3(800.0,   1700.0, 45.0),   label = "Gizli TOT Paketi #13", color = {r=120,g=255,b=120}, scale = 1.0 },
    { id = 14, coords = vector3(1000.0,  1900.0, 50.0),   label = "Gizli TOT Paketi #14", color = {r=255,g=100,b=160}, scale = 1.0 },
    { id = 15, coords = vector3(1200.0,  2100.0, 55.0),   label = "Gizli TOT Paketi #15", color = {r=255,g=255,b=120}, scale = 1.0 },

    { id = 16, coords = vector3(-800.0,  2000.0, 55.0),   label = "Gizli TOT Paketi #16", color = {r=200,g=255,b=200}, scale = 1.0 },
    { id = 17, coords = vector3(-1000.0, 2100.0, 60.0),   label = "Gizli TOT Paketi #17", color = {r=255,g=200,b=120}, scale = 1.0 },
    { id = 18, coords = vector3(1400.0,  2300.0, 65.0),   label = "Gizli TOT Paketi #18", color = {r=0,g=180,b=255},   scale = 1.0 },
    { id = 19, coords = vector3(1600.0,  2400.0, 70.0),   label = "Gizli TOT Paketi #19", color = {r=255,g=120,b=220}, scale = 1.0 },
    { id = 20, coords = vector3(1800.0,  2600.0, 75.0),   label = "Gizli TOT Paketi #20", color = {r=140,g=255,b=140}, scale = 1.0 },

    { id = 21, coords = vector3(-1200.0, 2300.0, 60.0),   label = "Gizli TOT Paketi #21", color = {r=255,g=180,b=0},   scale = 1.0 },
    { id = 22, coords = vector3(-1400.0, 2500.0, 65.0),   label = "Gizli TOT Paketi #22", color = {r=0,g=200,b=255},   scale = 1.0 },
    { id = 23, coords = vector3(-1600.0, 2700.0, 70.0),   label = "Gizli TOT Paketi #23", color = {r=120,g=255,b=120}, scale = 1.0 },
    { id = 24, coords = vector3(2000.0,  2800.0, 80.0),   label = "Gizli TOT Paketi #24", color = {r=255,g=100,b=160}, scale = 1.0 },
    { id = 25, coords = vector3(2200.0,  3000.0, 85.0),   label = "Gizli TOT Paketi #25", color = {r=255,g=255,b=120}, scale = 1.0 },

    { id = 26, coords = vector3(-1800.0, 2900.0, 75.0),   label = "Gizli TOT Paketi #26", color = {r=200,g=255,b=200}, scale = 1.0 },
    { id = 27, coords = vector3(-2000.0, 3100.0, 80.0),   label = "Gizli TOT Paketi #27", color = {r=255,g=200,b=120}, scale = 1.0 },
    { id = 28, coords = vector3(-2200.0, 3300.0, 85.0),   label = "Gizli TOT Paketi #28", color = {r=0,g=180,b=255},   scale = 1.0 },
    { id = 29, coords = vector3(-2400.0, 3500.0, 90.0),   label = "Gizli TOT Paketi #29", color = {r=255,g=120,b=220}, scale = 1.0 },
    { id = 30, coords = vector3(-2600.0, 3700.0, 95.0),   label = "Gizli TOT Paketi #30", color = {r=140,g=255,b=140}, scale = 1.0 },

    { id = 31, coords = vector3(300.0,   -300.0,  40.0),  label = "Gizli TOT Paketi #31", color = {r=255,g=180,b=0},   scale = 1.0 },
    { id = 32, coords = vector3(500.0,   -500.0,  45.0),  label = "Gizli TOT Paketi #32", color = {r=0,g=200,b=255},   scale = 1.0 },
    { id = 33, coords = vector3(700.0,   -700.0,  50.0),  label = "Gizli TOT Paketi #33", color = {r=120,g=255,b=120}, scale = 1.0 },
    { id = 34, coords = vector3(900.0,   -900.0,  55.0),  label = "Gizli TOT Paketi #34", color = {r=255,g=100,b=160}, scale = 1.0 },
    { id = 35, coords = vector3(1100.0, -1100.0,  60.0),  label = "Gizli TOT Paketi #35", color = {r=255,g=255,b=120}, scale = 1.0 },

    { id = 36, coords = vector3(-300.0,  -300.0,  40.0),  label = "Gizli TOT Paketi #36", color = {r=200,g=255,b=200}, scale = 1.0 },
    { id = 37, coords = vector3(-500.0,  -500.0,  45.0),  label = "Gizli TOT Paketi #37", color = {r=255,g=200,b=120}, scale = 1.0 },
    { id = 38, coords = vector3(-700.0,  -700.0,  50.0),  label = "Gizli TOT Paketi #38", color = {r=0,g=180,b=255},   scale = 1.0 },
    { id = 39, coords = vector3(-900.0,  -900.0,  55.0),  label = "Gizli TOT Paketi #39", color = {r=255,g=120,b=220}, scale = 1.0 },
    { id = 40, coords = vector3(-1100.0, -1100.0, 60.0),  label = "Gizli TOT Paketi #40", color = {r=140,g=255,b=140}, scale = 1.0 },

    { id = 41, coords = vector3(1300.0, -1300.0, 65.0),   label = "Gizli TOT Paketi #41", color = {r=255,g=180,b=0},   scale = 1.0 },
    { id = 42, coords = vector3(1500.0, -1500.0, 70.0),   label = "Gizli TOT Paketi #42", color = {r=0,g=200,b=255},   scale = 1.0 },
    { id = 43, coords = vector3(1700.0, -1700.0, 75.0),   label = "Gizli TOT Paketi #43", color = {r=120,g=255,b=120}, scale = 1.0 },
    { id = 44, coords = vector3(1900.0, -1900.0, 80.0),   label = "Gizli TOT Paketi #44", color = {r=255,g=100,b=160}, scale = 1.0 },
    { id = 45, coords = vector3(2100.0, -2100.0, 85.0),   label = "Gizli TOT Paketi #45", color = {r=255,g=255,b=120}, scale = 1.0 },

    { id = 46, coords = vector3(-1300.0, -1300.0, 65.0),  label = "Gizli TOT Paketi #46", color = {r=200,g=255,b=200}, scale = 1.0 },
    { id = 47, coords = vector3(-1500.0, -1500.0, 70.0),  label = "Gizli TOT Paketi #47", color = {r=255,g=200,b=120}, scale = 1.0 },
    { id = 48, coords = vector3(-1700.0, -1700.0, 75.0),  label = "Gizli TOT Paketi #48", color = {r=0,g=180,b=255},   scale = 1.0 },
    { id = 49, coords = vector3(-1900.0, -1900.0, 80.0),  label = "Gizli TOT Paketi #49", color = {r=255,g=120,b=220}, scale = 1.0 },
    { id = 50, coords = vector3(-2100.0, -2100.0, 85.0),  label = "Gizli TOT Paketi #50", color = {r=140,g=255,b=140}, scale = 1.0 },
}
