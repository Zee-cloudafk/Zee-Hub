local getgenv = getgenv or function() return _G end

-- Konfigurasi Utama
getgenv().Config = {
    AutoPlant = true,
    AutoHarvest = true,
    AutoBuySeed = true,
    AutoSell = true,
    SeedName = "Carrot", -- Bisa diganti misal: "Tomato", "Wheat", dll
    LoopDelay = 1
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
local LocalPlayer = game.Players.LocalPlayer

-- Fungsi mengubah angka menjadi format byte bawaan (untuk jumlah huruf benih)
local function getByteLength(str)
    return string.char(#str)
end

local function plantSeed()
    local nameLength = getByteLength(getgenv().Config.SeedName)
    -- Menggabungkan kode buffer awal dengan nama benih dinamis
    local bufferStr = "\t\000U\158\215C\254Z\014C\"\130\239\194" .. nameLength .. getgenv().Config.SeedName
    
    local args = {
        buffer.fromstring(bufferStr),
        { LocalPlayer.Character:FindFirstChildOfClass("Tool") or Instance.new("Tool") }
    }
    Remote:FireServer(unpack(args))
end

local function harvest()
    -- PERINGATAN: Ini masih menggunakan UUID hardcode milikmu. 
    -- Sementara hanya akan bekerja pada 1 plot spesifik.
    local args = {
        buffer.fromstring("\198\000$457d230b-f125-4eec-93e7-036f22003fe1\000")
    }
    Remote:FireServer(unpack(args))
end

local function buySeed()
    local nameLength = getByteLength(getgenv().Config.SeedName)
    local bufferStr = "y\000" .. nameLength .. getgenv().Config.SeedName
    
    local args = {
        buffer.fromstring(bufferStr)
    }
    Remote:FireServer(unpack(args))
end

local function sellCrops()
    local args = {
        buffer.fromstring("r\000\028\005\001\v\rShovel:Shovel\005\002\v\vBuild:Build\000")
    }
    Remote:FireServer(unpack(args))
end

--- MAIN LOOP ---
task.spawn(function()
    while task.wait(getgenv().Config.LoopDelay) do
        if getgenv().Config.AutoSell then 
            sellCrops() 
            task.wait(0.5) 
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

-- UNTUK TESTING: Aktifkan fitur Buy dan Plant
-- getgenv().Config.AutoBuySeed = true
-- getgenv().Config.AutoPlant = true
