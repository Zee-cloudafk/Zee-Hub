--[==[
    ZEE HUB - MATCHA EDITION
    =======================
    A wide, aesthetic Matcha Green Dev Panel for Roblox.
    Features: Aim Assist, ESP, Team/Wall Check.
    Executor: Vortex/Synapse/Studio Compatible.
    Status: Safe & Optimized.
]==]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui") -- Menggunakan CoreGui agar aman saat reset

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

---------------- SETTINGS & STATE ----------------
-- Default state untuk toggle
local AimEnabled = false
local ESPEnabled = false
local TeamCheck = true
local WallCheck = true
local FOV = 180 -- Field of View untuk deteksi Aim
local Smoothness = 0.15 -- Kehalusan gerakan kamera (Lerp)

-- Skema Warna Matcha Green (Estetis)
local MatchaColor = {
    Header = Color3.fromRGB(120, 160, 90), -- Hijau Matcha Header
    Background = Color3.fromRGB(20, 20, 30), -- Latar Belakang Gelap
    ButtonOn = Color3.fromRGB(65, 110, 65), -- Hijau saat Aktif
    ButtonOff = Color3.fromRGB(40, 40, 55), -- Abu Gelap saat Mati
    Text = Color3.fromRGB(255, 255, 255) -- Putih Teks
}

---------------- UI MAKER (WIDE VERSION) ----------------

-- Cek dan bersihkan UI lama jika ada
local ExistingGui = CoreGui:FindFirstChild("ZeeHub_Matcha_V2")
if ExistingGui then ExistingGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ZeeHub_Matcha_V2"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- BINGKAI UTAMA (LEBAR 550x160)
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 550, 0, 160)
frame.Position = UDim2.new(0.5, -275, 0.5, -80) -- Center on screen
frame.BackgroundColor3 = MatchaColor.Background
frame.BorderSizePixel = 0

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8) -- Sudut melengkung halus
frameCorner.Parent = frame

-- HEADER BAR (MATCHING HEADER)
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "ZEE HUB — DEV PANEL"
title.TextSize = 16
title.Font = Enum.Font.GothamBold -- Font modern tebal
title.BackgroundColor3 = MatchaColor.Header
title.TextColor3 = MatchaColor.Text

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- FUNGSI MEMBUAT TOMBOL (GRID LAYOUT 2x2)
-- @param text: Teks pada tombol
-- @param x: Posisi X absolut (piksel)
-- @param y: Posisi Y absolut (piksel)
local function createButton(text, x, y)
    local b = Instance.new("TextButton")
    b.Parent = frame
    b.Size = UDim2.new(0, 240, 0, 38) -- Lebar tombol disesuaikan untuk 2 kolom
    b.Position = UDim2.new(0, x, 0, y)
    b.Text = text
    b.Font = Enum.Font.GothamMedium -- Font modern sedang
    b.TextSize = 13
    b.BackgroundColor3 = MatchaColor.ButtonOff
    b.TextColor3 = MatchaColor.Text
    b.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = b
    return b
end

-- Posisi X dan Y diatur berpasangan kiri-kanan agar berjejer (Grid)
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

-- 1. Deteksi Tim (Aman untuk game berbasis tim)
local function sameTeam(player)
    if not TeamCheck then return false end
    if LP.Team and player.Team then
        return LP.Team == player.Team
    end
    return false
end

-- 2. Raycast (Untuk memastikan target tidak terhalang objek/dinding)
local function canSee(targetPart)
    if not WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    -- Mengabaikan karakter sendiri dan karakter target saat melakukan pengecekan raycast
    params.FilterDescendantsInstances = {LP.Character, targetPart.Parent}

    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

-- 3. Mencari Target Terdekat dari Kursor
local function getClosestTarget()
    local closest = nil
    local shortest = FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("Head") then
            if sameTeam(player) then continue end

            -- Menggunakan HumanoidRootPart atau Head sebagai tumpuan mekanik kamera
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

---------------- LOOP SYSTEMS ----------------

-- Kamera otomatis bergerak halus (Lerp) jika Aim Assist aktif (Biasa digunakan untuk mekanik Lock-On)
RunService.RenderStepped:Connect(function()
    if AimEnabled then
        local target = getClosestTarget()
        if target then
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Smoothness)
        end
    end
end)

-- Sistem Highlight Pemain (Bawaan Roblox) untuk membedakan pemain/objek (Matcha Color)
local function updateHighlight()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local existing = player.Character:FindFirstChild("Zee_Highlight")
            if ESPEnabled then
                if not existing then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Zee_Highlight"
                    hl.FillColor = MatchaColor.Header -- Menggunakan warna Matcha Header
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

-- Menangani pemain baru yang masuk ke dalam room game
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
    -- Perubahan warna tombol saat Aktif/Mati (Matcha)
    aimBtn.BackgroundColor3 = AimEnabled and MatchaColor.ButtonOn or MatchaColor.ButtonOff
end)

espBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espBtn.Text = ESPEnabled and "Player Highlight: ON" or "Player Highlight: OFF"
    -- Perubahan warna tombol saat Aktif/Mati (Matcha)
    espBtn.BackgroundColor3 = ESPEnabled and MatchaColor.ButtonOn or MatchaColor.ButtonOff
    updateHighlight() -- Update langsung saat tombol diklik
end)

teamBtn.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    teamBtn.Text = TeamCheck and "Team Check: ON" or "Team Check: OFF"
    -- Team Check On = Default, Team Check Off = Merah (Kritis)
    teamBtn.BackgroundColor3 = TeamCheck and MatchaColor.ButtonOff or Color3.fromRGB(90, 40, 40)
end)

wallBtn.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    wallBtn.Text = WallCheck and "Wall Check: ON" or "Wall Check: OFF"
    -- Wall Check On = Default, Wall Check Off = Merah (Kritis)
    wallBtn.BackgroundColor3 = WallCheck and MatchaColor.ButtonOff or Color3.fromRGB(90, 40, 40)
end)

-- Pesan konfirmasi di console
warn("ZEE HUB - Matcha Edition Loaded.")
