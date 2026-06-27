local getgenv = getgenv or function() return _G end

-- Konfigurasi Utama (Hanya Auto Plant)
getgenv().Config = {
    AutoPlant = false,
    SeedName = "Carrot",
    LoopDelay = 1
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.5)
    LocalPlayer = Players.LocalPlayer
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Packet"):WaitForChild("RemoteEvent")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local theme = {
    Background = Color3.fromRGB(13, 14, 18),      -- Obsidian charcoal
    Sidebar = Color3.fromRGB(20, 22, 28),         -- Dark slate
    TopBar = Color3.fromRGB(20, 22, 28),          -- Dark slate
    Cyan = Color3.fromRGB(0, 240, 255),           -- Neon Cyan
    Text = Color3.fromRGB(255, 255, 255),
    MutedText = Color3.fromRGB(140, 145, 155),
    Border = Color3.fromRGB(0, 240, 255),
    ElementBackground = Color3.fromRGB(25, 28, 36),
    Interactive = Color3.fromRGB(35, 40, 50)
}

--- FUNGSI GAME UTAMA ---

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
        local halfX = (closestPlot.Size.X / 2) - 1
        local halfZ = (closestPlot.Size.Z / 2) - 1
        
        local x = closestPlot.Position.X + (math.random() * 2 - 1) * halfX
        local z = closestPlot.Position.Z + (math.random() * 2 - 1) * halfZ
        local y = closestPlot.Position.Y
        
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

--- CUSTOM UI LIBRARY ---

local ZeeHubUI = {}
ZeeHubUI.__index = ZeeHubUI

function ZeeHubUI.new(title)
    local self = setmetatable({}, ZeeHubUI)
    
    local old = CoreGui:FindFirstChild("ZeeHubUI")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZeeHubUI"
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
    
    -- Neon Cyan glowing stroke border
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Cyan
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = main
    
    -- Sidebar Frame (Left) - Narrow 50px
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
    
    -- Logo "Z"
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0.5, -15, 0, 10)
    logo.BackgroundTransparency = 1
    logo.Text = "Z"
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 22
    logo.TextColor3 = theme.Cyan
    logo.Parent = sidebar
    
    -- Tab list container
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 1, -110)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    tabContainer.Parent = sidebar
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 10)
    tabListLayout.Parent = tabContainer
    
    -- Profile Card at bottom left (Narrow)
    local profileCard = Instance.new("Frame")
    profileCard.Name = "ProfileCard"
    profileCard.Size = UDim2.new(1, 0, 0, 50)
    profileCard.Position = UDim2.new(0, 0, 1, -50)
    profileCard.BackgroundTransparency = 1
    profileCard.Parent = sidebar
    
    -- Profile divider line
    local profDivider = Instance.new("Frame")
    profDivider.Size = UDim2.new(1, -20, 0, 1)
    profDivider.Position = UDim2.new(0, 10, 0, 0)
    profDivider.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    profDivider.BorderSizePixel = 0
    profDivider.Parent = profileCard
    
    -- Get player thumbnail
    local avatarImg = "rbxassetid://10747373867"
    local success, content = pcall(function()
        return Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size48x48
        )
    end)
    if success then
        avatarImg = content
    end
    
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 30, 0, 30)
    avatar.Position = UDim2.new(0.5, -15, 0.5, -15)
    avatar.BackgroundColor3 = theme.ElementBackground
    avatar.Image = avatarImg
    avatar.Parent = profileCard
    
    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = avatar
    
    local avStroke = Instance.new("UIStroke")
    avStroke.Color = theme.Cyan
    avStroke.Thickness = 1
    avStroke.Parent = avatar
    
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
    tbLine.BackgroundColor3 = Color3.fromRGB(30, 33, 42)
    tbLine.BorderSizePixel = 0
    tbLine.Parent = topbar
    
    -- Search Input Container
    local searchContainer = Instance.new("Frame")
    searchContainer.Size = UDim2.new(0.7, 0, 0, 26)
    searchContainer.Position = UDim2.new(0.05, 0, 0.5, -13)
    searchContainer.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
    searchContainer.BorderSizePixel = 0
    searchContainer.Parent = topbar
    
    local scCorner = Instance.new("UICorner")
    scCorner.CornerRadius = UDim.new(0, 5)
    scCorner.Parent = searchContainer
    
    local scStroke = Instance.new("UIStroke")
    scStroke.Color = Color3.fromRGB(40, 45, 55)
    scStroke.Thickness = 1
    scStroke.Parent = searchContainer
    
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 14, 0, 14)
    searchIcon.Position = UDim2.new(0, 8, 0.5, -7)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://9886659671"
    searchIcon.ImageColor3 = theme.Cyan
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
    dragBtn.ImageColor3 = theme.Cyan
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
        closeBtn.TextColor3 = theme.Cyan
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
    footerText.Text = "Zee-Hub | v1.4 | Game: Grow a Garden 2"
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

function ZeeHubUI:CreateTab(name, iconId)
    local tab = setmetatable({}, Tab)
    tab.Name = name
    tab.Window = self
    tab.Controls = {}
    tab.Sections = {}
    
    -- Tab Container Frame (Offset by 50px)
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
    
    -- Tab Button wrapper frame in Sidebar (50px wide)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, 0, 0, 36)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = self.Main.Sidebar.TabContainer
    
    local activeIndicator = Instance.new("Frame")
    activeIndicator.Size = UDim2.new(0, 3, 0, 20)
    activeIndicator.Position = UDim2.new(0, 0, 0.5, -10)
    activeIndicator.BackgroundColor3 = theme.Cyan
    activeIndicator.BorderSizePixel = 0
    activeIndicator.Visible = false
    activeIndicator.Parent = btnFrame
    
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 26, 0, 26)
    btn.Position = UDim2.new(0.5, -13, 0.5, -13)
    btn.BackgroundTransparency = 1
    btn.Image = iconId or "rbxassetid://4483345998"
    btn.ImageColor3 = theme.MutedText
    btn.Parent = btnFrame
    
    btn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(220, 220, 220)}):Play()
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
    tab.Indicator = activeIndicator
    
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function ZeeHubUI:SelectTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Container.Visible = false
        self.ActiveTab.Button.ImageColor3 = theme.MutedText
        self.ActiveTab.Indicator.Visible = false
    end
    
    self.ActiveTab = tab
    tab.Container.Visible = true
    tab.Button.ImageColor3 = theme.Cyan
    tab.Indicator.Visible = true
    self.SearchBox.Text = ""
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
    main.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    main.BorderSizePixel = 0
    main.Parent = parentCol
    main.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = main
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 40, 50)
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
    secIcon.ImageColor3 = theme.Cyan
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
    switch.BackgroundColor3 = toggle.State and theme.Cyan or Color3.fromRGB(43, 42, 51)
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
        local targetColor = toggle.State and theme.Cyan or Color3.fromRGB(43, 42, 51)
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
    btn.BackgroundColor3 = theme.ElementBackground
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 40, 50)
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
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
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
            opt.TextColor3 = (item == dropdown.Value) and theme.Cyan or theme.Text
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

function Section:CreateButton(name, callback)
    local button = {}
    button.Name = name
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = theme.ElementBackground
    btn.Text = name
    btn.TextColor3 = theme.Text
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 40, 50)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 40, 50)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementBackground}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    button.Frame = frame
    table.insert(self.Controls, button)
    return button
end

--- INSTANTIATE UI ---

local UI = ZeeHubUI.new("Zee-Hub | Grow a Garden 2")

-- Tab 1: Auto Farm (Target/Compass Icon)
local farmTab = UI:CreateTab("Auto Farm", "rbxassetid://10747372704")
local farmSec = farmTab:CreateSection("Farming", "rbxassetid://4483345998", "Left")

farmSec:CreateToggle("Auto Plant", getgenv().Config.AutoPlant, function(val)
    getgenv().Config.AutoPlant = val
end)

farmSec:CreateDropdown("Pilih Benih", {"Carrot", "Tomato", "Wheat", "Corn", "Potato"}, getgenv().Config.SeedName, function(val)
    getgenv().Config.SeedName = val
end)

-- Tab 2: Settings (Gear Icon)
local settingsTab = UI:CreateTab("Settings", "rbxassetid://10747383162")
local settingsSec = settingsTab:CreateSection("Pengaturan", "rbxassetid://10747383162", "Left")

settingsSec:CreateButton("Destroy UI", function()
    UI.Gui:Destroy()
end)

--- MAIN LOOP ---
task.spawn(function()
    while task.wait(getgenv().Config.LoopDelay) do
        if getgenv().Config.AutoPlant then 
            pcall(plantSeed) 
            task.wait(0.2) 
        end
    end
end)