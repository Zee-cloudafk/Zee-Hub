local getgenv = getgenv or function() return _G end

-- Konfigurasi Utama
getgenv().Config = {
    AutoPlant = false,
    AutoHarvest = false,
    AutoBuySeed = false,
    AutoSell = false,
    SeedName = "Carrot",
    LoopDelay = 0.5
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
local LocalPlayer = game.Players.LocalPlayer

--- FUNGSI UTAMA ---

local function plantSeed()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local closestPlot = nil
    local shortestDist = 60 

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "GardenTotalArea" and obj:IsA("BasePart") then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestPlot = obj
            end
        end
    end

    if closestPlot then
        local halfX = (closestPlot.Size.X / 2) - 1.5
        local halfZ = (closestPlot.Size.Z / 2) - 1.5
        local randX = closestPlot.Position.X + (math.random() * 2 - 1) * halfX
        local randZ = closestPlot.Position.Z + (math.random() * 2 - 1) * halfZ
        
        local coordinateBytes = string.pack("<fff", randX, closestPlot.Position.Y, randZ)
        local nameLength = string.char(#getgenv().Config.SeedName)
        local bufferStr = "\t\000" .. coordinateBytes .. nameLength .. getgenv().Config.SeedName
        
        local args = { buffer.fromstring(bufferStr), { char:FindFirstChildOfClass("Tool") or Instance.new("Tool") } }
        Remote:FireServer(unpack(args))
    end
end

local function harvest()
    for _, folder in pairs(workspace:GetDescendants()) do
        if folder.Name == "Plants" then
            for _, plant in pairs(folder:GetChildren()) do
                local splitName = string.split(plant.Name, "_")
                local uuid = splitName[2] 
                if uuid then
                    -- Mendeteksi baik Carrot (HarvestPart) maupun Tomato (Folder Fruits)
                    local isReady = plant:FindFirstChild("HarvestPart") or (plant:FindFirstChild("Fruits") and #plant.Fruits:GetChildren() > 0)
                    if isReady then
                        local bufferStr = "\198\000$" .. uuid .. "\000"
                        Remote:FireServer(buffer.fromstring(bufferStr))
                    end
                end
            end
        end
    end
end

local function buySeed()
    local nameLength = string.char(#getgenv().Config.SeedName)
    local bufferStr = "y\000" .. nameLength .. getgenv().Config.SeedName
    Remote:FireServer(buffer.fromstring(bufferStr))
end

local function sellCrops()
    Remote:FireServer(buffer.fromstring("\171\000%"))
end

--- MEMBANGUN UI ORION ---
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Zee-Hub v3.0", HidePremium = false, SaveConfig = true, ConfigFolder = "ZeeHub"})

local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})

FarmTab:AddDropdown({
	Name = "Pilih Benih",
	Default = "Carrot",
	Options = {"Carrot", "Tomato", "Wheat", "Corn", "Potato"},
	Callback = function(Value) getgenv().Config.SeedName = Value end    
})

FarmTab:AddToggle({Name = "Auto Plant", Callback = function(V) getgenv().Config.AutoPlant = V end})
FarmTab:AddToggle({Name = "Auto Harvest", Callback = function(V) getgenv().Config.AutoHarvest = V end})
FarmTab:AddToggle({Name = "Auto Buy Seed", Callback = function(V) getgenv().Config.AutoBuySeed = V end})
FarmTab:AddToggle({Name = "Auto Sell Crops", Callback = function(V) getgenv().Config.AutoSell = V end})

OrionLib:Init()

--- MAIN LOOP ---
task.spawn(function()
    while task.wait(getgenv().Config.LoopDelay) do
        if getgenv().Config.AutoSell then pcall(sellCrops) end
        if getgenv().Config.AutoHarvest then pcall(harvest) end
        if getgenv().Config.AutoBuySeed then pcall(buySeed) end
        if getgenv().Config.AutoPlant then pcall(plantSeed) end
    end
end)