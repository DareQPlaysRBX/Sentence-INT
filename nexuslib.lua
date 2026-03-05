--[[
╔═══════════════════════════════════════════════════════════╗
║  NEXUS  UI  ·  v1.0                                       ║
║  Aesthetic : Dark Precision                               ║
║  Accent    : #00CFEE cyan on #080909 carbon               ║
║  Layout    : narrow icon-only sidebar  (48 px)            ║
║  Corners   : near-sharp  (4 px)                           ║
║  Loading   : progress bar + mono % counter                ║
║  Notif     : bottom-left  ↑  stack                        ║
╚═══════════════════════════════════════════════════════════╝
--]]

local Nexus = {
    Version = "1.0",
    Flags   = {},
    Options = {},
    _conns  = {},
}

-- ── Services ──────────────────────────────────────────────────────────────────
local TS    = game:GetService("TweenService")
local UIS   = game:GetService("UserInputService")
local RS    = game:GetService("RunService")
local HS    = game:GetService("HttpService")
local Plrs  = game:GetService("Players")
local CG    = game:GetService("CoreGui")
local LP    = Plrs.LocalPlayer
local Cam   = workspace.CurrentCamera
local IsStudio = RS:IsStudio()

-- ── Colour Palette ────────────────────────────────────────────────────────────
local C = {
    -- Backgrounds
    base0  = Color3.fromRGB(  8,  9,  9),  -- window bg
    base1  = Color3.fromRGB( 13, 15, 16),  -- sidebar / panel
    base2  = Color3.fromRGB( 18, 21, 23),  -- element bg
    base3  = Color3.fromRGB( 24, 28, 30),  -- element hover
    base4  = Color3.fromRGB( 32, 37, 40),  -- pressed / active
    -- Borders
    line   = Color3.fromRGB( 38, 44, 48),  -- hairline
    lineH  = Color3.fromRGB( 58, 68, 74),  -- border hover
    lineA  = Color3.fromRGB( 88,102,110),  -- border active
    -- Text
    t0     = Color3.fromRGB(226, 234, 238), -- primary
    t1     = Color3.fromRGB(130, 146, 156), -- secondary
    t2     = Color3.fromRGB( 64,  76,  84), -- muted
    -- Accent
    cyan   = Color3.fromRGB(  0, 207, 238), -- THE accent
    cyanD  = Color3.fromRGB(  0, 140, 162), -- accent dark
    cyanDD = Color3.fromRGB(  0,  48,  58), -- accent tint bg
    -- Semantic
    ok     = Color3.fromRGB(  0, 214, 143),
    warn   = Color3.fromRGB(255, 184,   0),
    err    = Color3.fromRGB(255,  60,  60),
    info   = Color3.fromRGB( 77, 159, 255),
}

-- ── Tween presets ─────────────────────────────────────────────────────────────
local function TI(t,s,d)
    return TweenInfo.new(t or .2, s or Enum.EasingStyle.Exponential, d or Enum.EasingDirection.Out)
end
local TI_SNAP   = TI(.09)
local TI_FAST   = TI(.16)
local TI_MED    = TI(.26)
local TI_SLOW   = TI(.52)
local TI_SPRING = TweenInfo.new(.38, Enum.EasingStyle.Back,        Enum.EasingDirection.Out)
local TI_SINE   = TweenInfo.new(.4,  Enum.EasingStyle.Sine,        Enum.EasingDirection.InOut)

local function tw(o, p, info, cb)
    local t = TS:Create(o, info or TI_MED, p)
    if cb then t.Completed:Once(cb) end
    t:Play(); return t
end

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function merge(d, t)
    t = t or {}
    for k,v in pairs(d) do if t[k]==nil then t[k]=v end end
    return t
end
local function track(c) table.insert(Nexus._conns,c); return c end
local function safe(cb,...) local ok,e=pcall(cb,...); if not ok then warn("NEXUS: "..tostring(e)) end end

-- Icon asset map
local ICONS = {
    close  = "rbxassetid://6031094678",
    min    = "rbxassetid://6031094687",
    hide   = "rbxassetid://6031075929",
    home   = "rbxassetid://6026568195",
    set    = "rbxassetid://6031280882",
    star   = "rbxassetid://6031068423",
    flash  = "rbxassetid://6034333271",
    shield = "rbxassetid://6035078889",
    art    = "rbxassetid://6034316009",
    code   = "rbxassetid://6022668955",
    person = "rbxassetid://6034287594",
    save   = "rbxassetid://6035067857",
    info   = "rbxassetid://6026568227",
    warn   = "rbxassetid://6031071053",
    ok     = "rbxassetid://6031094667",
    chev_d = "rbxassetid://6031094687",
    chev_u = "rbxassetid://6031094679",
    arr    = "rbxassetid://6031090995",
    games  = "rbxassetid://6026660074",
    edit   = "rbxassetid://6034328955",
    delete = "rbxassetid://6022668885",
    search = "rbxassetid://6031154871",
    notif  = "rbxassetid://6034308946",
    unk    = "rbxassetid://6031079152",
}
local function ico(n)
    if not n or n=="" then return "" end
    if n:find("rbxassetid") then return n end
    if tonumber(n) then return "rbxassetid://"..n end
    return ICONS[n] or ICONS.unk
end

-- ── UI Primitives ─────────────────────────────────────────────────────────────
local function Box(p)
    p = p or {}
    local f = Instance.new("Frame")
    f.Name               = p.Name or "Box"
    f.Size               = p.Sz   or UDim2.new(1,0,0,36)
    f.Position           = p.Pos  or UDim2.new()
    f.AnchorPoint        = p.AP   or Vector2.zero
    f.BackgroundColor3   = p.Bg   or C.base2
    f.BackgroundTransparency = p.BgA or 0
    f.BorderSizePixel    = 0
    f.ZIndex             = p.Z    or 1
    f.LayoutOrder        = p.Ord  or 0
    f.Visible            = p.Vis  ~= false
    if p.Clip then f.ClipsDescendants = true end
    if p.AutoY then f.AutomaticSize = Enum.AutomaticSize.Y end
    if p.R ~= nil then
        local uc = Instance.new("UICorner")
        uc.CornerRadius = type(p.R)=="number" and UDim.new(0,p.R) or (p.R or UDim.new(0,4))
        uc.Parent = f
    end
    if p.Border then
        local s = Instance.new("UIStroke")
        s.Color           = p.BorderCol or C.line
        s.Transparency    = p.BorderA   or 0.35
        s.Thickness       = 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = f
    end
    if p.Par then f.Parent = p.Par end
    return f
end

local function Txt(p)
    p = p or {}
    local l = Instance.new("TextLabel")
    l.Name             = p.Name or "Txt"
    l.Text             = p.T    or ""
    l.Size             = p.Sz   or UDim2.new(1,0,0,14)
    l.Position         = p.Pos  or UDim2.new()
    l.AnchorPoint      = p.AP   or Vector2.zero
    l.Font             = p.Font or Enum.Font.GothamSemibold
    l.TextSize         = p.TS   or 13
    l.TextColor3       = p.Col  or C.t0
    l.TextTransparency = p.Alpha or 0
    l.TextXAlignment   = p.AX   or Enum.TextXAlignment.Left
    l.TextYAlignment   = p.AY   or Enum.TextYAlignment.Center
    l.TextWrapped      = p.Wrap or false
    l.RichText         = true
    l.BackgroundTransparency = 1
    l.BorderSizePixel  = 0
    l.ZIndex           = p.Z    or 2
    l.LayoutOrder      = p.Ord  or 0
    if p.AutoY then l.AutomaticSize = Enum.AutomaticSize.Y end
    if p.Par then l.Parent = p.Par end
    return l
end

local function Img(p)
    p = p or {}
    local i = Instance.new("ImageLabel")
    i.Name             = p.Name or "Img"
    i.Image            = ico(p.Ico or "")
    i.Size             = p.Sz   or UDim2.new(0,18,0,18)
    i.Position         = p.Pos  or UDim2.new(0.5,0,0.5,0)
    i.AnchorPoint      = p.AP   or Vector2.new(0.5,0.5)
    i.ImageColor3      = p.Col  or C.t0
    i.ImageTransparency = p.IA  or 0
    i.BackgroundTransparency = 1
    i.BorderSizePixel  = 0
    i.ZIndex           = p.Z    or 3
    i.ScaleType        = Enum.ScaleType.Fit
    if p.Par then i.Parent = p.Par end
    return i
end

local function Btn(par, z)
    local b = Instance.new("TextButton")
    b.Name="Btn"; b.Size=UDim2.new(1,0,1,0)
    b.BackgroundTransparency=1; b.Text=""; b.ZIndex=z or 8
    b.Parent=par; return b
end

local function List(par, gap, dir, ha, va)
    local l = Instance.new("UIListLayout")
    l.SortOrder       = Enum.SortOrder.LayoutOrder
    l.Padding         = UDim.new(0, gap or 4)
    l.FillDirection   = dir or Enum.FillDirection.Vertical
    if ha then l.HorizontalAlignment=ha end
    if va then l.VerticalAlignment=va end
    l.Parent = par; return l
end

local function Pad(par, top, bot, lft, rgt)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0,top or 0)
    p.PaddingBottom = UDim.new(0,bot or 0)
    p.PaddingLeft   = UDim.new(0,lft or 0)
    p.PaddingRight  = UDim.new(0,rgt or 0)
    p.Parent=par; return p
end

-- Hairline separator
local function Wire(par, vertical)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = C.line
    f.BackgroundTransparency = 0.4
    f.BorderSizePixel = 0; f.ZIndex = 2
    f.Size = vertical and UDim2.new(0,1,1,0) or UDim2.new(1,0,0,1)
    f.Parent = par; return f
end

-- ── Dragging ──────────────────────────────────────────────────────────────────
local function Draggable(handle, win)
    local dragging, dragStart, winStart = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=i.Position; winStart=win.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            tw(win,{Position=UDim2.new(winStart.X.Scale,winStart.X.Offset+d.X,winStart.Y.Scale,winStart.Y.Offset+d.Y)},TI(.15))
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION  (bottom-left, slides up)
-- ══════════════════════════════════════════════════════════════════════════════
function Nexus:Notify(data)
    task.spawn(function()
        data = merge({Title="Notice",Content="",Icon="info",Type="Info",Duration=nil}, data)
        local aMap = {Info=C.info, Success=C.ok, Warning=C.warn, Error=C.err}
        local ac = aMap[data.Type] or C.info

        local card = Box({Name="NCard",
            Sz=UDim2.new(0,290,0,0),
            Pos=UDim2.new(0,0,1,0), AP=Vector2.new(0,1),
            Bg=C.base1, BgA=0,
            Clip=true, R=4, Border=true, BorderCol=C.line, BorderA=0.3,
            Par=self._notifHolder})

        -- Left accent strip
        Box({Sz=UDim2.new(0,3,1,-8),Pos=UDim2.new(0,0,0,4),
            Bg=ac, BgA=0, R=0, Z=4, Par=card})

        Img({Ico=data.Icon, Sz=UDim2.new(0,14,0,14),
            Pos=UDim2.new(0,12,0,14), AP=Vector2.zero,
            Col=ac, IA=1, Z=4, Par=card})

        local ttl = Txt({T=data.Title, Sz=UDim2.new(1,-40,0,14),
            Pos=UDim2.new(0,34,0,8),
            Font=Enum.Font.GothamBold, TS=12, Col=C.t0, Alpha=1, Z=4, Par=card})

        local msg = Txt({T=data.Content, Sz=UDim2.new(1,-40,0,900),
            Pos=UDim2.new(0,34,0,24),
            Font=Enum.Font.Gotham, TS=11, Col=C.t1, Alpha=1, Wrap=true, Z=4, Par=card})

        task.wait()
        local th = msg.TextBounds.Y
        msg.Size = UDim2.new(1,-40,0,th)
        local H = 34 + th

        -- Animate in: expand height + slide up
        tw(card, {Size=UDim2.new(0,290,0,H), BackgroundTransparency=0}, TI_SLOW)
        task.wait(0.1)
        local strip = card:GetChildren()[2]  -- accent strip
        if strip then tw(strip,{BackgroundTransparency=0},TI_MED) end
        local imgL = card:FindFirstChildOfClass("ImageLabel")
        if imgL then tw(imgL,{ImageTransparency=0},TI_MED) end
        tw(ttl,{TextTransparency=0},TI_MED)
        task.wait(0.05)
        tw(msg,{TextTransparency=0.15},TI_MED)

        local dur = data.Duration or math.clamp(#data.Content*0.065+2.5, 2.5, 8)
        task.wait(dur)

        tw(card,{BackgroundTransparency=1},TI_FAST)
        if strip then tw(strip,{BackgroundTransparency=1},TI_FAST) end
        if imgL then tw(imgL,{ImageTransparency=1},TI_FAST) end
        tw(ttl,{TextTransparency=1},TI_FAST)
        tw(msg,{TextTransparency=1},TI_FAST)
        if card:FindFirstChildOfClass("UIStroke") then tw(card.UIStroke,{Transparency=1},TI_FAST) end
        task.wait(0.2)
        tw(card,{Size=UDim2.new(0,290,0,0)},TI_SLOW,function() card:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════════════════════════════════════════
function Nexus:CreateWindow(cfg)
    cfg = merge({
        Name            = "NEXUS",
        Subtitle        = "",
        Icon            = "",
        ToggleBind      = Enum.KeyCode.RightControl,
        LoadingEnabled  = true,
        LoadingTitle    = "NEXUS",
        LoadingSubtitle = "INITIALISING",
        ConfigurationSaving = {Enabled=false, FolderName="Nexus", FileName="config"},
    }, cfg)

    -- Sizing
    local vp   = Cam.ViewportSize
    local WW   = math.clamp(vp.X - 100, 560, 750)
    local WH   = math.clamp(vp.Y - 80,  400, 500)
    local FULL = UDim2.fromOffset(WW, WH)
    local MINI = UDim2.fromOffset(WW, 40)

    -- ── ScreenGui ─────────────────────────────────────────────────────────────
    local gui = Instance.new("ScreenGui")
    gui.Name = "NexusUI"; gui.DisplayOrder = 999999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true

    if gethui then gui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = CG
    elseif not IsStudio then gui.Parent = CG
    else gui.Parent = LP:WaitForChild("PlayerGui") end

    -- ── Notification holder (bottom-left) ────────────────────────────────────
    local notifHolder = Instance.new("Frame")
    notifHolder.Name = "Notifs"; notifHolder.Size = UDim2.new(0,294,1,-16)
    notifHolder.Position = UDim2.new(0,8,0,8)
    notifHolder.BackgroundTransparency = 1; notifHolder.ZIndex = 200
    notifHolder.Parent = gui
    local nList = List(notifHolder, 5)
    nList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    self._notifHolder = notifHolder

    -- ══════════════════════════════════════════════════════════════════════════
    -- MAIN WINDOW
    -- ══════════════════════════════════════════════════════════════════════════
    local win = Box({Name="NexusWin",
        Sz=UDim2.fromOffset(0,0),
        Pos=UDim2.new(0.5,0,0.5,0), AP=Vector2.new(0.5,0.5),
        Bg=C.base0, BgA=0, Clip=true,
        R=4, Border=true, BorderCol=C.line, BorderA=0.15,
        Z=1, Par=gui})

    -- Cyan top accent line (2px)
    local topLine = Box({Name="TopLine",
        Sz=UDim2.new(1,0,0,2), Pos=UDim2.new(0,0,0,0),
        Bg=C.cyan, BgA=0, Z=6, Par=win})

    -- Subtle corner glow top-left
    local glowTL = Box({Name="Glow",
        Sz=UDim2.new(0,200,0,120),
        Pos=UDim2.new(0,0,0,0),
        Bg=C.cyanDD, BgA=0.3, R=0, Z=0, Par=win})
    local glowGrad = Instance.new("UIGradient")
    glowGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0,0.4),
        NumberSequenceKeypoint.new(1,1)
    }
    glowGrad.Rotation = 135; glowGrad.Parent = glowTL

    -- ── Title bar ─────────────────────────────────────────────────────────────
    local TB_H = 40
    local titleBar = Box({Name="TitleBar",
        Sz=UDim2.new(1,0,0,TB_H), Pos=UDim2.new(0,0,0,2),
        Bg=C.base0, BgA=1, Z=4, Par=win})
    Draggable(titleBar, win)

    -- Window control buttons (left trio)
    local CTRL_ICONS = {{"X","close",C.err},{"−","min",C.t2},{"·","hide",C.t2}}
    local ctrlBtns = {}
    for idx, cd in ipairs(CTRL_ICONS) do
        local xPos = 10 + (idx-1)*30
        local cb = Box({Name=cd[1], Sz=UDim2.new(0,22,0,22),
            Pos=UDim2.new(0,xPos,0.5,0), AP=Vector2.new(0,0.5),
            Bg=C.base3, BgA=0.6, R=4, Border=true, BorderCol=C.line, BorderA=0.5,
            Z=5, Par=titleBar})
        local cIco = Img({Ico=cd[2], Sz=UDim2.new(0,12,0,12),
            Pos=UDim2.new(0.5,0,0.5,0), AP=Vector2.new(0.5,0.5),
            Col=C.t1, Z=6, Par=cb})
        local cCL = Btn(cb, 7)
        cb.MouseEnter:Connect(function()
            tw(cb,{BackgroundColor3=cd[3],BackgroundTransparency=0},TI_FAST)
            tw(cIco,{ImageColor3=Color3.new(1,1,1)},TI_FAST)
        end)
        cb.MouseLeave:Connect(function()
            tw(cb,{BackgroundColor3=C.base3,BackgroundTransparency=0.6},TI_FAST)
            tw(cIco,{ImageColor3=C.t1},TI_FAST)
        end)
        ctrlBtns[cd[1]] = {frame=cb, click=cCL}
    end

    -- Logo / icon
    local logoImg = Img({Ico=cfg.Icon,
        Sz=UDim2.new(0,18,0,18),
        Pos=UDim2.new(0,108,0.5,0), AP=Vector2.new(0,0.5),
        Col=C.t0, Z=5, Par=titleBar})

    -- Window name
    local nameOffX = cfg.Icon~="" and 132 or 108
    local nameLabel = Txt({T=cfg.Name,
        Sz=UDim2.new(0,220,0,16), Pos=UDim2.new(0,nameOffX,0,7),
        Font=Enum.Font.GothamBold, TS=13, Col=C.t0, Alpha=1, Z=5, Par=titleBar})
    local subLabel = Txt({T=cfg.Subtitle~="" and ("/ "..cfg.Subtitle) or ("/ v"..Nexus.Version),
        Sz=UDim2.new(0,200,0,12), Pos=UDim2.new(0,nameOffX,0,24),
        Font=Enum.Font.Gotham, TS=10, Col=C.t2, Alpha=1, Z=5, Par=titleBar})

    -- Live stat strip (right side of title)
    local statBar = Box({Name="StatBar",
        Sz=UDim2.new(0,130,0,24),
        Pos=UDim2.new(1,-8,0.5,0), AP=Vector2.new(1,0.5),
        Bg=C.base2, BgA=0, R=4, Z=5, Par=titleBar})
    local pingL = Txt({T="— ms", Sz=UDim2.new(0,60,1,0), Pos=UDim2.new(0,0,0,0),
        Font=Enum.Font.Code, TS=10, Col=C.t2, AX=Enum.TextXAlignment.Right, Z=6, Par=statBar})
    local plrsL = Txt({T="—/—", Sz=UDim2.new(0,55,1,0), Pos=UDim2.new(0,66,0,0),
        Font=Enum.Font.Code, TS=10, Col=C.t2, Z=6, Par=statBar})
    task.spawn(function()
        while task.wait(1.5) do
            if not win or not win.Parent then break end
            pcall(function()
                pingL.Text = math.floor(LP:GetNetworkPing()*1000).."ms"
                plrsL.Text = #Plrs:GetPlayers().."/"..Plrs.MaxPlayers
            end)
        end
    end)

    -- Title separator
    Wire(titleBar, false).Position = UDim2.new(0,0,1,-1)

    -- ── Sidebar  (48px, icon-only tabs + avatar at bottom) ────────────────────
    local SIDE_W = 48
    local sidebar = Box({Name="Sidebar",
        Sz=UDim2.new(0,SIDE_W,1,-TB_H-2),
        Pos=UDim2.new(0,0,0,TB_H+2),
        Bg=C.base1, BgA=0, Z=3, Par=win})
    -- Sidebar right border
    Wire(sidebar, true).Position = UDim2.new(1,-1,0,0)

    -- Cyan dot at top of sidebar
    Box({Sz=UDim2.new(0,4,0,4),
        Pos=UDim2.new(0.5,0,0,10), AP=Vector2.new(0.5,0),
        Bg=C.cyan, R=2, Z=4, Par=sidebar})

    -- Tab icon container
    local tabIconsList = Instance.new("ScrollingFrame")
    tabIconsList.Name = "TabIcons"
    tabIconsList.Size = UDim2.new(1,0,1,-56)
    tabIconsList.Position = UDim2.new(0,0,0,22)
    tabIconsList.BackgroundTransparency = 1; tabIconsList.BorderSizePixel = 0
    tabIconsList.ScrollBarThickness = 0
    tabIconsList.CanvasSize = UDim2.new(0,0,0,0); tabIconsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabIconsList.ZIndex = 4; tabIconsList.Parent = sidebar
    List(tabIconsList, 2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center)
    Pad(tabIconsList, 4, 4, 0, 0)

    -- Avatar at bottom of sidebar
    local avBox = Box({Sz=UDim2.new(0,32,0,32),
        Pos=UDim2.new(0.5,0,1,-10), AP=Vector2.new(0.5,1),
        Bg=C.base2, R=4, Z=4, Par=sidebar})
    local avImg = Instance.new("ImageLabel")
    avImg.Size = UDim2.new(1,0,1,0); avImg.BackgroundTransparency=1
    avImg.ZIndex=5; avImg.Parent=avBox
    Instance.new("UICorner",avImg).CornerRadius = UDim.new(0,4)
    local avStroke = Instance.new("UIStroke"); avStroke.Color=C.cyan
    avStroke.Thickness=1.5; avStroke.Transparency=0.55; avStroke.Parent=avImg
    pcall(function()
        avImg.Image = Plrs:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)

    -- Tooltip frame (shows on tab hover)
    local tooltip = Box({Name="Tooltip",
        Sz=UDim2.new(0,0,0,24),
        Pos=UDim2.new(0,SIDE_W+4,0,0),
        Bg=C.base3, R=4, Border=true, BorderCol=C.lineH, BorderA=0.2,
        Z=20, Vis=false, Par=win})
    tooltip.AutomaticSize = Enum.AutomaticSize.X
    Pad(tooltip,0,0,8,8)
    local tooltipL = Txt({T="",Sz=UDim2.new(0,0,1,0),
        Font=Enum.Font.GothamSemibold, TS=11, Col=C.t0, Z=21, Par=tooltip})
    tooltipL.AutomaticSize = Enum.AutomaticSize.X

    -- ── Content area ──────────────────────────────────────────────────────────
    local contentArea = Box({Name="Content",
        Sz=UDim2.new(1,-SIDE_W-1,1,-TB_H-2),
        Pos=UDim2.new(0,SIDE_W+1,0,TB_H+2),
        Bg=C.base0, BgA=1, Clip=true, Z=2, Par=win})

    -- ══════════════════════════════════════════════════════════════════════════
    -- LOADING SCREEN  — horizontal progress bar + mono counter
    -- ══════════════════════════════════════════════════════════════════════════
    local function RunLoading()
        local lf = Box({Name="Loading",
            Sz=UDim2.new(1,0,1,0), Bg=C.base0, BgA=0,
            Z=50, Par=win})
        Instance.new("UICorner",lf).CornerRadius = UDim.new(0,4)

        -- Logo
        local lLogo = Img({Ico=cfg.Icon,
            Sz=UDim2.new(0,32,0,32),
            Pos=UDim2.new(0.5,0,0.5,-50), AP=Vector2.new(0.5,0.5),
            Col=C.t0, Z=51, Par=lf})

        -- Title
        local lTitle = Txt({T=cfg.LoadingTitle,
            Sz=UDim2.new(1,0,0,24),
            Pos=UDim2.new(0.5,0,0.5,-14), AP=Vector2.new(0.5,0.5),
            Font=Enum.Font.GothamBold, TS=20, Col=C.t0,
            AX=Enum.TextXAlignment.Center, Alpha=1, Z=51, Par=lf})

        -- Subtitle
        local lSub = Txt({T=cfg.LoadingSubtitle,
            Sz=UDim2.new(1,0,0,14),
            Pos=UDim2.new(0.5,0,0.5,14), AP=Vector2.new(0.5,0.5),
            Font=Enum.Font.Code, TS=11, Col=C.t2,
            AX=Enum.TextXAlignment.Center, Alpha=1, Z=51, Par=lf})

        -- Progress bar track
        local pTrack = Box({Sz=UDim2.new(0.45,0,0,3),
            Pos=UDim2.new(0.5,0,0.5,42), AP=Vector2.new(0.5,0.5),
            Bg=C.base3, R=2, Z=51, Par=lf})

        local pFill = Box({Sz=UDim2.new(0,0,1,0),
            Bg=C.cyan, R=2, Z=52, Par=pTrack})

        -- Percentage
        local pctL = Txt({T="0%",
            Sz=UDim2.new(1,0,0,14),
            Pos=UDim2.new(0.5,0,0.5,52), AP=Vector2.new(0.5,0.5),
            Font=Enum.Font.Code, TS=10, Col=C.cyanD,
            AX=Enum.TextXAlignment.Center, Z=51, Par=lf})

        tw(win,{Size=FULL},TI_SLOW)
        task.wait(0.3)
        tw(lTitle,{TextTransparency=0},TI_MED)
        task.wait(0.1)
        tw(lSub,{TextTransparency=0.3},TI_MED)
        if cfg.Icon~="" then tw(lLogo,{ImageTransparency=0},TI_MED) end

        -- Progress animation (fake load)
        local steps = {0.12, 0.08, 0.15, 0.1, 0.18, 0.12, 0.1, 0.15}
        local pct = 0
        for _, step in ipairs(steps) do
            pct = math.min(pct + step, 1)
            tw(pFill,{Size=UDim2.new(pct,0,1,0)},TI(.25,Enum.EasingStyle.Quad))
            pctL.Text = math.floor(pct*100).."%"
            task.wait(0.13 + math.random()*0.1)
        end
        pctL.Text = "100%"
        tw(pFill,{Size=UDim2.new(1,0,1,0)},TI_FAST)
        task.wait(0.3)

        -- Fade cyan fill to white briefly
        tw(pFill,{BackgroundColor3=Color3.new(1,1,1)},TI_SNAP)
        task.wait(0.08)

        -- Fade out everything
        tw(lTitle,{TextTransparency=1},TI_FAST)
        tw(lSub,{TextTransparency=1},TI_FAST)
        tw(pctL,{TextTransparency=1},TI_FAST)
        tw(pTrack,{BackgroundTransparency=1},TI_FAST)
        tw(pFill,{BackgroundTransparency=1},TI_FAST)
        if cfg.Icon~="" then tw(lLogo,{ImageTransparency=1},TI_FAST) end
        task.wait(0.2)
        tw(lf,{BackgroundTransparency=1},TI_MED,function() lf:Destroy() end)
        task.wait(0.3)
    end

    -- ── Window state ──────────────────────────────────────────────────────────
    local W = {
        _gui=gui, _win=win, _content=contentArea,
        _tabs={}, _activeTab=nil,
        _visible=true, _minimized=false,
        _cfg=cfg,
    }

    gui.Enabled = true
    if cfg.LoadingEnabled then
        RunLoading()
    else
        tw(win,{Size=FULL},TI_SLOW)
        task.wait(0.35)
    end

    -- Reveal title after loading
    tw(topLine,{BackgroundTransparency=0.35},TI_MED)
    tw(nameLabel,{TextTransparency=0},TI_MED)
    tw(subLabel,{TextTransparency=0},TI_MED)

    -- ── Window controls logic ─────────────────────────────────────────────────
    local function HideW()
        W._visible=false
        tw(win,{Size=UDim2.fromOffset(0,0)},TI_SLOW,function() win.Visible=false end)
    end
    local function ShowW()
        win.Visible=true; W._visible=true
        tw(win,{Size=W._minimized and MINI or FULL},TI_SLOW)
    end

    ctrlBtns["X"].click.MouseButton1Click:Connect(function() Nexus:Destroy() end)
    ctrlBtns["·"].click.MouseButton1Click:Connect(function()
        Nexus:Notify({Title="Hidden",Content="Press "..cfg.ToggleBind.Name.." to restore.",Type="Info"})
        HideW()
    end)
    ctrlBtns["−"].click.MouseButton1Click:Connect(function()
        W._minimized = not W._minimized
        if W._minimized then
            sidebar.Visible=false; contentArea.Visible=false
            tw(win,{Size=MINI},TI_MED)
        else
            tw(win,{Size=FULL},TI_MED,function()
                sidebar.Visible=true; contentArea.Visible=true
            end)
        end
    end)
    track(UIS.InputBegan:Connect(function(inp,proc)
        if proc then return end
        if inp.KeyCode==cfg.ToggleBind then
            if W._visible then HideW() else ShowW() end
        end
    end))

    -- ── Tab state helpers ─────────────────────────────────────────────────────
    local function DeactivateAll()
        for _, td in ipairs(W._tabs) do
            td.page.Visible = false
            if td.activeBar then tw(td.activeBar,{BackgroundTransparency=1},TI_FAST) end
            if td.iconImg   then tw(td.iconImg,{ImageColor3=C.t2,ImageTransparency=0},TI_FAST) end
            if td.bgBox     then tw(td.bgBox,{BackgroundTransparency=1},TI_FAST) end
        end
        local hp = contentArea:FindFirstChild("HomePage")
        if hp then hp.Visible=false end
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- HOME TAB
    -- ══════════════════════════════════════════════════════════════════════════
    function W:CreateHomeTab(hCfg)
        hCfg = merge({Icon="home"}, hCfg or {})

        -- Icon button in sidebar
        local hBox = Box({Name="HomeTabBtn", Sz=UDim2.new(0,40,0,40),
            Bg=C.cyan, BgA=0.1, R=4, Z=5, Par=tabIconsList})
        -- Active left bar
        local hBar = Box({Sz=UDim2.new(0,3,0.6,0), Pos=UDim2.new(0,0,0.2,0),
            Bg=C.cyan, R=0, Z=6, Par=hBox})
        local hIco = Img({Ico=hCfg.Icon, Sz=UDim2.new(0,18,0,18),
            Col=C.cyan, Z=6, Par=hBox})
        local hCL = Btn(hBox, 7)

        -- Home page
        local hPage = Instance.new("ScrollingFrame")
        hPage.Name="HomePage"; hPage.Size=UDim2.new(1,0,1,0)
        hPage.BackgroundTransparency=1; hPage.BorderSizePixel=0
        hPage.ScrollBarThickness=2; hPage.ScrollBarImageColor3=C.line
        hPage.CanvasSize=UDim2.new(0,0,0,0); hPage.AutomaticCanvasSize=Enum.AutomaticSize.Y
        hPage.ZIndex=3; hPage.Visible=true; hPage.Parent=contentArea
        List(hPage,10); Pad(hPage,16,16,18,18)

        -- ── Player card ───────────────────────────────────────────────────────
        local pCard = Box({Name="PCard", Sz=UDim2.new(1,0,0,76),
            Bg=C.base2, BgA=0, R=4, Border=true, BorderCol=C.line, BorderA=0.4,
            Z=3, Par=hPage})
        -- Cyan left accent
        Box({Sz=UDim2.new(0,3,1,0), Bg=C.cyan, R=0, Z=4, Par=pCard})
        local pAv = Instance.new("ImageLabel")
        pAv.Size=UDim2.new(0,48,0,48); pAv.Position=UDim2.new(0,16,0.5,0); pAv.AnchorPoint=Vector2.new(0,0.5)
        pAv.BackgroundTransparency=1; pAv.ZIndex=4; pAv.Parent=pCard
        Instance.new("UICorner",pAv).CornerRadius=UDim.new(0,4)
        pcall(function()
            pAv.Image = Plrs:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        local pAS=Instance.new("UIStroke"); pAS.Color=C.cyan; pAS.Thickness=1.5; pAS.Transparency=0.5; pAS.Parent=pAv

        Txt({T=LP.DisplayName, Sz=UDim2.new(1,-90,0,18),
            Pos=UDim2.new(0,76,0,16), Font=Enum.Font.GothamBold, TS=16, Col=C.t0, Z=4, Par=pCard})
        Txt({T="@"..LP.Name, Sz=UDim2.new(1,-90,0,13),
            Pos=UDim2.new(0,76,0,36), Font=Enum.Font.Code, TS=11, Col=C.t2, Z=4, Par=pCard})

        -- Cyan badge
        local badge = Box({Sz=UDim2.new(0,0,0,20), Pos=UDim2.new(1,-12,0,14), AP=Vector2.new(1,0),
            Bg=C.cyanDD, R=4, Z=4, Par=pCard})
        badge.AutomaticSize = Enum.AutomaticSize.X; Pad(badge,0,0,8,8)
        Txt({T=cfg.Name, Sz=UDim2.new(0,0,1,0),
            Font=Enum.Font.GothamBold, TS=10, Col=C.cyan, Z=5, Par=badge}).AutomaticSize=Enum.AutomaticSize.X

        -- ── Server stats grid ─────────────────────────────────────────────────
        local sCard = Box({Name="SCard", Sz=UDim2.new(1,0,0,98),
            Bg=C.base2, BgA=0, R=4, Border=true, BorderCol=C.line, BorderA=0.4,
            Z=3, Par=hPage})
        Txt({T="<font color='rgb(0,207,238)'>SRV</font>  STATISTICS",
            Sz=UDim2.new(1,-20,0,12), Pos=UDim2.new(0,14,0,8),
            Font=Enum.Font.GothamBold, TS=9, Col=C.t2, Z=4, Par=sCard})

        local statVals = {}
        local sData = {{"PLAYERS",""},{"PING",""},{"UPTIME",""},{"REGION",""}}
        for i, sd in ipairs(sData) do
            local col = (i-1)%2; local row = math.floor((i-1)/2)
            local cW = (WW - SIDE_W - 50) / 2
            local x = 14 + col*cW; local y = 24 + row*32
            Txt({T=sd[1], Sz=UDim2.new(0,120,0,11),
                Pos=UDim2.new(0,x,0,y), Font=Enum.Font.GothamBold, TS=9, Col=C.t2, Z=4, Par=sCard})
            statVals[sd[1]] = Txt({T="—", Sz=UDim2.new(0,160,0,15),
                Pos=UDim2.new(0,x,0,y+12), Font=Enum.Font.Code, TS=14, Col=C.t0, Z=4, Par=sCard})
        end
        task.spawn(function()
            while task.wait(1) do
                if not win or not win.Parent then break end
                pcall(function()
                    statVals["PLAYERS"].Text = #Plrs:GetPlayers().."/"..Plrs.MaxPlayers
                    statVals["PING"].Text    = math.floor(LP:GetNetworkPing()*1000).."ms"
                    local t = math.floor(time())
                    statVals["UPTIME"].Text  = string.format("%02d:%02d:%02d",math.floor(t/3600),math.floor(t%3600/60),t%60)
                    pcall(function()
                        statVals["REGION"].Text = game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(LP)
                    end)
                end)
            end
        end)

        -- Activate
        local function activateHome()
            DeactivateAll()
            hPage.Visible = true
            tw(hBar,{BackgroundTransparency=0},TI_FAST)
            tw(hIco,{ImageColor3=C.cyan},TI_FAST)
            tw(hBox,{BackgroundTransparency=0.88},TI_FAST)
            W._activeTab = "Home"
        end
        activateHome()
        hCL.MouseButton1Click:Connect(activateHome)
        hBox.MouseEnter:Connect(function()
            if W._activeTab~="Home" then tw(hBox,{BackgroundTransparency=0.92},TI_FAST) end
            tooltipL.Text="Home"; tooltip.Visible=true
            tw(tooltip,{Position=UDim2.new(0,SIDE_W+4,0,hBox.AbsolutePosition.Y-win.AbsolutePosition.Y+8)},TI_SNAP)
        end)
        hBox.MouseLeave:Connect(function()
            if W._activeTab~="Home" then tw(hBox,{BackgroundTransparency=1},TI_FAST) end
            tooltip.Visible=false
        end)
        return {Activate=activateHome}
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- CREATE TAB
    -- ══════════════════════════════════════════════════════════════════════════
    function W:CreateTab(tCfg)
        tCfg = merge({Name="Tab", Icon="unk", ShowTitle=true}, tCfg or {})
        local Tab = {}
        local isFirst = #W._tabs==0

        -- Icon button
        local tBox = Box({Name=tCfg.Name.."Btn", Sz=UDim2.new(0,40,0,40),
            Bg=C.cyan, BgA=isFirst and 0.1 or 1, R=4,
            Z=5, Ord=#W._tabs+1, Par=tabIconsList})

        local tBar = Box({Sz=UDim2.new(0,3,0.6,0), Pos=UDim2.new(0,0,0.2,0),
            Bg=C.cyan, BgA=isFirst and 0 or 1, R=0, Z=6, Par=tBox})

        local tIco = Img({Ico=tCfg.Icon, Sz=UDim2.new(0,18,0,18),
            Col=isFirst and C.cyan or C.t2, Z=6, Par=tBox})
        local tCL = Btn(tBox, 7)

        -- Page
        local tPage = Instance.new("ScrollingFrame")
        tPage.Name=tCfg.Name; tPage.Size=UDim2.new(1,0,1,0)
        tPage.BackgroundTransparency=1; tPage.BorderSizePixel=0
        tPage.ScrollBarThickness=2; tPage.ScrollBarImageColor3=C.line
        tPage.CanvasSize=UDim2.new(0,0,0,0); tPage.AutomaticCanvasSize=Enum.AutomaticSize.Y
        tPage.ZIndex=3; tPage.Visible=isFirst; tPage.Parent=contentArea
        List(tPage,8); Pad(tPage,16,16,18,18)

        if tCfg.ShowTitle then
            local titleRow = Box({Sz=UDim2.new(1,0,0,26), BgA=1, Z=3, Par=tPage})
            Img({Ico=tCfg.Icon, Sz=UDim2.new(0,14,0,14),
                Pos=UDim2.new(0,0,0.5,0), AP=Vector2.new(0,0.5),
                Col=C.cyan, Z=4, Par=titleRow})
            Txt({T=tCfg.Name:upper(), Sz=UDim2.new(1,-22,0,16),
                Pos=UDim2.new(0,22,0.5,0), AP=Vector2.new(0,0.5),
                Font=Enum.Font.GothamBold, TS=15, Col=C.t0, Z=4, Par=titleRow})
        end

        table.insert(W._tabs, {btn=tBox, page=tPage, name=tCfg.Name,
            activeBar=tBar, iconImg=tIco, bgBox=tBox})
        if isFirst then W._activeTab=tCfg.Name end

        function Tab:Activate()
            DeactivateAll()
            tPage.Visible = true
            tw(tBar,{BackgroundTransparency=0},TI_FAST)
            tw(tIco,{ImageColor3=C.cyan},TI_FAST)
            tw(tBox,{BackgroundTransparency=0.88},TI_FAST)
            W._activeTab = tCfg.Name
        end

        tCL.MouseButton1Click:Connect(function() Tab:Activate() end)
        tBox.MouseEnter:Connect(function()
            if W._activeTab~=tCfg.Name then tw(tBox,{BackgroundTransparency=0.92},TI_FAST) end
            tooltipL.Text=tCfg.Name; tooltip.Visible=true
            tw(tooltip,{Position=UDim2.new(0,SIDE_W+4,0,tBox.AbsolutePosition.Y-win.AbsolutePosition.Y+8)},TI_SNAP)
        end)
        tBox.MouseLeave:Connect(function()
            if W._activeTab~=tCfg.Name then tw(tBox,{BackgroundTransparency=1},TI_FAST) end
            tooltip.Visible=false
        end)

        -- ════════════════════════════════════════════════════════════════════
        -- SECTION
        -- ════════════════════════════════════════════════════════════════════
        local _secN = 0

        function Tab:CreateSection(sName)
            sName = sName or ""
            _secN = _secN + 1
            local Sec = {}

            -- Header  ──[ NAME ]──
            local shRow = Box({Name="SH",
                Sz=UDim2.new(1,0,0,sName~="" and 20 or 6),
                BgA=1, Z=3, Par=tPage, Ord=#tPage:GetChildren()})

            if sName ~= "" then
                Wire(shRow,false).Size=UDim2.new(1,0,0,1)
                Wire(shRow,false).Position=UDim2.new(0,0,1,-1)
                -- Badge box
                local badge2 = Box({Sz=UDim2.new(0,0,0,16),
                    Pos=UDim2.new(0,0,0.5,0), AP=Vector2.new(0,0.5),
                    Bg=C.base0, R=0, Z=4, Par=shRow})
                badge2.AutomaticSize=Enum.AutomaticSize.X; Pad(badge2,0,0,0,6)
                Txt({T="<font color='rgb(0,207,238)'>#"..string.format("%02d",_secN).." </font><font color='rgb(64,76,84)'>"..sName:upper().."</font>",
                    Sz=UDim2.new(0,0,1,0),
                    Font=Enum.Font.GothamBold, TS=9, Col=C.t2, Z=5, Par=badge2}).AutomaticSize=Enum.AutomaticSize.X
            end

            local secCon = Box({Name="SC",Sz=UDim2.new(1,0,0,0),
                BgA=1, Z=3, AutoY=true, Ord=shRow.LayoutOrder+1, Par=tPage})
            List(secCon,4)

            -- ── Shared base ───────────────────────────────────────────────────
            local function Elem(h, autoY)
                local f = Box({Sz=UDim2.new(1,0,0,h or 36),
                    Bg=C.base2, BgA=0, R=4,
                    Border=true, BorderCol=C.line, BorderA=0.45,
                    Z=3, Par=secCon})
                if autoY then f.AutomaticSize=Enum.AutomaticSize.Y end
                return f
            end

            local function HoverEffect(f)
                f.MouseEnter:Connect(function()
                    tw(f,{BackgroundTransparency=0},TI_FAST)
                    if f:FindFirstChildOfClass("UIStroke") then
                        tw(f.UIStroke,{Color=C.lineH,Transparency=0.2},TI_FAST)
                    end
                end)
                f.MouseLeave:Connect(function()
                    tw(f,{BackgroundTransparency=0},TI_FAST)
                    if f:FindFirstChildOfClass("UIStroke") then
                        tw(f.UIStroke,{Color=C.line,Transparency=0.45},TI_FAST)
                    end
                end)
            end

            -- ── DIVIDER ───────────────────────────────────────────────────────
            function Sec:CreateDivider()
                local d = Wire(secCon,false)
                d.Size=UDim2.new(1,0,0,1); d.BackgroundTransparency=0.6
                return {Destroy=function() d:Destroy() end}
            end

            -- ── LABEL ─────────────────────────────────────────────────────────
            function Sec:CreateLabel(lc)
                lc = merge({Text="Label",Style=1}, lc or {})
                local cMap = {[1]=C.t1,[2]=C.info,[3]=C.warn}
                local bgMap = {[1]=C.base2,[2]=Color3.fromRGB(10,24,48),[3]=Color3.fromRGB(46,34,8)}
                local f = Elem(28)
                f.BackgroundColor3 = bgMap[lc.Style]
                if lc.Style>1 then
                    Box({Sz=UDim2.new(0,3,0.7,0),Pos=UDim2.new(0,0,0.15,0),
                        Bg=cMap[lc.Style],R=0,Z=4,Par=f})
                end
                local xo = lc.Style>1 and 14 or 10
                local lb = Txt({T=lc.Text, Sz=UDim2.new(1,-xo-6,0,13),
                    Pos=UDim2.new(0,xo,0.5,0), AP=Vector2.new(0,0.5),
                    Font=Enum.Font.GothamSemibold, TS=12, Col=cMap[lc.Style], Z=4, Par=f})
                local LV={}; function LV:Set(t) lb.Text=t end; function LV:Destroy() f:Destroy() end; return LV
            end

            -- ── PARAGRAPH ─────────────────────────────────────────────────────
            function Sec:CreateParagraph(pc)
                pc = merge({Title="Title",Content=""}, pc or {})
                local f = Elem(0, true)
                Pad(f,10,10,12,12); List(f,4)
                local pt = Txt({T=pc.Title, Sz=UDim2.new(1,0,0,15),
                    Font=Enum.Font.GothamBold, TS=13, Col=C.t0, Z=4, Par=f})
                local pcont = Txt({T=pc.Content, Sz=UDim2.new(1,0,0,0),
                    Font=Enum.Font.Gotham, TS=12, Col=C.t1, Wrap=true, Z=4, AutoY=true, Par=f})
                local PV={}
                function PV:Set(s) if s.Title then pt.Text=s.Title end; if s.Content then pcont.Text=s.Content end end
                function PV:Destroy() f:Destroy() end; return PV
            end

            -- ── BUTTON  (charge fill animation) ──────────────────────────────
            function Sec:CreateButton(bc)
                bc = merge({Name="Button",Description=nil,Callback=function()end}, bc or {})
                local h = bc.Description and 52 or 36
                local f = Elem(h); f.ClipsDescendants=true

                -- Charge fill layer
                local chargeFill = Box({Sz=UDim2.new(0,0,1,0),
                    Bg=C.cyanDD, BgA=0, R=0, Z=3, Par=f})

                -- Cyan left accent pip (shows on hover)
                local pip = Box({Sz=UDim2.new(0,3,1,0),Pos=UDim2.new(0,0,0,0),
                    Bg=C.cyan, BgA=1, R=0, Z=4, Par=f})
                pip.BackgroundTransparency = 1

                Txt({T=bc.Name, Sz=UDim2.new(1,-44,0,15),
                    Pos=UDim2.new(0,14,0,bc.Description and 9 or 11),
                    Font=Enum.Font.GothamSemibold, TS=13, Col=C.t0, Z=4, Par=f})
                if bc.Description then
                    Txt({T=bc.Description, Sz=UDim2.new(1,-44,0,13),
                        Pos=UDim2.new(0,14,0,28), Font=Enum.Font.Gotham, TS=11, Col=C.t1, Z=4, Par=f})
                end
                Img({Ico="arr", Sz=UDim2.new(0,12,0,12),
                    Pos=UDim2.new(1,-20,0.5,0), AP=Vector2.new(0,0.5),
                    Col=C.cyan, IA=0.6, Z=5, Par=f})

                local cl = Btn(f,6)
                f.MouseEnter:Connect(function()
                    tw(chargeFill,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=0},TI(.3,Enum.EasingStyle.Quad))
                    tw(pip,{BackgroundTransparency=0},TI_FAST)
                    if f:FindFirstChildOfClass("UIStroke") then
                        tw(f.UIStroke,{Color=C.cyan,Transparency=0.5},TI_FAST)
                    end
                end)
                f.MouseLeave:Connect(function()
                    tw(chargeFill,{Size=UDim2.new(0,0,1,0),BackgroundTransparency=1},TI_MED)
                    tw(pip,{BackgroundTransparency=1},TI_FAST)
                    if f:FindFirstChildOfClass("UIStroke") then
                        tw(f.UIStroke,{Color=C.line,Transparency=0.45},TI_FAST)
                    end
                end)
                cl.MouseButton1Click:Connect(function()
                    tw(chargeFill,{BackgroundColor3=C.cyan},TI_SNAP)
                    task.wait(0.12)
                    tw(chargeFill,{BackgroundColor3=C.cyanDD,Size=UDim2.new(0,0,1,0),BackgroundTransparency=1},TI_MED)
                    safe(bc.Callback)
                end)
                local BV={Settings=bc}
                function BV:Set(s) s=merge(bc,s or {}); bc=s end
                function BV:Destroy() f:Destroy() end; return BV
            end

            -- ── TOGGLE  (square knob, military-feel) ─────────────────────────
            function Sec:CreateToggle(tc)
                tc = merge({Name="Toggle",Description=nil,CurrentValue=false,Flag=nil,Callback=function()end}, tc or {})
                local h = tc.Description and 52 or 36
                local f = Elem(h)

                Txt({T=tc.Name, Sz=UDim2.new(1,-66,0,15),
                    Pos=UDim2.new(0,14,0,tc.Description and 9 or 11),
                    Font=Enum.Font.GothamSemibold, TS=13, Col=C.t0, Z=4, Par=f})
                if tc.Description then
                    Txt({T=tc.Description, Sz=UDim2.new(1,-66,0,13),
                        Pos=UDim2.new(0,14,0,28), Font=Enum.Font.Gotham, TS=11, Col=C.t1, Z=4, Par=f})
                end

                -- Square track
                local trk = Box({Sz=UDim2.new(0,40,0,20),
                    Pos=UDim2.new(1,-52,0.5,0), AP=Vector2.new(0,0.5),
                    Bg=C.base4, R=3,
                    Border=true, BorderCol=C.line, BorderA=0.3,
                    Z=4, Par=f})

                -- Square knob (NOT rounded pill)
                local knob = Box({Sz=UDim2.new(0,14,0,14),
                    Pos=UDim2.new(0,3,0.5,0), AP=Vector2.new(0,0.5),
                    Bg=C.t2, R=2, Z=5, Par=trk})

                local TV = {CurrentValue=tc.CurrentValue, Type="Toggle", Settings=tc}
                local function upd()
                    if TV.CurrentValue then
                        tw(trk,{BackgroundColor3=C.cyanDD},TI_MED)
                        tw(trk.UIStroke,{Color=C.cyan,Transparency=0.4},TI_MED)
                        tw(knob,{Position=UDim2.new(0,23,0.5,0),BackgroundColor3=C.cyan},TI_SPRING)
                    else
                        tw(trk,{BackgroundColor3=C.base4},TI_MED)
                        tw(trk.UIStroke,{Color=C.line,Transparency=0.3},TI_MED)
                        tw(knob,{Position=UDim2.new(0,3,0.5,0),BackgroundColor3=C.t2},TI_SPRING)
                    end
                end
                upd()
                HoverEffect(f)
                Btn(f,5).MouseButton1Click:Connect(function()
                    TV.CurrentValue=not TV.CurrentValue; upd(); safe(tc.Callback,TV.CurrentValue)
                end)
                function TV:Set(v) TV.CurrentValue=v; upd(); safe(tc.Callback,v) end
                function TV:Destroy() f:Destroy() end
                if tc.Flag then Nexus.Flags[tc.Flag]=TV; Nexus.Options[tc.Flag]=TV end
                return TV
            end

            -- ── SLIDER  (glowing track + floating value chip) ─────────────────
            function Sec:CreateSlider(sc)
                sc = merge({Name="Slider",Range={0,100},Increment=1,CurrentValue=50,Suffix="",Flag=nil,Callback=function()end}, sc or {})
                local f = Elem(52)

                Txt({T=sc.Name, Sz=UDim2.new(1,-100,0,15),
                    Pos=UDim2.new(0,14,0,8), Font=Enum.Font.GothamSemibold, TS=13, Col=C.t0, Z=4, Par=f})

                local valChip = Box({Sz=UDim2.new(0,0,0,18),
                    Pos=UDim2.new(1,-12,0,6), AP=Vector2.new(1,0),
                    Bg=C.cyanDD, R=4, Z=4, Par=f})
                valChip.AutomaticSize=Enum.AutomaticSize.X; Pad(valChip,0,0,6,6)
                local valL = Txt({T=tostring(sc.CurrentValue)..sc.Suffix,
                    Sz=UDim2.new(0,0,1,0),
                    Font=Enum.Font.Code, TS=11, Col=C.cyan,
                    AX=Enum.TextXAlignment.Center, Z=5, Par=valChip})
                valL.AutomaticSize=Enum.AutomaticSize.X

                -- Track
                local trackBg = Box({Sz=UDim2.new(1,-28,0,4),
                    Pos=UDim2.new(0,14,0,34), Bg=C.base4, R=2, Z=4, Par=f})
                -- Glow fill
                local fillF = Box({Sz=UDim2.new(0,0,1,0), Bg=C.cyan, R=2, Z=5, Par=trackBg})
                local fillGlow = Instance.new("UIGradient")
                fillGlow.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0,C.cyanD),
                    ColorSequenceKeypoint.new(1,C.cyan),
                }; fillGlow.Parent = fillF
                -- Thumb (square)
                local thumb = Box({Sz=UDim2.new(0,10,0,10),
                    Pos=UDim2.new(0,0,0.5,0), AP=Vector2.new(0.5,0.5),
                    Bg=C.t0, R=2, Z=6, Par=trackBg})

                local SV = {CurrentValue=sc.CurrentValue, Type="Slider", Settings=sc}
                local mn,mx,inc = sc.Range[1],sc.Range[2],sc.Increment

                local function setV(v)
                    v = math.clamp(v,mn,mx)
                    v = math.floor(v/inc+0.5)*inc
                    v = tonumber(string.format("%.10g",v))
                    SV.CurrentValue=v
                    valL.Text = tostring(v)..sc.Suffix
                    local pct = (v-mn)/(mx-mn)
                    tw(fillF,{Size=UDim2.new(pct,0,1,0)},TI_FAST)
                    tw(thumb,{Position=UDim2.new(pct,0,0.5,0)},TI_FAST)
                end
                setV(sc.CurrentValue)

                local drag=false
                local bCL=Btn(trackBg,8)
                local function fromInp(i)
                    local rel=math.clamp((i.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1)
                    setV(mn+(mx-mn)*rel); safe(sc.Callback,SV.CurrentValue)
                end
                bCL.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; fromInp(i) end
                end)
                bCL.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
                end)
                track(UIS.InputChanged:Connect(function(i)
                    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromInp(i) end
                end))
                HoverEffect(f)
                function SV:Set(v) setV(v); safe(sc.Callback,SV.CurrentValue) end
                function SV:Destroy() f:Destroy() end
                if sc.Flag then Nexus.Flags[sc.Flag]=SV; Nexus.Options[sc.Flag]=SV end
                return SV
            end

            -- ── DROPDOWN ──────────────────────────────────────────────────────
            function Sec:CreateDropdown(dc)
                dc = merge({Name="Dropdown",Description=nil,Options={},CurrentOption=nil,MultipleOptions=false,SpecialType=nil,Flag=nil,Callback=function()end}, dc or {})
                if dc.SpecialType=="Player" then
                    dc.Options={}; for _,p in ipairs(Plrs:GetPlayers()) do table.insert(dc.Options,p.Name) end
                end
                if type(dc.CurrentOption)=="string" then dc.CurrentOption={dc.CurrentOption} end
                dc.CurrentOption = dc.CurrentOption or {dc.Options[1] or ""}

                local cH = dc.Description and 52 or 36
                local f = Elem(cH); f.ClipsDescendants=true

                Txt({T=dc.Name, Sz=UDim2.new(1,-80,0,15),
                    Pos=UDim2.new(0,14,0,dc.Description and 9 or 11),
                    Font=Enum.Font.GothamSemibold, TS=13, Col=C.t0, Z=4, Par=f})
                if dc.Description then
                    Txt({T=dc.Description, Sz=UDim2.new(1,-80,0,13),
                        Pos=UDim2.new(0,14,0,28), Font=Enum.Font.Gotham, TS=11, Col=C.t1, Z=4, Par=f})
                end
                local selL = Txt({T=table.concat(dc.CurrentOption,", "),
                    Sz=UDim2.new(0,100,0,13), Pos=UDim2.new(1,-44,0,dc.Description and 10 or 12),
                    AP=Vector2.new(1,0), Font=Enum.Font.Code, TS=11, Col=C.t2,
                    AX=Enum.TextXAlignment.Right, Z=4, Par=f})
                local chevIco = Img({Ico="chev_d", Sz=UDim2.new(0,14,0,14),
                    Pos=UDim2.new(1,-20,0,dc.Description and 11 or 11),
                    Col=C.t2, Z=5, Par=f})

                local optList = Instance.new("Frame")
                optList.Size=UDim2.new(1,-10,0,0); optList.Position=UDim2.new(0,5,0,cH+4)
                optList.BackgroundTransparency=1; optList.AutomaticSize=Enum.AutomaticSize.Y
                optList.ZIndex=4; optList.Parent=f
                List(optList,2)

                local opened=false
                local sel={}; for _,o in ipairs(dc.CurrentOption) do sel[o]=true end
                local DV={CurrentOption=dc.CurrentOption, Type="Dropdown", Settings=dc}

                local function refOpts()
                    for _,c in ipairs(optList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                    for _,o in ipairs(dc.Options) do
                        local isS=sel[o]
                        local of=Box({Sz=UDim2.new(1,0,0,26),
                            Bg=isS and C.cyanDD or C.base3, BgA=0,
                            R=4, Border=true, BorderCol=isS and C.cyanD or C.line, BorderA=0.4,
                            Z=5, Par=optList})
                        if isS then
                            Box({Sz=UDim2.new(0,3,1,0), Bg=C.cyan, R=0, Z=6, Par=of})
                        end
                        Txt({T=o, Sz=UDim2.new(1,-26,1,0),
                            Pos=UDim2.new(0,isS and 10 or 8,0,0),
                            Font=Enum.Font.Gotham, TS=12, Col=isS and C.t0 or C.t1, Z=6, Par=of})
                        if isS then
                            Txt({T="✓", Sz=UDim2.new(0,20,1,0), Pos=UDim2.new(1,-20,0,0),
                                Font=Enum.Font.GothamBold, TS=11, Col=C.cyan,
                                AX=Enum.TextXAlignment.Center, Z=6, Par=of})
                        end
                        Btn(of,7).MouseButton1Click:Connect(function()
                            if dc.MultipleOptions then sel[o]=not sel[o]
                            else sel={}; sel[o]=true; opened=false
                                tw(chevIco,{Rotation=0}); tw(f,{Size=UDim2.new(1,0,0,cH)},TI_MED) end
                            local s={}; for _,op in ipairs(dc.Options) do if sel[op] then table.insert(s,op) end end
                            dc.CurrentOption=s; DV.CurrentOption=s
                            selL.Text=#s>0 and table.concat(s,", ") or "—"
                            refOpts(); safe(dc.Callback,dc.MultipleOptions and s or (s[1] or ""))
                        end)
                    end
                end
                refOpts()

                local hCL2=Instance.new("TextButton")
                hCL2.Size=UDim2.new(1,0,0,cH); hCL2.BackgroundTransparency=1
                hCL2.Text=""; hCL2.ZIndex=8; hCL2.Parent=f
                hCL2.MouseButton1Click:Connect(function()
                    opened=not opened
                    tw(chevIco,{Rotation=opened and 180 or 0})
                    tw(f,{Size=UDim2.new(1,0,0,opened and math.min(cH+8+#dc.Options*28,cH+168) or cH)},TI_MED)
                end)
                HoverEffect(f)
                function DV:Set(o) if type(o)=="table" then dc.CurrentOption=o else dc.CurrentOption={o} end; sel={}; for _,v in ipairs(dc.CurrentOption) do sel[v]=true end; selL.Text=table.concat(dc.CurrentOption,", "); refOpts() end
                function DV:Refresh(o) dc.Options=o; refOpts() end
                function DV:Destroy() f:Destroy() end
                if dc.Flag then Nexus.Flags[dc.Flag]=DV; Nexus.Options[dc.Flag]=DV end
                return DV
            end

            -- ── INPUT ─────────────────────────────────────────────────────────
            function Sec:CreateInput(ic)
                ic = merge({Name="Input",Description=nil,PlaceholderText="...",CurrentValue="",RemoveTextAfterFocusLost=false,Numeric=false,MaxCharacters=nil,Enter=false,Flag=nil,Callback=function()end}, ic or {})
                local h = ic.Description and 52 or 36
                local f = Elem(h)
                Txt({T=ic.Name, Sz=UDim2.new(1,-150,0,15),
                    Pos=UDim2.new(0,14,0,ic.Description and 9 or 11),
                    Font=Enum.Font.GothamSemibold, TS=13, Col=C.t0, Z=4, Par=f})
                if ic.Description then
                    Txt({T=ic.Description, Sz=UDim2.new(1,-150,0,13),
                        Pos=UDim2.new(0,14,0,28), Font=Enum.Font.Gotham, TS=11, Col=C.t1, Z=4, Par=f})
                end

                local ib = Instance.new("TextBox")
                ib.Size=UDim2.new(0,120,0,22); ib.Position=UDim2.new(1,-10,0.5,0); ib.AnchorPoint=Vector2.new(1,0.5)
                ib.BackgroundColor3=C.base4; ib.BackgroundTransparency=0; ib.BorderSizePixel=0
                ib.Font=Enum.Font.Code; ib.TextSize=12; ib.TextColor3=C.t0
                ib.PlaceholderText=ic.PlaceholderText; ib.PlaceholderColor3=C.t2
                ib.Text=ic.CurrentValue; ib.ClearTextOnFocus=false; ib.ZIndex=5; ib.Parent=f
                Instance.new("UICorner",ib).CornerRadius=UDim.new(0,4)
                local ibS=Instance.new("UIStroke"); ibS.Color=C.line; ibS.Transparency=0.3; ibS.Parent=ib
                Pad(ib,0,0,8,8)
                ib.Focused:Connect(function() tw(ibS,{Color=C.cyan,Transparency=0.45},TI_FAST) end)
                ib.FocusLost:Connect(function() tw(ibS,{Color=C.line,Transparency=0.3},TI_FAST) end)

                local IV={CurrentValue=ic.CurrentValue, Type="Input", Settings=ic}
                if ic.Numeric then ib:GetPropertyChangedSignal("Text"):Connect(function() if not tonumber(ib.Text) and ib.Text~="" and ib.Text~="." and ib.Text~="-" then ib.Text=ib.Text:match("[%-0-9.]*") or "" end end) end
                if ic.MaxCharacters then ib:GetPropertyChangedSignal("Text"):Connect(function() if #ib.Text>ic.MaxCharacters then ib.Text=ib.Text:sub(1,ic.MaxCharacters) end end) end
                ib.FocusLost:Connect(function(enter)
                    if ic.Enter and not enter then return end
                    IV.CurrentValue=ib.Text; safe(ic.Callback,ib.Text)
                    if ic.RemoveTextAfterFocusLost then ib.Text="" end
                end)
                if not ic.Enter then ib:GetPropertyChangedSignal("Text"):Connect(function() IV.CurrentValue=ib.Text; safe(ic.Callback,ib.Text) end) end
                HoverEffect(f)
                function IV:Set(v) ib.Text=tostring(v); IV.CurrentValue=tostring(v) end
                function IV:Destroy() f:Destroy() end
                if ic.Flag then Nexus.Flags[ic.Flag]=IV; Nexus.Options[ic.Flag]=IV end
                return IV
            end

            -- ── KEYBIND ───────────────────────────────────────────────────────
            function Sec:CreateBind(bc)
                bc = merge({Name="Keybind",Description=nil,CurrentBind="E",HoldToInteract=false,Flag=nil,Callback=function()end,OnChangedCallback=function()end}, bc or {})
                local h = bc.Description and 52 or 36
                local f = Elem(h)
                Txt({T=bc.Name, Sz=UDim2.new(1,-90,0,15),
                    Pos=UDim2.new(0,14,0,bc.Description and 9 or 11),
                    Font=Enum.Font.GothamSemibold, TS=13, Col=C.t0, Z=4, Par=f})
                if bc.Description then
                    Txt({T=bc.Description, Sz=UDim2.new(1,-90,0,13),
                        Pos=UDim2.new(0,14,0,28), Font=Enum.Font.Gotham, TS=11, Col=C.t1, Z=4, Par=f})
                end
                local bb = Instance.new("TextBox")
                bb.Size=UDim2.new(0,62,0,22); bb.Position=UDim2.new(1,-10,0.5,0); bb.AnchorPoint=Vector2.new(1,0.5)
                bb.BackgroundColor3=C.base4; bb.BackgroundTransparency=0; bb.BorderSizePixel=0
                bb.Font=Enum.Font.Code; bb.TextSize=12; bb.TextColor3=C.cyan
                bb.Text=bc.CurrentBind; bb.ClearTextOnFocus=true; bb.ZIndex=5; bb.Parent=f
                Instance.new("UICorner",bb).CornerRadius=UDim.new(0,4)
                local bbS=Instance.new("UIStroke"); bbS.Color=C.line; bbS.Transparency=0.3; bbS.Parent=bb

                local BV={CurrentBind=bc.CurrentBind, Active=false, Type="Keybind", Settings=bc}
                local checking=false
                bb.Focused:Connect(function() checking=true; bb.Text="..."; tw(bbS,{Color=C.cyan,Transparency=0.45},TI_FAST) end)
                bb.FocusLost:Connect(function() checking=false; tw(bbS,{Color=C.line,Transparency=0.3},TI_FAST); if bb.Text=="..." or bb.Text=="" then bb.Text=BV.CurrentBind end end)
                track(UIS.InputBegan:Connect(function(inp,proc)
                    if checking then
                        if inp.KeyCode~=Enum.KeyCode.Unknown then
                            local kn=inp.KeyCode.Name; BV.CurrentBind=kn; bc.CurrentBind=kn
                            bb.Text=kn; bb:ReleaseFocus(); safe(bc.OnChangedCallback,kn)
                        end
                    elseif BV.CurrentBind and not proc then
                        local ok,ke=pcall(function() return Enum.KeyCode[BV.CurrentBind] end)
                        if ok and inp.KeyCode==ke then
                            if not bc.HoldToInteract then BV.Active=not BV.Active; safe(bc.Callback,BV.Active)
                            else safe(bc.Callback,true); local cn; cn=inp.Changed:Connect(function(pr) if pr=="UserInputState" then cn:Disconnect(); safe(bc.Callback,false) end end) end
                        end
                    end
                end))
                HoverEffect(f)
                function BV:Set(v) BV.CurrentBind=v; bc.CurrentBind=v; bb.Text=v end
                function BV:Destroy() f:Destroy() end
                Sec.CreateKeybind=Sec.CreateBind
                if bc.Flag then Nexus.Flags[bc.Flag]=BV; Nexus.Options[bc.Flag]=BV end
                return BV
            end
            Sec.CreateKeybind = Sec.CreateBind

            -- ── COLOR PICKER ──────────────────────────────────────────────────
            function Sec:CreateColorPicker(cc)
                cc = merge({Name="Color",Color=Color3.fromRGB(0,207,238),Flag=nil,Callback=function()end}, cc or {})
                local cH=36
                local f = Elem(cH); f.ClipsDescendants=true
                Txt({T=cc.Name, Sz=UDim2.new(1,-55,0,15),
                    Pos=UDim2.new(0,14,0,11), Font=Enum.Font.GothamSemibold, TS=13, Col=C.t0, Z=4, Par=f})
                local prev=Box({Sz=UDim2.new(0,22,0,22), Pos=UDim2.new(1,-32,0,7),
                    Bg=cc.Color, R=4, Border=true, BorderCol=C.line, BorderA=0.4, Z=5, Par=f})

                local pArea=Instance.new("Frame"); pArea.Size=UDim2.new(1,-12,0,130)
                pArea.Position=UDim2.new(0,6,0,42); pArea.BackgroundTransparency=1; pArea.ZIndex=4; pArea.Parent=f
                local svBox=Instance.new("Frame"); svBox.Size=UDim2.new(1,0,0,100)
                svBox.BackgroundColor3=Color3.fromHSV(0,1,1); svBox.BorderSizePixel=0; svBox.ZIndex=5; svBox.Parent=pArea
                Instance.new("UICorner",svBox).CornerRadius=UDim.new(0,4)
                local wG=Instance.new("UIGradient"); wG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}; wG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}; wG.Parent=svBox
                local bOv=Instance.new("Frame"); bOv.Size=UDim2.new(1,0,1,0); bOv.BackgroundColor3=Color3.new(0,0,0); bOv.BorderSizePixel=0; bOv.ZIndex=6; bOv.Parent=svBox
                Instance.new("UICorner",bOv).CornerRadius=UDim.new(0,4)
                local bG=Instance.new("UIGradient"); bG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}; bG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}; bG.Rotation=90; bG.Parent=bOv
                local hBar=Instance.new("Frame"); hBar.Size=UDim2.new(1,0,0,14); hBar.Position=UDim2.new(0,0,0,106); hBar.BackgroundColor3=Color3.new(1,1,1); hBar.BorderSizePixel=0; hBar.ZIndex=5; hBar.Parent=pArea
                Instance.new("UICorner",hBar).CornerRadius=UDim.new(0,4)
                local hG=Instance.new("UIGradient"); hG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))}; hG.Parent=hBar

                local opened=false; local h2,s2,v2=Color3.toHSV(cc.Color)
                local CPV={Color=cc.Color, Type="ColorPicker", Settings=cc}
                local function updCol() CPV.Color=Color3.fromHSV(h2,s2,v2); prev.BackgroundColor3=CPV.Color; svBox.BackgroundColor3=Color3.fromHSV(h2,1,1); safe(cc.Callback,CPV.Color) end

                local hBtn=Instance.new("TextButton"); hBtn.Size=UDim2.new(1,0,0,cH); hBtn.BackgroundTransparency=1; hBtn.Text=""; hBtn.ZIndex=8; hBtn.Parent=f
                hBtn.MouseButton1Click:Connect(function() opened=not opened; tw(f,{Size=UDim2.new(1,0,0,opened and 178 or cH)},TI_MED) end)
                local svDrg=false; local svCL=Btn(bOv,9)
                local function upSV(i) s2=math.clamp((i.Position.X-svBox.AbsolutePosition.X)/svBox.AbsoluteSize.X,0,1); v2=1-math.clamp((i.Position.Y-svBox.AbsolutePosition.Y)/svBox.AbsoluteSize.Y,0,1); updCol() end
                svCL.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrg=true; upSV(i) end end)
                svCL.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrg=false end end)
                local hDrg=false; local hCL3=Btn(hBar,9)
                local function upH(i) h2=math.clamp((i.Position.X-hBar.AbsolutePosition.X)/hBar.AbsoluteSize.X,0,1); updCol() end
                hCL3.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hDrg=true; upH(i) end end)
                hCL3.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hDrg=false end end)
                track(UIS.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then if svDrg then upSV(i) end; if hDrg then upH(i) end end end))
                HoverEffect(f)
                function CPV:Set(s) if s.Color then h2,s2,v2=Color3.toHSV(s.Color); updCol() end end
                function CPV:Destroy() f:Destroy() end
                if cc.Flag then Nexus.Flags[cc.Flag]=CPV; Nexus.Options[cc.Flag]=CPV end
                return CPV
            end

            function Sec:Set(n)
                local lb = shRow:FindFirstChildOfClass("TextLabel")
                if lb then
                    lb.Text="<font color='rgb(0,207,238)'>#"..string.format("%02d",_secN).." </font><font color='rgb(64,76,84)'>"..n:upper().."</font>"
                end
            end
            function Sec:Destroy() shRow:Destroy(); secCon:Destroy() end
            return Sec
        end

        -- Tab-level shortcuts
        local _ds
        local function gds() if not _ds then _ds=Tab:CreateSection("") end return _ds end
        for _,m in ipairs({"CreateButton","CreateLabel","CreateParagraph","CreateToggle",
            "CreateSlider","CreateDivider","CreateDropdown","CreateInput","CreateBind",
            "CreateKeybind","CreateColorPicker"}) do
            Tab[m]=function(self,...) return gds()[m](gds(),...) end
        end
        return Tab
    end

    -- ── Config save/load ──────────────────────────────────────────────────────
    function W:SaveConfiguration()
        if not cfg.ConfigurationSaving or not cfg.ConfigurationSaving.Enabled then return end
        local data={}
        for k,flag in pairs(Nexus.Flags) do
            if     flag.Type=="ColorPicker" then data[k]={R=flag.Color.R*255,G=flag.Color.G*255,B=flag.Color.B*255}
            elseif flag.Type=="Toggle"      then data[k]=flag.CurrentValue
            elseif flag.Type=="Slider"      then data[k]=flag.CurrentValue
            elseif flag.Type=="Dropdown"    then data[k]=flag.CurrentOption
            elseif flag.Type=="Input"       then data[k]=flag.CurrentValue
            elseif flag.Type=="Keybind"     then data[k]=flag.CurrentBind end
        end
        pcall(function()
            local fld=cfg.ConfigurationSaving.FolderName or "Nexus"
            local fn=cfg.ConfigurationSaving.FileName or "config"
            if isfolder and not isfolder(fld) then makefolder(fld) end
            writefile(fld.."/"..fn..".json",HS:JSONEncode(data))
        end)
    end

    function W:LoadConfiguration()
        if not cfg.ConfigurationSaving or not cfg.ConfigurationSaving.Enabled then return end
        pcall(function()
            local fld=cfg.ConfigurationSaving.FolderName or "Nexus"
            local fn=cfg.ConfigurationSaving.FileName or "config"
            local path=fld.."/"..fn..".json"
            if isfile and isfile(path) then
                local data=HS:JSONDecode(readfile(path))
                for k,v in pairs(data) do
                    local flag=Nexus.Flags[k]
                    if flag then
                        if flag.Type=="ColorPicker" then flag:Set({Color=Color3.fromRGB(v.R,v.G,v.B)})
                        else flag:Set(v) end
                    end
                end
                Nexus:Notify({Title="Config loaded",Content="Restored successfully.",Icon="save",Type="Success"})
            end
        end)
    end

    return W
end

-- ── Destroy ───────────────────────────────────────────────────────────────────
function Nexus:Destroy()
    for _,c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    self._conns={}
    if self._notifHolder and self._notifHolder.Parent then
        self._notifHolder.Parent:Destroy()
    end
    self.Flags={}; self.Options={}
end

return Nexus
