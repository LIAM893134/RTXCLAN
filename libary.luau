-- ts full ai dont ask

local EleriumLib = {}
EleriumLib.__index = EleriumLib

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ==================== THEME ====================
local Theme = {
    Background      = Color3.fromRGB(6, 10, 18),
    TitleBar        = Color3.fromRGB(9, 16, 28),
    Sidebar         = Color3.fromRGB(4, 8, 16),
    Content         = Color3.fromRGB(6, 10, 18),
    ComponentBg     = Color3.fromRGB(8, 14, 26),
    ComponentHover  = Color3.fromRGB(18, 44, 88),
    Accent          = Color3.fromRGB(30, 90, 180),
    AccentBright    = Color3.fromRGB(74, 164, 255),
    TextPrimary     = Color3.fromRGB(200, 210, 230),
    TextSecondary   = Color3.fromRGB(120, 150, 190),
    TextDim         = Color3.fromRGB(70, 100, 140),
    SectionText     = Color3.fromRGB(100, 140, 190),
    SectionLine     = Color3.fromRGB(20, 40, 70),
    ToggleOn        = Color3.fromRGB(30, 90, 180),
    ToggleOff       = Color3.fromRGB(15, 25, 45),
    SliderFill      = Color3.fromRGB(74, 164, 255),
    SliderTrack     = Color3.fromRGB(15, 25, 45),
}

-- Tween Helper
local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function applyCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
end

local function applyStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Accent
    s.Thickness = thickness or 1
    s.Transparency = 0.6
    s.Parent = parent
end

-- ==================== CREATE WINDOW ====================
function EleriumLib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "EleriumLib"
    local size = options.Size or Vector2.new(580, 420)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EleriumLib"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = UDim2.new(0, size.X, 0, size.Y)
    window.Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
    window.BackgroundColor3 = Theme.Background
    window.BorderSizePixel = 0
    window.ClipsDescendants = true
    window.Parent = screenGui
    applyCorner(window, 8)
    applyStroke(window, Color3.fromRGB(30, 60, 100), 1)

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Theme.TitleBar
    titleBar.BorderSizePixel = 0
    titleBar.Parent = window
    applyCorner(titleBar, 8)

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.TextColor3 = Theme.AccentBright
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    Instance.new("UIPadding", titleText).PaddingLeft = UDim.new(0, 14)

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar

    closeBtn.MouseButton1Click:Connect(function()
        tween(window, {BackgroundTransparency = 1}, 0.3)
        task.delay(0.3, function() screenGui:Destroy() end)
    end)

    -- Body
    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, 0, 1, -36)
    body.Position = UDim2.new(0, 0, 0, 36)
    body.BackgroundTransparency = 1
    body.Parent = window

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 120, 1, 0)
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = body

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Parent = sidebar
    Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 10)

    -- Content
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -120, 1, 0)
    content.Position = UDim2.new(0, 120, 0, 0)
    content.BackgroundColor3 = Theme.Content
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 5
    content.ScrollBarImageColor3 = Theme.Accent
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new(0,0,0,0)
    content.Parent = body

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content
    Instance.new("UIPadding", content).Padding = UDim.new(0, 12)

    -- Window Object
    local WindowObj = {
        Tabs = {},
        CurrentTab = nil
    }

    -- ==================== ADD TAB ====================
    function WindowObj:AddTab(tabName: string)
        local tab = {}

        -- Sidebar Button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -12, 0, 34)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Theme.TextDim
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 13
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.LayoutOrder = #WindowObj.Tabs + 1
        tabBtn.Parent = sidebar
        Instance.new("UIPadding", tabBtn).PaddingLeft = UDim.new(0, 14)

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 3, 1, 0)
        accent.BackgroundColor3 = Theme.AccentBright
        accent.BackgroundTransparency = 1
        accent.Parent = tabBtn

        -- Tab Panel
        local tabPanel = Instance.new("Frame")
        tabPanel.Size = UDim2.new(1, 0, 0, 0)
        tabPanel.AutomaticSize = Enum.AutomaticSize.Y
        tabPanel.BackgroundTransparency = 1
        tabPanel.Visible = false
        tabPanel.Parent = content

        local panelLayout = Instance.new("UIListLayout")
        panelLayout.Padding = UDim.new(0, 7)
        panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
        panelLayout.Parent = tabPanel

        local function switchToThisTab()
            if WindowObj.CurrentTab then
                WindowObj.CurrentTab.Button.TextColor3 = Theme.TextDim
                tween(WindowObj.CurrentTab.Accent, {BackgroundTransparency = 1}, 0.15)
                WindowObj.CurrentTab.Panel.Visible = false
            end
            WindowObj.CurrentTab = tab
            tab.Panel.Visible = true
            tab.Button.TextColor3 = Theme.AccentBright
            tween(tab.Accent, {BackgroundTransparency = 0}, 0.15)
        end

        tabBtn.MouseButton1Click:Connect(switchToThisTab)

        tab.Button = tabBtn
        tab.Accent = accent
        tab.Panel = tabPanel

        table.insert(WindowObj.Tabs, tab)

        if #WindowObj.Tabs == 1 then
            switchToThisTab()
        end

        -- ==================== SECTION ====================
        function tab:AddSection(sectionName: string)
            local section = {}

            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(1, 0, 0, 0)
            sFrame.AutomaticSize = Enum.AutomaticSize.Y
            sFrame.BackgroundTransparency = 1
            sFrame.Parent = tabPanel

            local sLayout = Instance.new("UIListLayout")
            sLayout.Padding = UDim.new(0, 5)
            sLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sLayout.Parent = sFrame

            -- Section Header
            local header = Instance.new("TextLabel")
            header.Size = UDim2.new(1, 0, 0, 24)
            header.BackgroundTransparency = 1
            header.Text = string.upper(sectionName)
            header.TextColor3 = Theme.SectionText
            header.Font = Enum.Font.GothamBold
            header.TextSize = 11
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Parent = sFrame

            local function createComponent(height)
                local comp = Instance.new("Frame")
                comp.Size = UDim2.new(1, 0, 0, height or 34)
                comp.BackgroundColor3 = Theme.ComponentBg
                comp.BorderSizePixel = 0
                comp.Parent = sFrame
                applyCorner(comp, 6)
                applyStroke(comp, Color3.fromRGB(25, 55, 90), 1)

                comp.MouseEnter:Connect(function()
                    tween(comp, {BackgroundColor3 = Theme.ComponentHover}, 0.15)
                end)
                comp.MouseLeave:Connect(function()
                    tween(comp, {BackgroundColor3 = Theme.ComponentBg}, 0.15)
                end)

                return comp
            end

            -- Label
            function section:AddLabel(text: string)
                local frame = createComponent(30)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -20, 1, 0)
                label.Position = UDim2.new(0, 10, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = Theme.TextPrimary
                label.Font = Enum.Font.Gotham
                label.TextSize = 13
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame
                return label
            end

            -- Button
            function section:AddButton(text: string, callback: () -> ())
                local frame = createComponent(36)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundTransparency = 1
                btn.Text = text
                btn.TextColor3 = Theme.TextPrimary
                btn.Font = Enum.Font.GothamMedium
                btn.TextSize = 13
                btn.Parent = frame

                btn.MouseButton1Click:Connect(function()
                    tween(frame, {BackgroundColor3 = Theme.Accent}, 0.1)
                    task.delay(0.15, function()
                        tween(frame, {BackgroundColor3 = Theme.ComponentBg}, 0.2)
                    end)
                    if callback then callback() end
                end)
            end

            -- Toggle
            function section:AddToggle(text: string, default: boolean, callback)
                local state = default or false
                local frame = createComponent(34)

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -60, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = Theme.TextPrimary
                label.Font = Enum.Font.Gotham
                label.TextSize = 13
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame
                Instance.new("UIPadding", label).PaddingLeft = UDim.new(0, 10)

                local track = Instance.new("Frame")
                track.Size = UDim2.new(0, 42, 0, 20)
                track.Position = UDim2.new(1, -52, 0.5, -10)
                track.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
                track.Parent = frame
                applyCorner(track, 10)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 16, 0, 16)
                knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                knob.BackgroundColor3 = Color3.new(1,1,1)
                knob.Parent = track
                applyCorner(knob, 8)

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.Parent = frame

                btn.MouseButton1Click:Connect(function()
                    state = not state
                    tween(track, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}, 0.25)
                    tween(knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.25)
                    if callback then callback(state) end
                end)

                local toggleObj = {}
                function toggleObj:Set(val)
                    state = val
                    tween(track, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}, 0.25)
                    tween(knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.25)
                    if callback then callback(state) end
                end
                function toggleObj:Get() return state end
                return toggleObj
            end

            -- Slider
            function section:AddSlider(text: string, min: number, max: number, default: number, callback)
                min = min or 0
                max = max or 100
                default = math.clamp(default or min, min, max)

                local value = default
                local frame = createComponent(50)

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.6, 0, 0, 20)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = Theme.TextPrimary
                label.Font = Enum.Font.Gotham
                label.TextSize = 13
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0.4, 0, 0, 20)
                valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(value)
                valueLabel.TextColor3 = Theme.AccentBright
                valueLabel.Font = Enum.Font.GothamBold
                valueLabel.TextSize = 13
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = frame

                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, -20, 0, 6)
                track.Position = UDim2.new(0, 10, 0, 32)
                track.BackgroundColor3 = Theme.SliderTrack
                track.Parent = frame
                applyCorner(track, 3)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                fill.BackgroundColor3 = Theme.SliderFill
                fill.Parent = track
                applyCorner(fill, 3)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 14, 0, 14)
                knob.AnchorPoint = Vector2.new(0.5, 0.5)
                knob.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
                knob.BackgroundColor3 = Color3.new(1,1,1)
                knob.ZIndex = 2
                knob.Parent = track
                applyCorner(knob, 7)

                local dragging = false

                local function updateSlider(posX)
                    local rel = math.clamp((posX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + rel * (max - min) + 0.5)
                    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    knob.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
                    valueLabel.Text = tostring(value)
                    if callback then callback(value) end
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input.Position.X)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input.Position.X)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                local sliderObj = {}
                function sliderObj:Set(val)
                    value = math.clamp(val, min, max)
                    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    knob.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
                    valueLabel.Text = tostring(value)
                    if callback then callback(value) end
                end
                return sliderObj
            end

            -- Dropdown (einfach & funktional)
            function section:AddDropdown(text: string, options: table, default: string, callback)
                local selected = default or options[1] or "None"
                local frame = createComponent(34)

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.5, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = Theme.TextPrimary
                label.Font = Enum.Font.Gotham
                label.TextSize = 13
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame
                Instance.new("UIPadding", label).PaddingLeft = UDim.new(0, 10)

                local dropBtn = Instance.new("TextButton")
                dropBtn.Size = UDim2.new(0.48, 0, 0, 26)
                dropBtn.Position = UDim2.new(1, -10, 0.5, -13)
                dropBtn.AnchorPoint = Vector2.new(1, 0)
                dropBtn.BackgroundColor3 = Theme.Background
                dropBtn.Text = selected .. " ▼"
                dropBtn.TextColor3 = Theme.AccentBright
                dropBtn.Font = Enum.Font.Gotham
                dropBtn.TextSize = 12
                dropBtn.Parent = frame
                applyCorner(dropBtn, 5)

                -- Dropdown List (einfach gehalten)
                local listFrame = Instance.new("Frame")
                listFrame.Visible = false
                listFrame.Size = UDim2.new(0.48, 0, 0, 0)
                listFrame.Position = UDim2.new(1, -10, 1, 5)
                listFrame.AnchorPoint = Vector2.new(1, 0)
                listFrame.BackgroundColor3 = Theme.ComponentBg
                listFrame.ZIndex = 50
                listFrame.Parent = frame
                applyCorner(listFrame, 5)
                applyStroke(listFrame)

                local listLayout = Instance.new("UIListLayout")
                listLayout.Padding = UDim.new(0, 1)
                listLayout.Parent = listFrame

                for _, opt in ipairs(options) do
                    local item = Instance.new("TextButton")
                    item.Size = UDim2.new(1, 0, 0, 24)
                    item.BackgroundTransparency = 1
                    item.Text = "  " .. opt
                    item.TextColor3 = Theme.TextSecondary
                    item.TextXAlignment = Enum.TextXAlignment.Left
                    item.Font = Enum.Font.Gotham
                    item.TextSize = 12
                    item.ZIndex = 51
                    item.Parent = listFrame

                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        dropBtn.Text = selected .. " ▼"
                        listFrame.Visible = false
                        if callback then callback(selected) end
                    end)
                end

                dropBtn.MouseButton1Click:Connect(function()
                    listFrame.Visible = not listFrame.Visible
                end)

                local dd = {}
                function dd:Set(val)
                    selected = val
                    dropBtn.Text = selected .. " ▼"
                end
                return dd
            end

            return section
        end

        return tab
    end

    return WindowObj
end

return EleriumLib
