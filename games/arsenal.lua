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

---------------- GUI ----------------
local gui = Instance.new("ScreenGui")
gui.Name = "DevMenu"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0,320,0,250)
frame.Position = UDim2.new(0.5,-160,0.5,-125)
frame.BackgroundColor3 = Color3.fromRGB(30,30,40)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,40)
title.Text = "DEV MENU"
title.TextScaled = true
title.BackgroundColor3 = Color3.fromRGB(50,50,80)
title.TextColor3 = Color3.new(1,1,1)

local function createButton(text, y)
	local b = Instance.new("TextButton")
	b.Parent = frame
	b.Size = UDim2.new(0,260,0,35)
	b.Position = UDim2.new(0,30,0,y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(55,55,70)
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	return b
end

local aimBtn = createButton("Aim Assist: OFF", 50)
local espBtn = createButton("ESP: OFF", 95)
local teamBtn = createButton("Team Check: ON", 140)
local wallBtn = createButton("Wall Check: ON", 185)

---------------- DRAG ----------------
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

---------------- TEAM CHECK ----------------
local function sameTeam(player)
	if not TeamCheck then
		return false
	end

	if LP.Team and player.Team then
		return LP.Team == player.Team
	end

	return false
end

---------------- WALL CHECK ----------------
local function canSee(targetPart)
	if not WallCheck then
		return true
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {
		LP.Character,
		targetPart.Parent
	}

	local origin = Camera.CFrame.Position
	local direction = targetPart.Position - origin
	local result = workspace:Raycast(origin, direction, params)

	return result == nil
end

---------------- TARGET ----------------
local function getClosestTarget()
	local closest = nil
	local shortest = FOV

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and player.Character and player.Character:FindFirstChild("Head") then
			
			if sameTeam(player) then
				continue
			end

			local head = player.Character.Head
			local screenPos, visible = Camera:WorldToViewportPoint(head.Position)

			if visible and canSee(head) then
				local dist = (
					Vector2.new(Mouse.X, Mouse.Y) -
					Vector2.new(screenPos.X, screenPos.Y)
				).Magnitude

				if dist < shortest then
					shortest = dist
					closest = head
				end
			end
		end
	end

	return closest
end

---------------- AIM LOOP ----------------
RunService.RenderStepped:Connect(function()
	if AimEnabled then
		local target = getClosestTarget()
		if target then
			local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
			Camera.CFrame = Camera.CFrame:Lerp(targetCF, Smoothness)
		end
	end
end)

---------------- ESP ----------------
local function updateESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and player.Character then
			local existing = player.Character:FindFirstChild("ESP")

			if ESPEnabled then
				if not existing then
					local hl = Instance.new("Highlight")
					hl.Name = "ESP"
					hl.FillTransparency = 0.7
					hl.OutlineTransparency = 0
					hl.Parent = player.Character
				end
			else
				if existing then
					existing:Destroy()
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		updateESP()
	end)
end)

---------------- BUTTONS ----------------
aimBtn.MouseButton1Click:Connect(function()
	AimEnabled = not AimEnabled
	aimBtn.Text = AimEnabled and "Aim Assist: ON" or "Aim Assist: OFF"
end)

espBtn.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled
	espBtn.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
	updateESP()
end)

teamBtn.MouseButton1Click:Connect(function()
	TeamCheck = not TeamCheck
	teamBtn.Text = TeamCheck and "Team Check: ON" or "Team Check: OFF"
end)

wallBtn.MouseButton1Click:Connect(function()
	WallCheck = not WallCheck
	wallBtn.Text = WallCheck and "Wall Check: ON" or "Wall Check: OFF"
end)