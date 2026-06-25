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

local function plantSeed()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Mencari area tanah (GardenTotalArea) yang paling dekat dengan karaktermu
    local closestPlot = nil
    local shortestDist = 60 -- Maksimal jarak 60 stud agar tidak menanam di plot orang lain

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "GardenTotalArea" and obj:IsA("BasePart") then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestPlot = obj
            end
        end
    end

    -- Jika tanah terdekat ditemukan, kita akan menanam persis di dalamnya
    if closestPlot then
        -- Mengambil ukuran setengah tanah, dikurangi 1 stud agar tidak pas di garis tepi
        local halfX = (closestPlot.Size.X / 2) - 1
        local halfZ = (closestPlot.Size.Z / 2) - 1
        
        -- Mengacak posisi X dan Z tepat di dalam batas ukuran tanah
        local randX = closestPlot.Position.X + (math.random() * 2 - 1) * halfX
        local randZ = closestPlot.Position.Z + (math.random() * 2 - 1) * halfZ
        local posY = closestPlot.Position.Y -- Menyesuaikan ketinggian tanah otomatis
        
        -- Mengubah koordinat menjadi Bytecode (Float32)
        local coordinateBytes = string.pack("<fff", randX, posY, randZ)
        local nameLength = string.char(#getgenv().Config.SeedName)
        
        -- Merakit buffer akhir
        local bufferStr = "\t\000" .. coordinateBytes .. nameLength .. getgenv().Config.SeedName
        
        local args = {
            buffer.fromstring(bufferStr),
            { char:FindFirstChildOfClass("Tool") or Instance.new("Tool") }
        }
        Remote:FireServer(unpack(args))
    end
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
    local nameLength = string.char(#getgenv().Config.SeedName)
    local bufferStr = "y\000" .. nameLength .. getgenv().Config.SeedName
    local args = { buffer.fromstring(bufferStr) }
    Remote:FireServer(unpack(args))
end

local function sellCrops()
    -- Menggunakan kode buffer khusus untuk SELL
    local args = {
        buffer.fromstring("\171\000%")
    }
    Remote:FireServer(unpack(args))
end

--- MEMBANGUN UI ORION ---
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Zee-Hub | Grow a Garden 2", HidePremium = false, SaveConfig = true, ConfigFolder = "ZeeHub"})

local FarmTab = Window:MakeTab({
	Name = "Auto Farm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

FarmTab:AddDropdown({
	Name = "Pilih Benih",
	Default = "Carrot",
	Options = {"Carrot", "Tomato", "Wheat", "Corn", "Potato"}, -- Tambahkan nama benih lain jika perlu
	Callback = function(Value)
		getgenv().Config.SeedName = Value
	end    
})

FarmTab:AddSection({ Name = "Fitur Utama" })

FarmTab:AddToggle({
	Name = "Auto Plant",
	Default = false,
	Callback = function(Value)
		getgenv().Config.AutoPlant = Value
	end    
})

FarmTab:AddToggle({
	Name = "Auto Harvest",
	Default = false,
	Callback = function(Value)
		getgenv().Config.AutoHarvest = Value
	end    
})

FarmTab:AddSection({ Name = "Fitur Toko" })

FarmTab:AddToggle({
	Name = "Auto Buy Seed",
	Default = false,
	Callback = function(Value)
		getgenv().Config.AutoBuySeed = Value
	end    
})

FarmTab:AddToggle({
	Name = "Auto Sell Crops",
	Default = false,
	Callback = function(Value)
		getgenv().Config.AutoSell = Value
	end    
})

OrionLib:Init()

--- MAIN LOOP ---
task.spawn(function()
    while task.wait(getgenv().Config.LoopDelay) do
        -- Menggunakan pcall agar script tidak crash jika ada error kecil
        if getgenv().Config.AutoSell then 
            pcall(sellCrops) 
            task.wait(0.2) 
        end
        
        if getgenv().Config.AutoHarvest then 
            pcall(harvest) 
            task.wait(0.2) 
        end
        
        if getgenv().Config.AutoBuySeed then 
            pcall(buySeed) 
            task.wait(0.2) 
        end
        
        if getgenv().Config.AutoPlant then 
            pcall(plantSeed) 
            task.wait(0.2) 
        end
    end
end)