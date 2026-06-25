local getgenv = getgenv or function() return _G end

-- Konfigurasi Utama
getgenv().Config = {
    AutoPlant = false,
    AutoHarvest = false,
    AutoBuySeed = false,
    AutoSell = false,
    SeedName = "Carrot",
    LoopDelay = 1
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
local LocalPlayer = game.Players.LocalPlayer

--- FUNGSI UTAMA ---

local function getByteLength(str)
    return string.char(#str)
end

local function plantSeed()
    local nameLength = getByteLength(getgenv().Config.SeedName)
    local bufferStr = "\t\000U\158\215C\254Z\014C\"\130\239\194" .. nameLength .. getgenv().Config.SeedName
    
    local args = {
        buffer.fromstring(bufferStr),
        { LocalPlayer.Character:FindFirstChildOfClass("Tool") or Instance.new("Tool") }
    }
    Remote:FireServer(unpack(args))
end

local function harvest()
    for _, folder in pairs(workspace:GetDescendants()) do
        if folder.Name == "Plants" then
            for _, plant in pairs(folder:GetChildren()) do
                local splitName = string.split(plant.Name, "_")
                local uuid = splitName[2] 

                if uuid and plant:FindFirstChild("HarvestPart") then
                    local bufferStr = "\198\000$" .. uuid .. "\000"
                    local args = { buffer.fromstring(bufferStr) }
                    Remote:FireServer(unpack(args))
                end
            end
        end
    end
end

local function buySeed()
    local nameLength = getByteLength(getgenv().Config.SeedName)
    local bufferStr = "y\000" .. nameLength .. getgenv().Config.SeedName
    local args = { buffer.fromstring(bufferStr) }
    Remote:FireServer(unpack(args))
end

local function sellCrops()
    -- Catatan: Kodenya ini mungkin butuh direkam ulang pakai SimpleSpy nanti
    local args = {
        buffer.fromstring("r\000\028\005\001\v\rShovel:Shovel\005\002\v\vBuild:Build\000")
    }
    Remote:FireServer(unpack(args))
end

--- MEMBANGUN UI ORION ---

-- Memuat Orion Library dari GitHub
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Membuat Jendela Utama (Bisa ganti nama Zee-Hub)
local Window = OrionLib:MakeWindow({Name = "Zee-Hub | Grow a Garden 2", HidePremium = false, SaveConfig = true, ConfigFolder = "ZeeHub"})

-- Membuat Tab Menu
local FarmTab = Window:MakeTab({
	Name = "Auto Farm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Menambahkan Dropdown untuk memilih Benih
FarmTab:AddDropdown({
	Name = "Pilih Benih",
	Default = "Carrot",
	Options = {"Carrot", "Tomato", "Wheat", "Corn", "Potato"}, -- Tambahkan nama benih lain di game jika ada
	Callback = function(Value)
		getgenv().Config.SeedName = Value
        print("Benih diganti ke: " .. Value)
	end    
})

-- Menambahkan Pembatas (Garis)
FarmTab:AddSection({ Name = "Fitur Utama" })

-- Menambahkan Toggle Auto Plant
FarmTab:AddToggle({
	Name = "Auto Plant",
	Default = false,
	Callback = function(Value)
		getgenv().Config.AutoPlant = Value
	end    
})

-- Menambahkan Toggle Auto Harvest
FarmTab:AddToggle({
	Name = "Auto Harvest",
	Default = false,
	Callback = function(Value)
		getgenv().Config.AutoHarvest = Value
	end    
})

FarmTab:AddSection({ Name = "Fitur Toko" })

-- Menambahkan Toggle Auto Buy
FarmTab:AddToggle({
	Name = "Auto Buy Seed",
	Default = false,
	Callback = function(Value)
		getgenv().Config.AutoBuySeed = Value
	end    
})

-- Menambahkan Toggle Auto Sell
FarmTab:AddToggle({
	Name = "Auto Sell Crops",
	Default = false,
	Callback = function(Value)
		getgenv().Config.AutoSell = Value
	end    
})

-- Menyelesaikan pembuatan UI
OrionLib:Init()

--- MAIN LOOP (Berjalan di belakang layar sesuai pilihan UI) ---
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