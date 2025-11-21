Config = {}

-- Drift algılama hassasiyeti
Config.MinSpeedKmh      = 25      -- minimum hız (km/h)
Config.MinAngleDeg      = 10      -- minimum drift açısı
Config.MaxAngleDeg      = 80      -- maksimum drift açısı

-- Temel puan çarpanı
Config.ScoreMultiplierBase = 0.06

-- Combo sistemi
Config.ComboStepTimeMs  = 2500    -- her şu kadar ms'de çarpan artar
Config.ComboStepInc     = 0.25    -- her adımda eklenecek çarpan
Config.ComboMaxMul      = 4.0     -- max çarpan

-- Drift zinciri ayarları
Config.ChainTimeoutMs     = 3500  -- drift bitmiş sayılması için bekleme süresi
Config.MinDriftChainScore = 100   -- bu değerin altında zincir DB'ye yazılmaz

-- HUD ayarları
Config.ShowBestScore = true

-- Skor tablosu otomatik yenileme (F10 panel açıkken)
Config.ScoreboardRefreshMs = 3000
