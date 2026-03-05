--[[
╔═══════════════════════════════════════════════════════════╗
║  NEXUS UI  ·  v2.0 - REFACTORED                          ║
║  Theme: OG Sentence                                       ║
║  Architecture: Modular, Clean, Maintainable              ║
╚═══════════════════════════════════════════════════════════╝
--]]

-- ══════════════════════════════════════════════════════════
-- CORE LIBRARY
-- ══════════════════════════════════════════════════════════
local Nexus = {
    Version = "2.0",
    Flags = {},
    Options = {},
    _connections = {},
    _activeTheme = nil,
}

-- ══════════════════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════
-- THEME SYSTEM
-- ══════════════════════════════════════════════════════════
local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new(config)
    local self = setmetatable({}, ThemeManager)
    
    -- Parse hex colors to Color3
    self.colors = {}
    for key, hexValue in pairs(config) do
        if type(hexValue) == "string" and hexValue:sub(1,1) == "#" then
            self.colors[key] = self:HexToColor3(hexValue)
        else
            self.colors[key] = hexValue
        end
    end
    
    return self
end

function ThemeManager:HexToColor3(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1,2), 16) / 255
    local g = tonumber(hex:sub(3,4), 16) / 255
    local b = tonumber(hex:sub(5,6), 16) / 255
    return Color3.new(r, g, b)
end

function ThemeManager:Get(colorName)
    return self.colors[colorName] or Color3.new(1, 1, 1)
end

-- Initialize OG Sentence Theme
local OGSentenceTheme = ThemeManager.new({
    Name = "OG Sentence",
    PrimaryBackground = "#121212",
    SecondaryBackground = "#161616",
    TertiaryBackground = "#1a1a1a",
    BorderColor = "#252525",
    AccentColor = "#5A9FE8",
    TextPrimary = "#E8E8E8",
    TextSecondary = "#909090",
    ConsoleBackground = "#181818",
    ConsoleBorder = "#252525",
    ConsoleHeader = "#181818",
    ConsoleHeaderBorder = "#2d2d2d",
    ConsoleContent = "#151515",
    MenuBackground = "#181818",
    MenuBorder = "#2d2d2d",
    EditorBackground = "#111111",
    EditorForeground = "#d4d4d4",
    EditorLineHighlight = "#1e1e1e",
    EditorSelection = "#2d5a8a",
    EditorCursor = "#5A9FE8",
    EditorLineNumber = "#757575",
    EditorActiveLineNumber = "#c6c6c6",
    EditorPanelBackground = "#121212",
    EditorPanelBorder = "#252525",
    EditorStatusBar = "#161616",
    EditorNavbar = "#121212",
    WindowShadowColor = "#e3e4e6",
    ButtonNormalBackground = "#1f1f1f",
    ButtonNormalForeground = "#C8C8C8",
    ButtonNormalBorder = "#2d2d2d",
    ButtonHoverBackground = "#252525",
    ButtonPressedBackground = "#161616",
    ButtonPressedForeground = "#5A9FE8",
    ButtonDisabledBackground = "#141414",
    ButtonDisabledForeground = "#505050",
    ScriptsPanelBackground = "#121212",
    ScriptsPanelBorder = "#252525",
    ScriptsPanelHeader = "#181818",
    ScriptsPanelHeaderBorder = "#2d2d2d",
    ScriptsPanelHeaderText = "#A8A8A8",
    AutoExecPanelBackground = "#121212",
    AutoExecPanelBorder = "#252525",
    AutoExecPanelHeader = "#181818",
    AutoExecPanelHeaderBorder = "#2d2d2d",
    AutoExecPanelHeaderText = "#A8A8A8",
    AutoExecPlaceholderText = "#B0B0B0",
    GridSplitterColor = "#252525",
    NotificationPanelBackground = "#202020",
    NotificationPanelBorder = "#252525",
    NotificationPanelAccent = "#5A9FE8",
    NotificationPanelAccentGradientStart = "#5A9FE8",
    NotificationPanelAccentGradientEnd = "#4580C9",
    NotificationPanelIconBackground = "#161616",
    NotificationPanelIconBorder = "#2d2d2d",
    NotificationPanelText = "#E8E8E8"
})

Nexus._activeTheme = OGSentenceTheme

-- ══════════════════════════════════════════════════════════
-- TWEEN UTILITIES
-- ══════════════════════════════════════════════════════════
local TweenUtil = {}

function TweenUtil.Create(instance, properties, duration, style, direction, callback)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Exponential,
        direction or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    
    if callback then
        tween.Completed:Once(callback)
    end
    
    tween:Play()
    return tween
end

-- ══════════════════════════════════════════════════════════
-- DRAG SYSTEM (FIXED)
-- ══════════════════════════════════════════════════════════
local DragSystem = {}

function DragSystem.Enable(frame, dragHandle)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    local connection
    
    local function update(input)
        if not dragging then return end
        
        local delta = input.Position - dragStart
        TweenUtil.Create(frame, {
            Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        }, 0.1)
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            -- Track when mouse button is released globally
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                end
            end)
        end
    end)
    
    -- Global mouse movement tracking (FIXED - nie puszcza się przy szybkim ruchu)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- ══════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM (FIXED)
-- ══════════════════════════════════════════════════════════
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(parent, theme)
    local self = setmetatable({}, NotificationSystem)
    self.theme = theme
    self.container = self:CreateContainer(parent)
    return self
end

function NotificationSystem:CreateContainer(parent)
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 320, 1, -20)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.ZIndex = 200
    container.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = container
    
    return container
end

function NotificationSystem:Show(config)
    task.spawn(function()
        local title = config.Title or "Notification"
        local content = config.Content or ""
        local icon = config.Icon or "info"
        local notifType = config.Type or "Info"
        local duration = config.Duration or math.clamp(#content * 0.05 + 2, 2, 6)
        
        -- Type color mapping
        local typeColors = {
            Info = self.theme:Get("AccentColor"),
            Success = Color3.fromRGB(0, 214, 143),
            Warning = Color3.fromRGB(255, 184, 0),
            Error = Color3.fromRGB(255, 60, 60)
        }
        
        local accentColor = typeColors[notifType] or self.theme:Get("AccentColor")
        
        -- Create notification frame
        local notif = Instance.new("Frame")
        notif.Name = "Notification"
        notif.Size = UDim2.new(1, 0, 0, 0)
        notif.BackgroundColor3 = self.theme:Get("NotificationPanelBackground")
        notif.BackgroundTransparency = 1
        notif.BorderSizePixel = 0
        notif.ClipsDescendants = true
        notif.Parent = self.container
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = notif
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = self.theme:Get("NotificationPanelBorder")
        stroke.Transparency = 1
        stroke.Thickness = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = notif
        
        -- Accent bar
        local accentBar = Instance.new("Frame")
        accentBar.Size = UDim2.new(0, 3, 1, -8)
        accentBar.Position = UDim2.new(0, 0, 0, 4)
        accentBar.BackgroundColor3 = accentColor
        accentBar.BackgroundTransparency = 1
        accentBar.BorderSizePixel = 0
        accentBar.Parent = notif
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 2)
        barCorner.Parent = accentBar
        
        -- Icon
        local iconFrame = Instance.new("ImageLabel")
        iconFrame.Size = UDim2.new(0, 16, 0, 16)
        iconFrame.Position = UDim2.new(0, 14, 0, 12)
        iconFrame.BackgroundTransparency = 1
        iconFrame.Image = self:GetIcon(icon)
        iconFrame.ImageColor3 = accentColor
        iconFrame.ImageTransparency = 1
        iconFrame.Parent = notif
        
        -- Title
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, -45, 0, 16)
        titleLabel.Position = UDim2.new(0, 38, 0, 8)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 13
        titleLabel.TextColor3 = self.theme:Get("NotificationPanelText")
        titleLabel.TextTransparency = 1
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Text = title
        titleLabel.Parent = notif
        
        -- Content
        local contentLabel = Instance.new("TextLabel")
        contentLabel.Name = "Content"
        contentLabel.Size = UDim2.new(1, -45, 0, 1000)
        contentLabel.Position = UDim2.new(0, 38, 0, 26)
        contentLabel.BackgroundTransparency = 1
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.TextSize = 12
        contentLabel.TextColor3 = self.theme:Get("TextSecondary")
        contentLabel.TextTransparency = 1
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
        contentLabel.TextWrapped = true
        contentLabel.Text = content
        contentLabel.RichText = true
        contentLabel.Parent = notif
        
        -- Calculate height
        task.wait()
        local textHeight = contentLabel.TextBounds.Y
        contentLabel.Size = UDim2.new(1, -45, 0, textHeight)
        local totalHeight = 38 + textHeight
        
        -- Animate in
        TweenUtil.Create(notif, {
            Size = UDim2.new(1, 0, 0, totalHeight),
            BackgroundTransparency = 0
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        task.wait(0.1)
        
        TweenUtil.Create(stroke, {Transparency = 0.7}, 0.2)
        TweenUtil.Create(accentBar, {BackgroundTransparency = 0}, 0.2)
        TweenUtil.Create(iconFrame, {ImageTransparency = 0}, 0.2)
        TweenUtil.Create(titleLabel, {TextTransparency = 0}, 0.2)
        
        task.wait(0.05)
        
        TweenUtil.Create(contentLabel, {TextTransparency = 0.2}, 0.2)
        
        -- Wait duration
        task.wait(duration)
        
        -- Animate out
        TweenUtil.Create(notif, {BackgroundTransparency = 1}, 0.25)
        TweenUtil.Create(stroke, {Transparency = 1}, 0.25)
        TweenUtil.Create(accentBar, {BackgroundTransparency = 1}, 0.25)
        TweenUtil.Create(iconFrame, {ImageTransparency = 1}, 0.25)
        TweenUtil.Create(titleLabel, {TextTransparency = 1}, 0.25)
        TweenUtil.Create(contentLabel, {TextTransparency = 1}, 0.25)
        
        task.wait(0.3)
        
        TweenUtil.Create(notif, {
            Size = UDim2.new(1, 0, 0, 0)
        }, 0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, function()
            notif:Destroy()
        end)
    end)
end

function NotificationSystem:GetIcon(iconName)
    local icons = {
        info = "rbxassetid://6026568227",
        success = "rbxassetid://6031094667",
        warning = "rbxassetid://6031071053",
        error = "rbxassetid://6031094678",
        home = "rbxassetid://6026568195",
        settings = "rbxassetid://6031280882",
        save = "rbxassetid://6035067857",
    }
    
    return icons[iconName] or icons.info
end

-- ══════════════════════════════════════════════════════════
-- UI COMPONENT BUILDER
-- ══════════════════════════════════════════════════════════
local ComponentBuilder = {}

function ComponentBuilder.CreateFrame(config)
    config = config or {}
    
    local frame = Instance.new("Frame")
    frame.Name = config.Name or "Frame"
    frame.Size = config.Size or UDim2.new(1, 0, 0, 36)
    frame.Position = config.Position or UDim2.new(0, 0, 0, 0)
    frame.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    frame.BackgroundColor3 = config.BackgroundColor or Color3.fromRGB(18, 18, 18)
    frame.BackgroundTransparency = config.BackgroundTransparency or 0
    frame.BorderSizePixel = 0
    frame.ZIndex = config.ZIndex or 1
    frame.ClipsDescendants = config.ClipsDescendants or false
    
    if config.CornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, config.CornerRadius)
        corner.Parent = frame
    end
    
    if config.Stroke then
        local stroke = Instance.new("UIStroke")
        stroke.Color = config.StrokeColor or Color3.fromRGB(37, 37, 37)
        stroke.Transparency = config.StrokeTransparency or 0.3
        stroke.Thickness = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = frame
    end
    
    if config.Parent then
        frame.Parent = config.Parent
    end
    
    return frame
end

function ComponentBuilder.CreateTextLabel(config)
    config = config or {}
    
    local label = Instance.new("TextLabel")
    label.Name = config.Name or "TextLabel"
    label.Size = config.Size or UDim2.new(1, 0, 0, 20)
    label.Position = config.Position or UDim2.new(0, 0, 0, 0)
    label.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    label.BackgroundTransparency = 1
    label.Font = config.Font or Enum.Font.GothamSemibold
    label.TextSize = config.TextSize or 14
    label.TextColor3 = config.TextColor or Color3.fromRGB(232, 232, 232)
    label.TextTransparency = config.TextTransparency or 0
    label.TextXAlignment = config.TextXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = config.TextYAlignment or Enum.TextYAlignment.Center
    label.Text = config.Text or ""
    label.RichText = true
    label.ZIndex = config.ZIndex or 2
    
    if config.Parent then
        label.Parent = config.Parent
    end
    
    return label
end

function ComponentBuilder.CreateImageLabel(config)
    config = config or {}
    
    local image = Instance.new("ImageLabel")
    image.Name = config.Name or "ImageLabel"
    image.Size = config.Size or UDim2.new(0, 20, 0, 20)
    image.Position = config.Position or UDim2.new(0.5, 0, 0.5, 0)
    image.AnchorPoint = config.AnchorPoint or Vector2.new(0.5, 0.5)
    image.BackgroundTransparency = 1
    image.Image = config.Image or ""
    image.ImageColor3 = config.ImageColor or Color3.fromRGB(232, 232, 232)
    image.ImageTransparency = config.ImageTransparency or 0
    image.ScaleType = Enum.ScaleType.Fit
    image.ZIndex = config.ZIndex or 3
    
    if config.Parent then
        image.Parent = config.Parent
    end
    
    return image
end

function ComponentBuilder.CreateButton(parent, zIndex)
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = zIndex or 10
    button.Parent = parent
    return button
end

-- ══════════════════════════════════════════════════════════
-- TAB MANAGER (FIXED - tylko jedna zakładka aktywna)
-- ══════════════════════════════════════════════════════════
local TabManager = {}
TabManager.__index = TabManager

function TabManager.new(window, theme)
    local self = setmetatable({}, TabManager)
    self.window = window
    self.theme = theme
    self.tabs = {}
    self.activeTab = nil
    self.homeTab = nil
    return self
end

function TabManager:DeactivateAll()
    -- Deactivate all tabs
    for _, tab in pairs(self.tabs) do
        if tab.page then
            tab.page.Visible = false
        end
        if tab.activeBar then
            TweenUtil.Create(tab.activeBar, {BackgroundTransparency = 1}, 0.15)
        end
        if tab.icon then
            TweenUtil.Create(tab.icon, {
                ImageColor3 = self.theme:Get("TextSecondary")
            }, 0.15)
        end
        if tab.button then
            TweenUtil.Create(tab.button, {BackgroundTransparency = 1}, 0.15)
        end
    end
    
    -- Deactivate home tab
    if self.homeTab then
        if self.homeTab.page then
            self.homeTab.page.Visible = false
        end
        if self.homeTab.activeBar then
            TweenUtil.Create(self.homeTab.activeBar, {BackgroundTransparency = 1}, 0.15)
        end
        if self.homeTab.icon then
            TweenUtil.Create(self.homeTab.icon, {
                ImageColor3 = self.theme:Get("TextSecondary")
            }, 0.15)
        end
        if self.homeTab.button then
            TweenUtil.Create(self.homeTab.button, {BackgroundTransparency = 1}, 0.15)
        end
    end
end

function TabManager:ActivateTab(tabName)
    self:DeactivateAll()
    
    local tab = self.tabs[tabName] or (tabName == "Home" and self.homeTab)
    if not tab then return end
    
    self.activeTab = tabName
    
    if tab.page then
        tab.page.Visible = true
    end
    
    if tab.activeBar then
        TweenUtil.Create(tab.activeBar, {BackgroundTransparency = 0}, 0.15)
    end
    
    if tab.icon then
        TweenUtil.Create(tab.icon, {
            ImageColor3 = self.theme:Get("AccentColor")
        }, 0.15)
    end
    
    if tab.button then
        TweenUtil.Create(tab.button, {BackgroundTransparency = 0.88}, 0.15)
    end
end

-- ══════════════════════════════════════════════════════════
-- WINDOW BUILDER
-- ══════════════════════════════════════════════════════════
function Nexus:CreateWindow(config)
    config = config or {}
    config.Name = config.Name or "NEXUS"
    config.Subtitle = config.Subtitle or ""
    config.Icon = config.Icon or ""
    config.ToggleBind = config.ToggleBind or Enum.KeyCode.RightControl
    config.LoadingEnabled = config.LoadingEnabled ~= false
    config.LoadingTitle = config.LoadingTitle or "NEXUS"
    config.LoadingSubtitle = config.LoadingSubtitle or "Loading..."
    
    local theme = self._activeTheme
    
    -- Calculate dimensions
    local viewportSize = Camera.ViewportSize
    local windowWidth = math.clamp(viewportSize.X - 100, 560, 750)
    local windowHeight = math.clamp(viewportSize.Y - 80, 400, 500)
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusUI_v2"
    screenGui.DisplayOrder = 999999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = CoreGui
    end
    
    -- Create notification system
    local notificationSystem = NotificationSystem.new(screenGui, theme)
    
    -- Main window
    local mainWindow = ComponentBuilder.CreateFrame({
        Name = "MainWindow",
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor = theme:Get("PrimaryBackground"),
        BackgroundTransparency = 0,
        CornerRadius = 6,
        Stroke = true,
        StrokeColor = theme:Get("BorderColor"),
        StrokeTransparency = 0.3,
        ClipsDescendants = true,
        Parent = screenGui
    })
    
    -- Top accent line
    local topAccent = ComponentBuilder.CreateFrame({
        Name = "TopAccent",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor = theme:Get("AccentColor"),
        BackgroundTransparency = 0.35,
        Parent = mainWindow
    })
    
    -- Title bar
    local titleBarHeight = 40
    local titleBar = ComponentBuilder.CreateFrame({
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, titleBarHeight),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = mainWindow
    })
    
    -- Enable dragging (FIXED)
    DragSystem.Enable(mainWindow, titleBar)
    
    -- Window control buttons
    local controlButtons = {}
    local buttonData = {
        {symbol = "✕", color = Color3.fromRGB(255, 60, 60), action = "close"},
        {symbol = "−", color = theme:Get("TextSecondary"), action = "minimize"},
        {symbol = "○", color = theme:Get("TextSecondary"), action = "hide"}
    }
    
    for i, data in ipairs(buttonData) do
        local xPos = 10 + (i - 1) * 30
        
        local btnFrame = ComponentBuilder.CreateFrame({
            Name = data.action,
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0, xPos, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor = theme:Get("TertiaryBackground"),
            BackgroundTransparency = 0.6,
            CornerRadius = 4,
            Stroke = true,
            StrokeColor = theme:Get("BorderColor"),
            StrokeTransparency = 0.5,
            ZIndex = 5,
            Parent = titleBar
        })
        
        local btnLabel = ComponentBuilder.CreateTextLabel({
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor = theme:Get("TextSecondary"),
            Text = data.symbol,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 6,
            Parent = btnFrame
        })
        
        local btn = ComponentBuilder.CreateButton(btnFrame, 7)
        
        btnFrame.MouseEnter:Connect(function()
            TweenUtil.Create(btnFrame, {
                BackgroundColor3 = data.color,
                BackgroundTransparency = 0
            }, 0.15)
            TweenUtil.Create(btnLabel, {
                TextColor3 = Color3.new(1, 1, 1)
            }, 0.15)
        end)
        
        btnFrame.MouseLeave:Connect(function()
            TweenUtil.Create(btnFrame, {
                BackgroundColor3 = theme:Get("TertiaryBackground"),
                BackgroundTransparency = 0.6
            }, 0.15)
            TweenUtil.Create(btnLabel, {
                TextColor3 = theme:Get("TextSecondary")
            }, 0.15)
        end)
        
        controlButtons[data.action] = {frame = btnFrame, button = btn}
    end
    
    -- Window title
    local titleLabel = ComponentBuilder.CreateTextLabel({
        Name = "Title",
        Size = UDim2.new(0, 200, 0, 16),
        Position = UDim2.new(0, 108, 0, 8),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor = theme:Get("TextPrimary"),
        Text = config.Name,
        ZIndex = 5,
        Parent = titleBar
    })
    
    local subtitleLabel = ComponentBuilder.CreateTextLabel({
        Name = "Subtitle",
        Size = UDim2.new(0, 200, 0, 12),
        Position = UDim2.new(0, 108, 0, 24),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor = theme:Get("TextSecondary"),
        Text = config.Subtitle ~= "" and ("/ " .. config.Subtitle) or ("/ v" .. self.Version),
        ZIndex = 5,
        Parent = titleBar
    })
    
    -- Sidebar
    local sidebarWidth = 48
    local sidebar = ComponentBuilder.CreateFrame({
        Name = "Sidebar",
        Size = UDim2.new(0, sidebarWidth, 1, -titleBarHeight - 2),
        Position = UDim2.new(0, 0, 0, titleBarHeight + 2),
        BackgroundColor = theme:Get("SecondaryBackground"),
        BackgroundTransparency = 0,
        ZIndex = 3,
        Parent = mainWindow
    })
    
    -- Sidebar border
    local sidebarBorder = ComponentBuilder.CreateFrame({
        Name = "Border",
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor = theme:Get("BorderColor"),
        BackgroundTransparency = 0.4,
        Parent = sidebar
    })
    
    -- Tab icons container
    local tabIconsContainer = Instance.new("ScrollingFrame")
    tabIconsContainer.Name = "TabIcons"
    tabIconsContainer.Size = UDim2.new(1, 0, 1, -56)
    tabIconsContainer.Position = UDim2.new(0, 0, 0, 22)
    tabIconsContainer.BackgroundTransparency = 1
    tabIconsContainer.BorderSizePixel = 0
    tabIconsContainer.ScrollBarThickness = 0
    tabIconsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabIconsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabIconsContainer.ZIndex = 4
    tabIconsContainer.Parent = sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabIconsContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 4)
    tabPadding.PaddingBottom = UDim.new(0, 4)
    tabPadding.Parent = tabIconsContainer
    
    -- Avatar at bottom
    local avatarFrame = ComponentBuilder.CreateFrame({
        Name = "Avatar",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0.5, 0, 1, -10),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor = theme:Get("TertiaryBackground"),
        CornerRadius = 4,
        ZIndex = 4,
        Parent = sidebar
    })
    
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.BackgroundTransparency = 1
    avatarImage.ZIndex = 5
    avatarImage.Parent = avatarFrame
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 4)
    avatarCorner.Parent = avatarImage
    
    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = theme:Get("AccentColor")
    avatarStroke.Thickness = 1.5
    avatarStroke.Transparency = 0.55
    avatarStroke.Parent = avatarImage
    
    pcall(function()
        avatarImage.Image = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size48x48
        )
    end)
    
    -- Content area
    local contentArea = ComponentBuilder.CreateFrame({
        Name = "ContentArea",
        Size = UDim2.new(1, -sidebarWidth - 1, 1, -titleBarHeight - 2),
        Position = UDim2.new(0, sidebarWidth + 1, 0, titleBarHeight + 2),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = mainWindow
    })
    
    -- Tooltip
    local tooltip = ComponentBuilder.CreateFrame({
        Name = "Tooltip",
        Size = UDim2.new(0, 0, 0, 24),
        Position = UDim2.new(0, sidebarWidth + 4, 0, 0),
        BackgroundColor = theme:Get("TertiaryBackground"),
        CornerRadius = 4,
        Stroke = true,
        StrokeColor = theme:Get("BorderColor"),
        StrokeTransparency = 0.2,
        ZIndex = 20,
        Parent = mainWindow
    })
    tooltip.Visible = false
    tooltip.AutomaticSize = Enum.AutomaticSize.X
    
    local tooltipPadding = Instance.new("UIPadding")
    tooltipPadding.PaddingLeft = UDim.new(0, 8)
    tooltipPadding.PaddingRight = UDim.new(0, 8)
    tooltipPadding.Parent = tooltip
    
    local tooltipLabel = ComponentBuilder.CreateTextLabel({
        Size = UDim2.new(0, 0, 1, 0),
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextColor = theme:Get("TextPrimary"),
        Text = "",
        ZIndex = 21,
        Parent = tooltip
    })
    tooltipLabel.AutomaticSize = Enum.AutomaticSize.X
    
    -- Tab Manager
    local tabManager = TabManager.new(mainWindow, theme)
    
    -- Window state
    local windowState = {
        gui = screenGui,
        window = mainWindow,
        content = contentArea,
        tabManager = tabManager,
        notificationSystem = notificationSystem,
        theme = theme,
        visible = true,
        minimized = false,
        sidebarWidth = sidebarWidth,
        titleBarHeight = titleBarHeight,
        windowWidth = windowWidth,
        windowHeight = windowHeight,
        tabIconsContainer = tabIconsContainer,
        tooltip = tooltip,
        tooltipLabel = tooltipLabel,
        config = config
    }
    
    -- Loading screen
    if config.LoadingEnabled then
        self:ShowLoadingScreen(windowState)
    else
        TweenUtil.Create(mainWindow, {
            Size = UDim2.new(0, windowWidth, 0, windowHeight)
        }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
    
    -- Window controls
    controlButtons.close.button.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    controlButtons.hide.button.MouseButton1Click:Connect(function()
        windowState.visible = false
        TweenUtil.Create(mainWindow, {
            Size = UDim2.new(0, 0, 0, 0)
        }, 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, function()
            mainWindow.Visible = false
        end)
        
        self:Notify({
            Title = "Window Hidden",
            Content = "Press " .. config.ToggleBind.Name .. " to restore.",
            Type = "Info"
        })
    end)
    
    controlButtons.minimize.button.MouseButton1Click:Connect(function()
        windowState.minimized = not windowState.minimized
        
        if windowState.minimized then
            sidebar.Visible = false
            contentArea.Visible = false
            TweenUtil.Create(mainWindow, {
                Size = UDim2.new(0, windowWidth, 0, 40)
            }, 0.25)
        else
            TweenUtil.Create(mainWindow, {
                Size = UDim2.new(0, windowWidth, 0, windowHeight)
            }, 0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, function()
                sidebar.Visible = true
                contentArea.Visible = true
            end)
        end
    end)
    
    -- Toggle bind
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == config.ToggleBind then
            if windowState.visible then
                windowState.visible = false
                TweenUtil.Create(mainWindow, {
                    Size = UDim2.new(0, 0, 0, 0)
                }, 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, function()
                    mainWindow.Visible = false
                end)
            else
                mainWindow.Visible = true
                windowState.visible = true
                TweenUtil.Create(mainWindow, {
                    Size = windowState.minimized and 
                        UDim2.new(0, windowWidth, 0, 40) or 
                        UDim2.new(0, windowWidth, 0, windowHeight)
                }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end
        end
    end))
    
    -- Window API
    windowState.CreateHomeTab = function(self, homeConfig)
        return self:CreateHomeTabImpl(homeConfig)
    end
    
    windowState.CreateTab = function(self, tabConfig)
        return self:CreateTabImpl(tabConfig)
    end
    
    windowState.CreateHomeTabImpl = function(self, homeConfig)
        homeConfig = homeConfig or {}
        homeConfig.Icon = homeConfig.Icon or "rbxassetid://6026568195"
        
        -- Create home button
        local homeButton = ComponentBuilder.CreateFrame({
            Name = "HomeButton",
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundColor = theme:Get("AccentColor"),
            BackgroundTransparency = 0.1,
            CornerRadius = 4,
            ZIndex = 5,
            Parent = tabIconsContainer
        })
        
        local homeActiveBar = ComponentBuilder.CreateFrame({
            Name = "ActiveBar",
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor = theme:Get("AccentColor"),
            BackgroundTransparency = 0,
            ZIndex = 6,
            Parent = homeButton
        })
        
        local homeIcon = ComponentBuilder.CreateImageLabel({
            Name = "Icon",
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = homeConfig.Icon,
            ImageColor = theme:Get("AccentColor"),
            ZIndex = 6,
            Parent = homeButton
        })
        
        local homeClickButton = ComponentBuilder.CreateButton(homeButton, 7)
        
        -- Create home page
        local homePage = Instance.new("ScrollingFrame")
        homePage.Name = "HomePage"
        homePage.Size = UDim2.new(1, 0, 1, 0)
        homePage.BackgroundTransparency = 1
        homePage.BorderSizePixel = 0
        homePage.ScrollBarThickness = 2
        homePage.ScrollBarImageColor3 = theme:Get("BorderColor")
        homePage.CanvasSize = UDim2.new(0, 0, 0, 0)
        homePage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        homePage.ZIndex = 3
        homePage.Visible = true
        homePage.Parent = contentArea
        
        local homeLayout = Instance.new("UIListLayout")
        homeLayout.SortOrder = Enum.SortOrder.LayoutOrder
        homeLayout.Padding = UDim.new(0, 10)
        homeLayout.Parent = homePage
        
        local homePadding = Instance.new("UIPadding")
        homePadding.PaddingTop = UDim.new(0, 16)
        homePadding.PaddingBottom = UDim.new(0, 16)
        homePadding.PaddingLeft = UDim.new(0, 18)
        homePadding.PaddingRight = UDim.new(0, 18)
        homePadding.Parent = homePage
        
        -- Player card
        local playerCard = ComponentBuilder.CreateFrame({
            Name = "PlayerCard",
            Size = UDim2.new(1, 0, 0, 76),
            BackgroundColor = theme:Get("SecondaryBackground"),
            CornerRadius = 4,
            Stroke = true,
            StrokeColor = theme:Get("BorderColor"),
            StrokeTransparency = 0.4,
            ZIndex = 3,
            Parent = homePage
        })
        
        local cardAccent = ComponentBuilder.CreateFrame({
            Name = "Accent",
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor = theme:Get("AccentColor"),
            ZIndex = 4,
            Parent = playerCard
        })
        
        local playerAvatar = Instance.new("ImageLabel")
        playerAvatar.Size = UDim2.new(0, 48, 0, 48)
        playerAvatar.Position = UDim2.new(0, 16, 0.5, 0)
        playerAvatar.AnchorPoint = Vector2.new(0, 0.5)
        playerAvatar.BackgroundTransparency = 1
        playerAvatar.ZIndex = 4
        playerAvatar.Parent = playerCard
        
        local playerAvatarCorner = Instance.new("UICorner")
        playerAvatarCorner.CornerRadius = UDim.new(0, 4)
        playerAvatarCorner.Parent = playerAvatar
        
        local playerAvatarStroke = Instance.new("UIStroke")
        playerAvatarStroke.Color = theme:Get("AccentColor")
        playerAvatarStroke.Thickness = 1.5
        playerAvatarStroke.Transparency = 0.5
        playerAvatarStroke.Parent = playerAvatar
        
        pcall(function()
            playerAvatar.Image = Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        
        ComponentBuilder.CreateTextLabel({
            Text = LocalPlayer.DisplayName,
            Size = UDim2.new(1, -90, 0, 18),
            Position = UDim2.new(0, 76, 0, 16),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor = theme:Get("TextPrimary"),
            ZIndex = 4,
            Parent = playerCard
        })
        
        ComponentBuilder.CreateTextLabel({
            Text = "@" .. LocalPlayer.Name,
            Size = UDim2.new(1, -90, 0, 13),
            Position = UDim2.new(0, 76, 0, 36),
            Font = Enum.Font.Code,
            TextSize = 11,
            TextColor = theme:Get("TextSecondary"),
            ZIndex = 4,
            Parent = playerCard
        })
        
        -- Save to tab manager
        tabManager.homeTab = {
            page = homePage,
            activeBar = homeActiveBar,
            icon = homeIcon,
            button = homeButton
        }
        
        -- Activate home by default
        tabManager:ActivateTab("Home")
        
        -- Click handler
        homeClickButton.MouseButton1Click:Connect(function()
            tabManager:ActivateTab("Home")
        end)
        
        -- Hover effects
        homeButton.MouseEnter:Connect(function()
            if tabManager.activeTab ~= "Home" then
                TweenUtil.Create(homeButton, {BackgroundTransparency = 0.92}, 0.15)
            end
            tooltipLabel.Text = "Home"
            tooltip.Visible = true
            TweenUtil.Create(tooltip, {
                Position = UDim2.new(0, sidebarWidth + 4, 0, homeButton.AbsolutePosition.Y - mainWindow.AbsolutePosition.Y + 8)
            }, 0.1)
        end)
        
        homeButton.MouseLeave:Connect(function()
            if tabManager.activeTab ~= "Home" then
                TweenUtil.Create(homeButton, {BackgroundTransparency = 1}, 0.15)
            end
            tooltip.Visible = false
        end)
        
        return {
            Activate = function()
                tabManager:ActivateTab("Home")
            end
        }
    end
    
    windowState.CreateTabImpl = function(self, tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Icon = tabConfig.Icon or "rbxassetid://6031079152"
        tabConfig.ShowTitle = tabConfig.ShowTitle ~= false
        
        local Tab = {}
        
        -- Create tab button
        local tabButton = ComponentBuilder.CreateFrame({
            Name = tabConfig.Name .. "Button",
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundColor = theme:Get("AccentColor"),
            BackgroundTransparency = 1,
            CornerRadius = 4,
            ZIndex = 5,
            Parent = tabIconsContainer
        })
        tabButton.LayoutOrder = #tabIconsContainer:GetChildren()
        
        local tabActiveBar = ComponentBuilder.CreateFrame({
            Name = "ActiveBar",
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor = theme:Get("AccentColor"),
            BackgroundTransparency = 1,
            ZIndex = 6,
            Parent = tabButton
        })
        
        local tabIcon = ComponentBuilder.CreateImageLabel({
            Name = "Icon",
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = tabConfig.Icon,
            ImageColor = theme:Get("TextSecondary"),
            ZIndex = 6,
            Parent = tabButton
        })
        
        local tabClickButton = ComponentBuilder.CreateButton(tabButton, 7)
        
        -- Create tab page
        local tabPage = Instance.new("ScrollingFrame")
        tabPage.Name = tabConfig.Name
        tabPage.Size = UDim2.new(1, 0, 1, 0)
        tabPage.BackgroundTransparency = 1
        tabPage.BorderSizePixel = 0
        tabPage.ScrollBarThickness = 2
        tabPage.ScrollBarImageColor3 = theme:Get("BorderColor")
        tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabPage.ZIndex = 3
        tabPage.Visible = false
        tabPage.Parent = contentArea
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayout.Padding = UDim.new(0, 8)
        tabLayout.Parent = tabPage
        
        local tabPadding = Instance.new("UIPadding")
        tabPadding.PaddingTop = UDim.new(0, 16)
        tabPadding.PaddingBottom = UDim.new(0, 16)
        tabPadding.PaddingLeft = UDim.new(0, 18)
        tabPadding.PaddingRight = UDim.new(0, 18)
        tabPadding.Parent = tabPage
        
        -- Title section
        if tabConfig.ShowTitle then
            local titleSection = ComponentBuilder.CreateFrame({
                Name = "TitleSection",
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                ZIndex = 3,
                Parent = tabPage
            })
            
            ComponentBuilder.CreateImageLabel({
                Image = tabConfig.Icon,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ImageColor = theme:Get("AccentColor"),
                ZIndex = 4,
                Parent = titleSection
            })
            
            ComponentBuilder.CreateTextLabel({
                Text = tabConfig.Name:upper(),
                Size = UDim2.new(1, -22, 0, 16),
                Position = UDim2.new(0, 22, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor = theme:Get("TextPrimary"),
                ZIndex = 4,
                Parent = titleSection
            })
        end
        
        -- Save to tab manager
        tabManager.tabs[tabConfig.Name] = {
            page = tabPage,
            activeBar = tabActiveBar,
            icon = tabIcon,
            button = tabButton
        }
        
        -- Click handler
        tabClickButton.MouseButton1Click:Connect(function()
            tabManager:ActivateTab(tabConfig.Name)
        end)
        
        -- Hover effects
        tabButton.MouseEnter:Connect(function()
            if tabManager.activeTab ~= tabConfig.Name then
                TweenUtil.Create(tabButton, {BackgroundTransparency = 0.92}, 0.15)
            end
            tooltipLabel.Text = tabConfig.Name
            tooltip.Visible = true
            TweenUtil.Create(tooltip, {
                Position = UDim2.new(0, sidebarWidth + 4, 0, tabButton.AbsolutePosition.Y - mainWindow.AbsolutePosition.Y + 8)
            }, 0.1)
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabManager.activeTab ~= tabConfig.Name then
                TweenUtil.Create(tabButton, {BackgroundTransparency = 1}, 0.15)
            end
            tooltip.Visible = false
        end)
        
        -- Tab API
        Tab.Activate = function()
            tabManager:ActivateTab(tabConfig.Name)
        end
        
        Tab.CreateSection = function(self, sectionName)
            return self:CreateSectionImpl(sectionName, tabPage, theme)
        end
        
        Tab.CreateSectionImpl = function(self, sectionName, parent, sectionTheme)
            sectionName = sectionName or ""
            
            local Section = {}
            local sectionNumber = #parent:GetChildren()
            
            -- Section header
            if sectionName ~= "" then
                local headerFrame = ComponentBuilder.CreateFrame({
                    Name = "SectionHeader",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    ZIndex = 3,
                    Parent = parent
                })
                
                local headerLine1 = ComponentBuilder.CreateFrame({
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor = sectionTheme:Get("BorderColor"),
                    BackgroundTransparency = 0.6,
                    Parent = headerFrame
                })
                
                local headerLine2 = ComponentBuilder.CreateFrame({
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 1, -1),
                    BackgroundColor = sectionTheme:Get("BorderColor"),
                    BackgroundTransparency = 0.6,
                    Parent = headerFrame
                })
                
                local headerBadge = ComponentBuilder.CreateFrame({
                    Size = UDim2.new(0, 0, 0, 16),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor = sectionTheme:Get("PrimaryBackground"),
                    ZIndex = 4,
                    Parent = headerFrame
                })
                headerBadge.AutomaticSize = Enum.AutomaticSize.X
                
                local headerPadding = Instance.new("UIPadding")
                headerPadding.PaddingRight = UDim.new(0, 6)
                headerPadding.Parent = headerBadge
                
                local headerLabel = ComponentBuilder.CreateTextLabel({
                    Text = string.format(
                        '<font color="rgb(90,159,232)">#%02d </font><font color="rgb(64,76,84)">%s</font>',
                        sectionNumber,
                        sectionName:upper()
                    ),
                    Size = UDim2.new(0, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    TextSize = 9,
                    TextColor = sectionTheme:Get("TextSecondary"),
                    ZIndex = 5,
                    Parent = headerBadge
                })
                headerLabel.AutomaticSize = Enum.AutomaticSize.X
            end
            
            -- Section content container
            local sectionContainer = ComponentBuilder.CreateFrame({
                Name = "SectionContainer",
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                ZIndex = 3,
                Parent = parent
            })
            sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 4)
            sectionLayout.Parent = sectionContainer
            
            -- Section element builders
            Section.CreateButton = function(self, buttonConfig)
                buttonConfig = buttonConfig or {}
                buttonConfig.Name = buttonConfig.Name or "Button"
                buttonConfig.Description = buttonConfig.Description
                buttonConfig.Callback = buttonConfig.Callback or function() end
                
                local height = buttonConfig.Description and 52 or 36
                
                local buttonFrame = ComponentBuilder.CreateFrame({
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundColor = sectionTheme:Get("SecondaryBackground"),
                    CornerRadius = 4,
                    Stroke = true,
                    StrokeColor = sectionTheme:Get("BorderColor"),
                    StrokeTransparency = 0.45,
                    ClipsDescendants = true,
                    Parent = sectionContainer
                })
                
                local chargeFill = ComponentBuilder.CreateFrame({
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor = Color3.fromRGB(0, 48, 58),
                    BackgroundTransparency = 1,
                    ZIndex = 3,
                    Parent = buttonFrame
                })
                
                local pip = ComponentBuilder.CreateFrame({
                    Size = UDim2.new(0, 3, 1, 0),
                    BackgroundColor = sectionTheme:Get("AccentColor"),
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    Parent = buttonFrame
                })
                
                ComponentBuilder.CreateTextLabel({
                    Text = buttonConfig.Name,
                    Size = UDim2.new(1, -44, 0, 15),
                    Position = UDim2.new(0, 14, 0, buttonConfig.Description and 9 or 11),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    TextColor = sectionTheme:Get("TextPrimary"),
                    ZIndex = 4,
                    Parent = buttonFrame
                })
                
                if buttonConfig.Description then
                    ComponentBuilder.CreateTextLabel({
                        Text = buttonConfig.Description,
                        Size = UDim2.new(1, -44, 0, 13),
                        Position = UDim2.new(0, 14, 0, 28),
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor = sectionTheme:Get("TextSecondary"),
                        ZIndex = 4,
                        Parent = buttonFrame
                    })
                end
                
                ComponentBuilder.CreateImageLabel({
                    Image = "rbxassetid://6031090995",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -20, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ImageColor = sectionTheme:Get("AccentColor"),
                    ImageTransparency = 0.6,
                    ZIndex = 5,
                    Parent = buttonFrame
                })
                
                local clickButton = ComponentBuilder.CreateButton(buttonFrame, 6)
                
                buttonFrame.MouseEnter:Connect(function()
                    TweenUtil.Create(chargeFill, {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 0
                    }, 0.3, Enum.EasingStyle.Quad)
                    TweenUtil.Create(pip, {BackgroundTransparency = 0}, 0.15)
                    if buttonFrame:FindFirstChildOfClass("UIStroke") then
                        TweenUtil.Create(buttonFrame.UIStroke, {
                            Color3 = sectionTheme:Get("AccentColor"),
                            Transparency = 0.5
                        }, 0.15)
                    end
                end)
                
                buttonFrame.MouseLeave:Connect(function()
                    TweenUtil.Create(chargeFill, {
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1
                    }, 0.25)
                    TweenUtil.Create(pip, {BackgroundTransparency = 1}, 0.15)
                    if buttonFrame:FindFirstChildOfClass("UIStroke") then
                        TweenUtil.Create(buttonFrame.UIStroke, {
                            Color3 = sectionTheme:Get("BorderColor"),
                            Transparency = 0.45
                        }, 0.15)
                    end
                end)
                
                clickButton.MouseButton1Click:Connect(function()
                    TweenUtil.Create(chargeFill, {
                        BackgroundColor3 = sectionTheme:Get("AccentColor")
                    }, 0.1)
                    task.wait(0.12)
                    TweenUtil.Create(chargeFill, {
                        BackgroundColor3 = Color3.fromRGB(0, 48, 58),
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1
                    }, 0.25)
                    pcall(buttonConfig.Callback)
                end)
                
                return {
                    Settings = buttonConfig,
                    Set = function(self, settings)
                        buttonConfig = settings
                    end,
                    Destroy = function()
                        buttonFrame:Destroy()
                    end
                }
            end
            
            Section.CreateToggle = function(self, toggleConfig)
                toggleConfig = toggleConfig or {}
                toggleConfig.Name = toggleConfig.Name or "Toggle"
                toggleConfig.Description = toggleConfig.Description
                toggleConfig.CurrentValue = toggleConfig.CurrentValue or false
                toggleConfig.Flag = toggleConfig.Flag
                toggleConfig.Callback = toggleConfig.Callback or function() end
                
                local height = toggleConfig.Description and 52 or 36
                
                local toggleFrame = ComponentBuilder.CreateFrame({
                    Name = "Toggle",
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundColor = sectionTheme:Get("SecondaryBackground"),
                    CornerRadius = 4,
                    Stroke = true,
                    StrokeColor = sectionTheme:Get("BorderColor"),
                    StrokeTransparency = 0.45,
                    Parent = sectionContainer
                })
                
                ComponentBuilder.CreateTextLabel({
                    Text = toggleConfig.Name,
                    Size = UDim2.new(1, -66, 0, 15),
                    Position = UDim2.new(0, 14, 0, toggleConfig.Description and 9 or 11),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    TextColor = sectionTheme:Get("TextPrimary"),
                    ZIndex = 4,
                    Parent = toggleFrame
                })
                
                if toggleConfig.Description then
                    ComponentBuilder.CreateTextLabel({
                        Text = toggleConfig.Description,
                        Size = UDim2.new(1, -66, 0, 13),
                        Position = UDim2.new(0, 14, 0, 28),
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor = sectionTheme:Get("TextSecondary"),
                        ZIndex = 4,
                        Parent = toggleFrame
                    })
                end
                
                local track = ComponentBuilder.CreateFrame({
                    Name = "Track",
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -52, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor = Color3.fromRGB(32, 37, 40),
                    CornerRadius = 3,
                    Stroke = true,
                    StrokeColor = sectionTheme:Get("BorderColor"),
                    StrokeTransparency = 0.3,
                    ZIndex = 4,
                    Parent = toggleFrame
                })
                
                local knob = ComponentBuilder.CreateFrame({
                    Name = "Knob",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 3, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor = Color3.fromRGB(64, 76, 84),
                    CornerRadius = 2,
                    ZIndex = 5,
                    Parent = track
                })
                
                local Toggle = {
                    CurrentValue = toggleConfig.CurrentValue,
                    Type = "Toggle",
                    Settings = toggleConfig
                }
                
                local function update()
                    if Toggle.CurrentValue then
                        TweenUtil.Create(track, {
                            BackgroundColor3 = Color3.fromRGB(0, 48, 58)
                        }, 0.25)
                        TweenUtil.Create(track.UIStroke, {
                            Color3 = sectionTheme:Get("AccentColor"),
                            Transparency = 0.4
                        }, 0.25)
                        TweenUtil.Create(knob, {
                            Position = UDim2.new(0, 23, 0.5, 0),
                            BackgroundColor3 = sectionTheme:Get("AccentColor")
                        }, 0.38, Enum.EasingStyle.Back)
                    else
                        TweenUtil.Create(track, {
                            BackgroundColor3 = Color3.fromRGB(32, 37, 40)
                        }, 0.25)
                        TweenUtil.Create(track.UIStroke, {
                            Color3 = sectionTheme:Get("BorderColor"),
                            Transparency = 0.3
                        }, 0.25)
                        TweenUtil.Create(knob, {
                            Position = UDim2.new(0, 3, 0.5, 0),
                            BackgroundColor3 = Color3.fromRGB(64, 76, 84)
                        }, 0.38, Enum.EasingStyle.Back)
                    end
                end
                
                update()
                
                local clickButton = ComponentBuilder.CreateButton(toggleFrame, 5)
                clickButton.MouseButton1Click:Connect(function()
                    Toggle.CurrentValue = not Toggle.CurrentValue
                    update()
                    pcall(toggleConfig.Callback, Toggle.CurrentValue)
                end)
                
                toggleFrame.MouseEnter:Connect(function()
                    TweenUtil.Create(toggleFrame, {BackgroundTransparency = 0}, 0.15)
                    if toggleFrame.UIStroke then
                        TweenUtil.Create(toggleFrame.UIStroke, {
                            Color3 = Color3.fromRGB(58, 68, 74),
                            Transparency = 0.2
                        }, 0.15)
                    end
                end)
                
                toggleFrame.MouseLeave:Connect(function()
                    TweenUtil.Create(toggleFrame, {BackgroundTransparency = 0}, 0.15)
                    if toggleFrame.UIStroke then
                        TweenUtil.Create(toggleFrame.UIStroke, {
                            Color3 = sectionTheme:Get("BorderColor"),
                            Transparency = 0.45
                        }, 0.15)
                    end
                end)
                
                Toggle.Set = function(self, value)
                    Toggle.CurrentValue = value
                    update()
                    pcall(toggleConfig.Callback, value)
                end
                
                Toggle.Destroy = function()
                    toggleFrame:Destroy()
                end
                
                if toggleConfig.Flag then
                    Nexus.Flags[toggleConfig.Flag] = Toggle
                    Nexus.Options[toggleConfig.Flag] = Toggle
                end
                
                return Toggle
            end
            
            Section.CreateLabel = function(self, labelConfig)
                labelConfig = labelConfig or {}
                labelConfig.Text = labelConfig.Text or "Label"
                
                local labelFrame = ComponentBuilder.CreateFrame({
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor = sectionTheme:Get("SecondaryBackground"),
                    CornerRadius = 4,
                    Stroke = true,
                    StrokeColor = sectionTheme:Get("BorderColor"),
                    StrokeTransparency = 0.45,
                    Parent = sectionContainer
                })
                
                local label = ComponentBuilder.CreateTextLabel({
                    Text = labelConfig.Text,
                    Size = UDim2.new(1, -20, 0, 13),
                    Position = UDim2.new(0, 10, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    TextColor = sectionTheme:Get("TextSecondary"),
                    ZIndex = 4,
                    Parent = labelFrame
                })
                
                return {
                    Set = function(self, text)
                        label.Text = text
                    end,
                    Destroy = function()
                        labelFrame:Destroy()
                    end
                }
            end
            
            Section.CreateDivider = function(self)
                local divider = ComponentBuilder.CreateFrame({
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor = sectionTheme:Get("BorderColor"),
                    BackgroundTransparency = 0.6,
                    Parent = sectionContainer
                })
                
                return {
                    Destroy = function()
                        divider:Destroy()
                    end
                }
            end
            
            return Section
        end
        
        -- Shortcuts for elements without sections
        local defaultSection = nil
        
        local function getDefaultSection()
            if not defaultSection then
                defaultSection = Tab:CreateSection("")
            end
            return defaultSection
        end
        
        for _, method in ipairs({
            "CreateButton", "CreateToggle", "CreateLabel", 
            "CreateDivider", "CreateSlider", "CreateDropdown",
            "CreateInput", "CreateBind", "CreateKeybind", "CreateColorPicker"
        }) do
            Tab[method] = function(self, ...)
                return getDefaultSection()[method](getDefaultSection(), ...)
            end
        end
        
        return Tab
    end
    
    return windowState
end

-- ══════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ══════════════════════════════════════════════════════════
function Nexus:ShowLoadingScreen(windowState)
    local theme = windowState.theme
    local window = windowState.window
    local windowWidth = windowState.windowWidth
    local windowHeight = windowState.windowHeight
    
    local loadingFrame = ComponentBuilder.CreateFrame({
        Name = "Loading",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor = theme:Get("PrimaryBackground"),
        BackgroundTransparency = 0,
        ZIndex = 50,
        Parent = window
    })
    
    local loadingCorner = Instance.new("UICorner")
    loadingCorner.CornerRadius = UDim.new(0, 6)
    loadingCorner.Parent = loadingFrame
    
    -- Logo
    if windowState.config.Icon ~= "" then
        ComponentBuilder.CreateImageLabel({
            Image = windowState.config.Icon,
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0.5, 0, 0.5, -50),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ImageColor = theme:Get("TextPrimary"),
            ZIndex = 51,
            Parent = loadingFrame
        })
    end
    
    -- Title
    local titleLabel = ComponentBuilder.CreateTextLabel({
        Text = windowState.config.LoadingTitle,
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0.5, 0, 0.5, -14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor = theme:Get("TextPrimary"),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 51,
        Parent = loadingFrame
    })
    
    -- Subtitle
    local subtitleLabel = ComponentBuilder.CreateTextLabel({
        Text = windowState.config.LoadingSubtitle,
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0.5, 0, 0.5, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor = theme:Get("TextSecondary"),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 51,
        Parent = loadingFrame
    })
    
    -- Progress bar
    local progressTrack = ComponentBuilder.CreateFrame({
        Size = UDim2.new(0.45, 0, 0, 3),
        Position = UDim2.new(0.5, 0, 0.5, 42),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor = Color3.fromRGB(24, 28, 30),
        CornerRadius = 2,
        ZIndex = 51,
        Parent = loadingFrame
    })
    
    local progressFill = ComponentBuilder.CreateFrame({
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor = theme:Get("AccentColor"),
        CornerRadius = 2,
        ZIndex = 52,
        Parent = progressTrack
    })
    
    -- Percentage
    local percentLabel = ComponentBuilder.CreateTextLabel({
        Text = "0%",
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0.5, 0, 0.5, 52),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor = Color3.fromRGB(0, 140, 162),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 51,
        Parent = loadingFrame
    })
    
    -- Expand window
    TweenUtil.Create(window, {
        Size = UDim2.new(0, windowWidth, 0, windowHeight)
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    task.wait(0.3)
    
    -- Fade in text
    TweenUtil.Create(titleLabel, {TextTransparency = 0}, 0.25)
    task.wait(0.1)
    TweenUtil.Create(subtitleLabel, {TextTransparency = 0.3}, 0.25)
    
    -- Simulate loading
    local steps = {0.12, 0.08, 0.15, 0.1, 0.18, 0.12, 0.1, 0.15}
    local progress = 0
    
    for _, step in ipairs(steps) do
        progress = math.min(progress + step, 1)
        TweenUtil.Create(progressFill, {
            Size = UDim2.new(progress, 0, 1, 0)
        }, 0.25, Enum.EasingStyle.Quad)
        percentLabel.Text = math.floor(progress * 100) .. "%"
        task.wait(0.13 + math.random() * 0.1)
    end
    
    percentLabel.Text = "100%"
    TweenUtil.Create(progressFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.15)
    
    task.wait(0.3)
    
    -- Flash effect
    TweenUtil.Create(progressFill, {
        BackgroundColor3 = Color3.new(1, 1, 1)
    }, 0.1)
    task.wait(0.08)
    
    -- Fade out
    TweenUtil.Create(titleLabel, {TextTransparency = 1}, 0.15)
    TweenUtil.Create(subtitleLabel, {TextTransparency = 1}, 0.15)
    TweenUtil.Create(percentLabel, {TextTransparency = 1}, 0.15)
    TweenUtil.Create(progressTrack, {BackgroundTransparency = 1}, 0.15)
    TweenUtil.Create(progressFill, {BackgroundTransparency = 1}, 0.15)
    
    task.wait(0.2)
    
    TweenUtil.Create(loadingFrame, {BackgroundTransparency = 1}, 0.25, nil, nil, function()
        loadingFrame:Destroy()
    end)
    
    task.wait(0.3)
end

-- ══════════════════════════════════════════════════════════
-- NOTIFICATION API
-- ══════════════════════════════════════════════════════════
function Nexus:Notify(config)
    if self._notificationSystem then
        self._notificationSystem:Show(config)
    else
        warn("Nexus: Notification system not initialized")
    end
end

-- Store notification system reference
function Nexus:_SetNotificationSystem(system)
    self._notificationSystem = system
end

-- Update CreateWindow to store notification system
local originalCreateWindow = Nexus.CreateWindow
Nexus.CreateWindow = function(self, config)
    local window = originalCreateWindow(self, config)
    self:_SetNotificationSystem(window.notificationSystem)
    return window
end

-- ══════════════════════════════════════════════════════════
-- CLEANUP
-- ══════════════════════════════════════════════════════════
function Nexus:Destroy()
    for _, connection in ipairs(self._connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    
    self._connections = {}
    
    if self._notificationSystem and self._notificationSystem.container then
        pcall(function()
            self._notificationSystem.container.Parent:Destroy()
        end)
    end
    
    self.Flags = {}
    self.Options = {}
end

return Nexus
