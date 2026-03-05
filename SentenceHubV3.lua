--[[
╔══════════════════════════════════════════════════════════╗
║  SENTENCE Hub  ·  v3.0  ·  VOID MATRIX Edition          ║
║  Layout   : left sidebar + full-height content           ║
║  Accent   : #00D9FF electric cyan + #7B2FFF neon violet  ║
║  Motion   : slide tabs · spring knobs · glitch splash    ║
╚══════════════════════════════════════════════════════════╝
    Redesigned from ground up — new architecture, new soul.
]]

local Sentence = {
    Version = "3.0",
    Flags   = {},
    Options = {},
    _conns  = {},
}

-- ── Services ────────────────────────────────────────────────────────────────
local TS   = game:GetService("TweenService")
local UIS  = game:GetService("UserInputService")
local RS   = game:GetService("RunService")
local HS   = game:GetService("HttpService")
local Plrs = game:GetService("Players")
local CG   = game:GetService("CoreGui")
local LP   = Plrs.LocalPlayer
local Cam  = workspace.CurrentCamera
local Studio = RS:IsStudio()

-- ── Palette — VOID MATRIX ───────────────────────────────────────────────────
local P = {
    -- Backgrounds (deep blue-black family)
    void    = Color3.fromRGB(  6,  6, 12),   -- absolute void
    abyss   = Color3.fromRGB( 10, 10, 20),   -- window base
    deep    = Color3.fromRGB( 14, 14, 28),   -- sidebar bg
    panel   = Color3.fromRGB( 18, 18, 36),   -- card bg
    surface = Color3.fromRGB( 24, 24, 46),   -- element bg
    raised  = Color3.fromRGB( 30, 30, 58),   -- hover state
    lift    = Color3.fromRGB( 38, 38, 72),   -- active state
    glass   = Color3.fromRGB( 20, 20, 42),   -- glass overlay

    -- Borders
    wire    = Color3.fromRGB( 40, 42, 80),
    wireHov = Color3.fromRGB( 70, 74,130),
    wireAct = Color3.fromRGB(100,106,180),
    wireSel = Color3.fromRGB( 0, 180,220),

    -- Text
    hi      = Color3.fromRGB(232,236,255),
    mid     = Color3.fromRGB(120,128,168),
    dim     = Color3.fromRGB( 54, 58, 96),
    ghost   = Color3.fromRGB( 36, 38, 70),

    -- Accents
    cyan    = Color3.fromRGB(  0, 217,255),   -- primary accent
    cyanD   = Color3.fromRGB(  0, 148,190),   -- accent dark
    cyanDD  = Color3.fromRGB(  0,  38, 58),   -- accent tint bg

    violet  = Color3.fromRGB(123, 47,255),    -- secondary accent
    violetD = Color3.fromRGB( 80, 28,200),
    violetDD= Color3.fromRGB( 22,  8, 60),

    pink    = Color3.fromRGB(255, 62,160),    -- tertiary accent

    -- Status
    ok      = Color3.fromRGB( 72,220,140),
    warn    = Color3.fromRGB(255,196, 48),
    err     = Color3.fromRGB(255, 72, 72),
    info    = Color3.fromRGB(  0,217,255),
}

-- ── Tween helpers ────────────────────────────────────────────────────────────
local function ti(t, s, d)
    return TweenInfo.new(t or 0.2, s or Enum.EasingStyle.Exponential, d or Enum.EasingDirection.Out)
end
local TI_INSTANT = ti(0.06)
local TI_SNAP    = ti(0.12)
local TI_FAST    = ti(0.18)
local TI_MED     = ti(0.26)
local TI_SLOW    = ti(0.50)
local TI_SPRING  = TweenInfo.new(0.44, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
local TI_EASE    = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
local TI_SLIDE   = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tw(obj, props, info, cb)
    local t = TS:Create(obj, info or TI_MED, props)
    if cb then t.Completed:Once(cb) end
    t:Play(); return t
end

-- ── Utilities ────────────────────────────────────────────────────────────────
local function def(d, t)
    t = t or {}
    for k, v in pairs(d) do if t[k] == nil then t[k] = v end end
    return t
end
local function track(c)  table.insert(Sentence._conns, c); return c end
local function safe(cb, ...) local ok, e = pcall(cb, ...); if not ok then warn("SENTENCE: "..tostring(e)) end end
local function lerp(a, b, t) return a + (b - a) * t end

-- ── Icon map ─────────────────────────────────────────────────────────────────
local ICO = {
    close   = "rbxassetid://6031094678",
    min     = "rbxassetid://6031094687",
    hide    = "rbxassetid://6031075929",
    home    = "rbxassetid://6026568195",
    set     = "rbxassetid://6031280882",
    star    = "rbxassetid://6031068423",
    flash   = "rbxassetid://6034333271",
    shield  = "rbxassetid://6035078889",
    palette = "rbxassetid://6034316009",
    code    = "rbxassetid://6022668955",
    person  = "rbxassetid://6034287594",
    save    = "rbxassetid://6035067857",
    info    = "rbxassetid://6026568227",
    warn    = "rbxassetid://6031071053",
    err     = "rbxassetid://6031071057",
    ok      = "rbxassetid://6031094667",
    arr     = "rbxassetid://6031090995",
    search  = "rbxassetid://6031154871",
    unk     = "rbxassetid://6031079152",
    notif   = "rbxassetid://6034308946",
    edit    = "rbxassetid://6034328955",
    check   = "rbxassetid://6031094667",
    chev_d  = "rbxassetid://6031094687",
    chev_u  = "rbxassetid://6031094679",
    settings= "rbxassetid://6031280882",
}
local function ico(n)
    if not n or n == "" then return "" end
    if n:find("rbxassetid") then return n end
    if tonumber(n) then return "rbxassetid://"..n end
    return ICO[n] or ICO.unk
end

-- ── Core builders ─────────────────────────────────────────────────────────────
local function F(p)
    p = p or {}
    local f = Instance.new("Frame")
    f.Name               = p.Name or "F"
    f.Size               = p.Sz   or UDim2.new(1, 0, 0, 32)
    f.Position           = p.Pos  or UDim2.new()
    f.AnchorPoint        = p.AP   or Vector2.zero
    f.BackgroundColor3   = p.Bg   or P.surface
    f.BackgroundTransparency = p.BgA or 0
    f.BorderSizePixel    = 0
    f.ZIndex             = p.Z    or 1
    f.LayoutOrder        = p.Ord  or 0
    f.Visible            = p.Vis  ~= false
    if p.Clip then f.ClipsDescendants = true end
    if p.AS   then f.AutomaticSize   = Enum.AutomaticSize.Y end
    if p.R ~= false then
        local uc = Instance.new("UICorner")
        uc.CornerRadius = (type(p.R)=="userdata" and p.R) or UDim.new(0, p.R or 8)
        uc.Parent = f
    end
    if p.S then
        local s = Instance.new("UIStroke")
        s.Color           = p.SC or P.wire
        s.Transparency    = p.SA or 0.4
        s.Thickness       = p.SW or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = f
    end
    if p.Par then f.Parent = p.Par end
    return f
end

local function T(p)
    p = p or {}
    local l = Instance.new("TextLabel")
    l.Name             = p.Name or "T"
    l.Text             = p.Txt  or ""
    l.Size             = p.Sz   or UDim2.new(1, 0, 0, 16)
    l.Position         = p.Pos  or UDim2.new()
    l.AnchorPoint      = p.AP   or Vector2.zero
    l.Font             = p.Font or Enum.Font.GothamSemibold
    l.TextSize         = p.TS   or 13
    l.TextColor3       = p.Col  or P.hi
    l.TextTransparency = p.TA   or 0
    l.TextXAlignment   = p.AX   or Enum.TextXAlignment.Left
    l.TextYAlignment   = p.AY   or Enum.TextYAlignment.Center
    l.TextWrapped      = p.Wrap or false
    l.RichText         = true
    l.BackgroundTransparency = 1
    l.BorderSizePixel  = 0
    l.ZIndex           = p.Z    or 2
    l.LayoutOrder      = p.Ord  or 0
    if p.AS  then l.AutomaticSize = Enum.AutomaticSize.Y end
    if p.Par then l.Parent = p.Par end
    return l
end

local function I(p)
    p = p or {}
    local i = Instance.new("ImageLabel")
    i.Name              = p.Name or "I"
    i.Image             = ico(p.Ico or "")
    i.Size              = p.Sz   or UDim2.new(0, 16, 0, 16)
    i.Position          = p.Pos  or UDim2.new(0, 0, 0.5, 0)
    i.AnchorPoint       = p.AP   or Vector2.new(0, 0.5)
    i.ImageColor3       = p.Col  or P.hi
    i.ImageTransparency = p.IA   or 0
    i.BackgroundTransparency = 1
    i.BorderSizePixel   = 0
    i.ZIndex            = p.Z    or 3
    i.ScaleType         = Enum.ScaleType.Fit
    if p.Par then i.Parent = p.Par end
    return i
end

local function CL(par, z)
    local b = Instance.new("TextButton")
    b.Name = "CL"; b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1; b.Text = ""; b.ZIndex = z or 8
    b.Parent = par; return b
end

local function LL(par, gap, fillDir, ha, va)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0, gap or 4)
    if fillDir then l.FillDirection = fillDir end
    if ha then l.HorizontalAlignment = ha end
    if va then l.VerticalAlignment   = va end
    l.Parent = par; return l
end

local function PD(par, top, bot, lft, rgt)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bot or 0)
    p.PaddingLeft   = UDim.new(0, lft or 0)
    p.PaddingRight  = UDim.new(0, rgt or 0)
    p.Parent = par; return p
end

local function Stroke(par, col, trans, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or P.wire; s.Transparency = trans or 0.4
    s.Thickness = thick or 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = par; return s
end

local function GradH(par, c1, c2, a1, a2)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2 or c1)}
    g.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, a1 or 0), NumberSequenceKeypoint.new(1, a2 or 0)}
    g.Parent = par; return g
end

-- ── Dragging ─────────────────────────────────────────────────────────────────
local function Drag(handle, win)
    local drg, ds, dp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drg = true; ds = i.Position; dp = win.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drg = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            win.Position = UDim2.new(dp.X.Scale, dp.X.Offset + d.X, dp.Y.Scale, dp.Y.Offset + d.Y)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION  (bottom-right floating stack)
-- ══════════════════════════════════════════════════════════════════════════════
function Sentence:Notify(d)
    task.spawn(function()
        d = def({ Title = "Notice", Content = "", Icon = "info", Type = "Info", Duration = nil }, d)
        local aMap = { Info = P.info, Success = P.ok, Warning = P.warn, Error = P.err }
        local ac = aMap[d.Type] or P.info

        local card = F({ Name = "NC",
            Sz = UDim2.new(1, 0, 0, 0),
            Bg = P.panel, BgA = 0.02, Clip = true,
            R = 10, S = true, SC = P.wire, SA = 0.5,
            Par = self._notifBin })
        card.BackgroundTransparency = 1

        -- Gradient border glow top
        local topGlow = F({ Sz = UDim2.new(1, 0, 0, 1), Bg = ac, BgA = 0, Z = 4, R = false, Par = card })

        -- Left accent stripe
        local stripe = F({ Sz = UDim2.new(0, 3, 1, -16), Pos = UDim2.new(0, 8, 0, 8),
            Bg = ac, R = UDim.new(1, 0), Z = 4, Par = card })
        stripe.BackgroundTransparency = 1

        local icoL = I({ Ico = d.Icon, Sz = UDim2.new(0, 14, 0, 14),
            Pos = UDim2.new(0, 20, 0, 15), AP = Vector2.zero, Col = ac, IA = 1, Z = 4, Par = card })

        local ttl = T({ Txt = d.Title, Sz = UDim2.new(1, -44, 0, 15),
            Pos = UDim2.new(0, 40, 0, 9), Font = Enum.Font.GothamBold, TS = 13,
            Col = P.hi, TA = 1, Z = 4, Par = card })

        local msg = T({ Txt = d.Content, Sz = UDim2.new(1, -44, 0, 800),
            Pos = UDim2.new(0, 40, 0, 26), Font = Enum.Font.Gotham, TS = 11,
            Col = P.mid, TA = 1, Wrap = true, Z = 4, Par = card })

        task.wait()
        local th = msg.TextBounds.Y
        msg.Size = UDim2.new(1, -44, 0, th)
        local H = 36 + th

        tw(card, { Size = UDim2.new(1, 0, 0, H), BackgroundTransparency = 0.04 }, TI_SLOW)
        task.wait(0.1)
        tw(topGlow,  { BackgroundTransparency = 0.3 }, TI_FAST)
        tw(stripe,   { BackgroundTransparency = 0 },   TI_MED)
        tw(icoL,     { ImageTransparency = 0 },        TI_MED)
        tw(ttl,      { TextTransparency = 0 },         TI_MED)
        task.wait(0.05)
        tw(msg,      { TextTransparency = 0.15 },      TI_MED)

        local dur = d.Duration or math.clamp(#d.Content * 0.06 + 2.5, 2.5, 8)
        task.wait(dur)

        tw(card,    { BackgroundTransparency = 1 }, TI_FAST)
        tw(topGlow, { BackgroundTransparency = 1 }, TI_FAST)
        tw(stripe,  { BackgroundTransparency = 1 }, TI_FAST)
        tw(icoL,    { ImageTransparency = 1 },      TI_FAST)
        tw(ttl,     { TextTransparency = 1 },       TI_FAST)
        tw(msg,     { TextTransparency = 1 },       TI_FAST)
        if card:FindFirstChildOfClass("UIStroke") then
            tw(card.UIStroke, { Transparency = 1 }, TI_FAST)
        end
        task.wait(0.22)
        tw(card, { Size = UDim2.new(1, 0, 0, 0) }, TI_SLOW, function() card:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════════════════════════════════════════
function Sentence:CreateWindow(cfg)
    cfg = def({
        Name            = "SENTENCE",
        Subtitle        = "Hub",
        Icon            = "rbxassetid://118722741385791",
        ToggleBind      = Enum.KeyCode.RightControl,
        LoadingEnabled  = true,
        LoadingTitle    = "SENTENCE",
        LoadingSubtitle = "initialising system...",
        ConfigurationSaving = { Enabled = false, FolderName = "SENTENCE", FileName = "config" },
    }, cfg)

    -- ── Responsive sizing (+12% from original) ────────────────────────────────
    local vp = Cam.ViewportSize
    local WW = math.clamp(vp.X - 100, 627, 829)   -- was 560–740, +12%
    local WH = math.clamp(vp.Y - 90,  448, 549)   -- was 400–490, +12%

    local SB_W  = 190     -- sidebar width
    local TBar_H = 48     -- title bar height

    local FULL = UDim2.fromOffset(WW, WH)
    local MINI = UDim2.fromOffset(SB_W + 2, TBar_H)

    -- ── ScreenGui ─────────────────────────────────────────────────────────────
    local gui = Instance.new("ScreenGui")
    gui.Name = "SentenceV3"; gui.DisplayOrder = 999999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true

    if gethui then gui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = CG
    elseif not Studio then gui.Parent = CG
    else gui.Parent = LP:WaitForChild("PlayerGui") end

    -- ── Notification bin ──────────────────────────────────────────────────────
    local notifBin = Instance.new("Frame")
    notifBin.Name = "NB"; notifBin.Size = UDim2.new(0, 300, 1, -16)
    notifBin.Position = UDim2.new(1, -308, 0, 8)
    notifBin.BackgroundTransparency = 1; notifBin.ZIndex = 200; notifBin.Parent = gui
    local nbl = LL(notifBin, 6)
    nbl.VerticalAlignment = Enum.VerticalAlignment.Bottom
    self._notifBin = notifBin

    -- ══════════════════════════════════════════════════════════════════════════
    -- MAIN WINDOW
    -- ══════════════════════════════════════════════════════════════════════════
    local win = F({ Name = "Win",
        Sz = UDim2.fromOffset(0, 0),
        Pos = UDim2.new(0.5, 0, 0.5, 0), AP = Vector2.new(0.5, 0.5),
        Bg = P.abyss, BgA = 0, Clip = true,
        R = 12, S = true, SC = P.wire, SA = 0.3,
        Z = 1, Par = gui })

    -- Subtle outer glow layer (decorative frame inside)
    local outerGlow = F({ Name = "OGlow",
        Sz = UDim2.new(1, -2, 1, -2), Pos = UDim2.new(0, 1, 0, 1),
        Bg = P.void, BgA = 1, R = 11, Z = 0, Par = win })

    -- Atmospheric gradient: cyan tint top-left, violet tint bottom-right
    local atmoTL = F({ Sz = UDim2.new(0.5, 0, 0.4, 0), Pos = UDim2.new(0, 0, 0, 0),
        Bg = P.cyanDD, BgA = 0.5, R = 12, Z = 0, Par = win })
    GradH(atmoTL, P.cyan, P.abyss, 0.82, 1)

    local atmoBR = F({ Sz = UDim2.new(0.5, 0, 0.4, 0), Pos = UDim2.new(1, 0, 1, 0), AP = Vector2.new(1, 1),
        Bg = P.violetDD, BgA = 0.6, R = 12, Z = 0, Par = win })
    GradH(atmoBR, P.violet, P.abyss, 0.85, 1)

    -- Cyan top hairline
    local topLine = F({ Sz = UDim2.new(1, 0, 0, 1), Bg = P.cyan, BgA = 1, R = false, Z = 8, Par = win })
    tw(topLine, { BackgroundTransparency = 0.4 }, TI_SLOW)

    -- ── Title bar ─────────────────────────────────────────────────────────────
    local titleBar = F({ Name = "TB", Sz = UDim2.new(1, 0, 0, TBar_H),
        Bg = P.void, BgA = 0, Z = 5, Par = win })
    Drag(titleBar, win)

    -- Window control buttons
    local function WCtrl(name, col, xPos)
        local btn = F({ Name = name, Sz = UDim2.new(0, 14, 0, 14),
            Pos = UDim2.new(0, xPos, 0.5, 0), AP = Vector2.new(0, 0.5),
            Bg = col, R = UDim.new(1, 0), Z = 7, Par = titleBar })
        btn.BackgroundTransparency = 0.3
        local cl = CL(btn, 9)
        btn.MouseEnter:Connect(function() tw(btn, { BackgroundTransparency = 0 }, TI_FAST) end)
        btn.MouseLeave:Connect(function() tw(btn, { BackgroundTransparency = 0.3 }, TI_FAST) end)
        return btn, cl
    end

    local closeBtn, closeCL = WCtrl("Close", P.err,     14)
    local minBtn,   minCL   = WCtrl("Min",   P.warn,    34)
    local hideBtn,  hideCL  = WCtrl("Hide",  P.ok,      54)

    -- Logo
    local logoImg = I({ Ico = cfg.Icon, Sz = UDim2.new(0, 22, 0, 22),
        Pos = UDim2.new(0, 80, 0.5, 0), AP = Vector2.new(0, 0.5),
        IA = 1, Z = 6, Par = titleBar })

    -- Window name
    local nameL = T({ Txt = cfg.Name,
        Sz = UDim2.new(0, 220, 0, 17), Pos = UDim2.new(0, 108, 0, 7),
        Font = Enum.Font.GothamBold, TS = 15, Col = P.hi, TA = 1, Z = 6, Par = titleBar })
    local subL = T({ Txt = cfg.Subtitle,
        Sz = UDim2.new(0, 220, 0, 12), Pos = UDim2.new(0, 108, 0, 27),
        Font = Enum.Font.Gotham, TS = 10, Col = P.cyan, TA = 1, Z = 6, Par = titleBar })

    -- Version badge (right)
    local verBadge = F({ Sz = UDim2.new(0, 0, 0, 16), Pos = UDim2.new(1, -10, 0.5, 0),
        AP = Vector2.new(1, 0.5), Bg = P.cyanDD, R = 4, Z = 6, Par = titleBar })
    verBadge.AutomaticSize = Enum.AutomaticSize.X
    PD(verBadge, 0, 0, 6, 6)
    T({ Txt = "v"..Sentence.Version, Sz = UDim2.new(0, 0, 1, 0),
        Font = Enum.Font.GothamBold, TS = 9, Col = P.cyan, Z = 7, Par = verBadge }).AutomaticSize = Enum.AutomaticSize.X

    -- Hairline under title bar
    local tbSep = F({ Sz = UDim2.new(1, 0, 0, 1), Pos = UDim2.new(0, 0, 1, -1),
        Bg = P.wire, BgA = 0.5, R = false, Z = 6, Par = titleBar })

    -- ── Sidebar ───────────────────────────────────────────────────────────────
    local sidebar = F({ Name = "Sidebar",
        Sz = UDim2.new(0, SB_W, 1, -TBar_H), Pos = UDim2.new(0, 0, 0, TBar_H),
        Bg = P.deep, BgA = 0, Z = 3, Par = win })

    -- Right separator line
    local sbSep = F({ Sz = UDim2.new(0, 1, 1, 0), Pos = UDim2.new(1, 0, 0, 0),
        Bg = P.wire, BgA = 0.45, R = false, Z = 4, Par = sidebar })

    -- Tab list container (scrollable)
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.Size = UDim2.new(1, -1, 1, -8)
    tabList.Position = UDim2.new(0, 0, 0, 8)
    tabList.BackgroundTransparency = 1; tabList.BorderSizePixel = 0
    tabList.ScrollBarThickness = 2; tabList.ScrollBarImageColor3 = P.wire
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0); tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.ZIndex = 4; tabList.Parent = sidebar
    LL(tabList, 2); PD(tabList, 4, 4, 8, 8)

    -- Sidebar header label
    local sbHeader = T({ Txt = "NAVIGATION",
        Sz = UDim2.new(1, 0, 0, 12), Pos = UDim2.new(0, 0, 0, 0),
        Font = Enum.Font.GothamBold, TS = 9, Col = P.dim,
        AX = Enum.TextXAlignment.Left, Z = 5, Par = tabList, Ord = 0 })

    -- Active tab indicator (left bar that slides)
    local tabIndicator = F({ Name = "TInd",
        Sz = UDim2.new(0, 3, 0, 28), Pos = UDim2.new(0, 0, 0, 50),
        Bg = P.cyan, R = UDim.new(1, 0), Z = 6, Par = sidebar })
    tabIndicator.BackgroundTransparency = 1

    -- ── Content area ──────────────────────────────────────────────────────────
    local contentArea = F({ Name = "CA",
        Sz = UDim2.new(1, -SB_W - 1, 1, -TBar_H),
        Pos = UDim2.new(0, SB_W + 1, 0, TBar_H),
        Bg = P.void, BgA = 1, Clip = true, Z = 2, Par = win })

    -- ══════════════════════════════════════════════════════════════════════════
    -- SPLASH SCREEN — full VOID MATRIX boot sequence
    -- ══════════════════════════════════════════════════════════════════════════
    local function RunSplash()
        -- Full-cover overlay
        local sf = F({ Name = "Splash", Sz = UDim2.new(1, 0, 1, 0),
            Bg = P.void, BgA = 0, Z = 100, Par = win })
        Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 12)

        -- Animated scan-line
        local scanLine = F({ Sz = UDim2.new(1, 0, 0, 2), Pos = UDim2.new(0, 0, 0, 0),
            Bg = P.cyan, BgA = 0.75, R = false, Z = 102, Par = sf })
        GradH(scanLine, Color3.new(0, 0, 0), P.cyan, 1, 0.3)

        -- Grid lines (subtle)
        for i = 1, 6 do
            local gl = F({ Sz = UDim2.new(1, 0, 0, 1), Pos = UDim2.new(0, 0, i/7, 0),
                Bg = P.cyan, BgA = 0.93, R = false, Z = 101, Par = sf })
        end
        for i = 1, 8 do
            local gl = F({ Sz = UDim2.new(0, 1, 1, 0), Pos = UDim2.new(i/9, 0, 0, 0),
                Bg = P.cyan, BgA = 0.93, R = false, Z = 101, Par = sf })
        end

        -- Corner decorations (4 corners)
        local cornerSize = UDim2.fromOffset(20, 20)
        local corners = {
            { UDim2.new(0, 2, 0, 2),   Vector2.zero         },
            { UDim2.new(1, -22, 0, 2), Vector2.new(0, 0)    },
            { UDim2.new(0, 2, 1, -22), Vector2.new(0, 0)    },
            { UDim2.new(1,-22, 1,-22), Vector2.new(0, 0)    },
        }
        for _, cd in ipairs(corners) do
            local cf = F({ Sz = cornerSize, Pos = cd[1], AP = cd[2],
                Bg = P.cyan, BgA = 0.5, R = false, Z = 103, Par = sf })
        end

        -- Central logo icon
        local logoC = I({ Ico = cfg.Icon,
            Sz = UDim2.new(0, 0, 0, 0),
            Pos = UDim2.new(0.5, 0, 0.42, 0), AP = Vector2.new(0.5, 0.5),
            IA = 1, Z = 104, Par = sf })

        -- Glow ring behind logo
        local logoRing = F({ Sz = UDim2.new(0, 0, 0, 0),
            Pos = UDim2.new(0.5, 0, 0.42, 0), AP = Vector2.new(0.5, 0.5),
            Bg = P.cyan, BgA = 1, R = UDim.new(1, 0), Z = 103, Par = sf })

        -- Big title
        local bigTitle = T({ Txt = "",
            Sz = UDim2.new(1, 0, 0, 36), Pos = UDim2.new(0.5, 0, 0.56, 0), AP = Vector2.new(0.5, 0),
            Font = Enum.Font.GothamBold, TS = 32, Col = P.hi, TA = 1,
            AX = Enum.TextXAlignment.Center, Z = 104, Par = sf })

        local subTitle = T({ Txt = cfg.LoadingSubtitle,
            Sz = UDim2.new(1, 0, 0, 14), Pos = UDim2.new(0.5, 0, 0.71, 0), AP = Vector2.new(0.5, 0),
            Font = Enum.Font.Gotham, TS = 11, Col = P.dim, TA = 1,
            AX = Enum.TextXAlignment.Center, Z = 104, Par = sf })

        -- Progress bar
        local pbBg = F({ Sz = UDim2.new(0, 280, 0, 3), Pos = UDim2.new(0.5, 0, 0.81, 0), AP = Vector2.new(0.5, 0),
            Bg = P.surface, BgA = 0, R = UDim.new(1, 0), Z = 104, Par = sf })

        local pbFill = F({ Sz = UDim2.new(0, 0, 1, 0), Pos = UDim2.new(0, 0, 0, 0),
            Bg = P.cyan, R = UDim.new(1, 0), Z = 105, Par = pbBg })
        -- Gradient on fill
        GradH(pbFill, P.violet, P.cyan, 0.2, 0)

        -- Percentage text
        local pctL = T({ Txt = "0%",
            Sz = UDim2.new(0, 80, 0, 12), Pos = UDim2.new(0.5, 0, 0.85, 0), AP = Vector2.new(0.5, 0),
            Font = Enum.Font.GothamBold, TS = 10, Col = P.cyan, TA = 1,
            AX = Enum.TextXAlignment.Center, Z = 104, Par = sf })

        -- STATUS line (terminal-style)
        local statusL = T({ Txt = "> BOOTING...",
            Sz = UDim2.new(0, 280, 0, 12), Pos = UDim2.new(0.5, 0, 0.88, 0), AP = Vector2.new(0.5, 0),
            Font = Enum.Font.Code, TS = 10, Col = P.mid, TA = 1,
            AX = Enum.TextXAlignment.Left, Z = 104, Par = sf })

        -- ── Phase 1: Expand window ─────────────────────────────────────────────
        tw(win, { Size = FULL }, TI_SLOW)
        task.wait(0.3)
        tw(sf, { BackgroundTransparency = 0 }, TI_FAST)
        task.wait(0.15)

        -- Scan line animation
        task.spawn(function()
            while sf and sf.Parent do
                tw(scanLine, { Position = UDim2.new(0, 0, 1, 0) }, ti(1.8, Enum.EasingStyle.Linear))
                task.wait(1.85)
                scanLine.Position = UDim2.new(0, 0, 0, 0)
                task.wait(0.15)
            end
        end)

        -- ── Phase 2: Logo reveal ───────────────────────────────────────────────
        task.wait(0.2)
        tw(logoRing, { Size = UDim2.fromOffset(64, 64), BackgroundTransparency = 0.85 }, TI_SPRING)
        task.wait(0.05)
        tw(logoC, { Size = UDim2.fromOffset(48, 48), ImageTransparency = 0 }, TI_SPRING)
        task.wait(0.1)
        tw(pbBg, { BackgroundTransparency = 0.5 }, TI_MED)

        -- ── Phase 3: Typewriter title ──────────────────────────────────────────
        task.wait(0.2)
        local full = cfg.LoadingTitle
        for i = 1, #full do
            bigTitle.Text = full:sub(1, i) .. "<font color='rgb(0,217,255)'>_</font>"
            task.wait(0.045)
        end
        bigTitle.Text = full
        tw(bigTitle, { TextTransparency = 0 }, TI_MED)
        tw(subTitle,  { TextTransparency = 0.25 }, TI_MED)

        -- ── Phase 4: Progress bar ──────────────────────────────────────────────
        task.wait(0.2)
        local stages = {
            { 0.15, "> LOADING ASSETS..." },
            { 0.35, "> CONNECTING SERVICES..." },
            { 0.55, "> BUILDING INTERFACE..." },
            { 0.75, "> APPLYING STYLES..." },
            { 0.95, "> FINALISING..." },
            { 1.00, "> READY" },
        }
        for _, stage in ipairs(stages) do
            tw(pbFill, { Size = UDim2.new(stage[1], 0, 1, 0) }, ti(0.3, Enum.EasingStyle.Quart))
            pctL.Text = math.floor(stage[1] * 100) .. "%"
            statusL.Text = stage[2]
            task.wait(0.28)
        end
        pctL.Text = "100%"
        task.wait(0.35)

        -- ── Phase 5: Flash + dissolve ──────────────────────────────────────────
        -- White flash
        local flash = F({ Sz = UDim2.new(1, 0, 1, 0), Bg = P.cyan, BgA = 1, R = false, Z = 110, Par = sf })
        tw(flash, { BackgroundTransparency = 0.3 }, ti(0.06))
        task.wait(0.08)
        tw(flash, { BackgroundTransparency = 1 }, ti(0.35), function() flash:Destroy() end)

        -- Dissolve splash
        tw(bigTitle, { TextTransparency = 1 }, TI_FAST)
        tw(subTitle,  { TextTransparency = 1 }, TI_FAST)
        tw(logoC,    { ImageTransparency = 1 }, TI_FAST)
        tw(logoRing, { BackgroundTransparency = 1 }, TI_FAST)
        tw(pbBg,     { BackgroundTransparency = 1 }, TI_FAST)
        tw(pbFill,   { BackgroundTransparency = 1 }, TI_FAST)
        tw(pctL,     { TextTransparency = 1 }, TI_FAST)
        tw(statusL,  { TextTransparency = 1 }, TI_FAST)
        task.wait(0.22)
        tw(sf, { BackgroundTransparency = 1 }, TI_MED, function() sf:Destroy() end)
        task.wait(0.3)
    end

    -- ── Window state ─────────────────────────────────────────────────────────
    local W = {
        _gui       = gui,
        _win       = win,
        _content   = contentArea,
        _tabs      = {},
        _activeTab = nil,
        _tabIndex  = 0,
        _visible   = true,
        _minimized = false,
        _cfg       = cfg,
    }

    gui.Enabled = true
    if cfg.LoadingEnabled then
        RunSplash()
    else
        tw(win, { Size = FULL }, TI_SLOW)
        task.wait(0.45)
    end

    -- Reveal title text after loading
    tw(nameL, { TextTransparency = 0 }, TI_MED)
    tw(subL,  { TextTransparency = 0.2 }, TI_MED)
    tw(logoImg, { ImageTransparency = 0 }, TI_MED)

    -- ── Controls ──────────────────────────────────────────────────────────────
    local function HideW()
        W._visible = false
        tw(win, { Size = UDim2.fromOffset(0, 0) }, TI_SLOW, function() win.Visible = false end)
    end
    local function ShowW()
        win.Visible = true; W._visible = true
        tw(win, { Size = W._minimized and MINI or FULL }, TI_SLOW)
    end

    closeCL.MouseButton1Click:Connect(function() Sentence:Destroy() end)
    hideCL.MouseButton1Click:Connect(function()
        Sentence:Notify({ Title = "Hidden", Content = "Press "..cfg.ToggleBind.Name.." to restore.", Type = "Info" })
        HideW()
    end)
    minCL.MouseButton1Click:Connect(function()
        W._minimized = not W._minimized
        if W._minimized then
            sidebar.Visible = false; contentArea.Visible = false
            tw(win, { Size = MINI }, TI_MED)
        else
            tw(win, { Size = FULL }, TI_MED, function()
                sidebar.Visible = true; contentArea.Visible = true
            end)
        end
    end)
    track(UIS.InputBegan:Connect(function(inp, proc)
        if proc then return end
        if inp.KeyCode == cfg.ToggleBind then
            if W._visible then HideW() else ShowW() end
        end
    end))

    -- ── Indicator helper ─────────────────────────────────────────────────────
    local function MoveIndicator(btn)
        if not btn or not btn.Parent then return end
        task.wait()
        local absY = btn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
        tw(tabIndicator, {
            Position = UDim2.new(0, 0, 0, absY + (btn.AbsoluteSize.Y - 28) / 2),
            Size     = UDim2.new(0, 3, 0, 28),
            BackgroundTransparency = 0,
        }, TI_EASE)
    end

    -- ── Tab page slide transition ─────────────────────────────────────────────
    local function SlideIn(page, fromRight)
        local startX = fromRight and UDim2.new(0, 30, 0, 0) or UDim2.new(0, -30, 0, 0)
        page.Position = startX
        page.BackgroundTransparency = 1
        page.Visible = true
        tw(page, { Position = UDim2.new(0, 0, 0, 0) }, TI_SLIDE)
        -- fade in all immediate text/image children slightly
    end

    local function SlideOut(page, toLeft)
        tw(page, {
            Position = toLeft and UDim2.new(0, -20, 0, 0) or UDim2.new(0, 20, 0, 0)
        }, TI_SLIDE, function() page.Visible = false; page.Position = UDim2.new(0, 0, 0, 0) end)
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- HOME TAB
    -- ══════════════════════════════════════════════════════════════════════════
    function W:CreateHomeTab(hCfg)
        hCfg = def({ Icon = "home" }, hCfg or {})

        -- Tab pill in sidebar
        local hPill = F({ Name = "HomeTab",
            Sz = UDim2.new(1, 0, 0, 34),
            Bg = P.cyanDD, BgA = 0, R = 8, Z = 5, Par = tabList, Ord = 1 })

        -- Subtle fill on active
        local hActiveFill = F({ Sz = UDim2.new(1, 0, 1, 0), Bg = P.cyanDD, BgA = 1, R = 8, Z = 4, Par = hPill })
        GradH(hActiveFill, P.cyan, P.void, 0.85, 1)

        local hIco = I({ Ico = hCfg.Icon, Sz = UDim2.new(0, 16, 0, 16),
            Pos = UDim2.new(0, 12, 0.5, 0), AP = Vector2.new(0, 0.5),
            Col = P.cyan, Z = 6, Par = hPill })
        local hLbl = T({ Txt = "Home",
            Sz = UDim2.new(1, -36, 0, 16), Pos = UDim2.new(0, 34, 0.5, 0), AP = Vector2.new(0, 0.5),
            Font = Enum.Font.GothamSemibold, TS = 13, Col = P.hi, Z = 6, Par = hPill })
        local hCL = CL(hPill, 7)

        -- Home page (scrollable)
        local hPage = Instance.new("ScrollingFrame")
        hPage.Name = "HomePage"; hPage.Size = UDim2.new(1, 0, 1, 0)
        hPage.BackgroundTransparency = 1; hPage.BorderSizePixel = 0
        hPage.ScrollBarThickness = 2; hPage.ScrollBarImageColor3 = P.wireHov
        hPage.CanvasSize = UDim2.new(0, 0, 0, 0); hPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        hPage.ZIndex = 3; hPage.Visible = true; hPage.Parent = contentArea
        LL(hPage, 12); PD(hPage, 20, 20, 18, 18)

        -- ── Player hero card ──────────────────────────────────────────────────
        local heroCard = F({ Name = "Hero",
            Sz = UDim2.new(1, 0, 0, 90),
            Bg = P.panel, BgA = 0, S = true, SC = P.wire, SA = 0.45, R = 10, Z = 3, Par = hPage })

        -- Subtle radial glow
        local heroGlow = F({ Sz = UDim2.new(0.6, 0, 1.5, 0), Pos = UDim2.new(0, 0, 0.5, 0), AP = Vector2.new(0, 0.5),
            Bg = P.cyanDD, BgA = 0.5, R = 10, Z = 2, Par = heroCard })
        GradH(heroGlow, P.cyan, P.panel, 0.8, 1)

        -- Avatar
        local av = Instance.new("ImageLabel")
        av.Size = UDim2.new(0, 56, 0, 56); av.Position = UDim2.new(0, 16, 0.5, 0); av.AnchorPoint = Vector2.new(0, 0.5)
        av.BackgroundTransparency = 1; av.ZIndex = 4; av.Parent = heroCard
        Instance.new("UICorner", av).CornerRadius = UDim.new(0, 8)
        pcall(function()
            av.Image = Plrs:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        local avStroke = Stroke(av, P.cyan, 0.4, 2)

        T({ Txt = LP.DisplayName,
            Sz = UDim2.new(1, -100, 0, 20), Pos = UDim2.new(0, 84, 0, 18),
            Font = Enum.Font.GothamBold, TS = 18, Col = P.hi, Z = 4, Par = heroCard })

        T({ Txt = "<font color='rgb(120,128,168)'>@</font>"..LP.Name,
            Sz = UDim2.new(1, -100, 0, 14), Pos = UDim2.new(0, 84, 0, 42),
            Font = Enum.Font.Gotham, TS = 12, Col = P.mid, Z = 4, Par = heroCard })

        -- Hub name tag
        local htag = F({ Sz = UDim2.new(0, 0, 0, 20), Pos = UDim2.new(0, 84, 0, 60),
            Bg = P.cyanDD, R = 4, Z = 4, Par = heroCard })
        htag.AutomaticSize = Enum.AutomaticSize.X
        PD(htag, 0, 0, 8, 8)
        T({ Txt = cfg.Name, Sz = UDim2.new(0, 0, 1, 0),
            Font = Enum.Font.GothamBold, TS = 9, Col = P.cyan, Z = 5, Par = htag }).AutomaticSize = Enum.AutomaticSize.X

        -- Userid badge
        local uidBadge = F({ Sz = UDim2.new(0, 0, 0, 20), Pos = UDim2.new(1, -12, 0, 12), AP = Vector2.new(1, 0),
            Bg = P.surface, R = 4, Z = 4, Par = heroCard })
        uidBadge.AutomaticSize = Enum.AutomaticSize.X
        PD(uidBadge, 0, 0, 8, 8)
        T({ Txt = "ID: "..LP.UserId, Sz = UDim2.new(0, 0, 1, 0),
            Font = Enum.Font.GothamBold, TS = 9, Col = P.dim, Z = 5, Par = uidBadge }).AutomaticSize = Enum.AutomaticSize.X

        -- ── Stats grid (2x2) ──────────────────────────────────────────────────
        local statsRow = Instance.new("Frame")
        statsRow.Name = "StatsRow"; statsRow.Size = UDim2.new(1, 0, 0, 0)
        statsRow.BackgroundTransparency = 1; statsRow.AutomaticSize = Enum.AutomaticSize.Y
        statsRow.BorderSizePixel = 0; statsRow.ZIndex = 3; statsRow.Parent = hPage
        local sgLL = Instance.new("UIGridLayout")
        sgLL.CellSize = UDim2.new(0.5, -4, 0, 56)
        sgLL.CellPadding = UDim2.new(0, 8, 0, 8)
        sgLL.SortOrder = Enum.SortOrder.LayoutOrder
        sgLL.Parent = statsRow

        local sVals = {}
        local sData = {
            { "Players",  "—",   "person", P.ok    },
            { "Ping",     "—ms", "flash",  P.cyan  },
            { "Uptime",   "—",   "set",    P.warn  },
            { "Region",   "—",   "star",   P.violet },
        }
        for i, sd in ipairs(sData) do
            local sc = F({ Name = "S_"..sd[1], Sz = UDim2.new(1, 0, 1, 0),
                Bg = P.panel, BgA = 0, S = true, SC = P.wire, SA = 0.5, R = 8, Z = 3, Par = statsRow, Ord = i })

            -- Accent line left
            F({ Sz = UDim2.new(0, 3, 0.65, 0), Pos = UDim2.new(0, 0, 0.175, 0),
                Bg = sd[4], R = UDim.new(1, 0), Z = 4, Par = sc })

            I({ Ico = sd[3], Sz = UDim2.new(0, 14, 0, 14),
                Pos = UDim2.new(0, 14, 0, 10), AP = Vector2.zero,
                Col = sd[4], IA = 0, Z = 4, Par = sc })

            T({ Txt = sd[1]:upper(), Sz = UDim2.new(1, -12, 0, 10),
                Pos = UDim2.new(0, 12, 0, 10), Font = Enum.Font.GothamBold, TS = 9, Col = P.dim, Z = 4, Par = sc })

            sVals[sd[1]] = T({ Txt = sd[2], Sz = UDim2.new(1, -12, 0, 20),
                Pos = UDim2.new(0, 12, 0, 26), Font = Enum.Font.GothamBold, TS = 17, Col = P.hi, Z = 4, Par = sc })
        end

        task.spawn(function()
            while task.wait(1) do
                if not win or not win.Parent then break end
                pcall(function()
                    sVals["Players"].Text = #Plrs:GetPlayers().."/"..Plrs.MaxPlayers
                    sVals["Ping"].Text    = math.floor(LP:GetNetworkPing() * 1000).."ms"
                    local t = math.floor(time())
                    sVals["Uptime"].Text  = string.format("%02d:%02d:%02d",
                        math.floor(t/3600), math.floor(t%3600/60), t%60)
                    pcall(function()
                        sVals["Region"].Text = game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(LP)
                    end)
                end)
            end
        end)

        -- ── About card ────────────────────────────────────────────────────────
        local aboutCard = F({ Name = "About",
            Sz = UDim2.new(1, 0, 0, 0),
            Bg = P.panel, BgA = 0, S = true, SC = P.wire, SA = 0.5, R = 10, AS = true, Z = 3, Par = hPage })
        PD(aboutCard, 12, 14, 14, 14); LL(aboutCard, 5)

        -- Header row
        local aboutHdr = F({ Sz = UDim2.new(1, 0, 0, 18), BgA = 1, Z = 3, Par = aboutCard })
        T({ Txt = "<font color='rgb(0,217,255)'>◆</font>  ABOUT",
            Sz = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBold, TS = 10, Col = P.mid, Z = 4, Par = aboutHdr })

        T({ Txt = cfg.Name.." — v"..Sentence.Version,
            Sz = UDim2.new(1, 0, 0, 16), Font = Enum.Font.GothamBold, TS = 14, Col = P.hi, Z = 4, Par = aboutCard })
        T({ Txt = "Press <b>"..cfg.ToggleBind.Name.."</b> to toggle visibility. "..
                   "Drag the title bar to reposition the window.",
            Sz = UDim2.new(1, 0, 0, 0), Font = Enum.Font.Gotham, TS = 11, Col = P.mid,
            Wrap = true, AS = true, Z = 4, Par = aboutCard })

        -- Activate
        local function activateHome()
            for _, td in ipairs(W._tabs) do
                if td.page.Visible then
                    SlideOut(td.page, true)
                end
                tw(td.btn:FindFirstChildOfClass("ImageLabel") or Instance.new("ImageLabel"),
                    { ImageColor3 = P.mid }, TI_FAST)
                local lb = td.btn:FindFirstChildOfClass("TextLabel")
                if lb then tw(lb, { TextColor3 = P.mid }, TI_FAST) end
                local af = td.btn:FindFirstChild("ActiveFill")
                if af then tw(af, { BackgroundTransparency = 1 }, TI_FAST) end
            end
            hPage.Visible = true
            hPage.Position = UDim2.new(0, 30, 0, 0)
            tw(hPage, { Position = UDim2.new(0, 0, 0, 0) }, TI_SLIDE)
            tw(hIco, { ImageColor3 = P.cyan }, TI_FAST)
            tw(hLbl, { TextColor3 = P.hi }, TI_FAST)
            tw(hActiveFill, { BackgroundTransparency = 0 }, TI_FAST)
            MoveIndicator(hPill)
            W._activeTab = "Home"
            W._tabIndex  = 0
        end
        activateHome()
        hCL.MouseButton1Click:Connect(activateHome)
        hPill.MouseEnter:Connect(function()
            if W._activeTab ~= "Home" then tw(hLbl, { TextColor3 = P.hi }, TI_FAST) end
        end)
        hPill.MouseLeave:Connect(function()
            if W._activeTab ~= "Home" then tw(hLbl, { TextColor3 = P.mid }, TI_FAST) end
        end)
        return { Activate = activateHome }
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- CREATE TAB
    -- ══════════════════════════════════════════════════════════════════════════
    function W:CreateTab(tCfg)
        tCfg = def({ Name = "Tab", Icon = "unk", ShowTitle = true }, tCfg or {})
        local Tab = {}
        local tabIdx = #W._tabs + 1
        local isFirst = #W._tabs == 0

        -- Sidebar pill button
        local pill = F({ Name = tCfg.Name,
            Sz = UDim2.new(1, 0, 0, 34),
            Bg = P.surface, BgA = isFirst and 0 or 0.6,
            R = 8, Z = 5, Par = tabList, Ord = tabIdx + 10 })

        -- Active fill (hidden unless selected)
        local activeFill = F({ Name = "ActiveFill",
            Sz = UDim2.new(1, 0, 1, 0), Bg = P.cyanDD, BgA = isFirst and 0 or 1, R = 8, Z = 4, Par = pill })
        GradH(activeFill, P.cyan, P.void, 0.85, 1)

        local pIco = I({ Ico = tCfg.Icon, Sz = UDim2.new(0, 16, 0, 16),
            Pos = UDim2.new(0, 12, 0.5, 0), AP = Vector2.new(0, 0.5),
            Col = isFirst and P.cyan or P.mid, Z = 6, Par = pill })
        local pLbl = T({ Txt = tCfg.Name,
            Sz = UDim2.new(1, -36, 0, 16), Pos = UDim2.new(0, 34, 0.5, 0), AP = Vector2.new(0, 0.5),
            Font = Enum.Font.GothamSemibold, TS = 13, Col = isFirst and P.hi or P.mid, Z = 6, Par = pill })
        local pCL = CL(pill, 7)

        -- Tab page (scrollable)
        local tPage = Instance.new("ScrollingFrame")
        tPage.Name = tCfg.Name; tPage.Size = UDim2.new(1, 0, 1, 0)
        tPage.BackgroundTransparency = 1; tPage.BorderSizePixel = 0
        tPage.ScrollBarThickness = 2; tPage.ScrollBarImageColor3 = P.wireHov
        tPage.CanvasSize = UDim2.new(0, 0, 0, 0); tPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tPage.ZIndex = 3; tPage.Visible = isFirst; tPage.Parent = contentArea
        LL(tPage, 8); PD(tPage, 18, 18, 16, 16)

        -- Page title area
        if tCfg.ShowTitle then
            local titleRow = F({ Name = "TitleRow", Sz = UDim2.new(1, 0, 0, 36),
                Bg = P.panel, BgA = 0, R = 8, Z = 3, Par = tPage })

            -- Left cyan accent
            F({ Sz = UDim2.new(0, 3, 0.6, 0), Pos = UDim2.new(0, 0, 0.2, 0),
                Bg = P.cyan, R = UDim.new(1, 0), Z = 4, Par = titleRow })

            T({ Txt = tCfg.Name,
                Sz = UDim2.new(1, -20, 0, 20), Pos = UDim2.new(0, 14, 0.5, 0), AP = Vector2.new(0, 0.5),
                Font = Enum.Font.GothamBold, TS = 18, Col = P.hi, Z = 4, Par = titleRow })

            -- Cyan number badge
            local nbadge = F({ Sz = UDim2.new(0, 0, 0, 16), Pos = UDim2.new(1, -10, 0.5, 0), AP = Vector2.new(1, 0.5),
                Bg = P.cyanDD, R = 4, Z = 4, Par = titleRow })
            nbadge.AutomaticSize = Enum.AutomaticSize.X
            PD(nbadge, 0, 0, 6, 6)
            T({ Txt = string.format("%02d", tabIdx), Sz = UDim2.new(0, 0, 1, 0),
                Font = Enum.Font.GothamBold, TS = 9, Col = P.cyan, Z = 5, Par = nbadge }).AutomaticSize = Enum.AutomaticSize.X
        end

        table.insert(W._tabs, { btn = pill, page = tPage, name = tCfg.Name, idx = tabIdx })
        if isFirst then
            W._activeTab = tCfg.Name; W._tabIndex = tabIdx
            task.delay(0.1, function() MoveIndicator(pill) end)
        end

        -- ── Activate ──────────────────────────────────────────────────────────
        function Tab:Activate()
            local prev = W._tabIndex
            for _, td in ipairs(W._tabs) do
                if td.page.Visible and td.name ~= tCfg.Name then
                    SlideOut(td.page, td.idx < tabIdx)
                end
                local ic = td.btn:FindFirstChildOfClass("ImageLabel")
                local lb = td.btn:FindFirstChildOfClass("TextLabel")
                local af = td.btn:FindFirstChild("ActiveFill")
                if ic then tw(ic, { ImageColor3 = P.mid }, TI_FAST) end
                if lb then tw(lb, { TextColor3 = P.mid }, TI_FAST) end
                if af then tw(af, { BackgroundTransparency = 1 }, TI_FAST) end
            end
            local hp = contentArea:FindFirstChild("HomePage")
            if hp and hp.Visible then SlideOut(hp, true) end
            local hT = tabList:FindFirstChild("HomeTab")
            if hT then
                local hi = hT:FindFirstChildOfClass("ImageLabel")
                local hl = hT:FindFirstChildOfClass("TextLabel")
                if hi then tw(hi, { ImageColor3 = P.mid }, TI_FAST) end
                if hl then tw(hl, { TextColor3 = P.mid }, TI_FAST) end
                local haf = hT:FindFirstChild("ActiveFill")
                if haf then tw(haf, { BackgroundTransparency = 1 }, TI_FAST) end
            end

            -- Slide in from appropriate direction
            tPage.Visible = false
            SlideIn(tPage, prev and (type(prev) == "number" and prev <= tabIdx))

            tw(pIco,      { ImageColor3 = P.cyan }, TI_FAST)
            tw(pLbl,      { TextColor3 = P.hi },    TI_FAST)
            tw(activeFill, { BackgroundTransparency = 0 }, TI_FAST)
            MoveIndicator(pill)
            W._activeTab = tCfg.Name
            W._tabIndex  = tabIdx
        end

        pCL.MouseButton1Click:Connect(function() Tab:Activate() end)
        pill.MouseEnter:Connect(function()
            if W._activeTab ~= tCfg.Name then tw(pLbl, { TextColor3 = P.hi }, TI_FAST) end
        end)
        pill.MouseLeave:Connect(function()
            if W._activeTab ~= tCfg.Name then tw(pLbl, { TextColor3 = P.mid }, TI_FAST) end
        end)

        -- ════════════════════════════════════════════════════════════════════
        -- CREATE SECTION
        -- ════════════════════════════════════════════════════════════════════
        local _secCount = 0

        function Tab:CreateSection(sName)
            sName = sName or ""
            _secCount = _secCount + 1
            local Sec = {}

            -- Section header
            local shRow = F({ Name = "SH_"..sName,
                Sz = UDim2.new(1, 0, 0, sName ~= "" and 26 or 1),
                BgA = 1, Z = 3, Par = tPage, Ord = #tPage:GetChildren() })

            if sName ~= "" then
                -- Cyan dot + name
                local numStr = string.format("%02d", _secCount)
                T({ Txt = "<font color='rgb(0,217,255)'>"..numStr.." //</font>  "..sName:upper(),
                    Sz = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold, TS = 10, Col = P.mid, Z = 4, Par = shRow })
                -- Hairline at bottom
                F({ Sz = UDim2.new(1, 0, 0, 1), Pos = UDim2.new(0, 0, 1, 0),
                    Bg = P.wire, BgA = 0.5, R = false, Z = 3, Par = shRow })
            else
                F({ Sz = UDim2.new(1, 0, 0, 1), Pos = UDim2.new(0, 0, 0.5, 0),
                    Bg = P.wire, BgA = 0.65, R = false, Z = 3, Par = shRow })
            end

            local secCon = F({ Name = "SC_"..sName,
                Sz = UDim2.new(1, 0, 0, 0), BgA = 1, Z = 3, AS = true,
                Ord = shRow.LayoutOrder + 1, Par = tPage })
            LL(secCon, 5)

            -- ── Shared element helpers ────────────────────────────────────────
            local function Elem(h, as)
                local f = F({ Sz = UDim2.new(1, 0, 0, h),
                    Bg = P.panel, BgA = 0,
                    S = true, SC = P.wire, SA = 0.5, R = 8, Z = 3, Par = secCon })
                if as then f.AutomaticSize = Enum.AutomaticSize.Y end
                return f
            end

            local function HoverElem(f)
                f.MouseEnter:Connect(function()
                    tw(f, { BackgroundTransparency = 0 }, TI_FAST)
                    local s = f:FindFirstChildOfClass("UIStroke")
                    if s then tw(s, { Color = P.wireHov, Transparency = 0.25 }, TI_FAST) end
                end)
                f.MouseLeave:Connect(function()
                    tw(f, { BackgroundTransparency = 0 }, TI_FAST)
                    local s = f:FindFirstChildOfClass("UIStroke")
                    if s then tw(s, { Color = P.wire, Transparency = 0.5 }, TI_FAST) end
                end)
            end

            -- ── DIVIDER ───────────────────────────────────────────────────────
            function Sec:CreateDivider()
                local d = F({ Sz = UDim2.new(1, 0, 0, 1), Bg = P.wire, BgA = 0.5, R = false, Z = 3, Par = secCon })
                local DV = {}; function DV:Destroy() d:Destroy() end; return DV
            end

            -- ── LABEL ─────────────────────────────────────────────────────────
            function Sec:CreateLabel(lc)
                lc = def({ Text = "Label", Style = 1 }, lc or {})
                local cMap  = { [1] = P.mid, [2] = P.info, [3] = P.warn }
                local bgMap = { [1] = P.panel, [2] = Color3.fromRGB(8, 24, 48), [3] = Color3.fromRGB(44, 32, 8) }
                local f = Elem(30)
                f.BackgroundColor3 = bgMap[lc.Style]
                if lc.Style > 1 then
                    F({ Sz = UDim2.new(0, 3, 0.65, 0), Pos = UDim2.new(0, 6, 0.175, 0),
                        Bg = cMap[lc.Style], R = UDim.new(1, 0), Z = 4, Par = f })
                end
                local xo = lc.Style > 1 and 18 or 12
                local lb = T({ Txt = lc.Text, Sz = UDim2.new(1, -xo - 6, 0, 14),
                    Pos = UDim2.new(0, xo, 0.5, 0), AP = Vector2.new(0, 0.5),
                    Font = Enum.Font.GothamSemibold, TS = 12, Col = cMap[lc.Style], Z = 4, Par = f })
                local LV = {}
                function LV:Set(t) lb.Text = t end
                function LV:Destroy() f:Destroy() end
                return LV
            end

            -- ── PARAGRAPH ─────────────────────────────────────────────────────
            function Sec:CreateParagraph(pc)
                pc = def({ Title = "Title", Content = "" }, pc or {})
                local f = Elem(0, true)
                PD(f, 12, 12, 14, 14); LL(f, 5)

                -- Cyan accent line left
                F({ Sz = UDim2.new(0, 3, 1, -20), Pos = UDim2.new(0, 0, 0, 10),
                    Bg = P.cyan, R = UDim.new(1, 0), Z = 4, Par = f })

                local pt = T({ Txt = pc.Title, Sz = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.GothamBold, TS = 13, Col = P.hi, Z = 4, Par = f })
                local pcont = T({ Txt = pc.Content, Sz = UDim2.new(1, 0, 0, 0),
                    Font = Enum.Font.Gotham, TS = 12, Col = P.mid, Wrap = true, Z = 4, AS = true, Par = f })
                local PV = {}
                function PV:Set(s)
                    if s.Title   then pt.Text    = s.Title   end
                    if s.Content then pcont.Text = s.Content end
                end
                function PV:Destroy() f:Destroy() end
                return PV
            end

            -- ── BUTTON ────────────────────────────────────────────────────────
            function Sec:CreateButton(bc)
                bc = def({ Name = "Button", Description = nil, Callback = function() end }, bc or {})
                local h = bc.Description and 52 or 36
                local f = Elem(h); f.ClipsDescendants = true

                -- Slide fill from left
                local fillBg = F({ Name = "Fill", Sz = UDim2.new(0, 0, 1, 0),
                    Bg = P.raised, R = 8, Z = 3, Par = f })
                GradH(fillBg, P.cyan, P.void, 0.9, 1)

                T({ Txt = bc.Name,
                    Sz = UDim2.new(1, -46, 0, 16),
                    Pos = UDim2.new(0, 14, 0, bc.Description and 9 or 11),
                    Font = Enum.Font.GothamSemibold, TS = 13, Col = P.hi, Z = 4, Par = f })
                if bc.Description then
                    T({ Txt = bc.Description,
                        Sz = UDim2.new(1, -46, 0, 13),
                        Pos = UDim2.new(0, 14, 0, 28),
                        Font = Enum.Font.Gotham, TS = 11, Col = P.mid, Z = 4, Par = f })
                end
                -- Cyan arrow indicator right
                I({ Ico = "arr", Sz = UDim2.new(0, 12, 0, 12),
                    Pos = UDim2.new(1, -22, 0.5, 0), AP = Vector2.new(0, 0.5),
                    Col = P.cyan, IA = 0.4, Z = 5, Par = f })

                local cl = CL(f, 6)
                f.MouseEnter:Connect(function()
                    tw(fillBg, { Size = UDim2.new(1, 0, 1, 0) }, TI_MED)
                    local s = f:FindFirstChildOfClass("UIStroke")
                    if s then tw(s, { Color = P.wireSel, Transparency = 0.2 }, TI_FAST) end
                end)
                f.MouseLeave:Connect(function()
                    tw(fillBg, { Size = UDim2.new(0, 0, 1, 0) }, TI_MED)
                    local s = f:FindFirstChildOfClass("UIStroke")
                    if s then tw(s, { Color = P.wire, Transparency = 0.5 }, TI_FAST) end
                end)
                cl.MouseButton1Click:Connect(function()
                    tw(f, { BackgroundColor3 = P.cyanDD }, TI_SNAP)
                    task.wait(0.1)
                    tw(f, { BackgroundColor3 = P.panel }, TI_MED)
                    safe(bc.Callback)
                end)
                local BV = { Settings = bc }
                function BV:Set(s) bc = def(bc, s or {}) end
                function BV:Destroy() f:Destroy() end
                return BV
            end

            -- ── TOGGLE ────────────────────────────────────────────────────────
            function Sec:CreateToggle(tc)
                tc = def({ Name = "Toggle", Description = nil, CurrentValue = false, Flag = nil, Callback = function() end }, tc or {})
                local h = tc.Description and 52 or 36
                local f = Elem(h)

                T({ Txt = tc.Name,
                    Sz = UDim2.new(1, -62, 0, 16),
                    Pos = UDim2.new(0, 14, 0, tc.Description and 9 or 11),
                    Font = Enum.Font.GothamSemibold, TS = 13, Col = P.hi, Z = 4, Par = f })
                if tc.Description then
                    T({ Txt = tc.Description,
                        Sz = UDim2.new(1, -62, 0, 13), Pos = UDim2.new(0, 14, 0, 28),
                        Font = Enum.Font.Gotham, TS = 11, Col = P.mid, Z = 4, Par = f })
                end

                -- Track
                local trk = F({ Sz = UDim2.new(0, 42, 0, 22), Pos = UDim2.new(1, -52, 0.5, 0),
                    AP = Vector2.new(0, 0.5), Bg = P.raised, R = UDim.new(1, 0), Z = 4, Par = f })
                Stroke(trk, P.wire, 0.35)

                local knob = F({ Sz = UDim2.new(0, 16, 0, 16), Pos = UDim2.new(0, 3, 0.5, 0),
                    AP = Vector2.new(0, 0.5), Bg = P.mid, R = UDim.new(1, 0), Z = 5, Par = trk })

                local TV = { CurrentValue = tc.CurrentValue, Type = "Toggle", Settings = tc }
                local function upd()
                    if TV.CurrentValue then
                        tw(trk,  { BackgroundColor3 = P.cyanDD }, TI_MED)
                        tw(trk:FindFirstChildOfClass("UIStroke"), { Color = P.cyan, Transparency = 0.4 }, TI_MED)
                        tw(knob, { Position = UDim2.new(0, 23, 0.5, 0), BackgroundColor3 = P.cyan }, TI_SPRING)
                    else
                        tw(trk,  { BackgroundColor3 = P.raised }, TI_MED)
                        tw(trk:FindFirstChildOfClass("UIStroke"), { Color = P.wire, Transparency = 0.35 }, TI_MED)
                        tw(knob, { Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = P.mid }, TI_SPRING)
                    end
                end
                upd()
                HoverElem(f)
                CL(f, 5).MouseButton1Click:Connect(function()
                    TV.CurrentValue = not TV.CurrentValue; upd(); safe(tc.Callback, TV.CurrentValue)
                end)
                function TV:Set(v)   TV.CurrentValue = v; upd(); safe(tc.Callback, v) end
                function TV:Destroy() f:Destroy() end
                if tc.Flag then Sentence.Flags[tc.Flag] = TV; Sentence.Options[tc.Flag] = TV end
                return TV
            end

            -- ── SLIDER ────────────────────────────────────────────────────────
            function Sec:CreateSlider(sc)
                sc = def({ Name = "Slider", Range = {0, 100}, Increment = 1, CurrentValue = 50,
                    Suffix = "", Flag = nil, Callback = function() end }, sc or {})
                local f = Elem(54)

                -- Value label (right, cyan)
                local valL = T({ Txt = tostring(sc.CurrentValue)..sc.Suffix,
                    Sz = UDim2.new(0, 90, 0, 16), Pos = UDim2.new(1, -14, 0, 9), AP = Vector2.new(1, 0),
                    Font = Enum.Font.GothamBold, TS = 13, Col = P.cyan,
                    AX = Enum.TextXAlignment.Right, Z = 4, Par = f })
                T({ Txt = sc.Name,
                    Sz = UDim2.new(1, -105, 0, 16), Pos = UDim2.new(0, 14, 0, 9),
                    Font = Enum.Font.GothamSemibold, TS = 13, Col = P.hi, Z = 4, Par = f })

                -- Track (pill)
                local barBg = F({ Sz = UDim2.new(1, -28, 0, 5), Pos = UDim2.new(0, 14, 0, 38),
                    Bg = P.raised, BgA = 0, R = UDim.new(1, 0), Z = 4, Par = f })
                local fillF = F({ Sz = UDim2.new(0, 0, 1, 0), Bg = P.cyan, R = UDim.new(1, 0), Z = 5, Par = barBg })
                GradH(fillF, P.violet, P.cyan, 0.3, 0)

                -- Thumb
                local thumb = F({ Sz = UDim2.new(0, 12, 0, 12), Pos = UDim2.new(0, 0, 0.5, 0), AP = Vector2.new(0.5, 0.5),
                    Bg = P.cyan, R = UDim.new(1, 0), Z = 6, Par = barBg })
                Stroke(thumb, P.void, 0, 2)

                local SV = { CurrentValue = sc.CurrentValue, Type = "Slider", Settings = sc }
                local mn, mx, inc = sc.Range[1], sc.Range[2], sc.Increment

                local function setV(v)
                    v = math.clamp(v, mn, mx)
                    v = math.floor(v / inc + 0.5) * inc
                    v = tonumber(string.format("%.10g", v))
                    SV.CurrentValue = v
                    valL.Text = tostring(v)..sc.Suffix
                    local pct = (v - mn) / (mx - mn)
                    tw(fillF,  { Size = UDim2.new(pct, 0, 1, 0) }, TI_FAST)
                    tw(thumb,  { Position = UDim2.new(pct, 0, 0.5, 0) }, TI_FAST)
                end
                setV(sc.CurrentValue)

                local drag = false
                local bCL  = CL(barBg, 7)
                local function fromInp(i)
                    local rel = math.clamp((i.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    setV(mn + (mx - mn) * rel); safe(sc.Callback, SV.CurrentValue)
                end
                bCL.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        drag = true; fromInp(i)
                    end
                end)
                bCL.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        drag = false
                    end
                end)
                track(UIS.InputChanged:Connect(function(i)
                    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        fromInp(i)
                    end
                end))
                HoverElem(f)
                function SV:Set(v)   setV(v); safe(sc.Callback, SV.CurrentValue) end
                function SV:Destroy() f:Destroy() end
                if sc.Flag then Sentence.Flags[sc.Flag] = SV; Sentence.Options[sc.Flag] = SV end
                return SV
            end

            -- ── DROPDOWN ──────────────────────────────────────────────────────
            function Sec:CreateDropdown(dc)
                dc = def({ Name = "Dropdown", Description = nil, Options = {}, CurrentOption = nil,
                    MultipleOptions = false, SpecialType = nil, Flag = nil, Callback = function() end }, dc or {})
                if dc.SpecialType == "Player" then
                    dc.Options = {}
                    for _, p in ipairs(Plrs:GetPlayers()) do table.insert(dc.Options, p.Name) end
                end
                if type(dc.CurrentOption) == "string" then dc.CurrentOption = { dc.CurrentOption } end
                dc.CurrentOption = dc.CurrentOption or { dc.Options[1] or "" }

                local cH = dc.Description and 52 or 36
                local f = Elem(cH); f.ClipsDescendants = true

                T({ Txt = dc.Name,
                    Sz = UDim2.new(1, -80, 0, 16),
                    Pos = UDim2.new(0, 14, 0, dc.Description and 9 or 11),
                    Font = Enum.Font.GothamSemibold, TS = 13, Col = P.hi, Z = 4, Par = f })
                if dc.Description then
                    T({ Txt = dc.Description, Sz = UDim2.new(1, -80, 0, 13), Pos = UDim2.new(0, 14, 0, 28),
                        Font = Enum.Font.Gotham, TS = 11, Col = P.mid, Z = 4, Par = f })
                end
                local selL = T({ Txt = table.concat(dc.CurrentOption, ", "),
                    Sz = UDim2.new(0, 100, 0, 14),
                    Pos = UDim2.new(1, -52, 0, dc.Description and 11 or 12), AP = Vector2.new(1, 0),
                    Font = Enum.Font.Gotham, TS = 11, Col = P.dim,
                    AX = Enum.TextXAlignment.Right, Z = 4, Par = f })
                local arrIco = I({ Ico = "chev_d", Sz = UDim2.new(0, 14, 0, 14),
                    Pos = UDim2.new(1, -24, 0, dc.Description and 12 or 11), Col = P.mid, Z = 5, Par = f })

                -- Option list
                local optList = Instance.new("Frame")
                optList.Size = UDim2.new(1, -12, 0, 0); optList.Position = UDim2.new(0, 6, 0, cH + 5)
                optList.BackgroundTransparency = 1; optList.AutomaticSize = Enum.AutomaticSize.Y
                optList.ZIndex = 4; optList.Parent = f
                LL(optList, 2)

                local opened = false
                local sel = {}
                for _, o in ipairs(dc.CurrentOption) do sel[o] = true end
                local DV = { CurrentOption = dc.CurrentOption, Type = "Dropdown", Settings = dc }

                local function refOpts()
                    for _, c in ipairs(optList:GetChildren()) do
                        if c:IsA("Frame") then c:Destroy() end
                    end
                    for _, o in ipairs(dc.Options) do
                        local isS = sel[o]
                        local of = F({ Sz = UDim2.new(1, 0, 0, 28),
                            Bg = isS and P.surface or P.panel, BgA = isS and 0 or 0.2,
                            S = true, SC = isS and P.wireSel or P.wire, SA = isS and 0.3 or 0.65, R = 6, Z = 5, Par = optList })
                        if isS then
                            F({ Sz = UDim2.new(0, 3, 0.6, 0), Pos = UDim2.new(0, 0, 0.2, 0),
                                Bg = P.cyan, R = UDim.new(1, 0), Z = 6, Par = of })
                        end
                        T({ Txt = o, Sz = UDim2.new(1, -30, 1, 0),
                            Pos = UDim2.new(0, isS and 12 or 10, 0, 0),
                            Font = Enum.Font.Gotham, TS = 12, Col = isS and P.hi or P.mid, Z = 6, Par = of })
                        if isS then
                            T({ Txt = "✓", Sz = UDim2.new(0, 20, 1, 0), Pos = UDim2.new(1, -20, 0, 0),
                                Font = Enum.Font.GothamBold, TS = 11, Col = P.cyan,
                                AX = Enum.TextXAlignment.Right, Z = 6, Par = of })
                        end
                        CL(of, 7).MouseButton1Click:Connect(function()
                            if dc.MultipleOptions then sel[o] = not sel[o]
                            else sel = {}; sel[o] = true; opened = false
                                tw(arrIco, { Rotation = 0 })
                                tw(f, { Size = UDim2.new(1, 0, 0, cH) }, TI_MED)
                            end
                            local s = {}
                            for _, op in ipairs(dc.Options) do if sel[op] then table.insert(s, op) end end
                            dc.CurrentOption = s; DV.CurrentOption = s
                            selL.Text = #s > 0 and table.concat(s, ", ") or "—"
                            refOpts(); safe(dc.Callback, dc.MultipleOptions and s or (s[1] or ""))
                        end)
                    end
                end
                refOpts()

                local hCL2 = Instance.new("TextButton")
                hCL2.Size = UDim2.new(1, 0, 0, cH); hCL2.BackgroundTransparency = 1
                hCL2.Text = ""; hCL2.ZIndex = 8; hCL2.Parent = f
                hCL2.MouseButton1Click:Connect(function()
                    opened = not opened
                    tw(arrIco, { Rotation = opened and 180 or 0 })
                    tw(f, { Size = UDim2.new(1, 0, 0, opened and math.min(cH + 10 + #dc.Options * 30, cH + 170) or cH) }, TI_MED)
                end)
                HoverElem(f)
                function DV:Set(o)
                    if type(o) == "table" then dc.CurrentOption = o else dc.CurrentOption = { o } end
                    sel = {}
                    for _, v in ipairs(dc.CurrentOption) do sel[v] = true end
                    selL.Text = table.concat(dc.CurrentOption, ", "); refOpts()
                end
                function DV:Refresh(o) dc.Options = o; refOpts() end
                function DV:Destroy() f:Destroy() end
                if dc.Flag then Sentence.Flags[dc.Flag] = DV; Sentence.Options[dc.Flag] = DV end
                return DV
            end

            -- ── INPUT ─────────────────────────────────────────────────────────
            function Sec:CreateInput(ic)
                ic = def({ Name = "Input", Description = nil, PlaceholderText = "Type...",
                    CurrentValue = "", RemoveTextAfterFocusLost = false, Numeric = false,
                    MaxCharacters = nil, Enter = false, Flag = nil, Callback = function() end }, ic or {})
                local h = ic.Description and 52 or 36
                local f = Elem(h)

                T({ Txt = ic.Name, Sz = UDim2.new(1, -152, 0, 16),
                    Pos = UDim2.new(0, 14, 0, ic.Description and 9 or 11),
                    Font = Enum.Font.GothamSemibold, TS = 13, Col = P.hi, Z = 4, Par = f })
                if ic.Description then
                    T({ Txt = ic.Description, Sz = UDim2.new(1, -152, 0, 13),
                        Pos = UDim2.new(0, 14, 0, 28), Font = Enum.Font.Gotham, TS = 11, Col = P.mid, Z = 4, Par = f })
                end

                local ib = Instance.new("TextBox")
                ib.Size = UDim2.new(0, 128, 0, 24); ib.Position = UDim2.new(1, -12, 0.5, 0); ib.AnchorPoint = Vector2.new(1, 0.5)
                ib.BackgroundColor3 = P.surface; ib.BackgroundTransparency = 0; ib.BorderSizePixel = 0
                ib.Font = Enum.Font.Gotham; ib.TextSize = 12; ib.TextColor3 = P.hi
                ib.PlaceholderText = ic.PlaceholderText; ib.PlaceholderColor3 = P.dim
                ib.Text = ic.CurrentValue; ib.ClearTextOnFocus = false; ib.ZIndex = 5; ib.Parent = f
                Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 6)
                PD(ib, 0, 0, 8, 8)
                local ibS = Stroke(ib, P.wire, 0.3)

                ib.Focused:Connect(function()   tw(ibS, { Color = P.cyan,  Transparency = 0.2 }, TI_FAST) end)
                ib.FocusLost:Connect(function()  tw(ibS, { Color = P.wire,  Transparency = 0.3 }, TI_FAST) end)

                local IV = { CurrentValue = ic.CurrentValue, Type = "Input", Settings = ic }
                if ic.Numeric then
                    ib:GetPropertyChangedSignal("Text"):Connect(function()
                        if not tonumber(ib.Text) and ib.Text ~= "" and ib.Text ~= "." and ib.Text ~= "-" then
                            ib.Text = ib.Text:match("[%-0-9.]*") or ""
                        end
                    end)
                end
                if ic.MaxCharacters then
                    ib:GetPropertyChangedSignal("Text"):Connect(function()
                        if #ib.Text > ic.MaxCharacters then ib.Text = ib.Text:sub(1, ic.MaxCharacters) end
                    end)
                end
                ib.FocusLost:Connect(function(enter)
                    if ic.Enter and not enter then return end
                    IV.CurrentValue = ib.Text; safe(ic.Callback, ib.Text)
                    if ic.RemoveTextAfterFocusLost then ib.Text = "" end
                end)
                if not ic.Enter then
                    ib:GetPropertyChangedSignal("Text"):Connect(function()
                        IV.CurrentValue = ib.Text; safe(ic.Callback, ib.Text)
                    end)
                end
                HoverElem(f)
                function IV:Set(v)   ib.Text = tostring(v); IV.CurrentValue = tostring(v) end
                function IV:Destroy() f:Destroy() end
                if ic.Flag then Sentence.Flags[ic.Flag] = IV; Sentence.Options[ic.Flag] = IV end
                return IV
            end

            -- ── KEYBIND ───────────────────────────────────────────────────────
            function Sec:CreateBind(bc)
                bc = def({ Name = "Keybind", Description = nil, CurrentBind = "E",
                    HoldToInteract = false, Flag = nil,
                    Callback = function() end, OnChangedCallback = function() end }, bc or {})
                local h = bc.Description and 52 or 36
                local f = Elem(h)

                T({ Txt = bc.Name, Sz = UDim2.new(1, -92, 0, 16),
                    Pos = UDim2.new(0, 14, 0, bc.Description and 9 or 11),
                    Font = Enum.Font.GothamSemibold, TS = 13, Col = P.hi, Z = 4, Par = f })
                if bc.Description then
                    T({ Txt = bc.Description, Sz = UDim2.new(1, -92, 0, 13), Pos = UDim2.new(0, 14, 0, 28),
                        Font = Enum.Font.Gotham, TS = 11, Col = P.mid, Z = 4, Par = f })
                end

                local bb = Instance.new("TextBox")
                bb.Size = UDim2.new(0, 72, 0, 24); bb.Position = UDim2.new(1, -12, 0.5, 0); bb.AnchorPoint = Vector2.new(1, 0.5)
                bb.BackgroundColor3 = P.surface; bb.BackgroundTransparency = 0; bb.BorderSizePixel = 0
                bb.Font = Enum.Font.GothamBold; bb.TextSize = 12; bb.TextColor3 = P.cyan
                bb.Text = bc.CurrentBind; bb.ClearTextOnFocus = true; bb.ZIndex = 5; bb.Parent = f
                Instance.new("UICorner", bb).CornerRadius = UDim.new(0, 6)
                local bbS = Stroke(bb, P.wire, 0.3)

                local BV = { CurrentBind = bc.CurrentBind, Active = false, Type = "Keybind", Settings = bc }
                local checking = false
                bb.Focused:Connect(function()
                    checking = true; bb.Text = "..."
                    tw(bbS, { Color = P.cyan, Transparency = 0.2 }, TI_FAST)
                end)
                bb.FocusLost:Connect(function()
                    checking = false
                    tw(bbS, { Color = P.wire, Transparency = 0.3 }, TI_FAST)
                    if bb.Text == "..." or bb.Text == "" then bb.Text = BV.CurrentBind end
                end)
                track(UIS.InputBegan:Connect(function(inp, proc)
                    if checking then
                        if inp.KeyCode ~= Enum.KeyCode.Unknown then
                            local kn = inp.KeyCode.Name; BV.CurrentBind = kn; bc.CurrentBind = kn
                            bb.Text = kn; bb:ReleaseFocus(); safe(bc.OnChangedCallback, kn)
                        end
                    elseif BV.CurrentBind and not proc then
                        local ok, ke = pcall(function() return Enum.KeyCode[BV.CurrentBind] end)
                        if ok and inp.KeyCode == ke then
                            if not bc.HoldToInteract then
                                BV.Active = not BV.Active; safe(bc.Callback, BV.Active)
                            else
                                safe(bc.Callback, true)
                                local c; c = inp.Changed:Connect(function(pr)
                                    if pr == "UserInputState" then c:Disconnect(); safe(bc.Callback, false) end
                                end)
                            end
                        end
                    end
                end))
                HoverElem(f)
                function BV:Set(v)   BV.CurrentBind = v; bc.CurrentBind = v; bb.Text = v end
                function BV:Destroy() f:Destroy() end
                Sec.CreateKeybind = Sec.CreateBind
                if bc.Flag then Sentence.Flags[bc.Flag] = BV; Sentence.Options[bc.Flag] = BV end
                return BV
            end
            Sec.CreateKeybind = Sec.CreateBind

            -- ── COLOR PICKER ──────────────────────────────────────────────────
            function Sec:CreateColorPicker(cc)
                cc = def({ Name = "Color", Color = Color3.fromRGB(0, 217, 255), Flag = nil, Callback = function() end }, cc or {})
                local cH = 36
                local f = Elem(cH); f.ClipsDescendants = true

                T({ Txt = cc.Name, Sz = UDim2.new(1, -60, 0, 16),
                    Pos = UDim2.new(0, 14, 0, 11),
                    Font = Enum.Font.GothamSemibold, TS = 13, Col = P.hi, Z = 4, Par = f })

                -- Color preview swatch
                local prev = F({ Sz = UDim2.new(0, 26, 0, 26), Pos = UDim2.new(1, -38, 0, 5),
                    Bg = cc.Color, R = 6, S = true, SC = P.wire, SA = 0.35, Z = 5, Par = f })

                -- Picker area
                local pArea = Instance.new("Frame")
                pArea.Size = UDim2.new(1, -14, 0, 136); pArea.Position = UDim2.new(0, 7, 0, 44)
                pArea.BackgroundTransparency = 1; pArea.ZIndex = 4; pArea.Parent = f

                -- SV box
                local svBox = Instance.new("Frame")
                svBox.Size = UDim2.new(1, 0, 0, 100); svBox.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
                svBox.BorderSizePixel = 0; svBox.ZIndex = 5; svBox.Parent = pArea
                Instance.new("UICorner", svBox).CornerRadius = UDim.new(0, 7)

                local wG = Instance.new("UIGradient"); wG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}; wG.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)}; wG.Parent = svBox
                local bOv = Instance.new("Frame"); bOv.Size = UDim2.new(1,0,1,0); bOv.BackgroundColor3 = Color3.new(0,0,0); bOv.BorderSizePixel = 0; bOv.ZIndex = 6; bOv.Parent = svBox
                Instance.new("UICorner", bOv).CornerRadius = UDim.new(0, 7)
                local bG = Instance.new("UIGradient"); bG.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}; bG.Rotation = 90; bG.Parent = bOv

                local hBar = Instance.new("Frame")
                hBar.Size = UDim2.new(1, 0, 0, 16); hBar.Position = UDim2.new(0, 0, 0, 108)
                hBar.BackgroundColor3 = Color3.new(1,1,1); hBar.BorderSizePixel = 0; hBar.ZIndex = 5; hBar.Parent = pArea
                Instance.new("UICorner", hBar).CornerRadius = UDim.new(0, 5)
                local hG = Instance.new("UIGradient")
                hG.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0,     Color3.fromHSV(0,     1, 1)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                    ColorSequenceKeypoint.new(0.5,   Color3.fromHSV(0.5,   1, 1)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                    ColorSequenceKeypoint.new(1,     Color3.fromHSV(1,     1, 1)),
                }
                hG.Parent = hBar

                local opened = false
                local h2, s2, v2 = Color3.toHSV(cc.Color)
                local CPV = { Color = cc.Color, Type = "ColorPicker", Settings = cc }

                local function updCol()
                    CPV.Color = Color3.fromHSV(h2, s2, v2)
                    prev.BackgroundColor3 = CPV.Color
                    svBox.BackgroundColor3 = Color3.fromHSV(h2, 1, 1)
                    safe(cc.Callback, CPV.Color)
                end

                local hBtn3 = Instance.new("TextButton")
                hBtn3.Size = UDim2.new(1,0,0,cH); hBtn3.BackgroundTransparency = 1; hBtn3.Text = ""; hBtn3.ZIndex = 8; hBtn3.Parent = f
                hBtn3.MouseButton1Click:Connect(function()
                    opened = not opened
                    tw(f, { Size = UDim2.new(1, 0, 0, opened and 186 or cH) }, TI_MED)
                end)

                local svDrg = false; local svCL = CL(bOv, 9)
                local function upSV(i)
                    s2 = math.clamp((i.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                    v2 = 1 - math.clamp((i.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                    updCol()
                end
                svCL.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrg = true; upSV(i) end end)
                svCL.InputEnded:Connect(function(i)  if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrg = false end end)

                local hDrg = false; local hCL3 = CL(hBar, 9)
                local function upH(i)
                    h2 = math.clamp((i.Position.X - hBar.AbsolutePosition.X) / hBar.AbsoluteSize.X, 0, 1)
                    updCol()
                end
                hCL3.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hDrg = true; upH(i) end end)
                hCL3.InputEnded:Connect(function(i)  if i.UserInputType == Enum.UserInputType.MouseButton1 then hDrg = false end end)
                track(UIS.InputChanged:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement then
                        if svDrg then upSV(i) end
                        if hDrg  then upH(i)  end
                    end
                end))
                HoverElem(f)
                function CPV:Set(s)   if s.Color then h2, s2, v2 = Color3.toHSV(s.Color); updCol() end end
                function CPV:Destroy() f:Destroy() end
                if cc.Flag then Sentence.Flags[cc.Flag] = CPV; Sentence.Options[cc.Flag] = CPV end
                return CPV
            end

            function Sec:Set(n)
                local l = shRow:FindFirstChildOfClass("TextLabel")
                if l then l.Text = "<font color='rgb(0,217,255)'>"..string.format("%02d", _secCount).." //</font>  "..n:upper() end
            end
            function Sec:Destroy() shRow:Destroy(); secCon:Destroy() end
            return Sec
        end

        -- Tab-level shortcuts
        local _ds
        local function gds() if not _ds then _ds = Tab:CreateSection("") end return _ds end
        for _, m in ipairs({ "CreateButton","CreateLabel","CreateParagraph","CreateToggle",
                              "CreateSlider","CreateDivider","CreateDropdown","CreateInput",
                              "CreateBind","CreateKeybind","CreateColorPicker" }) do
            Tab[m] = function(self, ...) return gds()[m](gds(), ...) end
        end
        return Tab
    end

    -- ── Config Save / Load ────────────────────────────────────────────────────
    function W:SaveConfiguration()
        if not cfg.ConfigurationSaving or not cfg.ConfigurationSaving.Enabled then return end
        local data = {}
        for k, flag in pairs(Sentence.Flags) do
            if     flag.Type == "ColorPicker" then data[k] = { R = flag.Color.R*255, G = flag.Color.G*255, B = flag.Color.B*255 }
            elseif flag.Type == "Toggle"      then data[k] = flag.CurrentValue
            elseif flag.Type == "Slider"      then data[k] = flag.CurrentValue
            elseif flag.Type == "Dropdown"    then data[k] = flag.CurrentOption
            elseif flag.Type == "Input"       then data[k] = flag.CurrentValue
            elseif flag.Type == "Keybind"     then data[k] = flag.CurrentBind end
        end
        pcall(function()
            local fld = cfg.ConfigurationSaving.FolderName or "SENTENCE"
            local fn  = cfg.ConfigurationSaving.FileName   or "config"
            if isfolder and not isfolder(fld) then makefolder(fld) end
            writefile(fld.."/"..fn..".json", HS:JSONEncode(data))
        end)
    end

    function W:LoadConfiguration()
        if not cfg.ConfigurationSaving or not cfg.ConfigurationSaving.Enabled then return end
        pcall(function()
            local fld  = cfg.ConfigurationSaving.FolderName or "SENTENCE"
            local fn   = cfg.ConfigurationSaving.FileName   or "config"
            local path = fld.."/"..fn..".json"
            if isfile and isfile(path) then
                local data = HS:JSONDecode(readfile(path))
                for k, v in pairs(data) do
                    local flag = Sentence.Flags[k]
                    if flag then
                        if flag.Type == "ColorPicker" then flag:Set({ Color = Color3.fromRGB(v.R, v.G, v.B) })
                        else flag:Set(v) end
                    end
                end
                Sentence:Notify({ Title = "Config loaded", Content = "Restored successfully.", Icon = "save", Type = "Success" })
            end
        end)
    end

    return W
end

-- ── Destroy ───────────────────────────────────────────────────────────────────
function Sentence:Destroy()
    for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    self._conns = {}
    if self._notifBin and self._notifBin.Parent then
        self._notifBin.Parent:Destroy()
    end
    self.Flags = {}; self.Options = {}
end

return Sentence
