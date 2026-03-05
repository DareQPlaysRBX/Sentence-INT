-- ============================================================
--  Sentence Hub | Roblox GUI Library
--  Version: 1.0.0
--  Author: SentenceHub
-- ============================================================

local SentenceHub = {}
SentenceHub.__index = SentenceHub

-- ============================================================
-- SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ============================================================
-- THEME
-- ============================================================
local Theme = {
    Background      = Color3.fromRGB(10, 10, 15),
    Surface         = Color3.fromRGB(16, 16, 24),
    SurfaceAlt      = Color3.fromRGB(22, 22, 34),
    Border          = Color3.fromRGB(40, 40, 60),
    BorderHighlight = Color3.fromRGB(90, 80, 180),
    Accent          = Color3.fromRGB(120, 80, 255),
    AccentDim       = Color3.fromRGB(70, 50, 150),
    AccentGlow      = Color3.fromRGB(140, 100, 255),
    TextPrimary     = Color3.fromRGB(230, 230, 240),
    TextSecondary   = Color3.fromRGB(140, 140, 160),
    TextDisabled    = Color3.fromRGB(80, 80, 100),
    Success         = Color3.fromRGB(60, 200, 120),
    Warning         = Color3.fromRGB(255, 180, 60),
    Danger          = Color3.fromRGB(255, 70, 90),
    ToggleOn        = Color3.fromRGB(100, 200, 140),
    ToggleOff       = Color3.fromRGB(60, 60, 80),
    SliderFill      = Color3.fromRGB(120, 80, 255),
    SliderBg        = Color3.fromRGB(30, 30, 48),
    NotifBg         = Color3.fromRGB(20, 20, 32),
    Overlay         = Color3.fromRGB(0, 0, 0),
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function Tween(obj, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.2, style, direction)
    TweenService:Create(obj, info, props):Play()
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function MakeCorner(radius, parent)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function MakeStroke(color, thickness, parent)
    return Create("UIStroke", {
        Color     = color or Theme.Border,
        Thickness = thickness or 1,
        Parent    = parent,
    })
end

local function MakePadding(top, bottom, left, right, parent)
    return Create("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 6),
        PaddingBottom = UDim.new(0, bottom or 6),
        PaddingLeft   = UDim.new(0, left   or 10),
        PaddingRight  = UDim.new(0, right  or 10),
        Parent        = parent,
    })
end

local function MakeListLayout(spacing, fillDir, halign, valign, parent)
    return Create("UIListLayout", {
        Padding         = UDim.new(0, spacing or 6),
        FillDirection   = fillDir or Enum.FillDirection.Vertical,
        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = valign or Enum.VerticalAlignment.Top,
        SortOrder       = Enum.SortOrder.LayoutOrder,
        Parent          = parent,
    })
end

local function Ripple(parent, x, y)
    local rip = Create("Frame", {
        Size            = UDim2.new(0, 0, 0, 0),
        Position        = UDim2.new(0, x, 0, y),
        AnchorPoint     = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        ZIndex          = 100,
        Parent          = parent,
    })
    MakeCorner(999, rip)
    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    Tween(rip, { Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1 }, 0.5)
    task.delay(0.5, function() rip:Destroy() end)
end

-- ============================================================
-- DRAGGING
-- ============================================================
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, mousePos, framePos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            mousePos  = input.Position
            framePos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local NotifHolder

local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return end
    local sg = Create("ScreenGui", {
        Name             = "SentenceHubNotifs",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        Parent           = CoreGui,
    })
    NotifHolder = Create("Frame", {
        Size             = UDim2.new(0, 320, 1, 0),
        Position         = UDim2.new(1, -330, 0, 10),
        BackgroundTransparency = 1,
        Parent           = sg,
    })
    MakeListLayout(8, nil, Enum.HorizontalAlignment.Right, nil, NotifHolder)
end

function SentenceHub:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "Sentence Hub"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 4
    local ntype    = opts.Type     or "Info" -- Info | Success | Warning | Danger

    EnsureNotifHolder()

    local accentColor = ({
        Info    = Theme.Accent,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Danger  = Theme.Danger,
    })[ntype] or Theme.Accent

    local icon = ({
        Info    = "ℹ",
        Success = "✓",
        Warning = "⚠",
        Danger  = "✕",
    })[ntype] or "ℹ"

    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Theme.NotifBg,
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        Parent           = NotifHolder,
    })
    MakeCorner(8, card)
    MakeStroke(Theme.Border, 1, card)

    -- Left accent bar
    Create("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentColor,
        Parent           = card,
    })
    MakeCorner(4, Create("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = accentColor, Parent = card }))

    -- Icon
    Create("TextLabel", {
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 14, 0.5, -16),
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.85,
        Text             = icon,
        TextColor3       = accentColor,
        TextSize         = 16,
        Font             = Enum.Font.GothamBold,
        Parent           = card,
    })
    MakeCorner(8, card:FindFirstChildOfClass("Frame"))

    -- Title
    Create("TextLabel", {
        Size             = UDim2.new(1, -60, 0, 20),
        Position         = UDim2.new(0, 54, 0, 12),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = Theme.TextPrimary,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = card,
    })

    -- Message
    Create("TextLabel", {
        Size             = UDim2.new(1, -60, 0, 28),
        Position         = UDim2.new(0, 54, 0, 34),
        BackgroundTransparency = 1,
        Text             = message,
        TextColor3       = Theme.TextSecondary,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        Parent           = card,
    })

    -- Progress bar
    local prog = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accentColor,
        Parent           = card,
    })

    -- Slide in
    card.Position = UDim2.new(1, 10, 0, 0)
    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back)

    -- Progress shrink
    Tween(prog, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Tween(card, { Position = UDim2.new(1, 10, 0, 0) }, 0.3)
        task.delay(0.3, function() card:Destroy() end)
    end)
end

-- ============================================================
-- WINDOW
-- ============================================================
function SentenceHub:CreateWindow(opts)
    opts = opts or {}
    local windowTitle   = opts.Title   or "Sentence Hub"
    local windowSubtitle = opts.Subtitle or "v1.0"
    local windowSize    = opts.Size    or Vector2.new(560, 400)
    local windowPos     = opts.Position or UDim2.new(0.5, -windowSize.X/2, 0.5, -windowSize.Y/2)

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name           = "SentenceHub_" .. windowTitle,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = CoreGui,
    })

    -- Main Window Frame
    local Window = Create("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, windowSize.X, 0, windowSize.Y),
        Position         = windowPos,
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        Parent           = ScreenGui,
    })
    MakeCorner(10, Window)
    MakeStroke(Theme.Border, 1, Window)

    -- Shadow (fake)
    local Shadow = Create("ImageLabel", {
        Size             = UDim2.new(1, 60, 1, 60),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image            = "rbxassetid://6014261993",
        ImageColor3      = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.5,
        ScaleType        = Enum.ScaleType.Slice,
        SliceCenter      = Rect.new(49,49,450,450),
        ZIndex           = -1,
        Parent           = Window,
    })

    -- Title Bar
    local TitleBar = Create("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Surface,
        Parent           = Window,
    })

    -- Accent line
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.BorderHighlight,
        Parent           = TitleBar,
    })

    -- Logo dot
    local logoDot = Create("Frame", {
        Size             = UDim2.new(0, 8, 0, 8),
        Position         = UDim2.new(0, 16, 0.5, -4),
        BackgroundColor3 = Theme.Accent,
        Parent           = TitleBar,
    })
    MakeCorner(99, logoDot)

    -- Title text
    Create("TextLabel", {
        Size             = UDim2.new(0, 200, 1, 0),
        Position         = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text             = windowTitle,
        TextColor3       = Theme.TextPrimary,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = TitleBar,
    })

    -- Subtitle
    Create("TextLabel", {
        Size             = UDim2.new(0, 100, 1, 0),
        Position         = UDim2.new(0, 30, 0, 16),
        BackgroundTransparency = 1,
        Text             = windowSubtitle,
        TextColor3       = Theme.TextSecondary,
        TextSize         = 10,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = TitleBar,
    })

    -- Close button
    local CloseBtn = Create("TextButton", {
        Size             = UDim2.new(0, 30, 0, 30),
        Position         = UDim2.new(1, -40, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(255, 70, 90),
        BackgroundTransparency = 0.6,
        Text             = "✕",
        TextColor3       = Theme.TextPrimary,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        Parent           = TitleBar,
    })
    MakeCorner(6, CloseBtn)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { BackgroundTransparency = 0.1 }, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { BackgroundTransparency = 0.6 }, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Window, { Size = UDim2.new(0, windowSize.X, 0, 0) }, 0.3, Enum.EasingStyle.Back)
        task.delay(0.35, function() ScreenGui:Destroy() end)
    end)

    -- Minimize button
    local MinBtn = Create("TextButton", {
        Size             = UDim2.new(0, 30, 0, 30),
        Position         = UDim2.new(1, -78, 0.5, -15),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.4,
        Text             = "─",
        TextColor3       = Theme.TextSecondary,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        Parent           = TitleBar,
    })
    MakeCorner(6, MinBtn)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Window, { Size = UDim2.new(0, windowSize.X, 0, 48) }, 0.3, Enum.EasingStyle.Quart)
        else
            Tween(Window, { Size = UDim2.new(0, windowSize.X, 0, windowSize.Y) }, 0.3, Enum.EasingStyle.Back)
        end
    end)

    MakeDraggable(Window, TitleBar)

    -- Tab nav sidebar
    local Sidebar = Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 140, 1, -48),
        Position         = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = Theme.Surface,
        Parent           = Window,
    })
    MakeListLayout(4, nil, Enum.HorizontalAlignment.Center, nil, Sidebar)
    MakePadding(8, 8, 6, 6, Sidebar)

    -- Divider
    Create("Frame", {
        Size             = UDim2.new(0, 1, 1, -48),
        Position         = UDim2.new(0, 140, 0, 48),
        BackgroundColor3 = Theme.Border,
        Parent           = Window,
    })

    -- Content area
    local ContentHolder = Create("Frame", {
        Name             = "ContentHolder",
        Size             = UDim2.new(1, -140, 1, -48),
        Position         = UDim2.new(0, 141, 0, 48),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = Window,
    })

    -- Animate in
    Window.Size = UDim2.new(0, windowSize.X, 0, 0)
    Tween(Window, { Size = UDim2.new(0, windowSize.X, 0, windowSize.Y) }, 0.45, Enum.EasingStyle.Back)

    -- ============================================================
    -- TAB SYSTEM
    -- ============================================================
    local WindowObj  = {}
    local Tabs       = {}
    local ActiveTab  = nil

    function WindowObj:AddTab(tabName, tabIcon)
        tabIcon = tabIcon or "☰"

        local TabBtn = Create("TextButton", {
            Size             = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.SurfaceAlt,
            BackgroundTransparency = 1,
            Text             = "",
            Parent           = Sidebar,
        })
        MakeCorner(6, TabBtn)

        -- Icon
        Create("TextLabel", {
            Size             = UDim2.new(0, 20, 1, 0),
            Position         = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text             = tabIcon,
            TextColor3       = Theme.TextSecondary,
            TextSize         = 14,
            Font             = Enum.Font.GothamBold,
            Parent           = TabBtn,
        })

        local TabLabel = Create("TextLabel", {
            Size             = UDim2.new(1, -32, 1, 0),
            Position         = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text             = tabName,
            TextColor3       = Theme.TextSecondary,
            TextSize         = 12,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = TabBtn,
        })

        -- Active indicator
        local ActiveBar = Create("Frame", {
            Size             = UDim2.new(0, 2, 0.6, 0),
            Position         = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Parent           = TabBtn,
        })
        MakeCorner(4, ActiveBar)

        -- Tab Content Frame
        local TabContent = Create("ScrollingFrame", {
            Name             = tabName,
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible          = false,
            Parent           = ContentHolder,
        })
        MakeListLayout(6, nil, Enum.HorizontalAlignment.Center, nil, TabContent)
        MakePadding(10, 10, 10, 10, TabContent)

        local function SelectTab()
            -- Deselect others
            for _, t in pairs(Tabs) do
                Tween(t.Btn, { BackgroundTransparency = 1 }, 0.15)
                Tween(t.Bar, { BackgroundTransparency = 1 }, 0.15)
                t.Label.Font = Enum.Font.Gotham
                Tween(t.Label, { TextColor3 = Theme.TextSecondary }, 0.15)
                t.Content.Visible = false
            end
            -- Select this
            Tween(TabBtn, { BackgroundTransparency = 0.7 }, 0.15)
            Tween(ActiveBar, { BackgroundTransparency = 0 }, 0.15)
            TabLabel.Font = Enum.Font.GothamBold
            Tween(TabLabel, { TextColor3 = Theme.Accent }, 0.15)
            TabContent.Visible = true
            ActiveTab = tabName
        end

        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn, Mouse.X - TabBtn.AbsolutePosition.X, Mouse.Y - TabBtn.AbsolutePosition.Y)
            SelectTab()
        end)

        table.insert(Tabs, {
            Btn     = TabBtn,
            Label   = TabLabel,
            Bar     = ActiveBar,
            Content = TabContent,
        })

        if #Tabs == 1 then SelectTab() end

        -- ============================================================
        -- ELEMENT BUILDERS
        -- ============================================================
        local TabObj = {}

        -- Helper: container for elements
        local function MakeItemFrame(h)
            local f = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, h or 40),
                BackgroundColor3 = Theme.SurfaceAlt,
                Parent           = TabContent,
            })
            MakeCorner(6, f)
            MakeStroke(Theme.Border, 1, f)
            return f
        end

        -- SECTION LABEL
        function TabObj:AddSection(name)
            local sec = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Parent           = TabContent,
            })
            Create("TextLabel", {
                Size             = UDim2.new(0, 0, 1, 0),
                AutomaticSize    = Enum.AutomaticSize.X,
                Position         = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text             = name:upper(),
                TextColor3       = Theme.Accent,
                TextSize         = 10,
                Font             = Enum.Font.GothamBold,
                LetterSpacing    = 2,
                Parent           = sec,
            })
            Create("Frame", {
                Size             = UDim2.new(1, -60, 0, 1),
                Position         = UDim2.new(0, 60, 0.5, 0),
                BackgroundColor3 = Theme.Border,
                Parent           = sec,
            })
        end

        -- LABEL
        function TabObj:AddLabel(text)
            local f = MakeItemFrame(36)
            f.BackgroundTransparency = 0.6
            Create("TextLabel", {
                Size             = UDim2.new(1, -16, 1, 0),
                Position         = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text             = text,
                TextColor3       = Theme.TextSecondary,
                TextSize         = 12,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextWrapped      = true,
                Parent           = f,
            })
            local LabelObj = {}
            function LabelObj:Set(t) f:FindFirstChildOfClass("TextLabel").Text = t end
            return LabelObj
        end

        -- BUTTON
        function TabObj:AddButton(opts)
            opts = opts or {}
            local label    = opts.Name    or "Button"
            local desc     = opts.Desc    or ""
            local callback = opts.Callback or function() end

            local f = MakeItemFrame(44)

            Create("TextLabel", {
                Size             = UDim2.new(1, -100, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = label,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = f,
            })

            if desc ~= "" then
                Create("TextLabel", {
                    Size             = UDim2.new(1, -100, 0, 14),
                    Position         = UDim2.new(0, 12, 0, 24),
                    BackgroundTransparency = 1,
                    Text             = desc,
                    TextColor3       = Theme.TextSecondary,
                    TextSize         = 10,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = f,
                })
                f.Size = UDim2.new(1, 0, 0, 52)
            end

            local btn = Create("TextButton", {
                Size             = UDim2.new(0, 80, 0, 28),
                Position         = UDim2.new(1, -92, 0.5, -14),
                BackgroundColor3 = Theme.Accent,
                Text             = "Execute",
                TextColor3       = Color3.fromRGB(255, 255, 255),
                TextSize         = 11,
                Font             = Enum.Font.GothamBold,
                Parent           = f,
            })
            MakeCorner(6, btn)

            btn.MouseEnter:Connect(function()
                Tween(btn, { BackgroundColor3 = Theme.AccentGlow }, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, { BackgroundColor3 = Theme.Accent }, 0.15)
            end)
            btn.MouseButton1Click:Connect(function()
                Ripple(btn, Mouse.X - btn.AbsolutePosition.X, Mouse.Y - btn.AbsolutePosition.Y)
                task.spawn(callback)
            end)
        end

        -- TOGGLE
        function TabObj:AddToggle(opts)
            opts = opts or {}
            local label    = opts.Name     or "Toggle"
            local default  = opts.Default  or false
            local callback = opts.Callback or function() end

            local f = MakeItemFrame(44)
            local state = default

            Create("TextLabel", {
                Size             = UDim2.new(1, -70, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = label,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = f,
            })

            local track = Create("Frame", {
                Size             = UDim2.new(0, 44, 0, 22),
                Position         = UDim2.new(1, -56, 0.5, -11),
                BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                Parent           = f,
            })
            MakeCorner(99, track)

            local knob = Create("Frame", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = state and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent           = track,
            })
            MakeCorner(99, knob)

            local function setToggle(val)
                state = val
                Tween(track, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                Tween(knob, { Position = state and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }, 0.2)
                task.spawn(callback, state)
            end

            local hitbox = Create("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                Parent           = f,
            })
            hitbox.MouseButton1Click:Connect(function()
                setToggle(not state)
            end)

            local ToggleObj = {}
            function ToggleObj:Set(val) setToggle(val) end
            function ToggleObj:Get() return state end
            return ToggleObj
        end

        -- SLIDER
        function TabObj:AddSlider(opts)
            opts = opts or {}
            local label    = opts.Name    or "Slider"
            local min      = opts.Min     or 0
            local max      = opts.Max     or 100
            local default  = opts.Default or 50
            local suffix   = opts.Suffix  or ""
            local callback = opts.Callback or function() end

            local f = MakeItemFrame(60)
            local value = math.clamp(default, min, max)

            Create("TextLabel", {
                Size             = UDim2.new(1, -80, 0, 20),
                Position         = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text             = label,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = f,
            })

            local valLabel = Create("TextLabel", {
                Size             = UDim2.new(0, 70, 0, 20),
                Position         = UDim2.new(1, -82, 0, 8),
                BackgroundTransparency = 1,
                Text             = tostring(value) .. suffix,
                TextColor3       = Theme.Accent,
                TextSize         = 12,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Right,
                Parent           = f,
            })

            local track = Create("Frame", {
                Size             = UDim2.new(1, -24, 0, 6),
                Position         = UDim2.new(0, 12, 0, 36),
                BackgroundColor3 = Theme.SliderBg,
                Parent           = f,
            })
            MakeCorner(99, track)

            local fill = Create("Frame", {
                Size             = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                Parent           = track,
            })
            MakeCorner(99, fill)

            local thumb = Create("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex           = 2,
                Parent           = track,
            })
            MakeCorner(99, thumb)

            local draggingSlider = false

            local function updateSlider(input)
                local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * rel)
                valLabel.Text = tostring(value) .. suffix
                Tween(fill,  { Size = UDim2.new(rel, 0, 1, 0) }, 0.05)
                Tween(thumb, { Position = UDim2.new(rel, -7, 0.5, -7) }, 0.05)
                task.spawn(callback, value)
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    updateSlider(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)

            local SliderObj = {}
            function SliderObj:Set(val)
                value = math.clamp(val, min, max)
                local rel = (value - min) / (max - min)
                valLabel.Text = tostring(value) .. suffix
                Tween(fill,  { Size = UDim2.new(rel, 0, 1, 0) }, 0.1)
                Tween(thumb, { Position = UDim2.new(rel, -7, 0.5, -7) }, 0.1)
            end
            function SliderObj:Get() return value end
            return SliderObj
        end

        -- DROPDOWN
        function TabObj:AddDropdown(opts)
            opts = opts or {}
            local label    = opts.Name     or "Dropdown"
            local options  = opts.Options  or {}
            local default  = opts.Default  or (options[1] or "Select...")
            local callback = opts.Callback or function() end

            local f = MakeItemFrame(44)
            f.ClipsDescendants = false
            local selected = default
            local opened   = false

            Create("TextLabel", {
                Size             = UDim2.new(0.5, 0, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = label,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = f,
            })

            local dropBtn = Create("TextButton", {
                Size             = UDim2.new(0.45, 0, 0, 28),
                Position         = UDim2.new(0.52, 0, 0.5, -14),
                BackgroundColor3 = Theme.Surface,
                Text             = "",
                Parent           = f,
            })
            MakeCorner(6, dropBtn)
            MakeStroke(Theme.Border, 1, dropBtn)

            local selLabel = Create("TextLabel", {
                Size             = UDim2.new(1, -24, 1, 0),
                Position         = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text             = selected,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 11,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = dropBtn,
            })

            Create("TextLabel", {
                Size             = UDim2.new(0, 16, 1, 0),
                Position         = UDim2.new(1, -18, 0, 0),
                BackgroundTransparency = 1,
                Text             = "▾",
                TextColor3       = Theme.TextSecondary,
                TextSize         = 10,
                Font             = Enum.Font.GothamBold,
                Parent           = dropBtn,
            })

            -- Options list
            local optList = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                Position         = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Theme.Surface,
                ClipsDescendants = true,
                ZIndex           = 10,
                Visible          = false,
                Parent           = dropBtn,
            })
            MakeCorner(6, optList)
            MakeStroke(Theme.Border, 1, optList)
            MakeListLayout(2, nil, nil, nil, optList)
            MakePadding(4, 4, 4, 4, optList)

            local function closeDropdown()
                opened = false
                Tween(optList, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                task.delay(0.2, function() optList.Visible = false end)
            end

            local function openDropdown()
                opened = true
                optList.Visible = true
                local h = math.min(#options * 28 + 8, 140)
                Tween(optList, { Size = UDim2.new(1, 0, 0, h) }, 0.2, Enum.EasingStyle.Back)
            end

            for _, opt in ipairs(options) do
                local ob = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme.SurfaceAlt,
                    BackgroundTransparency = 1,
                    Text             = opt,
                    TextColor3       = Theme.TextSecondary,
                    TextSize         = 11,
                    Font             = Enum.Font.Gotham,
                    ZIndex           = 11,
                    Parent           = optList,
                })
                MakeCorner(4, ob)
                ob.MouseEnter:Connect(function()
                    Tween(ob, { BackgroundTransparency = 0.6, TextColor3 = Theme.TextPrimary }, 0.1)
                end)
                ob.MouseLeave:Connect(function()
                    Tween(ob, { BackgroundTransparency = 1, TextColor3 = Theme.TextSecondary }, 0.1)
                end)
                ob.MouseButton1Click:Connect(function()
                    selected = opt
                    selLabel.Text = opt
                    closeDropdown()
                    task.spawn(callback, opt)
                end)
            end

            dropBtn.MouseButton1Click:Connect(function()
                if opened then closeDropdown() else openDropdown() end
            end)

            local DropObj = {}
            function DropObj:Set(val)
                selected = val
                selLabel.Text = val
            end
            function DropObj:Get() return selected end
            return DropObj
        end

        -- TEXTBOX
        function TabObj:AddTextbox(opts)
            opts = opts or {}
            local label       = opts.Name        or "Input"
            local placeholder = opts.Placeholder or "Type here..."
            local default     = opts.Default     or ""
            local callback    = opts.Callback    or function() end

            local f = MakeItemFrame(56)

            Create("TextLabel", {
                Size             = UDim2.new(1, -16, 0, 18),
                Position         = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text             = label,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 12,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = f,
            })

            local box = Create("TextBox", {
                Size             = UDim2.new(1, -24, 0, 24),
                Position         = UDim2.new(0, 12, 0, 26),
                BackgroundColor3 = Theme.Background,
                Text             = default,
                PlaceholderText  = placeholder,
                PlaceholderColor3 = Theme.TextDisabled,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 12,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent           = f,
            })
            MakeCorner(6, box)
            MakeStroke(Theme.Border, 1, box)
            MakePadding(0, 0, 8, 8, box)

            box.Focused:Connect(function()
                Tween(box, { }, 0.15)
                MakeStroke(Theme.Accent, 1, box)
            end)
            box.FocusLost:Connect(function(enter)
                MakeStroke(Theme.Border, 1, box)
                if enter then task.spawn(callback, box.Text) end
            end)

            local TbObj = {}
            function TbObj:Get() return box.Text end
            function TbObj:Set(t) box.Text = t end
            return TbObj
        end

        -- KEYBIND
        function TabObj:AddKeybind(opts)
            opts = opts or {}
            local label    = opts.Name     or "Keybind"
            local default  = opts.Default  or Enum.KeyCode.Unknown
            local callback = opts.Callback or function() end

            local f = MakeItemFrame(44)
            local bound = default
            local listening = false

            Create("TextLabel", {
                Size             = UDim2.new(0.6, 0, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = label,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = f,
            })

            local kbBtn = Create("TextButton", {
                Size             = UDim2.new(0, 90, 0, 26),
                Position         = UDim2.new(1, -100, 0.5, -13),
                BackgroundColor3 = Theme.Surface,
                Text             = bound.Name,
                TextColor3       = Theme.Accent,
                TextSize         = 11,
                Font             = Enum.Font.GothamBold,
                Parent           = f,
            })
            MakeCorner(6, kbBtn)
            MakeStroke(Theme.Border, 1, kbBtn)

            kbBtn.MouseButton1Click:Connect(function()
                listening = true
                kbBtn.Text = "..."
                Tween(kbBtn, { TextColor3 = Theme.Warning }, 0.1)
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if listening and not gp then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        bound = input.KeyCode
                        kbBtn.Text = bound.Name
                        Tween(kbBtn, { TextColor3 = Theme.Accent }, 0.1)
                        listening = false
                    end
                elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == bound then
                        task.spawn(callback)
                    end
                end
            end)

            local KbObj = {}
            function KbObj:Get() return bound end
            return KbObj
        end

        -- COLOR PICKER (simple HSV)
        function TabObj:AddColorPicker(opts)
            opts = opts or {}
            local label    = opts.Name     or "Color"
            local default  = opts.Default  or Color3.fromRGB(120, 80, 255)
            local callback = opts.Callback or function() end

            local f = MakeItemFrame(44)
            f.ClipsDescendants = false
            local currentColor = default
            local pickerOpen = false

            Create("TextLabel", {
                Size             = UDim2.new(1, -80, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = label,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = f,
            })

            local preview = Create("TextButton", {
                Size             = UDim2.new(0, 60, 0, 26),
                Position         = UDim2.new(1, -72, 0.5, -13),
                BackgroundColor3 = currentColor,
                Text             = "",
                Parent           = f,
            })
            MakeCorner(6, preview)
            MakeStroke(Theme.Border, 1, preview)

            -- Minimal color picker popup (hue slider)
            local popup = Create("Frame", {
                Size             = UDim2.new(0, 200, 0, 80),
                Position         = UDim2.new(0, 0, 1, 6),
                BackgroundColor3 = Theme.Surface,
                Visible          = false,
                ZIndex           = 20,
                Parent           = f,
            })
            MakeCorner(8, popup)
            MakeStroke(Theme.Border, 1, popup)

            Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 20),
                Position         = UDim2.new(0, 0, 0, 4),
                BackgroundTransparency = 1,
                Text             = "Hue",
                TextColor3       = Theme.TextSecondary,
                TextSize         = 10,
                Font             = Enum.Font.Gotham,
                ZIndex           = 21,
                Parent           = popup,
            })

            -- Hue gradient bar
            local hueBar = Create("Frame", {
                Size             = UDim2.new(1, -20, 0, 14),
                Position         = UDim2.new(0, 10, 0, 26),
                BackgroundColor3 = Color3.fromRGB(255,0,0),
                ZIndex           = 21,
                Parent           = popup,
            })
            MakeCorner(4, hueBar)

            local hueGrad = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,0)),
                }),
                Parent = hueBar,
            })

            local hueKnob = Create("Frame", {
                Size             = UDim2.new(0, 10, 0, 18),
                Position         = UDim2.new(0, -5, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                ZIndex           = 22,
                Parent           = hueBar,
            })
            MakeCorner(3, hueKnob)

            local satLabel = Create("TextLabel", {
                Size             = UDim2.new(1, -20, 0, 18),
                Position         = UDim2.new(0, 10, 0, 50),
                BackgroundTransparency = 0.5,
                BackgroundColor3 = Color3.fromRGB(0,0,0),
                Text             = "Click hue bar to pick",
                TextColor3       = Theme.TextSecondary,
                TextSize         = 9,
                Font             = Enum.Font.Gotham,
                ZIndex           = 21,
                Parent           = popup,
            })
            MakeCorner(4, satLabel)

            local h, s, v = Color3.toHSV(currentColor)
            local function applyHue(newH)
                h = newH
                currentColor = Color3.fromHSV(h, 0.8, 0.9)
                Tween(preview, { BackgroundColor3 = currentColor }, 0.1)
                task.spawn(callback, currentColor)
            end

            local draggingHue = false
            hueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    Tween(hueKnob, { Position = UDim2.new(rel, -5, 0.5, -9) }, 0.05)
                    applyHue(rel)
                end
            end)
            hueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local rel = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    Tween(hueKnob, { Position = UDim2.new(rel, -5, 0.5, -9) }, 0.05)
                    applyHue(rel)
                end
            end)

            preview.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                popup.Visible = pickerOpen
            end)

            local CpObj = {}
            function CpObj:Get() return currentColor end
            function CpObj:Set(c)
                currentColor = c
                preview.BackgroundColor3 = c
            end
            return CpObj
        end

        -- SEPARATOR
        function TabObj:AddSeparator()
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Border,
                Parent           = TabContent,
            })
        end

        return TabObj
    end

    return WindowObj
end

-- ============================================================
-- GLOBAL NOTIFICATION SHORTCUT
-- ============================================================
function SentenceHub.Notify(opts)
    local lib = setmetatable({}, SentenceHub)
    lib:Notify(opts)
end

-- ============================================================
-- RETURN
-- ============================================================
return SentenceHub
