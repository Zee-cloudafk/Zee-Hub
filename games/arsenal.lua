local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

---------------- SETTINGS ----------------
local AimEnabled = false
local ESPEnabled = false
local TeamCheck = true
local WallCheck = true
local FOV = 180
local Smoothness = 0.15

---------------- UI MAKER (WIDE VERSION) ----------------
local CoreGui = game:GetService("CoreGui")
local ExistingGui = CoreGui:FindFirstChild("DevMenuV2")
if ExistingGui then ExistingGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DevMenuV2"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- UKURAN DIUBAH LEBIH LEBAR (Lebar: 550, Tinggi: 160)
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 550, 0, 160)
frame.Position = UDim2.new(0.5, -275, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

-- TITLE BAR LEBIH LEBAR
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "ZEE HUB — DEV PANEL"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.BackgroundColor3 = Color3.fromRGB(219, 112, 147) -- Pink Aesthetic
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- FUNGSI MEMBUAT TOMBOL BERJEJER KE SAMPING
local function createButton(text, x, y)
    local b = Instance.new("TextButton")
    b.Parent = frame
    b.Size = UDim2.new(0, 240, 0, 38) -- Lebar tombol disesuaikan
    b.Position = UDim2.new(0, x, 0, y)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = b
    return b
end

-- Posisi X dan Y diatur berpasangan kiri-kanan agar rapi
local aimBtn = createButton("Aim Assist: OFF", 25, 55)       -- Baris 1 Kiri
local espBtn = createButton("Player Highlight: OFF", 285, 55) -- Baris 1 Kanan
local teamBtn = createButton("Team Check: ON", 25, 105)       -- Baris 2 Kiri
local wallBtn = createButton("Wall Check: ON", 285, 105)     -- Baris 2 Kanan

---------------- UI DRAGGING SYSTEM ----------------
local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

---------------- MECHANICS ----------------
local function sameTeam(player)
    if not TeamCheck then return false end
    if LP.Team and player.Team then
        return LP.Team == player.Team
    end
    return false
end

local function canSee(targetPart)
    if not WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, targetPart.Parent}

    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

local function getClosestTarget()
    local closest = nil
    local shortest = FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("Head") then
            if sameTeam(player) then continue end

            local head = player.Character.Head
            local screenPos, visible = Camera:WorldToViewportPoint(head.Position)

            if visible and canSee(head) then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if AimEnabled then
        local target = getClosestTarget()
        if target then
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Smoothness)
        end
    end
end)

local function updateHighlight()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local existing = player.Character:FindFirstChild("GameHighlight")
            if ESPEnabled then
                if not existing then
                    local hl = Instance.new("Highlight")
                    hl.Name = "GameHighlight"
                    hl.FillColor = Color3.fromRGB(219, 112, 147)
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.OutlineTransparency = 0
                    hl.Parent = player.Character
                end
            else
                if existing then existing:Destroy() end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        updateHighlight()
    end)
end)

---------------- BUTTONS INTERACTION ----------------
aimBtn.MouseButton1Click:Connect(function()
    AimEnabled = not AimEnabled
    aimBtn.Text = AimEnabled and "Aim Assist: ON" or "Aim Assist: OFF"
    aimBtn.BackgroundColor3 = AimEnabled and Color3.fromRGB(65, 90, 65) or Color3.fromRGB(40, 40, 55)
end)

espBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espBtn.Text = ESPEnabled and "Player Highlight: ON" or "Player Highlight: OFF"
    espBtn.BackgroundColor3 = ESPEnabled and Color3.fromRGB(65, 90, 65) or Color3.fromRGB(40, 40, 55)
    updateHighlight()
end)

teamBtn.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    teamBtn.Text = TeamCheck and "Team Check: ON" or "Team Check: OFF"
    teamBtn.BackgroundColor3 = TeamCheck and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(90, 40, 40)
end)

wallBtn.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    wallBtn.Text = WallCheck and "Wall Check: ON" or "Wall Check: OFF"
    wallBtn.BackgroundColor3 = WallCheck and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(90, 40, 40)
end)
