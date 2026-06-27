local getgenv = getgenv or function() return _G end

-- Konfigurasi Utama
getgenv().Config = {
    AutoPlant = false,
    AutoHarvest = false,
    AutoBuySeed = false,
    AutoSell = false,
    SeedName = "Carrot",
    LoopDelay = 1,
    
    -- Planting settings
    PlantGridSpacing = 4,
    AutoExpandGarden = false,
    PlantAtSavedPos = false,
    PlantPos = "0, 0, 0",
    
    -- Harvesting settings
    AutoCollectDrops = false,
    HarvestMode = "Filtered",
    FruitsOnly = false,
    
    -- Growing settings
    AutoPlaceSprinklers = false,
    SprinklerType = "All",
    SprinkleAtSavedPos = false,
    SprinklerPos = "0, 0, 0",
    
    AutoWater = false,
    WateringCanType = "All",
    WaterAtSavedPos = false,
    WaterPos = "0, 0, 0"
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
local LocalPlayer = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local theme = {
    Background = Color3.fromRGB(21, 20, 25),
    Sidebar = Color3.fromRGB(28, 27, 33),
    TopBar = Color3.fromRGB(28, 27, 33),
    Pink = Color3.fromRGB(255, 125, 162),
    Text = Color3.fromRGB(255, 255, 255),
    MutedText = Color3.fromRGB(150, 150, 160),
    Border = Color3.fromRGB(255, 125, 162),
    ElementBackground = Color3.fromRGB(28, 27, 33),
    Interactive = Color3.fromRGB(43, 42, 51)
}

--- HELPER FUNCTIONS ---

local function parseCoords(str)
    local parts = string.split(str, ",")
    if #parts == 3 then
        local x = tonumber(parts[1])
        local y = tonumber(parts[2])
        local z = tonumber(parts[3])
        if x and y and z then
            return x, y, z
        end
    end
    return nil
end

--- FUNGSI GAME UTAMA ---

local function plantSeed()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local x, y, z
    if getgenv().Config.PlantAtSavedPos then
        local sx, sy, sz = parseCoords(getgenv().Config.PlantPos)
        if sx and sy and sz then
            x, y, z = sx, sy, sz
        end
    end
    
    if not x then
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
        
        if closestPlot then
            local maxSpacing = getgenv().Config.PlantGridSpacing
            local halfX = (closestPlot.Size.X / 2) - 1
            local halfZ = (closestPlot.Size.Z / 2) - 1
            
            x = closestPlot.Position.X + (math.random() * 2 - 1) * halfX
            z = closestPlot.Position.Z + (math.random() * 2 - 1) * halfZ
            y = closestPlot.Position.Y
        end
    end
    
    if x and y and z then
        local coordinateBytes = string.pack("<fff", x, y, z)
        local nameLength = string.char(#getgenv().Config.SeedName)
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
    local args = {
        buffer.fromstring("\171\000%")
    }
    Remote:FireServer(unpack(args))
end

--- CUSTOM UI LIBRARY ---

local ChiyoUI = {}
ChiyoUI.__index = ChiyoUI

function ChiyoUI.new(title)
    local self = setmetatable({}, ChiyoUI)
    
    local old = CoreGui:FindFirstChild("ChiyoHubUI")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ChiyoHubUI"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    self.Gui = gui
    
    -- Main Window Frame
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 680, 0, 420)
    main.Position = UDim2.new(0.5, -340, 0.5, -210)
    main.BackgroundColor3 = theme.Background
    main.BorderSizePixel = 0
    main.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main
    
    -- Glowing stroke border
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = main
    
    -- Sidebar Frame (Left)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 50, 1, 0)
    sidebar.BackgroundColor3 = theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    
    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 8)
    sbCorner.Parent = sidebar
    
    -- Cover sidebar's right corners
    local sbLine = Instance.new("Frame")
    sbLine.Size = UDim2.new(0, 5, 1, 0)
    sbLine.Position = UDim2.new(1, -5, 0, 0)
    sbLine.BackgroundColor3 = theme.Sidebar
    sbLine.BorderSizePixel = 0
    sbLine.Parent = sidebar
    
    -- Logo "C"
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0.5, -15, 0, 10)
    logo.BackgroundTransparency = 1
    logo.Text = "C"
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 22
    logo.TextColor3 = theme.Pink
    logo.Parent = sidebar
    
    -- Tab icons container
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, 0, 1, -50)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    tabContainer.Parent = sidebar
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 10)
    tabListLayout.Parent = tabContainer
    
    -- Top Bar
    local topbar = Instance.new("Frame")
    topbar.Name = "TopBar"
    topbar.Size = UDim2.new(1, -50, 0, 40)
    topbar.Position = UDim2.new(0, 50, 0, 0)
    topbar.BackgroundColor3 = theme.TopBar
    topbar.BorderSizePixel = 0
    topbar.Parent = main
    
    local tbLine = Instance.new("Frame")
    tbLine.Size = UDim2.new(1, 0, 0, 1)
    tbLine.Position = UDim2.new(0, 0, 1, -1)
    tbLine.BackgroundColor3 = Color3.fromRGB(35, 34, 42)
    tbLine.BorderSizePixel = 0
    tbLine.Parent = topbar
    
    -- Search Input Container
    local searchContainer = Instance.new("Frame")
    searchContainer.Size = UDim2.new(0.7, 0, 0, 26)
    searchContainer.Position = UDim2.new(0.05, 0, 0.5, -13)
    searchContainer.BackgroundColor3 = Color3.fromRGB(21, 20, 25)
    searchContainer.BorderSizePixel = 0
    searchContainer.Parent = topbar
    
    local scCorner = Instance.new("UICorner")
    scCorner.CornerRadius = UDim.new(0, 5)
    scCorner.Parent = searchContainer
    
    local scStroke = Instance.new("UIStroke")
    scStroke.Color = Color3.fromRGB(50, 50, 60)
    scStroke.Thickness = 1
    scStroke.Parent = searchContainer
    
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 14, 0, 14)
    searchIcon.Position = UDim2.new(0, 8, 0.5, -7)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://9886659671"
    searchIcon.ImageColor3 = theme.MutedText
    searchIcon.Parent = searchContainer
    
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -30, 1, 0)
    searchBox.Position = UDim2.new(0, 25, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Cari"
    searchBox.PlaceholderColor3 = theme.MutedText
    searchBox.TextColor3 = theme.Text
    searchBox.TextSize = 12
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchContainer
    
    -- Drag Icon
    local dragBtn = Instance.new("ImageLabel")
    dragBtn.Size = UDim2.new(0, 20, 0, 20)
    dragBtn.Position = UDim2.new(0.95, -20, 0.5, -10)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Image = "rbxassetid://10747384394"
    dragBtn.ImageColor3 = theme.Pink
    dragBtn.Parent = topbar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(0.95, -50, 0.5, -10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = theme.MutedText
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = topbar
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.TextColor3 = theme.Pink
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.TextColor3 = theme.MutedText
    end)
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    self.SearchBox = searchBox
    self.Main = main
    self.TopBar = topbar
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- Dragging Mechanics
    local dragging = false
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    -- Search Handler
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        if self.ActiveTab then
            for _, section in ipairs(self.ActiveTab.Sections) do
                local visibleControls = 0
                for _, ctrl in ipairs(section.Controls) do
                    if ctrl.Name then
                        local matches = ctrl.Name:lower():find(query, 1, true) ~= nil
                        ctrl.Frame.Visible = matches
                        if matches then
                            visibleControls = visibleControls + 1
                        end
                    end
                end
                if query ~= "" and visibleControls == 0 then
                    section.Main.Visible = false
                else
                    section.Main.Visible = true
                end
            end
        end
    end)
    
    -- Footer
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, -50, 0, 22)
    footer.Position = UDim2.new(0, 50, 1, -22)
    footer.BackgroundTransparency = 1
    footer.Parent = main
    
    local footerText = Instance.new("TextLabel")
    footerText.Size = UDim2.new(1, -20, 1, 0)
    footerText.Position = UDim2.new(0, 10, 0, 0)
    footerText.BackgroundTransparency = 1
    footerText.Text = "discord.gg/chiyo | v1.4 | Game: Grow a Garden 2"
    footerText.TextColor3 = theme.MutedText
    footerText.TextSize = 10
    footerText.Font = Enum.Font.Gotham
    footerText.TextXAlignment = Enum.TextXAlignment.Center
    footerText.Parent = footer
    
    -- Toggle visibility with RightControl
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            main.Visible = not main.Visible
        end
    end)
    
    return self
end

local Tab = {}
Tab.__index = Tab

function ChiyoUI:CreateTab(name, iconId)
    local tab = setmetatable({}, Tab)
    tab.Name = name
    tab.Window = self
    tab.Controls = {}
    tab.Sections = {}
    
    -- Tab Container Frame
    local container = Instance.new("Frame")
    container.Name = name .. "Tab"
    container.Size = UDim2.new(1, -50, 1, -62)
    container.Position = UDim2.new(0, 50, 0, 40)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = self.Main
    
    tab.Container = container
    
    -- Two columns structure
    local leftCol = Instance.new("ScrollingFrame")
    leftCol.Size = UDim2.new(0.48, 0, 1, 0)
    leftCol.Position = UDim2.new(0.01, 0, 0, 0)
    leftCol.BackgroundTransparency = 1
    leftCol.ScrollBarThickness = 0
    leftCol.Parent = container
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 10)
    leftLayout.Parent = leftCol
    
    local rightCol = Instance.new("ScrollingFrame")
    rightCol.Size = UDim2.new(0.48, 0, 1, 0)
    rightCol.Position = UDim2.new(0.51, 0, 0, 0)
    rightCol.BackgroundTransparency = 1
    rightCol.ScrollBarThickness = 0
    rightCol.Parent = container
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 10)
    rightLayout.Parent = rightCol
    
    tab.LeftColumn = leftCol
    tab.RightColumn = rightCol
    
    -- Sidebar icon button
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 26, 0, 26)
    btn.BackgroundTransparency = 1
    btn.Image = iconId or "rbxassetid://4483345998"
    btn.ImageColor3 = theme.MutedText
    btn.Parent = self.Main.Sidebar.TabContainer
    
    btn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageColor3 = theme.MutedText}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    tab.Button = btn
    
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function ChiyoUI:SelectTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Container.Visible = false
        self.ActiveTab.Button.ImageColor3 = theme.MutedText
    end
    
    self.ActiveTab = tab
    tab.Container.Visible = true
    tab.Button.ImageColor3 = theme.Pink
    self.SearchBox.Text = "" -- clear search
end

local Section = {}
Section.__index = Section

function Tab:CreateSection(name, iconId, column)
    local section = setmetatable({}, Section)
    section.Tab = self
    section.Name = name
    section.Controls = {}
    
    local parentCol = (column == "Right") and self.RightColumn or self.LeftColumn
    
    local main = Instance.new("Frame")
    main.Name = name .. "Section"
    main.Size = UDim2.new(1, 0, 0, 0)
    main.BackgroundColor3 = Color3.fromRGB(24, 23, 28)
    main.BorderSizePixel = 0
    main.Parent = parentCol
    main.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = main
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 50)
    stroke.Thickness = 1
    stroke.Parent = main
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundTransparency = 1
    header.Parent = main
    
    local secIcon = Instance.new("ImageLabel")
    secIcon.Size = UDim2.new(0, 16, 0, 16)
    secIcon.Position = UDim2.new(0, 8, 0.5, -8)
    secIcon.BackgroundTransparency = 1
    secIcon.Image = iconId or "rbxassetid://4483345998"
    secIcon.ImageColor3 = theme.Pink
    secIcon.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 30, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = theme.Text
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local arrow = Instance.new("ImageButton")
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.Position = UDim2.new(1, -22, 0.5, -7)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://10747375176"
    arrow.ImageColor3 = theme.MutedText
    arrow.Parent = header
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 1, -32)
    container.Position = UDim2.new(0, 8, 0, 32)
    container.BackgroundTransparency = 1
    container.Parent = main
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = container
    
    section.Main = main
    section.Container = container
    section.Arrow = arrow
    section.Collapsed = false
    
    local function adjustSize()
        if not section.Collapsed then
            container.Visible = true
            local targetHeight = listLayout.AbsoluteContentSize.Y + 40
            TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
        else
            local anim = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 32)})
            anim:Play()
            anim.Completed:Connect(function()
                if section.Collapsed then
                    container.Visible = false
                end
            end)
        end
    end
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(adjustSize)
    
    arrow.MouseButton1Click:Connect(function()
        section.Collapsed = not section.Collapsed
        arrow.Rotation = section.Collapsed and -90 or 0
        adjustSize()
    end)
    
    table.insert(self.Sections, section)
    
    return section
end

function Section:CreateToggle(name, default, callback)
    local toggle = {}
    toggle.Name = name
    toggle.State = default or false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.MutedText
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 30, 0, 16)
    switch.Position = UDim2.new(1, -30, 0.5, -8)
    switch.BackgroundColor3 = toggle.State and theme.Pink or Color3.fromRGB(43, 42, 51)
    switch.Text = ""
    switch.BorderSizePixel = 0
    switch.Parent = frame
    
    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = switch
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = toggle.State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    
    local kbCorner = Instance.new("UICorner")
    kbCorner.CornerRadius = UDim.new(1, 0)
    kbCorner.Parent = knob
    
    local function updateVisual(animate)
        local targetColor = toggle.State and theme.Pink or Color3.fromRGB(43, 42, 51)
        local targetPos = toggle.State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        
        if animate then
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        else
            switch.BackgroundColor3 = targetColor
            knob.Position = targetPos
        end
    end
    
    switch.MouseButton1Click:Connect(function()
        toggle.State = not toggle.State
        updateVisual(true)
        pcall(callback, toggle.State)
    end)
    
    function toggle:Set(state)
        toggle.State = state
        updateVisual(false)
        pcall(callback, toggle.State)
    end
    
    toggle.Frame = frame
    table.insert(self.Controls, toggle)
    return toggle
end

function Section:CreateSlider(name, min, max, default, callback)
    local slider = {}
    slider.Name = name
    slider.Value = default or min
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.MutedText
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valText = Instance.new("TextLabel")
    valText.Size = UDim2.new(0.4, 0, 0, 16)
    valText.Position = UDim2.new(0.6, 0, 0, 0)
    valText.BackgroundTransparency = 1
    valText.Text = tostring(slider.Value) .. " studs/" .. tostring(max) .. " studs"
    valText.TextColor3 = theme.Pink
    valText.TextSize = 11
    valText.Font = Enum.Font.GothamBold
    valText.TextXAlignment = Enum.TextXAlignment.Right
    valText.Parent = frame
    
    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 22)
    track.BackgroundColor3 = Color3.fromRGB(43, 42, 51)
    track.Text = ""
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local trCorner = Instance.new("UICorner")
    trCorner.CornerRadius = UDim.new(1, 0)
    trCorner.Parent = track
    
    local fill = Instance.new("Frame")
    local pct = (slider.Value - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = theme.Pink
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local flCorner = Instance.new("UICorner")
    flCorner.CornerRadius = UDim.new(1, 0)
    flCorner.Parent = fill
    
    local function updateValue(input)
        local pos = input.Position.X - track.AbsolutePosition.X
        local width = track.AbsoluteSize.X
        local clamped = math.clamp(pos / width, 0, 1)
        
        local val = math.round(min + (clamped * (max - min)))
        slider.Value = val
        valText.Text = tostring(val) .. " studs/" .. tostring(max) .. " studs"
        fill.Size = UDim2.new(clamped, 0, 1, 0)
        
        pcall(callback, val)
    end
    
    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)
    
    function slider:Set(val)
        val = math.clamp(val, min, max)
        slider.Value = val
        valText.Text = tostring(val) .. " studs/" .. tostring(max) .. " studs"
        local pct = (val - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        pcall(callback, val)
    end
    
    slider.Frame = frame
    table.insert(self.Controls, slider)
    return slider
end

function Section:CreateDropdown(name, list, default, callback)
    local dropdown = {}
    dropdown.Name = name
    dropdown.Value = default or list[1]
    dropdown.Open = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.MutedText
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.Position = UDim2.new(0, 0, 0, 20)
    btn.BackgroundColor3 = Color3.fromRGB(28, 27, 33)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(43, 42, 51)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    local btnText = Instance.new("TextLabel")
    btnText.Size = UDim2.new(1, -30, 1, 0)
    btnText.Position = UDim2.new(0, 10, 0, 0)
    btnText.BackgroundTransparency = 1
    btnText.Text = dropdown.Value
    btnText.TextColor3 = theme.Text
    btnText.TextSize = 11
    btnText.Font = Enum.Font.GothamMedium
    btnText.TextXAlignment = Enum.TextXAlignment.Left
    btnText.Parent = btn
    
    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 12, 0, 12)
    arrow.Position = UDim2.new(1, -22, 0.5, -6)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://10747375176"
    arrow.ImageColor3 = theme.MutedText
    arrow.Parent = btn
    
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 0, 44)
    listFrame.BackgroundColor3 = Color3.fromRGB(23, 22, 27)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = frame
    
    local lfCorner = Instance.new("UICorner")
    lfCorner.CornerRadius = UDim.new(0, 4)
    lfCorner.Parent = listFrame
    
    local lfList = Instance.new("UIListLayout")
    lfList.SortOrder = Enum.SortOrder.LayoutOrder
    lfList.Parent = listFrame
    
    local function populate()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, item in ipairs(list) do
            local opt = Instance.new("TextButton")
            opt.Size = UDim2.new(1, 0, 0, 24)
            opt.BackgroundTransparency = 1
            opt.Text = item
            opt.TextColor3 = (item == dropdown.Value) and theme.Pink or theme.Text
            opt.TextSize = 11
            opt.Font = Enum.Font.GothamMedium
            opt.Parent = listFrame
            
            opt.MouseButton1Click:Connect(function()
                dropdown.Value = item
                btnText.Text = item
                pcall(callback, item)
                
                dropdown.Open = false
                listFrame.Visible = false
                frame.Size = UDim2.new(1, 0, 0, 44)
                arrow.Rotation = 0
            end)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        dropdown.Open = not dropdown.Open
        if dropdown.Open then
            populate()
            listFrame.Visible = true
            local height = #list * 24
            listFrame.Size = UDim2.new(1, 0, 0, height)
            frame.Size = UDim2.new(1, 0, 0, 48 + height)
            arrow.Rotation = 180
        else
            listFrame.Visible = false
            frame.Size = UDim2.new(1, 0, 0, 44)
            arrow.Rotation = 0
        end
    end)
    
    function dropdown:Set(val)
        dropdown.Value = val
        btnText.Text = val
        pcall(callback, val)
    end
    
    dropdown.Frame = frame
    table.insert(self.Controls, dropdown)
    return dropdown
end

function Section:CreateTextBox(name, placeholder, default, callback)
    local textbox = {}
    textbox.Name = name
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.MutedText
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 24)
    box.Position = UDim2.new(0, 0, 0, 20)
    box.BackgroundColor3 = Color3.fromRGB(28, 27, 33)
    box.Text = default or ""
    box.PlaceholderText = placeholder or "Ketik di sini..."
    box.PlaceholderColor3 = theme.MutedText
    box.TextColor3 = theme.Text
    box.TextSize = 11
    box.Font = Enum.Font.GothamMedium
    box.Parent = frame
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(43, 42, 51)
    stroke.Thickness = 1
    stroke.Parent = box
    
    box.Focused:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = theme.Pink}):Play()
    end)
    box.FocusLost:Connect(function(enterPressed)
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(43, 42, 51)}):Play()
        pcall(callback, box.Text)
    end)
    
    function textbox:Set(val)
        box.Text = val
        pcall(callback, val)
    end
    
    textbox.Frame = frame
    table.insert(self.Controls, textbox)
    return textbox
end

function Section:CreateButton(name, callback)
    local button = {}
    button.Name = name
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(28, 27, 33)
    btn.Text = name
    btn.TextColor3 = theme.Text
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(43, 42, 51)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(38, 37, 45)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 27, 33)}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    button.Frame = frame
    table.insert(self.Controls, button)
    return button
end

--- INSTANTIATE UI ---

local UI = ChiyoUI.new("Chiyo Hub | Grow a Garden 2")

-- Tab 1: Farms (Leaf Icon)
local farmTab = UI:CreateTab("Farms", "rbxassetid://4483345998")

-- Left Column Sections
local plantingSection = farmTab:CreateSection("Planting", "rbxassetid://4483345998", "Left")
local harvestingSection = farmTab:CreateSection("Harvesting", "rbxassetid://10618978415", "Left")

-- Right Column Sections
local growingSection = farmTab:CreateSection("Growing", "rbxassetid://10618979201", "Right")
local sellingSection = farmTab:CreateSection("Selling", "rbxassetid://10747372704", "Right")

-- Planting Elements
plantingSection:CreateToggle("Auto Plant", getgenv().Config.AutoPlant, function(val)
    getgenv().Config.AutoPlant = val
end)

plantingSection:CreateDropdown("Seeds to Plant", {"Carrot", "Tomato", "Wheat", "Corn", "Potato"}, getgenv().Config.SeedName, function(val)
    getgenv().Config.SeedName = val
end)

plantingSection:CreateSlider("Plant Grid Spacing", 1, 10, getgenv().Config.PlantGridSpacing, function(val)
    getgenv().Config.PlantGridSpacing = val
end)

plantingSection:CreateToggle("Auto Expand Garden", getgenv().Config.AutoExpandGarden, function(val)
    getgenv().Config.AutoExpandGarden = val
end)

plantingSection:CreateButton("Teleport to My Garden", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local closestPlot = nil
        local shortestDist = 9999
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
            hrp.CFrame = CFrame.new(closestPlot.Position + Vector3.new(0, 3, 0))
        end
    end
end)

plantingSection:CreateToggle("Plant at Saved Position", getgenv().Config.PlantAtSavedPos, function(val)
    getgenv().Config.PlantAtSavedPos = val
end)

local plantPosBox = plantingSection:CreateTextBox("Plant Position", "X, Y, Z", getgenv().Config.PlantPos, function(val)
    getgenv().Config.PlantPos = val
end)

plantingSection:CreateButton("Save Plant Position", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position
        local posStr = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
        getgenv().Config.PlantPos = posStr
        plantPosBox:Set(posStr)
    end
end)

plantingSection:CreateButton("Clear Plant Position", function()
    getgenv().Config.PlantPos = "0, 0, 0"
    plantPosBox:Set("0, 0, 0")
end)

-- Harvesting Elements
harvestingSection:CreateToggle("Auto Harvest", getgenv().Config.AutoHarvest, function(val)
    getgenv().Config.AutoHarvest = val
end)

harvestingSection:CreateToggle("Auto Collect Drops", getgenv().Config.AutoCollectDrops, function(val)
    getgenv().Config.AutoCollectDrops = val
end)

harvestingSection:CreateDropdown("Harvest Mode", {"All", "Filtered"}, getgenv().Config.HarvestMode, function(val)
    getgenv().Config.HarvestMode = val
end)

harvestingSection:CreateToggle("Fruits Only", getgenv().Config.FruitsOnly, function(val)
    getgenv().Config.FruitsOnly = val
end)

-- Growing Elements
growingSection:CreateToggle("Auto Place Sprinklers", getgenv().Config.AutoPlaceSprinklers, function(val)
    getgenv().Config.AutoPlaceSprinklers = val
end)

growingSection:CreateDropdown("Sprinklers", {"All", "Basic", "Golden"}, getgenv().Config.SprinklerType, function(val)
    getgenv().Config.SprinklerType = val
end)

growingSection:CreateToggle("Sprinkle at Saved Position", getgenv().Config.SprinkleAtSavedPos, function(val)
    getgenv().Config.SprinkleAtSavedPos = val
end)

local sprinklerPosBox = growingSection:CreateTextBox("Sprinkler Position", "X, Y, Z", getgenv().Config.SprinklerPos, function(val)
    getgenv().Config.SprinklerPos = val
end)

growingSection:CreateButton("Save Sprinkler Position", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position
        local posStr = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
        getgenv().Config.SprinklerPos = posStr
        sprinklerPosBox:Set(posStr)
    end
end)

growingSection:CreateButton("Clear Sprinkler Position", function()
    getgenv().Config.SprinklerPos = "0, 0, 0"
    sprinklerPosBox:Set("0, 0, 0")
end)

growingSection:CreateToggle("Auto Water Plants", getgenv().Config.AutoWater, function(val)
    getgenv().Config.AutoWater = val
end)

growingSection:CreateDropdown("Watering Cans", {"All", "Basic", "Golden"}, getgenv().Config.WateringCanType, function(val)
    getgenv().Config.WateringCanType = val
end)

growingSection:CreateToggle("Water at Saved Position", getgenv().Config.WaterAtSavedPos, function(val)
    getgenv().Config.WaterAtSavedPos = val
end)

local waterPosBox = growingSection:CreateTextBox("Water Position", "X, Y, Z", getgenv().Config.WaterPos, function(val)
    getgenv().Config.WaterPos = val
end)

growingSection:CreateButton("Save Water Position", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position
        local posStr = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
        getgenv().Config.WaterPos = posStr
        waterPosBox:Set(posStr)
    end
end)

growingSection:CreateButton("Clear Water Position", function()
    getgenv().Config.WaterPos = "0, 0, 0"
    waterPosBox:Set("0, 0, 0")
end)

-- Selling Elements
sellingSection:CreateToggle("Auto Sell", getgenv().Config.AutoSell, function(val)
    getgenv().Config.AutoSell = val
end)

-- Tab 2: Shop (House Icon)
local shopTab = UI:CreateTab("Shop", "rbxassetid://10747373867")
local shopSec = shopTab:CreateSection("Auto Buy Settings", "rbxassetid://10747373867", "Left")
shopSec:CreateToggle("Auto Buy Seeds", getgenv().Config.AutoBuySeed, function(val)
    getgenv().Config.AutoBuySeed = val
end)
shopSec:CreateToggle("Auto Buy Watering Cans", false, function(val)
    print("[Chiyo Hub] Auto Buy Watering Cans toggled: ", val)
end)

-- Tab 3: Eggs (Egg Icon)
local eggTab = UI:CreateTab("Eggs", "rbxassetid://10747374712")
local eggSec = eggTab:CreateSection("Auto Open Eggs", "rbxassetid://10747374712", "Left")
eggSec:CreateToggle("Auto Open Common Egg", false, function() end)

-- Tab 4: Skills (Star Icon)
local skillsTab = UI:CreateTab("Skills", "rbxassetid://10747373176")
local skillsSec = skillsTab:CreateSection("Player Stats", "rbxassetid://10747373176", "Left")
skillsSec:CreateToggle("Auto Rebirth", false, function() end)

-- Tab 5: Combat (Swords Icon)
local combatTab = UI:CreateTab("Combat", "rbxassetid://10747372439")
local combatSec = combatTab:CreateSection("Pest Control", "rbxassetid://10747372439", "Left")
combatSec:CreateToggle("Auto Attack Pests", false, function() end)

-- Placeholders for other sidebar tabs (Tabs 6-9)
local mailTab = UI:CreateTab("Mail", "rbxassetid://10747374026")
local giftTab = UI:CreateTab("Gift", "rbxassetid://10747374245")
local visualTab = UI:CreateTab("Visuals", "rbxassetid://10747373516")
local alertTab = UI:CreateTab("Alerts", "rbxassetid://10747373672")

-- Tab 10: Settings (Gear Icon)
local settingsTab = UI:CreateTab("Settings", "rbxassetid://10747383162")
local uiSec = settingsTab:CreateSection("UI Configuration", "rbxassetid://10747383162", "Left")
uiSec:CreateSlider("Loop Delay (s)", 1, 10, getgenv().Config.LoopDelay, function(val)
    getgenv().Config.LoopDelay = val
end)
uiSec:CreateButton("Destroy UI", function()
    UI.Gui:Destroy()
end)

--- MAIN LOOP ---
task.spawn(function()
    while task.wait(getgenv().Config.LoopDelay) do
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