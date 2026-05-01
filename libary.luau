-- full ai shit dont ask

local EleriumLib = {}
EleriumLib.__index = EleriumLib

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background      = Color3.fromRGB(6, 10, 18),
    TitleBar        = Color3.fromRGB(9, 16, 28),
    Sidebar         = Color3.fromRGB(4, 8, 16),
    Content         = Color3.fromRGB(6, 10, 18),
    ComponentBg     = Color3.fromRGB(8, 14, 26),
    ComponentHover  = Color3.fromRGB(18, 44, 88),
    Accent          = Color3.fromRGB(74, 164, 255),
    AccentBright    = Color3.fromRGB(100, 180, 255),
    TextPrimary     = Color3.fromRGB(200, 210, 230),
    TextDim         = Color3.fromRGB(90, 120, 160),
    SectionText     = Color3.fromRGB(120, 160, 210),
}

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function applyCorner(p, r) 
    local c = Instance.new("UICorner") 
    c.CornerRadius = UDim.new(0, r or 6) 
    c.Parent = p 
end

local function applyStroke(p, color)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(30, 60, 100)
    s.Thickness = 1
    s.Parent = p
end

function EleriumLib:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "EleriumLib"

    local screen = Instance.new("ScreenGui")
    screen.ResetOnSpawn = false
    screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 580, 0, 420)
    win.Position = UDim2.new(0.5, -290, 0.5, -210)
    win.BackgroundColor3 = Theme.Background
    win.BorderSizePixel = 0
    win.Parent = screen
    applyCorner(win, 8)
    applyStroke(win)

    -- TitleBar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,36)
    titleBar.BackgroundColor3 = Theme.TitleBar
    titleBar.Parent = win
    applyCorner(titleBar, 8)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1,-80,1,0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Theme.AccentBright
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = titleBar
    Instance.new("UIPadding", titleLbl).PaddingLeft = UDim.new(0,14)

    -- Close Button
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,26,0,26)
    close.Position = UDim2.new(1,-34,0.5,-13)
    close.BackgroundTransparency = 1
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 70, 70)
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.Parent = titleBar

    close.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)

    -- Body
    local body = Instance.new("Frame")
    body.Size = UDim2.new(1,0,1,-36)
    body.Position = UDim2.new(0,0,0,36)
    body.BackgroundTransparency = 1
    body.Parent = win

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 130, 1, 0)
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = body

    local sidebarList = Instance.new("UIListLayout")
    sidebarList.Padding = UDim.new(0, 6)
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Parent = sidebar
    Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 12)

    -- Content ScrollingFrame
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -130, 1, 0)
    content.Position = UDim2.new(0, 130, 0, 0)
    content.BackgroundColor3 = Theme.Content
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 5
    content.ScrollBarImageColor3 = Theme.Accent
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new(0,0,0,0)
    content.Parent = body

    local contentList = Instance.new("UIListLayout")
    contentList.Padding = UDim.new(0, 8)
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Parent = content
    Instance.new("UIPadding", content).Padding = UDim.new(0, 14)

    local Window = { Tabs = {}, CurrentTab = nil }

    function Window:AddTab(name: string)
        local tab = {}

        -- Tab Button in Sidebar
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 36)
        btn.BackgroundTransparency = 1
        btn.Text = "   " .. name
        btn.TextColor3 = Theme.TextDim
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.Parent = sidebar

        local accentLine = Instance.new("Frame")
        accentLine.Size = UDim2.new(0, 4, 1, 0)
        accentLine.BackgroundColor3 = Theme.Accent
        accentLine.BackgroundTransparency = 1
        accentLine.Parent = btn

        -- Tab Panel
        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(1, 0, 0, 0)
        panel.AutomaticSize = Enum.AutomaticSize.Y
        panel.BackgroundTransparency = 1
        panel.Visible = false
        panel.Parent = content

        local panelList = Instance.new("UIListLayout")
        panelList.Padding = UDim.new(0, 7)
        panelList.SortOrder = Enum.SortOrder.LayoutOrder
        panelList.Parent = panel

        local function activate()
            if Window.CurrentTab then
                Window.CurrentTab.Btn.TextColor3 = Theme.TextDim
                tween(Window.CurrentTab.Accent, {BackgroundTransparency = 1})
                Window.CurrentTab.Panel.Visible = false
            end

            Window.CurrentTab = tab
            tab.Panel.Visible = true
            tab.Btn.TextColor3 = Theme.AccentBright
            tween(tab.Accent, {BackgroundTransparency = 0})
        end

        btn.MouseButton1Click:Connect(activate)

        tab.Btn = btn
        tab.Accent = accentLine
        tab.Panel = panel

        table.insert(Window.Tabs, tab)

        if #Window.Tabs == 1 then
            activate()
        end

        -- ==================== AddSection ====================
        function tab:AddSection(sectionTitle: string)
            local section = {}

            local sFrame = Instance.new("Frame")
            sFrame.BackgroundTransparency = 1
            sFrame.AutomaticSize = Enum.AutomaticSize.Y
            sFrame.Size = UDim2.new(1,0,0,0)
            sFrame.Parent = panel

            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 6)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = sFrame

            local header = Instance.new("TextLabel")
            header.Size = UDim2.new(1,0,0,22)
            header.BackgroundTransparency = 1
            header.Text = string.upper(sectionTitle)
            header.TextColor3 = Theme.SectionText
            header.Font = Enum.Font.GothamBold
            header.TextSize = 11
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Parent = sFrame

            local function newComp(height)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1,0,0, height or 34)
                f.BackgroundColor3 = Theme.ComponentBg
                f.BorderSizePixel = 0
                f.AutomaticSize = Enum.AutomaticSize.Y
                f.Parent = sFrame
                applyCorner(f, 6)
                applyStroke(f)
                return f
            end

            function section:AddLabel(text: string)
                local f = newComp(30)
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1,-20,1,0)
                lbl.Position = UDim2.new(0,10,0,0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = Theme.TextPrimary
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.Parent = f
                return lbl
            end

            function section:AddButton(text: string, callback)
                local f = newComp(36)
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1,0,1,0)
                b.BackgroundTransparency = 1
                b.Text = text
                b.TextColor3 = Theme.TextPrimary
                b.Font = Enum.Font.GothamMedium
                b.TextSize = 13
                b.Parent = f

                b.MouseButton1Click:Connect(function()
                    tween(f, {BackgroundColor3 = Theme.Accent}, 0.1)
                    task.delay(0.15, function() tween(f, {BackgroundColor3 = Theme.ComponentBg}, 0.2) end)
                    if callback then callback() end
                end)
            end

            -- Toggle, Slider, Dropdown kannst du später selbst erweitern oder ich baue sie dir ein.

            return section
        end

        return tab
    end

    return Window
end

return EleriumLib
