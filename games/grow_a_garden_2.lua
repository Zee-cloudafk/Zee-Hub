-- Menggunakan global environment agar toggle bisa diaktifkan/dinonaktifkan
local getgenv = getgenv or function() return _G end

-- Konfigurasi Fitur
getgenv().Config = {
    AutoPlant = false,
    AutoHarvest = false,
    AutoBuySeed = false,
    AutoSell = false,
    SeedName = "Basic Seed", -- Ganti dengan nama benih di game
    LoopDelay = 1 -- Waktu jeda antar aksi (dalam detik)
}

-- Layanan yang sering digunakan
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

--- FUNGSI UTAMA (Ganti dengan RemoteEvent dari game) ---

local function buySeed()
    -- CONTOH: ReplicatedStorage.Remotes.BuyItem:FireServer(getgenv().Config.SeedName, 1)
    print("Mencoba membeli benih: " .. getgenv().Config.SeedName)
end

local function plantSeed()
    -- Kamu perlu mencari tahu bagaimana game mendeteksi 'Plot' atau tanah
    -- CONTOH: ReplicatedStorage.Remotes.Plant:FireServer(PlotID, getgenv().Config.SeedName)
    print("Mencoba menanam benih...")
end

local function harvest()
    -- CONTOH: ReplicatedStorage.Remotes.Harvest:FireServer(PlotID)
    print("Mencoba memanen tanaman...")
end

local function sellCrops()
    -- CONTOH: ReplicatedStorage.Remotes.SellAll:FireServer()
    print("Mencoba menjual semua hasil panen...")
end

--- MAIN LOOP ---

task.spawn(function()
    while task.wait(getgenv().Config.LoopDelay) do
        -- Cek setiap fitur apakah sedang aktif (true)
        if getgenv().Config.AutoSell then
            sellCrops()
            task.wait(0.5) -- Jeda agar server tidak mendeteksi spam
        end
        
        if getgenv().Config.AutoHarvest then
            harvest()
            task.wait(0.5)
        end
        
        if getgenv().Config.AutoBuySeed then
            buySeed()
            task.wait(0.5)
        end
        
        if getgenv().Config.AutoPlant then
            plantSeed()
            task.wait(0.5)
        end
    end
end)

-- Cara mengaktifkan script (ubah false menjadi true pada tabel Config di atas)
-- getgenv().Config.AutoPlant = true
