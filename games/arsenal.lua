--[==[
    Z-HUBZ - MATCHA EDITION (with Minimize System)
    =============================================
    A wide, aesthetic Matcha Green Dev Panel for Roblox.
    Features: Aim Assist, ESP, Team/Wall Check.
    Executor: Vortex/Synapse/Studio Compatible.
    Status: Safe & Optimized.
]==]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService") -- Untuk animasi halus

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

---------------- STATE ----------------
local AimEnabled = false
local ESPEnabled = false
local TeamCheck = true
local WallCheck = true
local FOV = 180
local Smoothness = 0.15
local IsMinimized = false -- Status UI utama (Minimize atau tidak)

---------------- COLORS (MATCHA) ----------------
local MatchaColor = {
    Header = Color3.fromRGB(120, 160, 90),
    Background = Color3.fromRGB(20, 20, 30),
    ButtonOn = Color3.fromRGB(65, 110, 65),
    ButtonOff = Color3.fromRGB(40, 40, 55),
    Text = Color3.fromRGB(255, 255, 255),
    Logo = Color3.fromRGB(255, 255, 255),
    LogoOutline = Color3.fromRGB(0, 0, 0)
}

---------------- UI BASE ----------------
local ExistingGui = CoreGui:FindFirstChild("ZHubz_Matcha_V3")
if ExistingGui then ExistingGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ZHubz_Matcha_V3"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

---------------- UI MAIN FRAME (Wide V3) ----------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = gui
MainFrame.Size = UDim2.new(0, 550, 0, 160)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -80)
MainFrame.BackgroundColor3 = MatchaColor.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true -- Penting untuk drag

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = MainFrame

-- Header Bar
local Header = Instance.new("TextLabel")
Header.Name = "Header"
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Text = "Z-HUBZ — DEV PANEL"
Header.TextSize = 16
Header.Font = Enum.Font.GothamBold
Header.BackgroundColor3 = MatchaColor.Header
Header.TextColor3 = MatchaColor.Text

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = Header

---------------- BUTTONS GRID ----------------
local function createButton(text, x, y, parent)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(0, 240, 0, 38)
    b.Position = UDim2.new(0, x, 0, y)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.BackgroundColor3 = MatchaColor.ButtonOff
    b.TextColor3 = MatchaColor.Text
    b.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = b
    return b
end

local aimBtn = createButton("Aim Assist: OFF", 25, 55, MainFrame)
local espBtn = createButton("Player Highlight: OFF", 285, 55, MainFrame)
local teamBtn = createButton("Team Check: ON", 25, 105, MainFrame)
local wallBtn = createButton("Wall Check: ON", 285, 105, MainFrame)

---------------- MINIMIZE SYSTEM (Z LOGO BUTTON) ----------------

-- Bingkai Luar Bulat (Matcha outline)
local MinimizeOuter = Instance.new("Frame")
MinimizeOuter.Name = "MinimizeOuter"
MinimizeOuter.Parent = gui
MinimizeOuter.Size = UDim2.new(0, 60, 0, 60)
-- Posisi default di pojok kanan atas, tidak menghalangi UI utama
MinimizeOuter.Position = UDim2.new(0.5, 300, 0.5, -150)
MinimizeOuter.BackgroundColor3 = MatchaColor.Header
MinimizeOuter.BorderSizePixel = 0

local outerCorner = Instance.new("UICorner")
outerCorner.CornerRadius = UDim.new(1, 0) -- Lingkaran sempurna
outerCorner.Parent = MinimizeOuter

-- Bingkai Dalam Bulat (Gelap)
local MinimizeInner = Instance.new("Frame")
MinimizeInner.Name = "MinimizeInner"
MinimizeInner.Parent = MinimizeOuter
MinimizeInner.Size = UDim2.new(0, 52, 0, 52)
MinimizeInner.Position = UDim2.new(0.5, -26, 0.5, -26) -- Centered
MinimizeInner.BackgroundColor3 = MatchaColor.Background
MinimizeInner.BorderSizePixel = 0

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(1, 0)
innerCorner.Parent = MinimizeInner

-- Teks Logo 'Z' (Tombol Klik)
local LogoButton = Instance.new("TextButton")
LogoButton.Name = "LogoButton"
LogoButton.Parent = MinimizeInner
LogoButton.Size = UDim2.new(1, 0, 1, 0) -- Full inner frame
LogoButton.Position = UDim2.new(0, 0, 0, 0)
LogoButton.Text = "Z"
LogoButton.TextSize = 35
LogoButton.Font = Enum.Font.GothamBold -- Font imut/modern
LogoButton.TextColor3 = MatchaColor.Logo -- Putih bersih
LogoButton.TextStrokeColor3 = MatchaColor.LogoOutline -- Outline tipis agar pop
LogoButton.TextStrokeTransparency = 0.5
LogoButton.BackgroundTransparency = 1 -- Transparan background

-- Animasi Hover untuk Tombol Logo
LogoButton.MouseEnter:Connect(function()
    TweenService:Create(MinimizeInner, TweenInfo.new(0.2), {BackgroundColor3 = MatchaColor.ButtonOff}):Play()
end)
LogoButton.MouseLeave:Connect(function()
    TweenService:Create(MinimizeInner, TweenInfo.new(0.2), {BackgroundColor3 = MatchaColor.Background}):Play()
end)

-- LOGIKA MINIMIZE (TOGGLE)
local function ToggleMinimize()
    IsMinimized = not IsMinimized
    
    if IsMinimized then
        -- Sembunyikan UI utama dengan animasi halus (Optional, tapi ini instan)
        MainFrame.Visible = false
        -- Tampilkan notifikasi kecil di console
        warn("Z-HUBZ: UI Minimized. Click 'Z' to Restore.")
    else
        -- Tampilkan kembali UI utama
        MainFrame.Visible = true
        warn("Z-HUBZ: UI Restored.")
    end
end

-- Hubungkan klik tombol logo ke fungsi minimize
LogoButton.MouseButton1Click:Connect(ToggleMinimize)

---------------- UI DRAGGING SYSTEMS ----------------

-- Fungsi generik untuk membuat Instance dapat didrag
local function MakeDraggable(instance, dragHandle)
    local dragging = false
    local dragStart
    local startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = instance.Position
        end
    end)
    
    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            instance.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Aktifkan Drag untuk UI Utama (via Header)
MakeDraggable(MainFrame, Header)

-- Aktifkan Drag untuk Tombol Minimize (via Logo/Bingkai Dalam)
MakeDraggable(MinimizeOuter, MinimizeInner)

---------------- MECHANICS & LOOP ----------------

-- 1. Deteksi Tim
local function sameTeam(player)
    if not TeamCheck then return false end
    if LP.Team and player.Team then
        return LP.Team == player.Team
    end
    return false
end

-- 2. Raycast (Wall Check)
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

-- 3. Mencari Target Terdekat
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

-- 4. Aim Loop
RunService.RenderStepped:Connect(function()
    if AimEnabled then
        local target = getClosestTarget()
        if target then
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Smoothness)
        end
    end
end)

-- 5. ESP System
local function updateHighlight()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local existing = player.Character:FindFirstChild("Zee_Highlight")
            if ESPEnabled then
                if not existing then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Zee_Highlight"
                    hl.FillColor = MatchaColor.Header
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
    aimBtn.BackgroundColor3 = AimEnabled and MatchaColor.ButtonOn or MatchaColor.ButtonOff
end)

espBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espBtn.Text = ESPEnabled and "Player Highlight: ON" or "Player Highlight: OFF"
    espBtn.BackgroundColor3 = ESPEnabled and MatchaColor.ButtonOn or MatchaColor.ButtonOff
    updateHighlight()
end)

teamBtn.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    teamBtn.Text = TeamCheck and "Team Check: ON" or "Team Check: OFF"
    teamBtn.BackgroundColor3 = TeamCheck and MatchaColor.ButtonOff or Color3.fromRGB(90, 40, 40)
end)

wallBtn.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    wallBtn.Text = WallCheck and "Wall Check: ON" or "Wall Check: OFF"
    wallBtn.BackgroundColor3 = WallCheck and MatchaColor.ButtonOff or Color3.fromRGB(90, 40, 40)
end)

-- Konfirmasi Load
warn("Z-HUBZ V3 (Matcha + Minimize) Loaded.")
