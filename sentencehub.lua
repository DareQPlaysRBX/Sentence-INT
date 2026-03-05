--[[
    ╔═══════════════════════════════════════════════╗
    ║         SENTENCE Hub  ·  v1.0.0               ║
    ║    Clean · Professional · Animated            ║
    ╚═══════════════════════════════════════════════╝
]]

local Sentence = {
    Version    = "1.0.0",
    Flags      = {},
    Options    = {},
    _conns     = {},
}

-- ── Services ──────────────────────────────────────────────────────────────────
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer
local Camera            = workspace.CurrentCamera
local IsStudio          = RunService:IsStudio()

-- ── Palette ───────────────────────────────────────────────────────────────────
local C = {
    -- Base
    base0     = Color3.fromRGB( 9,  9, 13),   -- deepest bg
    base1     = Color3.fromRGB(14, 14, 20),   -- window bg
    base2     = Color3.fromRGB(20, 20, 28),   -- sidebar / panel
    base3     = Color3.fromRGB(28, 28, 38),   -- element bg
    base4     = Color3.fromRGB(36, 36, 50),   -- element hover
    -- Borders
    bdr       = Color3.fromRGB(52, 52, 72),
    bdrHov    = Color3.fromRGB(80, 80, 110),
    bdrAct    = Color3.fromRGB(120,110,170),
    -- Text
    txtHi     = Color3.fromRGB(240,238,255),
    txtMid    = Color3.fromRGB(170,165,200),
    txtLow    = Color3.fromRGB(100, 95,130),
    -- Accents  (electric violet → indigo)
    acc1      = Color3.fromRGB(140, 90,255),  -- primary accent
    acc2      = Color3.fromRGB(100,160,255),  -- secondary accent (blue)
    acc3      = Color3.fromRGB(200,120,255),  -- tertiary (pink-violet)
    -- Semantic
    ok        = Color3.fromRGB( 80,210,130),
    warn      = Color3.fromRGB(230,175, 50),
    err       = Color3.fromRGB(220, 65, 65),
    info      = Color3.fromRGB( 80,155,240),
    -- Toggle
    togOn     = Color3.fromRGB(140, 90,255),
    togOff    = Color3.fromRGB( 44, 44, 62),
}

local ACCENT_SEQ = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, C.acc1),
    ColorSequenceKeypoint.new(0.50, C.acc2),
    ColorSequenceKeypoint.new(1.00, C.acc3),
}

-- ── Tween helpers ─────────────────────────────────────────────────────────────
local function TI(t, style, dir)
    return TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Exponential, dir or Enum.EasingDirection.Out)
end
local TI_FAST   = TI(0.12)
local TI_MED    = TI(0.25)
local TI_SLOW   = TI(0.55)
local TI_SPRING = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tw(obj, props, info, cb)
    local t = TweenService:Create(obj, info or TI_MED, props)
    if cb then t.Completed:Once(cb) end
    t:Play(); return t
end

-- ── Utilities ─────────────────────────────────────────────────────────────────
local function defaults(def, tbl)
    tbl = tbl or {}
    for k, v in pairs(def) do if tbl[k] == nil then tbl[k] = v end end
    return tbl
end

local function track(conn)
    table.insert(Sentence._conns, conn); return conn
end

local ICONS = {
    home         = "rbxassetid://6026568195",
    settings     = "rbxassetid://6031280882",
    search       = "rbxassetid://6031154871",
    info         = "rbxassetid://6026568227",
    warning      = "rbxassetid://6031071053",
    close        = "rbxassetid://6031094678",
    check        = "rbxassetid://6031094667",
    eye_off      = "rbxassetid://6031075929",
    eye          = "rbxassetid://6031075931",
    minimize     = "rbxassetid://6031094687",
    person       = "rbxassetid://6034287594",
    star         = "rbxassetid://6031068423",
    flash        = "rbxassetid://6034333271",
    shield       = "rbxassetid://6035078889",
    refresh      = "rbxassetid://6031097226",
    wifi         = "rbxassetid://6034461626",
    arrow_r      = "rbxassetid://6031090995",
    chev_d       = "rbxassetid://6031094687",
    chev_u       = "rbxassetid://6031094679",
    delete       = "rbxassetid://6022668885",
    edit         = "rbxassetid://6034328955",
    save         = "rbxassetid://6035067857",
    code         = "rbxassetid://6022668955",
    palette      = "rbxassetid://6034316009",
    games        = "rbxassetid://6026660074",
    notif        = "rbxassetid://6034308946",
    power        = "rbxassetid://6034457105",
    unknown      = "rbxassetid://6031079152",
}

local function icon(name)
    if not name then return "" end
    if name:find("rbxassetid") then return name end
    if tonumber(name) then return "rbxassetid://"..name end
    return ICONS[name] or ICONS.unknown
end

-- ── Core UI builders ──────────────────────────────────────────────────────────
local function Frame(props)
    props = props or {}
    local f = Instance.new("Frame")
    f.Name               = props.Name or "Frame"
    f.Size               = props.Size or UDim2.new(1,0,0,40)
    f.Position           = props.Position or UDim2.new()
    f.AnchorPoint        = props.AnchorPoint or Vector2.zero
    f.BackgroundColor3   = props.BgColor or C.base3
    f.BackgroundTransparency = props.BgAlpha or 0
    f.BorderSizePixel    = 0
    f.ZIndex             = props.ZIndex or 1
    f.LayoutOrder        = props.Order or 0
    f.Visible            = props.Visible ~= false
    if props.Clip then f.ClipsDescendants = true end

    if props.Radius ~= false then
        local uc = Instance.new("UICorner")
        uc.CornerRadius = props.Radius or UDim.new(0,8)
        uc.Parent = f
    end
    if props.Stroke or props.StrokeColor then
        local s = Instance.new("UIStroke")
        s.Color       = props.StrokeColor or C.bdr
        s.Transparency = props.StrokeAlpha or 0.4
        s.Thickness   = props.StrokeWidth or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = f
    end
    if props.Parent then f.Parent = props.Parent end
    return f
end

local function Lbl(props)
    props = props or {}
    local l = Instance.new("TextLabel")
    l.Name             = props.Name or "Label"
    l.Text             = props.Text or ""
    l.Size             = props.Size or UDim2.new(1,0,0,18)
    l.Position         = props.Position or UDim2.new()
    l.AnchorPoint      = props.AnchorPoint or Vector2.zero
    l.Font             = props.Font or Enum.Font.GothamSemibold
    l.TextSize         = props.TextSize or 13
    l.TextColor3       = props.Color or C.txtHi
    l.TextTransparency = props.Alpha or 0
    l.TextXAlignment   = props.AlignX or Enum.TextXAlignment.Left
    l.TextYAlignment   = props.AlignY or Enum.TextYAlignment.Center
    l.TextWrapped      = props.Wrap or false
    l.RichText         = true
    l.BackgroundTransparency = 1
    l.BorderSizePixel  = 0
    l.ZIndex           = props.ZIndex or 2
    l.LayoutOrder      = props.Order or 0
    if props.AutoY then l.AutomaticSize = Enum.AutomaticSize.Y end
    if props.Parent then l.Parent = props.Parent end
    return l
end

local function Img(props)
    props = props or {}
    local i = Instance.new("ImageLabel")
    i.Name             = props.Name or "Img"
    i.Image            = icon(props.Icon or "")
    i.Size             = props.Size or UDim2.new(0,20,0,20)
    i.Position         = props.Position or UDim2.new(0,0,0.5,0)
    i.AnchorPoint      = props.AnchorPoint or Vector2.new(0,0.5)
    i.ImageColor3      = props.Color or C.txtHi
    i.ImageTransparency = props.Alpha or 0
    i.BackgroundTransparency = 1
    i.BorderSizePixel  = 0
    i.ZIndex           = props.ZIndex or 2
    i.ScaleType        = Enum.ScaleType.Fit
    if props.Parent then i.Parent = props.Parent end
    return i
end

local function ClickBtn(parent, zindex)
    local b = Instance.new("TextButton")
    b.Name = "Click"; b.Size = UDim2.new(1,0,1,0)
    b.BackgroundTransparency = 1; b.Text = ""
    b.ZIndex = zindex or 10; b.Parent = parent
    return b
end

local function ListLayout(parent, gap, align)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0, gap or 5)
    if align then l.HorizontalAlignment = align end
    l.Parent = parent; return l
end

local function Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent; return p
end

local function GradFrame(parent, seq, size, pos, zidx, anchor, rotation)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1,0,0,2)
    f.Position = pos or UDim2.new()
    f.AnchorPoint = anchor or Vector2.zero
    f.BackgroundColor3 = Color3.new(1,1,1)
    f.BorderSizePixel = 0
    f.ZIndex = zidx or 3
    f.Parent = parent
    local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(1,0); uc.Parent = f
    local g = Instance.new("UIGradient"); g.Color = seq or ACCENT_SEQ
    if rotation then g.Rotation = rotation end
    g.Parent = f
    return f, g
end

-- ── Dragging ─────────────────────────────────────────────────────────────────
local function MakeDraggable(handle, window)
    local drag, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = i.Position; startPos = window.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and drag then
            local d = i.Position - dragStart
            tw(window, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)}, TI(0.18, Enum.EasingStyle.Exponential))
        end
    end)
end

-- ── Safe callback ─────────────────────────────────────────────────────────────
local function Safe(cb, ...)
    local ok, err = pcall(cb, ...)
    if not ok then warn("SENTENCE Hub callback error: "..tostring(err)) end
end

-- ══════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION
-- ══════════════════════════════════════════════════════════════════════════════
function Sentence:Notify(data)
    task.spawn(function()
        data = defaults({Title="Notification", Content="", Icon="info", Duration=nil, Type="Info"}, data)
        local typeAcc = {Info=C.info, Success=C.ok, Warning=C.warn, Error=C.err}
        local acc = typeAcc[data.Type] or C.info

        local card = Frame({
            Name="Notif", Size=UDim2.new(1,0,0,0),
            BgColor=C.base2, BgAlpha=0.05, Clip=true,
            Radius=UDim.new(0,10), Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.5,
            Parent=self._notifHolder,
        })

        -- Accent glow left strip
        local strip = Frame({
            Size=UDim2.new(0,3,1,-12), Position=UDim2.new(0,5,0,6),
            BgColor=acc, BgAlpha=0, Radius=UDim.new(1,0), ZIndex=3, Parent=card,
        })

        local ico = Img({Icon=data.Icon, Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,16,0,14),
            AnchorPoint=Vector2.zero, Color=acc, Alpha=1, ZIndex=3, Parent=card})

        local ttl = Lbl({Text=data.Title, Size=UDim2.new(1,-46,0,16), Position=UDim2.new(0,42,0,8),
            Font=Enum.Font.GothamBold, TextSize=13, Color=C.txtHi, Alpha=1, ZIndex=3, Parent=card})

        local msg = Lbl({Text=data.Content, Size=UDim2.new(1,-46,0,900), Position=UDim2.new(0,42,0,26),
            Font=Enum.Font.Gotham, TextSize=12, Color=C.txtMid, Alpha=1, Wrap=true, ZIndex=3, Parent=card})

        task.wait()
        local th = msg.TextBounds.Y
        msg.Size = UDim2.new(1,-46,0,th)
        local totalH = 36 + th

        tw(card, {Size=UDim2.new(1,0,0,totalH)}, TI_SLOW)
        task.wait(0.1)
        tw(strip, {BackgroundTransparency=0})
        tw(ico,   {ImageTransparency=0})
        tw(ttl,   {TextTransparency=0})
        tw(msg,   {TextTransparency=0})

        local dur = data.Duration or math.clamp(#data.Content*0.07+2.5, 2.5, 9)
        task.wait(dur)

        tw(card, {BackgroundTransparency=1})
        tw(strip, {BackgroundTransparency=1})
        tw(ico,  {ImageTransparency=1})
        tw(ttl,  {TextTransparency=1})
        tw(msg,  {TextTransparency=1})
        tw(card.UIStroke, {Transparency=1})
        task.wait(0.3)
        tw(card, {Size=UDim2.new(1,0,0,0)}, TI_SLOW, function() card:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════════════════════════════════════════
function Sentence:CreateWindow(cfg)
    cfg = defaults({
        Name         = "SENTENCE Hub",
        Subtitle     = "",
        Icon         = "rbxassetid://118722741385791",
        Theme        = "Default",
        ToggleBind   = Enum.KeyCode.RightControl,
        LoadingEnabled = true,
        LoadingTitle   = "SENTENCE",
        LoadingSubtitle = "Initialising...",
        ConfigurationSaving = {Enabled=false, FolderName="SENTENCE", FileName="config"},
    }, cfg)

    -- ── Responsive size ───────────────────────────────────────────────────────
    local vp = Camera.ViewportSize
    local WIN_W = math.clamp(vp.X - 120, 520, 720)
    local WIN_H = math.clamp(vp.Y - 100, 380, 470)
    local FULL_SIZE = UDim2.fromOffset(WIN_W, WIN_H)
    local MIN_SIZE  = UDim2.fromOffset(WIN_W, 44)

    -- ── ScreenGui ─────────────────────────────────────────────────────────────
    local gui = Instance.new("ScreenGui")
    gui.Name = "SentenceHub"
    gui.DisplayOrder = 999999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui); gui.Parent = CoreGui
    elseif not IsStudio then
        gui.Parent = CoreGui
    else
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ── Notification holder ───────────────────────────────────────────────────
    local notifHolder = Instance.new("Frame")
    notifHolder.Name = "Notifications"
    notifHolder.Size = UDim2.new(0,300,1,-20)
    notifHolder.Position = UDim2.new(1,-310,0,10)
    notifHolder.BackgroundTransparency = 1
    notifHolder.ZIndex = 200
    notifHolder.Parent = gui
    local nl = ListLayout(notifHolder, 6)
    nl.VerticalAlignment = Enum.VerticalAlignment.Bottom
    self._notifHolder = notifHolder

    -- ── Main window frame ─────────────────────────────────────────────────────
    local win = Frame({
        Name="Window", Size=UDim2.fromOffset(0,0),
        Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5),
        BgColor=C.base1, BgAlpha=0.04, Clip=true,
        Radius=UDim.new(0,12), Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.3,
        ZIndex=1, Parent=gui,
    })

    -- Subtle noise-like gradient overlay for depth
    local depthGrad = Frame({
        Size=UDim2.new(1,0,1,0), BgColor=C.base0, BgAlpha=0.55,
        ZIndex=0, Parent=win,
    })
    depthGrad.Name = "DepthBg"
    Instance.new("UICorner", depthGrad).CornerRadius = UDim.new(0,12)

    -- Top accent line (animated gradient)
    local topLine, topLineGrad = GradFrame(win, ACCENT_SEQ, UDim2.new(1,0,0,2), UDim2.new(0,0,0,0), 5)
    Instance.new("UICorner", topLine).CornerRadius = UDim.new(0,12)

    -- ── Title bar ─────────────────────────────────────────────────────────────
    local titleBar = Frame({
        Name="TitleBar", Size=UDim2.new(1,0,0,44), Position=UDim2.new(0,0,0,2),
        BgAlpha=1, ZIndex=3, Parent=win,
    })
    MakeDraggable(titleBar, win)

    -- Logo icon
    local logoImg = Img({
        Icon=cfg.Icon, Size=UDim2.new(0,22,0,22),
        Position=UDim2.new(0,14,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        Alpha=1, ZIndex=4, Parent=titleBar,
    })

    -- Window name
    local nameLabel = Lbl({
        Text=cfg.Name, Size=UDim2.new(0,250,0,18),
        Position=UDim2.new(0,44,0,7),
        Font=Enum.Font.GothamBold, TextSize=14,
        Color=C.txtHi, Alpha=1, ZIndex=4, Parent=titleBar,
    })
    -- Subtitle
    if cfg.Subtitle and cfg.Subtitle ~= "" then
        Lbl({Text=cfg.Subtitle, Size=UDim2.new(0,250,0,13),
            Position=UDim2.new(0,44,0,24),
            Font=Enum.Font.Gotham, TextSize=11,
            Color=C.txtLow, Alpha=0, ZIndex=4, Parent=titleBar,
        })
    end

    -- Version badge
    Lbl({Text="v"..Sentence.Version, Size=UDim2.new(0,60,0,14),
        Position=UDim2.new(0,44+#cfg.Name*7.5+4, 0, 14),
        Font=Enum.Font.Gotham, TextSize=10,
        Color=C.acc1, Alpha=0, ZIndex=4, Parent=titleBar,
    })

    -- Title separator
    local titleSep = Frame({
        Name="Sep", Size=UDim2.new(1,-24,0,1),
        Position=UDim2.new(0,12,1,0),
        BgColor=C.bdr, BgAlpha=0.55, ZIndex=3, Radius=UDim.new(1,0), Parent=titleBar,
    })

    -- ── Control buttons ───────────────────────────────────────────────────────
    local function CtrlBtn(name, ico, xOff, col)
        local b = Frame({
            Name=name, Size=UDim2.new(0,26,0,26),
            Position=UDim2.new(1,xOff,0.5,0), AnchorPoint=Vector2.new(0,0.5),
            BgColor=C.base3, BgAlpha=0.5,
            Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.6,
            Radius=UDim.new(0,7), ZIndex=5, Parent=titleBar,
        })
        Img({Icon=ico, Size=UDim2.new(0,14,0,14),
            Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5),
            Color=col or C.txtMid, Alpha=0.1, ZIndex=6, Parent=b,
        })
        local click = ClickBtn(b, 7)
        b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency=0.15}, TI_FAST) end)
        b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency=0.5}, TI_FAST) end)
        return b, click
    end

    local closeBtn,  closeClick  = CtrlBtn("Close",    "close",   -38, C.err)
    local minBtn,    minClick    = CtrlBtn("Minimize",  "minimize",-68, C.txtMid)
    local hideBtn,   hideClick   = CtrlBtn("Hide",      "eye_off", -98, C.txtMid)

    -- Animate icons in after load
    for _, b in ipairs({closeBtn, minBtn, hideBtn}) do
        local ic = b:FindFirstChildOfClass("ImageLabel")
        if ic then task.delay(0.1, function() tw(ic, {ImageTransparency=0}) end) end
    end

    -- ── Sidebar ───────────────────────────────────────────────────────────────
    local SIDEBAR_W = 160
    local sidebar = Frame({
        Name="Sidebar", Size=UDim2.new(0,SIDEBAR_W,1,-46),
        Position=UDim2.new(0,0,0,46),
        BgColor=C.base2, BgAlpha=0.35, ZIndex=2, Parent=win,
    })
    sidebar.Name = "Sidebar"

    -- Sidebar right border
    Frame({
        Size=UDim2.new(0,1,1,-10), Position=UDim2.new(1,0,0,5),
        BgColor=C.bdr, BgAlpha=0.55, ZIndex=3, Parent=sidebar,
    })

    -- Sidebar brand accent at bottom
    local sideBrand, _ = GradFrame(sidebar, ACCENT_SEQ, UDim2.new(0.6,0,0,2),
        UDim2.new(0.2,0,1,-8), 3)

    -- Tab buttons scroll container
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.Size = UDim2.new(1,0,1,-40)
    tabScroll.Position = UDim2.new(0,0,0,6)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 0
    tabScroll.CanvasSize = UDim2.new(0,0,0,0)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.ZIndex = 3
    tabScroll.Parent = sidebar
    ListLayout(tabScroll, 3)
    Padding(tabScroll, 6, 6, 8, 8)

    -- Player info at bottom of sidebar
    local playerFrame = Frame({
        Size=UDim2.new(1,0,0,36), Position=UDim2.new(0,0,1,-38),
        BgAlpha=1, ZIndex=3, Parent=sidebar,
    })
    local pAvatar = Instance.new("ImageLabel")
    pAvatar.Size = UDim2.new(0,24,0,24)
    pAvatar.Position = UDim2.new(0,10,0.5,0); pAvatar.AnchorPoint = Vector2.new(0,0.5)
    pAvatar.BackgroundTransparency = 1; pAvatar.ZIndex = 4; pAvatar.Parent = playerFrame
    local pAC = Instance.new("UICorner"); pAC.CornerRadius = UDim.new(1,0); pAC.Parent = pAvatar
    pcall(function()
        pAvatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    local pStroke = Instance.new("UIStroke"); pStroke.Color = C.acc1; pStroke.Thickness = 1.5
    pStroke.Transparency = 0.4; pStroke.Parent = pAvatar
    Lbl({Text=LocalPlayer.DisplayName, Size=UDim2.new(1,-44,0,14),
        Position=UDim2.new(0,40,0,4), Font=Enum.Font.GothamSemibold, TextSize=11,
        Color=C.txtMid, ZIndex=4, Parent=playerFrame,
    })

    -- ── Content area ──────────────────────────────────────────────────────────
    local content = Frame({
        Name="Content", Size=UDim2.new(1,-SIDEBAR_W-1,1,-46),
        Position=UDim2.new(0,SIDEBAR_W+1,0,46),
        BgAlpha=1, Clip=true, ZIndex=2, Parent=win,
    })

    -- ══════════════════════════════════════════════════════════════════════════
    -- LOADING SCREEN
    -- ══════════════════════════════════════════════════════════════════════════
    local function RunLoading()
        local lf = Frame({
            Name="Loading", Size=UDim2.new(1,0,1,0),
            BgColor=C.base0, BgAlpha=0, Radius=UDim.new(0,12),
            ZIndex=50, Parent=win,
        })

        -- Animated gradient line
        local ll, _ = GradFrame(lf, ACCENT_SEQ, UDim2.new(0.45,0,0,2),
            UDim2.new(0.275,0,0.5,30), 51)

        -- Logo
        local lLogo = Img({
            Icon=cfg.Icon, Size=UDim2.new(0,36,0,36),
            Position=UDim2.new(0.5,0,0.5,-42), AnchorPoint=Vector2.new(0.5,0.5),
            Alpha=1, ZIndex=51, Parent=lf,
        })
        local lTitle = Lbl({
            Text=cfg.LoadingTitle, Size=UDim2.new(1,0,0,24),
            Position=UDim2.new(0.5,0,0.5,-8), AnchorPoint=Vector2.new(0.5,0.5),
            Font=Enum.Font.GothamBold, TextSize=22,
            Color=C.txtHi, Alpha=1, AlignX=Enum.TextXAlignment.Center, ZIndex=51, Parent=lf,
        })
        local lSub = Lbl({
            Text=cfg.LoadingSubtitle, Size=UDim2.new(1,0,0,16),
            Position=UDim2.new(0.5,0,0.5,14), AnchorPoint=Vector2.new(0.5,0.5),
            Font=Enum.Font.Gotham, TextSize=12,
            Color=C.txtLow, Alpha=1, AlignX=Enum.TextXAlignment.Center, ZIndex=51, Parent=lf,
        })

        -- Staggered fade in
        tw(win,    {Size=FULL_SIZE}, TI_SLOW)
        task.wait(0.3)
        tw(lLogo,  {ImageTransparency=0}, TI(0.5))
        task.wait(0.1)
        tw(lTitle, {TextTransparency=0}, TI(0.5))
        task.wait(0.08)
        tw(lSub,   {TextTransparency=0}, TI(0.5))
        task.wait(0.12)
        tw(ll,     {BackgroundTransparency=0}, TI(0.4))
        task.wait(2.2)

        -- Fade out
        tw(lLogo,  {ImageTransparency=1})
        tw(lTitle, {TextTransparency=1})
        tw(lSub,   {TextTransparency=1})
        tw(ll,     {BackgroundTransparency=1})
        task.wait(0.25)
        tw(lf, {BackgroundTransparency=1}, TI_MED, function() lf:Destroy() end)
        task.wait(0.35)
        return true
    end

    -- ── Window state ──────────────────────────────────────────────────────────
    local W = {
        _gui        = gui,
        _win        = win,
        _content    = content,
        _tabs       = {},       -- {btn, page, name}
        _activeTab  = nil,
        _visible    = true,
        _minimized  = false,
        _cfg        = cfg,
    }

    -- Open animation
    gui.Enabled = true
    if cfg.LoadingEnabled then
        RunLoading()
    else
        tw(win, {Size=FULL_SIZE}, TI_SLOW)
        task.wait(0.3)
    end

    -- Reveal title bar elements
    tw(logoImg, {ImageTransparency=0}, TI(0.4))
    tw(nameLabel, {TextTransparency=0}, TI(0.4))

    -- ── Hide / Show / Minimize ────────────────────────────────────────────────
    local function HideWin()
        W._visible = false
        tw(win, {Size=UDim2.fromOffset(0,0)}, TI_SLOW, function() win.Visible = false end)
    end
    local function ShowWin()
        win.Visible = true; W._visible = true
        tw(win, {Size = W._minimized and MIN_SIZE or FULL_SIZE}, TI_SLOW)
    end

    closeClick.MouseButton1Click:Connect(function() Sentence:Destroy() end)
    hideClick.MouseButton1Click:Connect(function()
        Sentence:Notify({Title="Hidden", Content="Press "..cfg.ToggleBind.Name.." to show.", Icon="eye_off", Type="Info"})
        HideWin()
    end)
    minClick.MouseButton1Click:Connect(function()
        W._minimized = not W._minimized
        if W._minimized then
            sidebar.Visible = false; content.Visible = false
            tw(win, {Size=MIN_SIZE}, TI_MED)
        else
            tw(win, {Size=FULL_SIZE}, TI_MED, function()
                sidebar.Visible = true; content.Visible = true
            end)
        end
    end)

    track(UserInputService.InputBegan:Connect(function(inp, proc)
        if proc then return end
        if inp.KeyCode == cfg.ToggleBind then
            if W._visible then HideWin() else ShowWin() end
        end
    end))

    -- ══════════════════════════════════════════════════════════════════════════
    -- HOME TAB
    -- ══════════════════════════════════════════════════════════════════════════
    function W:CreateHomeTab(homeCfg)
        homeCfg = defaults({Icon="home"}, homeCfg or {})

        -- Sidebar tab button
        local hBtn = Frame({
            Name="HomeTab", Size=UDim2.new(1,0,0,34),
            BgColor=C.acc1, BgAlpha=0, Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.6,
            Radius=UDim.new(0,7), ZIndex=4, Parent=tabScroll, Order=0,
        })
        local hIndic = Frame({
            Size=UDim2.new(0,3,0.6,0), Position=UDim2.new(0,0,0.2,0),
            BgColor=C.acc1, BgAlpha=1, Radius=UDim.new(1,0), ZIndex=5, Parent=hBtn,
        })
        hIndic.BackgroundTransparency = 1
        Img({Icon=homeCfg.Icon, Size=UDim2.new(0,16,0,16),
            Position=UDim2.new(0,12,0.5,0), AnchorPoint=Vector2.new(0,0.5),
            Color=C.acc1, Alpha=0.2, ZIndex=5, Parent=hBtn,
        })
        Lbl({Text="Home", Size=UDim2.new(1,-36,0,14),
            Position=UDim2.new(0,34,0.5,0), AnchorPoint=Vector2.new(0,0.5),
            Font=Enum.Font.GothamSemibold, TextSize=12,
            Color=C.txtMid, Alpha=0, ZIndex=5, Parent=hBtn,
        })
        ClickBtn(hBtn, 6)

        -- Home page
        local hPage = Instance.new("ScrollingFrame")
        hPage.Name="HomePage"; hPage.Size=UDim2.new(1,0,1,0)
        hPage.BackgroundTransparency=1; hPage.BorderSizePixel=0
        hPage.ScrollBarThickness=2; hPage.ScrollBarImageColor3=C.bdr
        hPage.CanvasSize=UDim2.new(0,0,0,0); hPage.AutomaticCanvasSize=Enum.AutomaticSize.Y
        hPage.ZIndex=2; hPage.Visible=true; hPage.Parent=content
        ListLayout(hPage, 8)
        Padding(hPage, 12, 12, 14, 14)

        -- Player card
        local pCard = Frame({
            Name="PlayerCard", Size=UDim2.new(1,0,0,70),
            BgColor=C.base3, BgAlpha=0.3, Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.5,
            Radius=UDim.new(0,8), ZIndex=3, Parent=hPage,
        })
        local bigAv = Instance.new("ImageLabel")
        bigAv.Size=UDim2.new(0,46,0,46); bigAv.Position=UDim2.new(0,12,0.5,0)
        bigAv.AnchorPoint=Vector2.new(0,0.5); bigAv.BackgroundTransparency=1; bigAv.ZIndex=4; bigAv.Parent=pCard
        Instance.new("UICorner",bigAv).CornerRadius=UDim.new(1,0)
        pcall(function() bigAv.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
        local avS = Instance.new("UIStroke"); avS.Color=C.acc1; avS.Thickness=2; avS.Transparency=0.35; avS.Parent=bigAv
        Lbl({Text="Hello, "..LocalPlayer.DisplayName, Size=UDim2.new(1,-80,0,18),
            Position=UDim2.new(0,70,0,14), Font=Enum.Font.GothamBold, TextSize=16,
            Color=C.txtHi, ZIndex=4, Parent=pCard,
        })
        Lbl({Text="@"..LocalPlayer.Name.."  ·  "..cfg.Name, Size=UDim2.new(1,-80,0,14),
            Position=UDim2.new(0,70,0,36), Font=Enum.Font.Gotham, TextSize=11,
            Color=C.txtLow, ZIndex=4, Parent=pCard,
        })

        -- Stats grid
        local sCard = Frame({
            Name="Stats", Size=UDim2.new(1,0,0,106),
            BgColor=C.base3, BgAlpha=0.3, Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.5,
            Radius=UDim.new(0,8), ZIndex=3, Parent=hPage,
        })
        Lbl({Text="SERVER INFO", Size=UDim2.new(1,-20,0,14), Position=UDim2.new(0,12,0,8),
            Font=Enum.Font.GothamBold, TextSize=10, Color=C.txtLow, ZIndex=4, Parent=sCard,
        })

        local statVals = {}
        local statData = {{"Players","---"},{"Ping","---"},{"Uptime","---"},{"Region","---"}}
        for i, sd in ipairs(statData) do
            local row = (i-1) >= 2 and 1 or 0
            local col = (i-1) % 2
            local x, y = 12 + col*220, 28 + row*36
            Lbl({Text=sd[1], Size=UDim2.new(0,100,0,13), Position=UDim2.new(0,x,0,y),
                Font=Enum.Font.Gotham, TextSize=10, Color=C.txtLow, ZIndex=4, Parent=sCard,
            })
            statVals[sd[1]] = Lbl({Text=sd[2], Size=UDim2.new(0,200,0,16),
                Position=UDim2.new(0,x,0,y+14), Font=Enum.Font.GothamSemibold, TextSize=12,
                Color=C.txtHi, ZIndex=4, Parent=sCard,
            })
        end

        task.spawn(function()
            while task.wait(1) do
                if not win or not win.Parent then break end
                pcall(function()
                    statVals["Players"].Text = #Players:GetPlayers().."/"..Players.MaxPlayers
                    statVals["Ping"].Text = math.floor(LocalPlayer:GetNetworkPing()*1000).."ms"
                    local t = math.floor(time())
                    statVals["Uptime"].Text = string.format("%02d:%02d:%02d", math.floor(t/3600), math.floor(t%3600/60), t%60)
                    pcall(function()
                        statVals["Region"].Text = game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(LocalPlayer)
                    end)
                end)
            end
        end)

        -- Activate
        local function activateHome()
            for _, td in ipairs(W._tabs) do
                td.page.Visible = false
                tw(td.btn, {BackgroundTransparency=1})
                tw(td.btn.UIStroke, {Transparency=0.6})
                local ic = td.btn:FindFirstChildOfClass("ImageLabel")
                if ic then tw(ic, {ImageColor3=C.txtMid}) end
                local lbl = td.btn:FindFirstChildOfClass("TextLabel")
                if lbl then tw(lbl, {TextTransparency=0.4}) end
                local ind = td.btn:FindFirstChild("Indic")
                if ind then tw(ind, {BackgroundTransparency=1}) end
            end
            hPage.Visible = true
            tw(hBtn, {BackgroundTransparency=0.88})
            tw(hBtn.UIStroke, {Transparency=0.2})
            tw(hIndic, {BackgroundTransparency=0})
            local hi = hBtn:FindFirstChildOfClass("ImageLabel")
            if hi then tw(hi, {ImageColor3=C.acc1, ImageTransparency=0}) end
            local hl = hBtn:FindFirstChildOfClass("TextLabel")
            if hl then tw(hl, {TextTransparency=0, TextColor3=C.txtHi}) end
            W._activeTab = "Home"
        end

        activateHome()
        hBtn:FindFirstChild("Click").MouseButton1Click:Connect(activateHome)
        hBtn.MouseEnter:Connect(function()
            if W._activeTab ~= "Home" then tw(hBtn,{BackgroundTransparency=0.92},TI_FAST) end
        end)
        hBtn.MouseLeave:Connect(function()
            if W._activeTab ~= "Home" then tw(hBtn,{BackgroundTransparency=1},TI_FAST) end
        end)

        return {Activate=activateHome}
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- CREATE TAB
    -- ══════════════════════════════════════════════════════════════════════════
    function W:CreateTab(tabCfg)
        tabCfg = defaults({Name="Tab", Icon="unknown", ShowTitle=true}, tabCfg or {})
        local Tab = {}
        local isFirst = #W._tabs == 0

        -- Sidebar button
        local tBtn = Frame({
            Name=tabCfg.Name, Size=UDim2.new(1,0,0,34),
            BgColor=C.acc1, BgAlpha=isFirst and 0.88 or 1,
            Stroke=true, StrokeColor=C.bdr, StrokeAlpha=isFirst and 0.2 or 0.6,
            Radius=UDim.new(0,7), ZIndex=4, Parent=tabScroll, Order=#W._tabs+1,
        })

        -- Active indicator strip
        local tIndic = Frame({
            Name="Indic", Size=UDim2.new(0,3,0.6,0), Position=UDim2.new(0,0,0.2,0),
            BgColor=C.acc1, BgAlpha=isFirst and 0 or 1, Radius=UDim.new(1,0),
            ZIndex=5, Parent=tBtn,
        })

        local tIco = Img({
            Icon=tabCfg.Icon, Size=UDim2.new(0,16,0,16),
            Position=UDim2.new(0,12,0.5,0), AnchorPoint=Vector2.new(0,0.5),
            Color=isFirst and C.acc1 or C.txtMid,
            Alpha=isFirst and 0 or 0.2, ZIndex=5, Parent=tBtn,
        })
        local tLbl = Lbl({
            Text=tabCfg.Name, Size=UDim2.new(1,-36,0,14),
            Position=UDim2.new(0,34,0.5,0), AnchorPoint=Vector2.new(0,0.5),
            Font=Enum.Font.GothamSemibold, TextSize=12,
            Color=isFirst and C.txtHi or C.txtMid,
            Alpha=isFirst and 0 or 0.4, ZIndex=5, Parent=tBtn,
        })
        ClickBtn(tBtn, 6)

        -- Tab page
        local tPage = Instance.new("ScrollingFrame")
        tPage.Name=tabCfg.Name; tPage.Size=UDim2.new(1,0,1,0)
        tPage.BackgroundTransparency=1; tPage.BorderSizePixel=0
        tPage.ScrollBarThickness=2; tPage.ScrollBarImageColor3=C.bdr
        tPage.CanvasSize=UDim2.new(0,0,0,0); tPage.AutomaticCanvasSize=Enum.AutomaticSize.Y
        tPage.ZIndex=2; tPage.Visible=isFirst; tPage.Parent=content
        ListLayout(tPage, 6)
        Padding(tPage, 12, 12, 14, 14)

        if tabCfg.ShowTitle then
            Lbl({Text=tabCfg.Name, Size=UDim2.new(1,0,0,24),
                Font=Enum.Font.GothamBold, TextSize=17, Color=C.txtHi,
                ZIndex=3, Parent=tPage,
            })
        end

        table.insert(W._tabs, {btn=tBtn, page=tPage, name=tabCfg.Name, indic=tIndic, ico=tIco, lbl=tLbl})
        if isFirst then W._activeTab = tabCfg.Name end

        function Tab:Activate()
            -- Deactivate all
            for _, td in ipairs(W._tabs) do
                td.page.Visible = false
                tw(td.btn,        {BackgroundTransparency=1}, TI_MED)
                tw(td.btn.UIStroke,{Transparency=0.6}, TI_MED)
                tw(td.ico,        {ImageColor3=C.txtMid, ImageTransparency=0.2}, TI_MED)
                tw(td.lbl,        {TextTransparency=0.4, TextColor3=C.txtMid}, TI_MED)
                tw(td.indic,      {BackgroundTransparency=1}, TI_MED)
            end
            -- Hide home if present
            local hp = content:FindFirstChild("HomePage")
            if hp then hp.Visible = false end
            local homeBtn = tabScroll:FindFirstChild("HomeTab")
            if homeBtn then
                tw(homeBtn, {BackgroundTransparency=1})
                local hi = homeBtn:FindFirstChildOfClass("ImageLabel")
                if hi then tw(hi, {ImageTransparency=0.2, ImageColor3=C.txtMid}) end
                local hl = homeBtn:FindFirstChildOfClass("TextLabel")
                if hl then tw(hl, {TextTransparency=0.4}) end
                local hIndic = homeBtn:FindFirstChild("Indic")
                if hIndic then tw(hIndic, {BackgroundTransparency=1}) end
            end

            tPage.Visible = true
            tw(tBtn,        {BackgroundTransparency=0.88}, TI_MED)
            tw(tBtn.UIStroke,{Transparency=0.2}, TI_MED)
            tw(tIco,        {ImageColor3=C.acc1, ImageTransparency=0}, TI_MED)
            tw(tLbl,        {TextTransparency=0, TextColor3=C.txtHi}, TI_MED)
            tw(tIndic,      {BackgroundTransparency=0}, TI_SPRING)
            W._activeTab = tabCfg.Name
        end

        tBtn:FindFirstChild("Click").MouseButton1Click:Connect(function() Tab:Activate() end)
        tBtn.MouseEnter:Connect(function()
            if W._activeTab ~= tabCfg.Name then tw(tBtn,{BackgroundTransparency=0.92},TI_FAST) end
        end)
        tBtn.MouseLeave:Connect(function()
            if W._activeTab ~= tabCfg.Name then tw(tBtn,{BackgroundTransparency=1},TI_FAST) end
        end)

        -- ════════════════════════════════════════════════════════════════════
        -- CREATE SECTION
        -- ════════════════════════════════════════════════════════════════════
        function Tab:CreateSection(sName)
            sName = sName or ""
            local Sec = {}

            local secHeader = Instance.new("Frame")
            secHeader.Name = "SecHeader_"..sName
            secHeader.Size = UDim2.new(1,0,0, sName~="" and 22 or 2)
            secHeader.BackgroundTransparency = 1
            secHeader.LayoutOrder = #tPage:GetChildren()
            secHeader.Parent = tPage

            if sName ~= "" then
                local secLine = Frame({
                    Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0.5,0),
                    BgColor=C.bdr, BgAlpha=0.6, Radius=UDim.new(1,0),
                    ZIndex=3, Parent=secHeader,
                })
                Lbl({Text=sName:upper(), Size=UDim2.new(0,0,0,14),
                    Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5),
                    Font=Enum.Font.GothamBold, TextSize=10, Color=C.txtLow,
                    AlignX=Enum.TextXAlignment.Left, ZIndex=4, Parent=secHeader,
                }).AutomaticSize = Enum.AutomaticSize.X
            end

            local secContainer = Instance.new("Frame")
            secContainer.Name = "SecContainer_"..sName
            secContainer.Size = UDim2.new(1,0,0,0)
            secContainer.AutomaticSize = Enum.AutomaticSize.Y
            secContainer.BackgroundTransparency = 1
            secContainer.LayoutOrder = secHeader.LayoutOrder + 1
            secContainer.Parent = tPage
            ListLayout(secContainer, 4)

            -- ── Element helpers ───────────────────────────────────────────────
            local function ElemBase(h)
                local f = Frame({
                    Size=UDim2.new(1,0,0,h), BgColor=C.base3, BgAlpha=0.35,
                    Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.45,
                    Radius=UDim.new(0,7), ZIndex=3, Parent=secContainer,
                })
                return f
            end

            local function HoverStroke(el)
                el.MouseEnter:Connect(function() tw(el.UIStroke,{Color=C.bdrHov},TI_FAST) end)
                el.MouseLeave:Connect(function() tw(el.UIStroke,{Color=C.bdr},TI_FAST) end)
            end

            -- ── DIVIDER ───────────────────────────────────────────────────────
            function Sec:CreateDivider()
                local d = Frame({
                    Size=UDim2.new(1,0,0,1), BgColor=C.bdr, BgAlpha=0.55,
                    Radius=UDim.new(1,0), ZIndex=3, Parent=secContainer,
                })
                return {Visible=function(_,v) d.Visible=v end, Destroy=function() d:Destroy() end}
            end

            -- ── LABEL ─────────────────────────────────────────────────────────
            function Sec:CreateLabel(lCfg)
                lCfg = defaults({Text="Label", Style=1}, lCfg or {})
                local colMap  = {[1]=C.txtMid, [2]=C.info, [3]=C.warn}
                local bgMap   = {[1]=C.base3,  [2]=Color3.fromRGB(20,35,60), [3]=Color3.fromRGB(55,42,18)}
                local h = 30
                local f = Frame({
                    Size=UDim2.new(1,0,0,h), BgColor=bgMap[lCfg.Style], BgAlpha=0.45,
                    Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.45, Radius=UDim.new(0,7),
                    ZIndex=3, Parent=secContainer,
                })
                if lCfg.Style > 1 then
                    Frame({Size=UDim2.new(0,3,1,-8),Position=UDim2.new(0,4,0,4),
                        BgColor=colMap[lCfg.Style],Radius=UDim.new(1,0),ZIndex=4,Parent=f})
                end
                local xOff = lCfg.Style>1 and 16 or 10
                local tl = Lbl({Text=lCfg.Text, Size=UDim2.new(1,-xOff-8,0,14),
                    Position=UDim2.new(0,xOff,0.5,0), AnchorPoint=Vector2.new(0,0.5),
                    Font=Enum.Font.GothamSemibold, TextSize=12,
                    Color=colMap[lCfg.Style], ZIndex=4, Parent=f,
                })
                local LV = {}
                function LV:Set(t) tl.Text=t end
                function LV:Destroy() f:Destroy() end
                return LV
            end

            -- ── PARAGRAPH ─────────────────────────────────────────────────────
            function Sec:CreateParagraph(pCfg)
                pCfg = defaults({Title="Title", Content="Content"}, pCfg or {})
                local f = Frame({
                    Size=UDim2.new(1,0,0,0), BgColor=C.base3, BgAlpha=0.35,
                    Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.45, Radius=UDim.new(0,7),
                    ZIndex=3, Parent=secContainer,
                })
                f.AutomaticSize = Enum.AutomaticSize.Y
                Padding(f, 10, 10, 12, 12)
                ListLayout(f, 4)
                local pt = Lbl({Text=pCfg.Title, Size=UDim2.new(1,0,0,16),
                    Font=Enum.Font.GothamBold, TextSize=13, Color=C.txtHi, ZIndex=4, Parent=f,
                })
                local pc = Lbl({Text=pCfg.Content, Size=UDim2.new(1,0,0,0),
                    Font=Enum.Font.Gotham, TextSize=12, Color=C.txtMid, Wrap=true, ZIndex=4, AutoY=true, Parent=f,
                })
                local PV = {}
                function PV:Set(s) if s.Title then pt.Text=s.Title end; if s.Content then pc.Text=s.Content end end
                function PV:Destroy() f:Destroy() end
                return PV
            end

            -- ── BUTTON ────────────────────────────────────────────────────────
            function Sec:CreateButton(bCfg)
                bCfg = defaults({Name="Button", Description=nil, Callback=function()end}, bCfg or {})
                local h = bCfg.Description and 50 or 34
                local f = ElemBase(h)
                local titleL = Lbl({Text=bCfg.Name,
                    Size=UDim2.new(1,-50,0,16),
                    Position=UDim2.new(0,12,0,bCfg.Description and 7 or 9),
                    Font=Enum.Font.GothamSemibold, TextSize=13, Color=C.txtHi, ZIndex=4, Parent=f,
                })
                if bCfg.Description then
                    Lbl({Text=bCfg.Description, Size=UDim2.new(1,-50,0,13),
                        Position=UDim2.new(0,12,0,26), Font=Enum.Font.Gotham, TextSize=11,
                        Color=C.txtLow, ZIndex=4, Parent=f,
                    })
                end
                -- Arrow indicator
                Img({Icon="arrow_r", Size=UDim2.new(0,14,0,14),
                    Position=UDim2.new(1,-24,0.5,0), AnchorPoint=Vector2.new(0,0.5),
                    Color=C.acc1, Alpha=0.4, ZIndex=4, Parent=f,
                })
                local click = ClickBtn(f, 5)
                HoverStroke(f)
                click.MouseButton1Click:Connect(function()
                    tw(f,{BackgroundColor3=C.base4},TI_FAST)
                    tw(f.UIStroke,{Color=C.bdrAct},TI_FAST)
                    task.wait(0.15)
                    tw(f,{BackgroundColor3=C.base3},TI_MED)
                    tw(f.UIStroke,{Color=C.bdr},TI_MED)
                    Safe(bCfg.Callback)
                end)
                local BV = {Settings=bCfg}
                function BV:Set(s) s=defaults(bCfg,s or {}); bCfg=s; titleL.Text=s.Name end
                function BV:Destroy() f:Destroy() end
                return BV
            end

            -- ── TOGGLE ────────────────────────────────────────────────────────
            function Sec:CreateToggle(tCfg)
                tCfg = defaults({Name="Toggle",Description=nil,CurrentValue=false,Flag=nil,Callback=function()end}, tCfg or {})
                local h = tCfg.Description and 50 or 34
                local f = ElemBase(h)
                Lbl({Text=tCfg.Name, Size=UDim2.new(1,-72,0,16),
                    Position=UDim2.new(0,12,0,tCfg.Description and 7 or 9),
                    Font=Enum.Font.GothamSemibold, TextSize=13, Color=C.txtHi, ZIndex=4, Parent=f,
                })
                if tCfg.Description then
                    Lbl({Text=tCfg.Description, Size=UDim2.new(1,-72,0,13),
                        Position=UDim2.new(0,12,0,26), Font=Enum.Font.Gotham, TextSize=11,
                        Color=C.txtLow, ZIndex=4, Parent=f,
                    })
                end

                -- Track
                local track2 = Instance.new("Frame")
                track2.Name="Track"; track2.Size=UDim2.new(0,38,0,20)
                track2.Position=UDim2.new(1,-50,0.5,0); track2.AnchorPoint=Vector2.new(0,0.5)
                track2.BackgroundColor3=C.togOff; track2.BorderSizePixel=0; track2.ZIndex=4; track2.Parent=f
                Instance.new("UICorner",track2).CornerRadius=UDim.new(1,0)
                local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,14,0,14)
                knob.Position=UDim2.new(0,3,0.5,0); knob.AnchorPoint=Vector2.new(0,0.5)
                knob.BackgroundColor3=Color3.new(1,1,1); knob.BorderSizePixel=0; knob.ZIndex=5; knob.Parent=track2
                Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

                local TV = {CurrentValue=tCfg.CurrentValue, Type="Toggle", Settings=tCfg}
                local function updateVis()
                    if TV.CurrentValue then
                        tw(track2,{BackgroundColor3=C.togOn})
                        tw(knob,{Position=UDim2.new(0,21,0.5,0)},TI_SPRING)
                    else
                        tw(track2,{BackgroundColor3=C.togOff})
                        tw(knob,{Position=UDim2.new(0,3,0.5,0)},TI_SPRING)
                    end
                end
                updateVis()

                HoverStroke(f)
                ClickBtn(f,5).MouseButton1Click:Connect(function()
                    TV.CurrentValue = not TV.CurrentValue
                    updateVis(); Safe(tCfg.Callback, TV.CurrentValue)
                end)
                function TV:Set(v) TV.CurrentValue=v; updateVis(); Safe(tCfg.Callback,v) end
                function TV:Destroy() f:Destroy() end
                if tCfg.Flag then Sentence.Flags[tCfg.Flag]=TV; Sentence.Options[tCfg.Flag]=TV end
                return TV
            end

            -- ── SLIDER ────────────────────────────────────────────────────────
            function Sec:CreateSlider(sCfg)
                sCfg = defaults({Name="Slider",Range={0,100},Increment=1,CurrentValue=50,Suffix="",Flag=nil,Callback=function()end}, sCfg or {})
                local f = ElemBase(50)
                local valL = Lbl({Text=tostring(sCfg.CurrentValue)..sCfg.Suffix,
                    Size=UDim2.new(0,80,0,16), Position=UDim2.new(1,-12,0,8), AnchorPoint=Vector2.new(1,0),
                    Font=Enum.Font.GothamBold, TextSize=12, Color=C.acc1,
                    AlignX=Enum.TextXAlignment.Right, ZIndex=4, Parent=f,
                })
                Lbl({Text=sCfg.Name, Size=UDim2.new(1,-100,0,16),
                    Position=UDim2.new(0,12,0,8), Font=Enum.Font.GothamSemibold, TextSize=13,
                    Color=C.txtHi, ZIndex=4, Parent=f,
                })

                local barBg = Frame({
                    Size=UDim2.new(1,-24,0,5), Position=UDim2.new(0,12,0,33),
                    BgColor=C.base4, BgAlpha=0, Radius=UDim.new(1,0), ZIndex=4, Parent=f,
                })
                local fill = Frame({
                    Size=UDim2.new(0,0,1,0), BgColor=C.acc1, BgAlpha=0,
                    Radius=UDim.new(1,0), ZIndex=5, Parent=barBg,
                })
                -- Gradient fill
                local fg = Instance.new("UIGradient"); fg.Color=ACCENT_SEQ; fg.Parent=fill

                local SV = {CurrentValue=sCfg.CurrentValue, Type="Slider", Settings=sCfg}
                local mn, mx, inc = sCfg.Range[1], sCfg.Range[2], sCfg.Increment

                local function setVal(v)
                    v = math.clamp(v, mn, mx)
                    v = math.floor(v/inc+0.5)*inc
                    v = tonumber(string.format("%.10g",v))
                    SV.CurrentValue = v
                    valL.Text = tostring(v)..sCfg.Suffix
                    tw(fill,{Size=UDim2.new((v-mn)/(mx-mn),0,1,0)},TI_FAST)
                end
                setVal(sCfg.CurrentValue)

                local drag2=false
                local barClick = ClickBtn(barBg, 6)
                local function fromInput(inp)
                    local rel = math.clamp((inp.Position.X-barBg.AbsolutePosition.X)/barBg.AbsoluteSize.X,0,1)
                    setVal(mn+(mx-mn)*rel); Safe(sCfg.Callback, SV.CurrentValue)
                end
                barClick.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        drag2=true; fromInput(i)
                    end
                end)
                barClick.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag2=false end
                end)
                track(UserInputService.InputChanged:Connect(function(i)
                    if drag2 and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromInput(i) end
                end))

                HoverStroke(f)
                function SV:Set(v) setVal(v); Safe(sCfg.Callback,SV.CurrentValue) end
                function SV:Destroy() f:Destroy() end
                if sCfg.Flag then Sentence.Flags[sCfg.Flag]=SV; Sentence.Options[sCfg.Flag]=SV end
                return SV
            end

            -- ── DROPDOWN ──────────────────────────────────────────────────────
            function Sec:CreateDropdown(dCfg)
                dCfg = defaults({Name="Dropdown",Description=nil,Options={},CurrentOption=nil,MultipleOptions=false,SpecialType=nil,Flag=nil,Callback=function()end}, dCfg or {})
                if dCfg.SpecialType=="Player" then
                    dCfg.Options={}; for _,p in ipairs(Players:GetPlayers()) do table.insert(dCfg.Options,p.Name) end
                end
                if type(dCfg.CurrentOption)=="string" then dCfg.CurrentOption={dCfg.CurrentOption} end
                dCfg.CurrentOption = dCfg.CurrentOption or {dCfg.Options[1] or ""}

                local closedH = dCfg.Description and 50 or 34
                local f = ElemBase(closedH)
                f.ClipsDescendants = true

                Lbl({Text=dCfg.Name, Size=UDim2.new(1,-70,0,16),
                    Position=UDim2.new(0,12,0,dCfg.Description and 7 or 9),
                    Font=Enum.Font.GothamSemibold, TextSize=13, Color=C.txtHi, ZIndex=4, Parent=f,
                })
                if dCfg.Description then
                    Lbl({Text=dCfg.Description, Size=UDim2.new(1,-70,0,13),
                        Position=UDim2.new(0,12,0,26), Font=Enum.Font.Gotham, TextSize=11,
                        Color=C.txtLow, ZIndex=4, Parent=f,
                    })
                end

                local selL = Lbl({Text=table.concat(dCfg.CurrentOption,", "),
                    Size=UDim2.new(0,110,0,14), Position=UDim2.new(1,-48,0,dCfg.Description and 10 or 10),
                    AnchorPoint=Vector2.new(1,0), Font=Enum.Font.Gotham, TextSize=11,
                    Color=C.txtLow, AlignX=Enum.TextXAlignment.Right, ZIndex=4, Parent=f,
                })
                local arrow = Img({Icon="chev_d", Size=UDim2.new(0,16,0,16),
                    Position=UDim2.new(1,-26,0,dCfg.Description and 10 or 9),
                    Color=C.txtLow, ZIndex=4, Parent=f,
                })

                local optList = Instance.new("Frame")
                optList.Size=UDim2.new(1,-14,0,0); optList.Position=UDim2.new(0,7,0,closedH+4)
                optList.BackgroundTransparency=1; optList.AutomaticSize=Enum.AutomaticSize.Y
                optList.ZIndex=4; optList.Parent=f
                ListLayout(optList, 2)

                local opened=false
                local sel={}; for _,o in ipairs(dCfg.CurrentOption) do sel[o]=true end

                local DV = {CurrentOption=dCfg.CurrentOption, Type="Dropdown", Settings=dCfg}

                local function refreshOpts()
                    for _,c in ipairs(optList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                    for _, o in ipairs(dCfg.Options) do
                        local isS = sel[o]
                        local of = Frame({
                            Size=UDim2.new(1,0,0,26), BgColor=isS and C.base4 or C.base3,
                            BgAlpha=isS and 0.2 or 0.6, Stroke=true, StrokeColor=C.bdr, StrokeAlpha=0.7,
                            Radius=UDim.new(0,6), ZIndex=5, Parent=optList,
                        })
                        if isS then
                            Img({Icon="check", Size=UDim2.new(0,12,0,12),
                                Position=UDim2.new(1,-18,0.5,0), AnchorPoint=Vector2.new(0,0.5),
                                Color=C.acc1, ZIndex=6, Parent=of,
                            })
                        end
                        Lbl({Text=o, Size=UDim2.new(1,-28,1,0), Position=UDim2.new(0,8,0,0),
                            Font=Enum.Font.Gotham, TextSize=12,
                            Color=isS and C.txtHi or C.txtMid, ZIndex=6, Parent=of,
                        })
                        ClickBtn(of,7).MouseButton1Click:Connect(function()
                            if dCfg.MultipleOptions then
                                sel[o]=not sel[o]
                            else
                                sel={}; sel[o]=true
                                opened=false
                                tw(arrow,{Rotation=0})
                                tw(f,{Size=UDim2.new(1,0,0,closedH)},TI_MED)
                            end
                            local s={}; for _,op in ipairs(dCfg.Options) do if sel[op] then table.insert(s,op) end end
                            dCfg.CurrentOption=s; DV.CurrentOption=s
                            selL.Text = #s>0 and table.concat(s,", ") or "None"
                            refreshOpts(); Safe(dCfg.Callback, dCfg.MultipleOptions and s or (s[1] or ""))
                        end)
                    end
                end
                refreshOpts()

                local hClick = Instance.new("TextButton")
                hClick.Size=UDim2.new(1,0,0,closedH); hClick.BackgroundTransparency=1
                hClick.Text=""; hClick.ZIndex=8; hClick.Parent=f
                hClick.MouseButton1Click:Connect(function()
                    opened=not opened
                    if opened then
                        tw(arrow,{Rotation=180})
                        tw(f,{Size=UDim2.new(1,0,0,math.min(closedH+6+#dCfg.Options*28, closedH+160))},TI_MED)
                    else
                        tw(arrow,{Rotation=0})
                        tw(f,{Size=UDim2.new(1,0,0,closedH)},TI_MED)
                    end
                end)

                HoverStroke(f)
                function DV:Set(o) if type(o)=="table" then dCfg.CurrentOption=o else dCfg.CurrentOption={o} end; sel={}; for _,v in ipairs(dCfg.CurrentOption) do sel[v]=true end; selL.Text=table.concat(dCfg.CurrentOption,", "); refreshOpts() end
                function DV:Refresh(o) dCfg.Options=o; refreshOpts() end
                function DV:Destroy() f:Destroy() end
                if dCfg.Flag then Sentence.Flags[dCfg.Flag]=DV; Sentence.Options[dCfg.Flag]=DV end
                return DV
            end

            -- ── INPUT ─────────────────────────────────────────────────────────
            function Sec:CreateInput(iCfg)
                iCfg = defaults({Name="Input",Description=nil,PlaceholderText="Type...",CurrentValue="",RemoveTextAfterFocusLost=false,Numeric=false,MaxCharacters=nil,Enter=false,Flag=nil,Callback=function()end}, iCfg or {})
                local h = iCfg.Description and 50 or 34
                local f = ElemBase(h)
                Lbl({Text=iCfg.Name, Size=UDim2.new(1,-160,0,16),
                    Position=UDim2.new(0,12,0,iCfg.Description and 7 or 9),
                    Font=Enum.Font.GothamSemibold, TextSize=13, Color=C.txtHi, ZIndex=4, Parent=f,
                })
                if iCfg.Description then
                    Lbl({Text=iCfg.Description, Size=UDim2.new(1,-160,0,13),
                        Position=UDim2.new(0,12,0,26), Font=Enum.Font.Gotham, TextSize=11,
                        Color=C.txtLow, ZIndex=4, Parent=f,
                    })
                end

                local ib = Instance.new("TextBox")
                ib.Size=UDim2.new(0,120,0,22); ib.Position=UDim2.new(1,-12,0.5,0)
                ib.AnchorPoint=Vector2.new(1,0.5); ib.BackgroundColor3=C.base4
                ib.BackgroundTransparency=0.3; ib.BorderSizePixel=0
                ib.Font=Enum.Font.Gotham; ib.TextSize=12; ib.TextColor3=C.txtHi
                ib.PlaceholderText=iCfg.PlaceholderText; ib.PlaceholderColor3=C.txtLow
                ib.Text=iCfg.CurrentValue; ib.ClearTextOnFocus=false; ib.ZIndex=5; ib.Parent=f
                Instance.new("UICorner",ib).CornerRadius=UDim.new(0,6)
                local ibS=Instance.new("UIStroke"); ibS.Color=C.bdr; ibS.Transparency=0.4; ibS.Parent=ib
                Padding(ib,0,0,7,7)

                ib.Focused:Connect(function() tw(ibS,{Color=C.acc1,Transparency=0.2},TI_FAST) end)
                ib.FocusLost:Connect(function() tw(ibS,{Color=C.bdr,Transparency=0.4},TI_FAST) end)

                local IV = {CurrentValue=iCfg.CurrentValue, Type="Input", Settings=iCfg}
                if iCfg.Numeric then
                    ib:GetPropertyChangedSignal("Text"):Connect(function()
                        if not tonumber(ib.Text) and ib.Text~="" and ib.Text~="." and ib.Text~="-" then ib.Text=ib.Text:match("[%-0-9.]*") or "" end
                    end)
                end
                if iCfg.MaxCharacters then
                    ib:GetPropertyChangedSignal("Text"):Connect(function() if #ib.Text>iCfg.MaxCharacters then ib.Text=ib.Text:sub(1,iCfg.MaxCharacters) end end)
                end
                ib.FocusLost:Connect(function(enter)
                    if iCfg.Enter and not enter then return end
                    IV.CurrentValue=ib.Text; Safe(iCfg.Callback,ib.Text)
                    if iCfg.RemoveTextAfterFocusLost then ib.Text="" end
                end)
                if not iCfg.Enter then
                    ib:GetPropertyChangedSignal("Text"):Connect(function() IV.CurrentValue=ib.Text; Safe(iCfg.Callback,ib.Text) end)
                end

                HoverStroke(f)
                function IV:Set(v) ib.Text=tostring(v); IV.CurrentValue=tostring(v) end
                function IV:Destroy() f:Destroy() end
                if iCfg.Flag then Sentence.Flags[iCfg.Flag]=IV; Sentence.Options[iCfg.Flag]=IV end
                return IV
            end

            -- ── KEYBIND ───────────────────────────────────────────────────────
            function Sec:CreateBind(bCfg)
                bCfg = defaults({Name="Keybind",Description=nil,CurrentBind="E",HoldToInteract=false,Flag=nil,Callback=function()end,OnChangedCallback=function()end}, bCfg or {})
                local h = bCfg.Description and 50 or 34
                local f = ElemBase(h)
                Lbl({Text=bCfg.Name, Size=UDim2.new(1,-100,0,16),
                    Position=UDim2.new(0,12,0,bCfg.Description and 7 or 9),
                    Font=Enum.Font.GothamSemibold, TextSize=13, Color=C.txtHi, ZIndex=4, Parent=f,
                })
                if bCfg.Description then
                    Lbl({Text=bCfg.Description, Size=UDim2.new(1,-100,0,13),
                        Position=UDim2.new(0,12,0,26), Font=Enum.Font.Gotham, TextSize=11,
                        Color=C.txtLow, ZIndex=4, Parent=f,
                    })
                end

                local bb = Instance.new("TextBox")
                bb.Size=UDim2.new(0,58,0,22); bb.Position=UDim2.new(1,-12,0.5,0)
                bb.AnchorPoint=Vector2.new(1,0.5); bb.BackgroundColor3=C.base4
                bb.BackgroundTransparency=0.3; bb.BorderSizePixel=0
                bb.Font=Enum.Font.GothamBold; bb.TextSize=12; bb.TextColor3=C.acc1
                bb.Text=bCfg.CurrentBind; bb.ClearTextOnFocus=true; bb.ZIndex=5; bb.Parent=f
                Instance.new("UICorner",bb).CornerRadius=UDim.new(0,6)
                local bbS=Instance.new("UIStroke"); bbS.Color=C.bdr; bbS.Transparency=0.4; bbS.Parent=bb

                local BV={CurrentBind=bCfg.CurrentBind,Active=false,Type="Keybind",Settings=bCfg}
                local checking=false
                bb.Focused:Connect(function() checking=true; bb.Text="..."; tw(bbS,{Color=C.acc1,Transparency=0.2},TI_FAST) end)
                bb.FocusLost:Connect(function() checking=false; tw(bbS,{Color=C.bdr,Transparency=0.4},TI_FAST); if bb.Text=="..." or bb.Text=="" then bb.Text=BV.CurrentBind end end)

                track(UserInputService.InputBegan:Connect(function(inp, proc)
                    if checking then
                        if inp.KeyCode~=Enum.KeyCode.Unknown then
                            local kn=inp.KeyCode.Name; BV.CurrentBind=kn; bCfg.CurrentBind=kn
                            bb.Text=kn; bb:ReleaseFocus(); Safe(bCfg.OnChangedCallback,kn)
                        end
                    elseif BV.CurrentBind and not proc then
                        local ok,ke=pcall(function() return Enum.KeyCode[BV.CurrentBind] end)
                        if ok and inp.KeyCode==ke then
                            if not bCfg.HoldToInteract then
                                BV.Active=not BV.Active; Safe(bCfg.Callback,BV.Active)
                            else
                                Safe(bCfg.Callback,true)
                                local conn; conn=inp.Changed:Connect(function(p)
                                    if p=="UserInputState" then conn:Disconnect(); Safe(bCfg.Callback,false) end
                                end)
                            end
                        end
                    end
                end))

                HoverStroke(f)
                function BV:Set(v) BV.CurrentBind=v; bCfg.CurrentBind=v; bb.Text=v end
                function BV:Destroy() f:Destroy() end
                Sec.CreateKeybind = Sec.CreateBind
                if bCfg.Flag then Sentence.Flags[bCfg.Flag]=BV; Sentence.Options[bCfg.Flag]=BV end
                return BV
            end
            Sec.CreateKeybind = Sec.CreateBind

            -- ── COLOR PICKER ──────────────────────────────────────────────────
            function Sec:CreateColorPicker(cpCfg)
                cpCfg = defaults({Name="Color",Color=Color3.fromRGB(140,90,255),Flag=nil,Callback=function()end}, cpCfg or {})
                local closedH=34
                local f = ElemBase(closedH)
                f.ClipsDescendants=true
                Lbl({Text=cpCfg.Name, Size=UDim2.new(1,-70,0,16),
                    Position=UDim2.new(0,12,0,9), Font=Enum.Font.GothamSemibold, TextSize=13,
                    Color=C.txtHi, ZIndex=4, Parent=f,
                })
                local prev=Instance.new("Frame"); prev.Size=UDim2.new(0,22,0,22)
                prev.Position=UDim2.new(1,-34,0,6); prev.BackgroundColor3=cpCfg.Color
                prev.BorderSizePixel=0; prev.ZIndex=5; prev.Parent=f
                Instance.new("UICorner",prev).CornerRadius=UDim.new(0,6)
                Instance.new("UIStroke",prev).Color=C.bdr

                -- Picker area
                local pArea=Instance.new("Frame"); pArea.Size=UDim2.new(1,-16,0,130)
                pArea.Position=UDim2.new(0,8,0,40); pArea.BackgroundTransparency=1; pArea.ZIndex=4; pArea.Parent=f

                local svBox=Instance.new("Frame"); svBox.Size=UDim2.new(1,0,0,100)
                svBox.BackgroundColor3=Color3.fromHSV(0,1,1); svBox.BorderSizePixel=0; svBox.ZIndex=5; svBox.Parent=pArea
                Instance.new("UICorner",svBox).CornerRadius=UDim.new(0,6)
                local wGrad=Instance.new("UIGradient"); wGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}; wGrad.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}; wGrad.Parent=svBox
                local bOv=Instance.new("Frame"); bOv.Size=UDim2.new(1,0,1,0); bOv.BackgroundColor3=Color3.new(0,0,0); bOv.BorderSizePixel=0; bOv.ZIndex=6; bOv.Parent=svBox
                Instance.new("UICorner",bOv).CornerRadius=UDim.new(0,6)
                local bGrad=Instance.new("UIGradient"); bGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}; bGrad.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}; bGrad.Rotation=90; bGrad.Parent=bOv

                local hBar=Instance.new("Frame"); hBar.Size=UDim2.new(1,0,0,14); hBar.Position=UDim2.new(0,0,0,106); hBar.BackgroundColor3=Color3.new(1,1,1); hBar.BorderSizePixel=0; hBar.ZIndex=5; hBar.Parent=pArea
                Instance.new("UICorner",hBar).CornerRadius=UDim.new(0,4)
                local hGrad=Instance.new("UIGradient"); hGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))}; hGrad.Parent=hBar

                local opened=false
                local h2,s2,v2=Color3.toHSV(cpCfg.Color)
                local CPV={Color=cpCfg.Color,Type="ColorPicker",Settings=cpCfg}

                local function updateColor()
                    CPV.Color=Color3.fromHSV(h2,s2,v2)
                    prev.BackgroundColor3=CPV.Color; svBox.BackgroundColor3=Color3.fromHSV(h2,1,1)
                    Safe(cpCfg.Callback,CPV.Color)
                end

                local hBtn2=Instance.new("TextButton"); hBtn2.Size=UDim2.new(1,0,0,closedH); hBtn2.BackgroundTransparency=1; hBtn2.Text=""; hBtn2.ZIndex=8; hBtn2.Parent=f
                hBtn2.MouseButton1Click:Connect(function() opened=not opened; tw(f,{Size=UDim2.new(1,0,0,opened and 180 or closedH)},TI_MED) end)

                local svDrag=false; local svI=ClickBtn(bOv,9)
                local function updSV(inp) s2=math.clamp((inp.Position.X-svBox.AbsolutePosition.X)/svBox.AbsoluteSize.X,0,1); v2=1-math.clamp((inp.Position.Y-svBox.AbsolutePosition.Y)/svBox.AbsoluteSize.Y,0,1); updateColor() end
                svI.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true; updSV(i) end end)
                svI.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end end)

                local hDrag=false; local hI=ClickBtn(hBar,9)
                local function updH(inp) h2=math.clamp((inp.Position.X-hBar.AbsolutePosition.X)/hBar.AbsoluteSize.X,0,1); updateColor() end
                hI.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hDrag=true; updH(i) end end)
                hI.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hDrag=false end end)

                track(UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseMovement then
                        if svDrag then updSV(i) end
                        if hDrag then updH(i) end
                    end
                end))

                HoverStroke(f)
                function CPV:Set(s) if s.Color then h2,s2,v2=Color3.toHSV(s.Color); updateColor() end end
                function CPV:Destroy() f:Destroy() end
                if cpCfg.Flag then Sentence.Flags[cpCfg.Flag]=CPV; Sentence.Options[cpCfg.Flag]=CPV end
                return CPV
            end

            function Sec:Set(n) local lbl=secHeader:FindFirstChildOfClass("TextLabel"); if lbl then lbl.Text=n:upper() end end
            function Sec:Destroy() secHeader:Destroy(); secContainer:Destroy() end
            return Sec
        end

        -- Shortcut methods directly on Tab
        local _defSec
        local function getDS() if not _defSec then _defSec=Tab:CreateSection("") end return _defSec end
        for _, m in ipairs({"CreateButton","CreateLabel","CreateParagraph","CreateToggle","CreateSlider","CreateDivider","CreateDropdown","CreateInput","CreateBind","CreateKeybind","CreateColorPicker"}) do
            Tab[m]=function(self,...) return getDS()[m](getDS(),...) end
        end

        return Tab
    end

    -- ── Config save / load ────────────────────────────────────────────────────
    function W:SaveConfiguration()
        if not cfg.ConfigurationSaving or not cfg.ConfigurationSaving.Enabled then return end
        local data={}
        for k,flag in pairs(Sentence.Flags) do
            if flag.Type=="ColorPicker" then data[k]={R=flag.Color.R*255,G=flag.Color.G*255,B=flag.Color.B*255}
            elseif flag.Type=="Toggle" then data[k]=flag.CurrentValue
            elseif flag.Type=="Slider" then data[k]=flag.CurrentValue
            elseif flag.Type=="Dropdown" then data[k]=flag.CurrentOption
            elseif flag.Type=="Input" then data[k]=flag.CurrentValue
            elseif flag.Type=="Keybind" then data[k]=flag.CurrentBind end
        end
        pcall(function()
            local folder=cfg.ConfigurationSaving.FolderName or "SENTENCE"
            local file=cfg.ConfigurationSaving.FileName or "config"
            if isfolder and not isfolder(folder) then makefolder(folder) end
            writefile(folder.."/"..file..".json", HttpService:JSONEncode(data))
        end)
    end

    function W:LoadConfiguration()
        if not cfg.ConfigurationSaving or not cfg.ConfigurationSaving.Enabled then return end
        pcall(function()
            local folder=cfg.ConfigurationSaving.FolderName or "SENTENCE"
            local file=cfg.ConfigurationSaving.FileName or "config"
            local path=folder.."/"..file..".json"
            if isfile and isfile(path) then
                local data=HttpService:JSONDecode(readfile(path))
                for k,v in pairs(data) do
                    local flag=Sentence.Flags[k]
                    if flag then
                        if flag.Type=="ColorPicker" then flag:Set({Color=Color3.fromRGB(v.R,v.G,v.B)})
                        else flag:Set(v) end
                    end
                end
                Sentence:Notify({Title="Loaded",Content="Configuration restored.",Icon="save",Type="Success"})
            end
        end)
    end

    return W
end

-- ── Destroy ───────────────────────────────────────────────────────────────────
function Sentence:Destroy()
    for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    self._conns = {}
    if self._notifHolder and self._notifHolder.Parent then
        self._notifHolder.Parent:Destroy()
    end
    self.Flags = {}; self.Options = {}
end

return Sentence
