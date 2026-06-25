local getgenv = getgenv or function() return _G end

-- Konfigurasi
getgenv().Config = {
    AutoPlant = true,
    AutoHarvest = true,
    AutoBuySeed = true,
    AutoSell = true,
    SeedName = "Carrot",
    LoopDelay = 0.5
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
local LocalPlayer = game.Players.LocalPlayer

--- FUNGSI UTAMA ---

local function plantSeed()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- Mencari semua area tanah di seluruh Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "GardenTotalArea" and obj:IsA("BasePart") then
            -- Jarak aman 30 stud
            if (char.HumanoidRootPart.Position - obj.Position).Magnitude < 30 then
                local halfX, halfZ = (obj.Size.X / 2) - 1, (obj.Size.Z / 2) - 1
                local pos = obj.Position + Vector3.new((math.random() * 2 - 1) * halfX, 0, (math.random() * 2 - 1) * halfZ)
                
                local bufferStr = "\t\000" .. string.pack("<fff", pos.X, obj.Position.Y, pos.Z) .. string.char(#getgenv().Config.SeedName) .. getgenv().Config.SeedName
                Remote:FireServer(buffer.fromstring(bufferStr), {char:FindFirstChildOfClass("Tool") or Instance.new("Tool")})
            end
        end
    end
end

local function harvest()
    -- Mencari semua objek di workspace
    for _, plant in pairs(workspace:GetDescendants()) do
        -- Cek jika objek adalah tanaman (punya nama mengandung ID user)
        if string.find(plant.Name, tostring(LocalPlayer.UserId)) then
            local uuid = string.split(plant.Name, "_")[2]
            if uuid and (plant:FindFirstChild("HarvestPart") or plant:FindFirstChild("Fruits")) then
                Remote:FireServer(buffer.fromstring("\198\000$" .. uuid .. "\000"))
            end
        end
    end
end

local function buySeed()
    Remote:FireServer(buffer.fromstring("y\000" .. string.char(#getgenv().Config.SeedName) .. getgenv().Config.SeedName))
end

local function sellCrops()
    Remote:FireServer(buffer.fromstring("\171\000%"))
end

--- UI ORION ---
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Zee-Hub Final | Grow a Garden 2", HidePremium = false, SaveConfig = true, ConfigFolder = "ZeeHub"})
local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})

FarmTab:AddDropdown({Name = "Pilih Benih", Default = "Carrot", Options = {"Carrot", "Tomato", "Wheat", "Corn", "Potato"}, Callback = function(V) getgenv().Config.SeedName = V end})
FarmTab:AddToggle({Name = "Auto Plant", Callback = function(V) getgenv().Config.AutoPlant = V end})
FarmTab:AddToggle({Name = "Auto Harvest", Callback = function(V) getgenv().Config.AutoHarvest = V end})
FarmTab:AddToggle({Name = "Auto Buy Seed", Callback = function(V) getgenv().Config.AutoBuySeed = V end})
FarmTab:AddToggle({Name = "Auto Sell Crops", Callback = function(V) getgenv().Config.AutoSell = V end})

OrionLib:Init()

--- LOOPING ---
task.spawn(function()
    while task.wait(getgenv().Config.LoopDelay) do
        if getgenv().Config.AutoSell then pcall(sellCrops) end
        if getgenv().Config.AutoHarvest then pcall(harvest) end
        if getgenv().Config.AutoBuySeed then pcall(buySeed) end
        if getgenv().Config.AutoPlant then pcall(plantSeed) end
    end
end)