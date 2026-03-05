--[[
╔══════════════════════════════════════════════════════╗
║  SENTENCE Hub  ·  v2.0  ·  Terminal Luxe             ║
║  Layout   : horizontal tab-bar, full-width content   ║
║  Accent   : #AEFF5E electric lime on #050508 void    ║
║  Motion   : spring knobs · slide fills · typewriter  ║
╚══════════════════════════════════════════════════════╝
]]

local Sentence = {
    Version = "2.0",
    Flags   = {},
    Options = {},
    _conns  = {},
}

-- ── Services ──────────────────────────────────────────────────────────────────
local TS   = game:GetService("TweenService")
local UIS  = game:GetService("UserInputService")
local RS   = game:GetService("RunService")
local HS   = game:GetService("HttpService")
local Plrs = game:GetService("Players")
local CG   = game:GetService("CoreGui")
local LP   = Plrs.LocalPlayer
local Cam  = workspace.CurrentCamera
local Studio = RS:IsStudio()

-- ── Palette ───────────────────────────────────────────────────────────────────
local P = {
    void    = Color3.fromRGB(  5,  5,  8),   -- deepest bg
    ink     = Color3.fromRGB(  9,  9, 14),   -- window bg
    deep    = Color3.fromRGB( 13, 13, 20),   -- panel/card bg
    surface = Color3.fromRGB( 18, 18, 28),   -- element bg
    raised  = Color3.fromRGB( 24, 24, 36),   -- element hover
    lift    = Color3.fromRGB( 32, 32, 46),   -- active state

    wire    = Color3.fromRGB( 38, 38, 56),   -- hairline border
    wireHov = Color3.fromRGB( 62, 62, 82),   -- border hover
    wireAct = Color3.fromRGB( 90, 90,120),   -- border active

    hi      = Color3.fromRGB(240,242,248),   -- primary text
    mid     = Color3.fromRGB(148,150,172),   -- secondary text
    dim     = Color3.fromRGB( 72, 74, 96),   -- muted text

    lime    = Color3.fromRGB(174,255, 94),   -- THE accent
    limeD   = Color3.fromRGB(112,200, 48),   -- accent dark
    limeDD  = Color3.fromRGB( 54, 96, 22),   -- accent very dark (bg tint)

    ok      = Color3.fromRGB( 94,214,138),
    warn    = Color3.fromRGB(242,182, 54),
    err     = Color3.fromRGB(224, 62, 62),
    info    = Color3.fromRGB( 72,158,248),
}

-- ── Tween helpers ─────────────────────────────────────────────────────────────
local function ti(t,s,d)
    return TweenInfo.new(t or 0.2,
        s or Enum.EasingStyle.Exponential,
        d or Enum.EasingDirection.Out)
end
local TI_SNAP   = ti(0.10)
local TI_FAST   = ti(0.18)
local TI_MED    = ti(0.28)
local TI_SLOW   = ti(0.55)
local TI_SPRING = TweenInfo.new(0.42, Enum.EasingStyle.Back,        Enum.EasingDirection.Out)
local TI_EASE   = TweenInfo.new(0.35, Enum.EasingStyle.Quad,        Enum.EasingDirection.InOut)

local function tw(obj, props, info, cb)
    local t = TS:Create(obj, info or TI_MED, props)
    if cb then t.Completed:Once(cb) end
    t:Play(); return t
end

-- ── Micro-utilities ───────────────────────────────────────────────────────────
local function def(d, t)
    t = t or {}
    for k,v in pairs(d) do if t[k]==nil then t[k]=v end end
    return t
end
local function track(c) table.insert(Sentence._conns, c); return c end
local function safe(cb,...) local ok,e=pcall(cb,...); if not ok then warn("SENTENCE: "..tostring(e)) end end

-- Icon map (asset IDs)
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
    chev_d  = "rbxassetid://6031094687",
    chev_u  = "rbxassetid://6031094679",
    arr     = "rbxassetid://6031090995",
    search  = "rbxassetid://6031154871",
    games   = "rbxassetid://6026660074",
    unk     = "rbxassetid://6031079152",
    notif   = "rbxassetid://6034308946",
    edit    = "rbxassetid://6034328955",
}
local function ico(n)
    if not n then return "" end
    if n:find("rbxassetid") then return n end
    if tonumber(n) then return "rbxassetid://"..n end
    return ICO[n] or ICO.unk
end

-- ── Core builders ─────────────────────────────────────────────────────────────
-- Frame
local function F(p)
    p = p or {}
    local f = Instance.new("Frame")
    f.Name               = p.Name or "F"
    f.Size               = p.Sz   or UDim2.new(1,0,0,32)
    f.Position           = p.Pos  or UDim2.new()
    f.AnchorPoint        = p.AP   or Vector2.zero
    f.BackgroundColor3   = p.Bg   or P.surface
    f.BackgroundTransparency = p.BgA or 0
    f.BorderSizePixel    = 0
    f.ZIndex             = p.Z    or 1
    f.LayoutOrder        = p.Ord  or 0
    f.Visible            = p.Vis  ~= false
    if p.Clip then f.ClipsDescendants = true end
    if p.AS   then f.AutomaticSize = Enum.AutomaticSize.Y end
    if p.R ~= false then
        local uc = Instance.new("UICorner")
        uc.CornerRadius = p.R or UDim.new(0,6)
        uc.Parent = f
    end
    if p.S then
        local s = Instance.new("UIStroke")
        s.Color            = p.SC  or P.wire
        s.Transparency     = p.SA  or 0.3
        s.Thickness        = p.SW  or 1
        s.ApplyStrokeMode  = Enum.ApplyStrokeMode.Border
        s.Parent = f
    end
    if p.Par then f.Parent = p.Par end
    return f
end

-- Text
local function T(p)
    p = p or {}
    local l = Instance.new("TextLabel")
    l.Name             = p.Name or "T"
    l.Text             = p.Txt  or ""
    l.Size             = p.Sz   or UDim2.new(1,0,0,16)
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
    if p.AS then l.AutomaticSize = Enum.AutomaticSize.Y end
    if p.Par then l.Parent = p.Par end
    return l
end

-- Image
local function I(p)
    p = p or {}
    local i = Instance.new("ImageLabel")
    i.Name             = p.Name or "I"
    i.Image            = ico(p.Ico or "")
    i.Size             = p.Sz   or UDim2.new(0,16,0,16)
    i.Position         = p.Pos  or UDim2.new(0,0,0.5,0)
    i.AnchorPoint      = p.AP   or Vector2.new(0,0.5)
    i.ImageColor3      = p.Col  or P.hi
    i.ImageTransparency = p.IA  or 0
    i.BackgroundTransparency = 1
    i.BorderSizePixel  = 0
    i.ZIndex           = p.Z    or 3
    i.ScaleType        = Enum.ScaleType.Fit
    if p.Par then i.Parent = p.Par end
    return i
end

-- Click overlay
local function CL(par, z)
    local b = Instance.new("TextButton")
    b.Name="CL"; b.Size=UDim2.new(1,0,1,0)
    b.BackgroundTransparency=1; b.Text=""; b.ZIndex=z or 8
    b.Parent=par; return b
end

-- Layout
local function LL(par, gap, ha)
    local l = Instance.new("UIListLayout")
    l.SortOrder=Enum.SortOrder.LayoutOrder
    l.Padding=UDim.new(0,gap or 4)
    if ha then l.HorizontalAlignment=ha end
    l.Parent=par; return l
end

local function PD(par,top,bot,lft,rgt)
    local p=Instance.new("UIPadding")
    p.PaddingTop=UDim.new(0,top or 0); p.PaddingBottom=UDim.new(0,bot or 0)
    p.PaddingLeft=UDim.new(0,lft or 0); p.PaddingRight=UDim.new(0,rgt or 0)
    p.Parent=par; return p
end

-- Hairline (1px separator)
local function HL(par, vert, col, alp)
    local f=Instance.new("Frame")
    f.BackgroundColor3=col or P.wire
    f.BackgroundTransparency=alp or 0.5
    f.BorderSizePixel=0; f.ZIndex=3
    if vert then
        f.Size=UDim2.new(0,1,1,0)
    else
        f.Size=UDim2.new(1,0,0,1)
    end
    f.Parent=par; return f
end

-- ── Dragging ──────────────────────────────────────────────────────────────────
local function Drag(handle, win)
    local drg, ds, dp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drg=true; ds=i.Position; dp=win.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drg=false end end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if drg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            tw(win,{Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)},ti(0.14))
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION  (bottom-right stack)
-- ══════════════════════════════════════════════════════════════════════════════
function Sentence:Notify(d)
    task.spawn(function()
        d=def({Title="Notice",Content="",Icon="info",Type="Info",Duration=nil},d)
        local aMap={Info=P.info,Success=P.ok,Warning=P.warn,Error=P.err}
        local ac=aMap[d.Type] or P.info

        local card=F({Name="NC",Sz=UDim2.new(1,0,0,0),
            Bg=P.deep,BgA=0.04,Clip=true,
            R=UDim.new(0,8),S=true,SC=P.wire,SA=0.45,
            Par=self._notifBin})
        card.BackgroundTransparency=1

        -- Accent left pip
        local pip=F({Sz=UDim2.new(0,2,1,-10),Pos=UDim2.new(0,5,0,5),
            Bg=ac,R=UDim.new(1,0),Z=4,Par=card})
        pip.BackgroundTransparency=1

        local icoL=I({Ico=d.Icon,Sz=UDim2.new(0,14,0,14),
            Pos=UDim2.new(0,16,0,14),AP=Vector2.zero,Col=ac,IA=1,Z=4,Par=card})

        local ttl=T({Txt=d.Title,Sz=UDim2.new(1,-40,0,14),
            Pos=UDim2.new(0,36,0,8),Font=Enum.Font.GothamBold,TS=13,
            Col=P.hi,TA=1,Z=4,Par=card})

        local msg=T({Txt=d.Content,Sz=UDim2.new(1,-40,0,800),
            Pos=UDim2.new(0,36,0,24),Font=Enum.Font.Gotham,TS=11,
            Col=P.mid,TA=1,Wrap=true,Z=4,Par=card})

        task.wait()
        local th=msg.TextBounds.Y
        msg.Size=UDim2.new(1,-40,0,th)
        local H=34+th

        tw(card,{Size=UDim2.new(1,0,0,H),BackgroundTransparency=0.04},TI_SLOW)
        task.wait(0.12)
        tw(pip,  {BackgroundTransparency=0},TI_MED)
        tw(icoL, {ImageTransparency=0},TI_MED)
        tw(ttl,  {TextTransparency=0},TI_MED)
        task.wait(0.05)
        tw(msg,  {TextTransparency=0.15},TI_MED)

        local dur=d.Duration or math.clamp(#d.Content*0.065+2.5,2.5,8)
        task.wait(dur)

        tw(card, {BackgroundTransparency=1},TI_FAST)
        tw(pip,  {BackgroundTransparency=1},TI_FAST)
        tw(icoL, {ImageTransparency=1},TI_FAST)
        tw(ttl,  {TextTransparency=1},TI_FAST)
        tw(msg,  {TextTransparency=1},TI_FAST)
        if card:FindFirstChildOfClass("UIStroke") then
            tw(card.UIStroke,{Transparency=1},TI_FAST)
        end
        task.wait(0.22)
        tw(card,{Size=UDim2.new(1,0,0,0)},TI_SLOW,function() card:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════════════════════════════════════════
function Sentence:CreateWindow(cfg)
    cfg=def({
        Name            = "SENTENCE",
        Subtitle        = "Hub",
        Icon            = "rbxassetid://118722741385791",
        ToggleBind      = Enum.KeyCode.RightControl,
        LoadingEnabled  = true,
        LoadingTitle    = "SENTENCE",
        LoadingSubtitle = "initialising system...",
        ConfigurationSaving={Enabled=false,FolderName="SENTENCE",FileName="config"},
    },cfg)

    -- Responsive
    local vp=Cam.ViewportSize
    local WW=math.clamp(vp.X-100, 560, 740)
    local WH=math.clamp(vp.Y-90,  400, 490)
    local FULL=UDim2.fromOffset(WW,WH)
    local MINI=UDim2.fromOffset(WW,46)

    -- ── ScreenGui ─────────────────────────────────────────────────────────────
    local gui=Instance.new("ScreenGui")
    gui.Name="SentenceV2"; gui.DisplayOrder=999999999
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true

    if gethui then gui.Parent=gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent=CG
    elseif not Studio then gui.Parent=CG
    else gui.Parent=LP:WaitForChild("PlayerGui") end

    -- ── Notification bin ──────────────────────────────────────────────────────
    local notifBin=Instance.new("Frame")
    notifBin.Name="NB"; notifBin.Size=UDim2.new(0,290,1,-16)
    notifBin.Position=UDim2.new(1,-298,0,8)
    notifBin.BackgroundTransparency=1; notifBin.ZIndex=200; notifBin.Parent=gui
    local nbl=LL(notifBin,5); nbl.VerticalAlignment=Enum.VerticalAlignment.Bottom
    self._notifBin=notifBin

    -- ══════════════════════════════════════════════════════════════════════════
    -- MAIN WINDOW
    -- ══════════════════════════════════════════════════════════════════════════
    local win=F({Name="Win",Sz=UDim2.fromOffset(0,0),
        Pos=UDim2.new(0.5,0,0.5,0),AP=Vector2.new(0.5,0.5),
        Bg=P.ink,BgA=0,Clip=true,
        R=UDim.new(0,10),S=true,SC=P.wire,SA=0.2,
        Z=1,Par=gui})
    win.ZIndex=1

    -- ── Void background fill ──────────────────────────────────────────────────
    -- Dot-grid accent top-right  (decorative atmosphere)
    local atmoFrame=F({Name="Atmo",Sz=UDim2.new(0.55,0,0.45,0),
        Pos=UDim2.new(1,0,0,0),AP=Vector2.new(1,0),
        Bg=P.limeDD,BgA=0.88,R=UDim.new(0,10),Z=0,Par=win})

    -- Soft gradient overlay to blend atmo into bg
    local atmoGrad=Instance.new("UIGradient")
    atmoGrad.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1,Color3.new(0,0,0)),
    }
    atmoGrad.Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0,0.7),
        NumberSequenceKeypoint.new(1,1),
    }
    atmoGrad.Rotation=200
    atmoGrad.Parent=atmoFrame

    -- Thin lime top accent line
    local topLine=F({Name="TopLine",Sz=UDim2.new(1,0,0,1),
        Pos=UDim2.new(0,0,0,0),Bg=P.lime,BgA=0,Z=6,Par=win})
    tw(topLine,{BackgroundTransparency=0.4},TI_SLOW)

    -- ── Title bar ─────────────────────────────────────────────────────────────
    -- Height: 46px
    local titleBar=F({Name="TB",Sz=UDim2.new(1,0,0,46),
        Pos=UDim2.new(0,0,0,0),Bg=P.void,BgA=0,Z=4,Par=win})
    Drag(titleBar,win)

    -- Window controls  (left side — clean dots)
    local function WCtrl(name,icn,xPos,hoverCol)
        local btn=F({Name=name,Sz=UDim2.new(0,24,0,24),
            Pos=UDim2.new(0,xPos,0.5,0),AP=Vector2.new(0,0.5),
            Bg=P.surface,BgA=0,
            S=true,SC=P.wire,SA=0.6,
            R=UDim.new(1,0),Z=6,Par=titleBar})
        local ic=I({Ico=icn,Sz=UDim2.new(0,12,0,12),
            Pos=UDim2.new(0.5,0,0.5,0),AP=Vector2.new(0.5,0.5),
            Col=P.dim,IA=0,Z=7,Par=btn})
        local cl=CL(btn,8)
        btn.MouseEnter:Connect(function()
            tw(btn,{BackgroundColor3=hoverCol or P.raised,BackgroundTransparency=0},TI_FAST)
            tw(ic,{ImageColor3=P.hi,ImageTransparency=0},TI_FAST)
        end)
        btn.MouseLeave:Connect(function()
            tw(btn,{BackgroundTransparency=0},TI_FAST)
            tw(ic,{ImageColor3=P.dim,ImageTransparency=0.1},TI_FAST)
        end)
        task.delay(0.6,function() tw(ic,{ImageTransparency=0.1},TI_MED) end)
        return btn,cl,ic
    end

    local closeBtn, closeCL = WCtrl("Close","close",12, P.err)
    local minBtn,   minCL   = WCtrl("Min",  "min",  42, P.raised)
    local hideBtn,  hideCL  = WCtrl("Hide", "hide", 72, P.raised)

    -- Logo (starts visible; image loads async on Roblox's side)
    local logoImg=I({Ico=cfg.Icon,Sz=UDim2.new(0,20,0,20),
        Pos=UDim2.new(0,108,0.5,0),AP=Vector2.new(0,0.5),
        IA=0,Z=5,Par=titleBar})

    -- Window name (hidden until loading finishes)
    local nameL=T({Txt=cfg.Name,
        Sz=UDim2.new(0,200,0,16),Pos=UDim2.new(0,134,0,8),
        Font=Enum.Font.GothamBold,TS=14,Col=P.hi,TA=1,Z=5,Par=titleBar})
    local subL=T({Txt=cfg.Subtitle,
        Sz=UDim2.new(0,200,0,12),Pos=UDim2.new(0,134,0,26),
        Font=Enum.Font.Gotham,TS=10,Col=P.lime,TA=1,Z=5,Par=titleBar})

    -- Version  (right side)
    local verL=T({Txt="v"..Sentence.Version,
        Sz=UDim2.new(0,40,0,14),Pos=UDim2.new(1,-12,0.5,0),AP=Vector2.new(1,0.5),
        Font=Enum.Font.Gotham,TS=10,Col=P.dim,AX=Enum.TextXAlignment.Right,Z=5,Par=titleBar})

    -- Title hairline separator
    local tbSep=HL(titleBar,false,P.wire,0.6)
    tbSep.Position=UDim2.new(0,0,1,0); tbSep.Size=UDim2.new(1,0,0,1)

    -- ── Tab bar  ──────────────────────────────────────────────────────────────
    -- Horizontal pills just below title bar
    local TAB_H = 40
    local tabBar=F({Name="TabBar",Sz=UDim2.new(1,0,0,TAB_H),
        Pos=UDim2.new(0,0,0,46),Bg=P.void,BgA=0,Z=3,Par=win})

    local tabScroll=Instance.new("ScrollingFrame")
    tabScroll.Name="TS"; tabScroll.Size=UDim2.new(1,-16,1,0)
    tabScroll.Position=UDim2.new(0,8,0,0)
    tabScroll.BackgroundTransparency=1; tabScroll.BorderSizePixel=0
    tabScroll.ScrollBarThickness=0; tabScroll.CanvasSize=UDim2.new(0,0,0,0)
    tabScroll.AutomaticCanvasSize=Enum.AutomaticSize.X
    tabScroll.ScrollingDirection=Enum.ScrollingDirection.X
    tabScroll.ZIndex=4; tabScroll.Parent=tabBar

    local tsLL=Instance.new("UIListLayout")
    tsLL.FillDirection=Enum.FillDirection.Horizontal
    tsLL.SortOrder=Enum.SortOrder.LayoutOrder
    tsLL.Padding=UDim.new(0,4)
    tsLL.VerticalAlignment=Enum.VerticalAlignment.Center
    tsLL.Parent=tabScroll

    -- Hairline under tab bar
    local tabSep=HL(tabBar,false,P.wire,0.6)
    tabSep.Position=UDim2.new(0,0,1,-1); tabSep.Size=UDim2.new(1,0,0,1)

    -- Sliding underline indicator
    local tabIndicator=F({Name="Ind",Sz=UDim2.new(0,0,0,2),
        Pos=UDim2.new(0,8,1,-1),Bg=P.lime,BgA=0,
        R=UDim.new(1,0),Z=5,Par=tabBar})

    -- ── Content area ──────────────────────────────────────────────────────────
    local CONTENT_TOP = 46+TAB_H
    local contentArea=F({Name="CA",
        Sz=UDim2.new(1,0,1,-CONTENT_TOP),
        Pos=UDim2.new(0,0,0,CONTENT_TOP),
        Bg=P.void,BgA=1,Clip=true,Z=2,Par=win})

    -- ══════════════════════════════════════════════════════════════════════════
    -- LOADING SCREEN  — typewriter effect
    -- ══════════════════════════════════════════════════════════════════════════
    local function RunLoading()
        local lf=F({Name="Loading",Sz=UDim2.new(1,0,1,0),
            Bg=P.void,BgA=0,Z=50,Par=win})
        Instance.new("UICorner",lf).CornerRadius=UDim.new(0,10)

        -- Big title (typewriter)
        local lTitle=T({Txt="",Sz=UDim2.new(1,0,0,32),
            Pos=UDim2.new(0.5,0,0.5,-22),AP=Vector2.new(0.5,0.5),
            Font=Enum.Font.GothamBold,TS=28,
            Col=P.hi,AX=Enum.TextXAlignment.Center,Z=51,Par=lf})

        -- Subtitle
        local lSub=T({Txt=cfg.LoadingSubtitle,
            Sz=UDim2.new(1,0,0,14),
            Pos=UDim2.new(0.5,0,0.5,18),AP=Vector2.new(0.5,0.5),
            Font=Enum.Font.Gotham,TS=11,
            Col=P.dim,TA=1,AX=Enum.TextXAlignment.Center,Z=51,Par=lf})

        -- Lime accent dot
        local dot=F({Sz=UDim2.new(0,6,0,6),
            Pos=UDim2.new(0.5,0,0.5,50),AP=Vector2.new(0.5,0.5),
            Bg=P.lime,BgA=1,R=UDim.new(1,0),Z=51,Par=lf})

        -- Logo
        local lLogo=I({Ico=cfg.Icon,Sz=UDim2.new(0,28,0,28),
            Pos=UDim2.new(0.5,-82,0.5,-22),AP=Vector2.new(0.5,0.5),
            IA=1,Z=51,Par=lf})

        tw(win,{Size=FULL},TI_SLOW)
        task.wait(0.35)

        -- Typewriter
        tw(lLogo,{ImageTransparency=0},TI_MED)
        local full=cfg.LoadingTitle
        for i=1,#full do
            lTitle.Text=full:sub(1,i).."<font color='rgb(174,255,94)'>_</font>"
            task.wait(0.055)
        end
        lTitle.Text=full
        task.wait(0.1)
        tw(lSub,{TextTransparency=0.3},TI_MED)
        task.wait(0.08)
        tw(dot,{BackgroundTransparency=0},TI_MED)

        -- Pulse dot
        task.spawn(function()
            while dot and dot.Parent do
                tw(dot,{BackgroundTransparency=0.2},ti(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut))
                task.wait(0.5)
                tw(dot,{BackgroundTransparency=0.7},ti(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut))
                task.wait(0.5)
            end
        end)

        task.wait(1.6)
        tw(lTitle,{TextTransparency=1},TI_FAST)
        tw(lSub,  {TextTransparency=1},TI_FAST)
        tw(lLogo, {ImageTransparency=1},TI_FAST)
        tw(dot,   {BackgroundTransparency=1},TI_FAST)
        task.wait(0.2)
        tw(lf,{BackgroundTransparency=1},TI_MED,function() lf:Destroy() end)
        task.wait(0.3)
    end

    -- ── Window state ──────────────────────────────────────────────────────────
    local W={
        _gui=gui,_win=win,_content=contentArea,
        _tabs={},_activeTab=nil,
        _visible=true,_minimized=false,
        _cfg=cfg,
    }

    gui.Enabled=true
    if cfg.LoadingEnabled then
        RunLoading()
    else
        tw(win,{Size=FULL},TI_SLOW)
        task.wait(0.35)
    end

    -- Reveal title bar text AFTER loading finishes (logo is always visible IA=0)
    tw(nameL,{TextTransparency=0},TI_MED)
    tw(subL,{TextTransparency=0.2},TI_MED)

    -- ── Controls ──────────────────────────────────────────────────────────────
    local function HideW()
        W._visible=false
        tw(win,{Size=UDim2.fromOffset(0,0)},TI_SLOW,function() win.Visible=false end)
    end
    local function ShowW()
        win.Visible=true; W._visible=true
        tw(win,{Size=W._minimized and MINI or FULL},TI_SLOW)
    end

    closeCL.MouseButton1Click:Connect(function() Sentence:Destroy() end)
    hideCL.MouseButton1Click:Connect(function()
        Sentence:Notify({Title="UI Hidden",Content="Press "..cfg.ToggleBind.Name.." to restore.",Type="Info"})
        HideW()
    end)
    minCL.MouseButton1Click:Connect(function()
        W._minimized=not W._minimized
        if W._minimized then
            tabBar.Visible=false; contentArea.Visible=false
            tw(win,{Size=MINI},TI_MED)
        else
            tw(win,{Size=FULL},TI_MED,function()
                tabBar.Visible=true; contentArea.Visible=true
            end)
        end
    end)
    track(UIS.InputBegan:Connect(function(inp,proc)
        if proc then return end
        if inp.KeyCode==cfg.ToggleBind then
            if W._visible then HideW() else ShowW() end
        end
    end))

    -- ── Indicator helper ─────────────────────────────────────────────────────
    local function MoveIndicator(btn)
        if not btn or not btn.Parent then return end
        task.wait()  -- let layout settle
        local abs=btn.AbsolutePosition.X - tabScroll.AbsolutePosition.X
        tw(tabIndicator,{
            Position=UDim2.new(0,abs+8,1,-1),
            Size=UDim2.new(0,btn.AbsoluteSize.X-16,0,2),
            BackgroundTransparency=0,
        },TI_EASE)
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- HOME TAB
    -- ══════════════════════════════════════════════════════════════════════════
    function W:CreateHomeTab(hCfg)
        hCfg=def({Icon="home"},hCfg or {})

        -- Tab pill button
        local hPill=F({Name="HomeTab",Sz=UDim2.new(0,80,0,28),
            Bg=P.surface,BgA=0,
            S=false,R=UDim.new(0,6),Z=5,Par=tabScroll})
        I({Ico=hCfg.Icon,Sz=UDim2.new(0,14,0,14),
            Pos=UDim2.new(0,10,0.5,0),AP=Vector2.new(0,0.5),
            Col=P.dim,IA=0,Z=6,Par=hPill})
        T({Txt="Home",Sz=UDim2.new(1,-28,0,14),
            Pos=UDim2.new(0,28,0.5,0),AP=Vector2.new(0,0.5),
            Font=Enum.Font.GothamSemibold,TS=12,Col=P.mid,Z=6,Par=hPill})
        local hCL=CL(hPill,7)

        -- Home page
        local hPage=Instance.new("ScrollingFrame")
        hPage.Name="HomePage"; hPage.Size=UDim2.new(1,0,1,0)
        hPage.BackgroundTransparency=1; hPage.BorderSizePixel=0
        hPage.ScrollBarThickness=2; hPage.ScrollBarImageColor3=P.wire
        hPage.CanvasSize=UDim2.new(0,0,0,0); hPage.AutomaticCanvasSize=Enum.AutomaticSize.Y
        hPage.ZIndex=3; hPage.Visible=true; hPage.Parent=contentArea
        LL(hPage,10); PD(hPage,16,16,16,16)

        -- ── Player banner ─────────────────────────────────────────────────────
        local banner=F({Name="Banner",Sz=UDim2.new(1,0,0,72),
            Bg=P.deep,BgA=0,S=true,SC=P.wire,SA=0.55,R=UDim.new(0,8),Z=3,Par=hPage})

        -- Lime left accent bar
        F({Sz=UDim2.new(0,2,0.7,0),Pos=UDim2.new(0,0,0.15,0),
            Bg=P.lime,R=UDim.new(1,0),Z=4,Par=banner})

        local pAv=Instance.new("ImageLabel")
        pAv.Size=UDim2.new(0,44,0,44); pAv.Position=UDim2.new(0,14,0.5,0); pAv.AnchorPoint=Vector2.new(0,0.5)
        pAv.BackgroundTransparency=1; pAv.ZIndex=4; pAv.Parent=banner
        Instance.new("UICorner",pAv).CornerRadius=UDim.new(0,6)
        pcall(function()
            pAv.Image=Plrs:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
        end)
        local pAS=Instance.new("UIStroke"); pAS.Color=P.lime; pAS.Thickness=1.5; pAS.Transparency=0.5; pAS.Parent=pAv

        T({Txt=LP.DisplayName,Sz=UDim2.new(1,-75,0,17),
            Pos=UDim2.new(0,70,0,16),Font=Enum.Font.GothamBold,TS=16,Col=P.hi,Z=4,Par=banner})
        T({Txt="@"..LP.Name,Sz=UDim2.new(1,-75,0,13),
            Pos=UDim2.new(0,70,0,36),Font=Enum.Font.Gotham,TS=11,Col=P.dim,Z=4,Par=banner})

        -- Lime pill tag  (script name)
        local tag=F({Name="Tag",Sz=UDim2.new(0,0,0,18),
            Pos=UDim2.new(1,-12,0,12),AP=Vector2.new(1,0),
            Bg=P.limeDD,R=UDim.new(0,4),Z=4,Par=banner})
        tag.AutomaticSize=Enum.AutomaticSize.X
        PD(tag,0,0,8,8)
        T({Txt=cfg.Name,Sz=UDim2.new(0,0,1,0),
            Font=Enum.Font.GothamBold,TS=10,Col=P.lime,Z=5,Par=tag}).AutomaticSize=Enum.AutomaticSize.X

        -- ── Stat grid ─────────────────────────────────────────────────────────
        local statGrid=F({Name="Stats",Sz=UDim2.new(1,0,0,100),
            Bg=P.deep,BgA=0,S=true,SC=P.wire,SA=0.55,R=UDim.new(0,8),Z=3,Par=hPage})

        T({Txt="SERVER",Sz=UDim2.new(1,-20,0,12),
            Pos=UDim2.new(0,12,0,8),Font=Enum.Font.GothamBold,TS=9,Col=P.lime,Z=4,Par=statGrid})

        local sVals={}
        local sData={{"Players",""},{"Ping",""},{"Uptime",""},{"Region",""}}
        for i,sd in ipairs(sData) do
            local col=(i-1)%2; local row=math.floor((i-1)/2)
            local x=12+col*((WW-60)/2); local y=26+row*30
            T({Txt=sd[1]:upper(),Sz=UDim2.new(0,120,0,11),Pos=UDim2.new(0,x,0,y),
                Font=Enum.Font.GothamBold,TS=9,Col=P.dim,Z=4,Par=statGrid})
            sVals[sd[1]]=T({Txt="—",Sz=UDim2.new(0,180,0,14),Pos=UDim2.new(0,x,0,y+12),
                Font=Enum.Font.GothamSemibold,TS=13,Col=P.hi,Z=4,Par=statGrid})
        end
        task.spawn(function()
            while task.wait(1) do
                if not win or not win.Parent then break end
                pcall(function()
                    sVals["Players"].Text=#Plrs:GetPlayers().."/"..Plrs.MaxPlayers
                    sVals["Ping"].Text=math.floor(LP:GetNetworkPing()*1000).."ms"
                    local t=math.floor(time())
                    sVals["Uptime"].Text=string.format("%02d:%02d:%02d",math.floor(t/3600),math.floor(t%3600/60),t%60)
                    pcall(function()
                        sVals["Region"].Text=game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(LP)
                    end)
                end)
            end
        end)

        -- Activate
        local function activateHome()
            for _,td in ipairs(W._tabs) do
                td.page.Visible=false
                local ic=td.btn:FindFirstChildOfClass("ImageLabel")
                local lb=td.btn:FindFirstChildOfClass("TextLabel")
                if ic then tw(ic,{ImageColor3=P.dim},TI_FAST) end
                if lb then tw(lb,{TextColor3=P.mid},TI_FAST) end
            end
            hPage.Visible=true
            local hi=hPill:FindFirstChildOfClass("ImageLabel")
            local hl=hPill:FindFirstChildOfClass("TextLabel")
            if hi then tw(hi,{ImageColor3=P.lime},TI_FAST) end
            if hl then tw(hl,{TextColor3=P.hi},TI_FAST) end
            MoveIndicator(hPill)
            W._activeTab="Home"
        end
        activateHome()
        hCL.MouseButton1Click:Connect(activateHome)
        hPill.MouseEnter:Connect(function()
            if W._activeTab~="Home" then
                local lb=hPill:FindFirstChildOfClass("TextLabel")
                if lb then tw(lb,{TextColor3=P.hi},TI_FAST) end
            end
        end)
        hPill.MouseLeave:Connect(function()
            if W._activeTab~="Home" then
                local lb=hPill:FindFirstChildOfClass("TextLabel")
                if lb then tw(lb,{TextColor3=P.mid},TI_FAST) end
            end
        end)
        return {Activate=activateHome}
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- CREATE TAB
    -- ══════════════════════════════════════════════════════════════════════════
    function W:CreateTab(tCfg)
        tCfg=def({Name="Tab",Icon="unk",ShowTitle=true},tCfg or {})
        local Tab={}
        local isFirst=#W._tabs==0

        -- Measure approximate text width for pill
        local pillW = #tCfg.Name*7.2 + 36

        local pill=F({Name=tCfg.Name,Sz=UDim2.new(0,pillW,0,28),
            Bg=P.surface,BgA=1,
            R=UDim.new(0,6),Z=5,Par=tabScroll,Ord=#W._tabs+10})

        local pIco=I({Ico=tCfg.Icon,Sz=UDim2.new(0,14,0,14),
            Pos=UDim2.new(0,10,0.5,0),AP=Vector2.new(0,0.5),
            Col=isFirst and P.lime or P.dim,Z=6,Par=pill})
        local pLbl=T({Txt=tCfg.Name,Sz=UDim2.new(1,-28,0,14),
            Pos=UDim2.new(0,28,0.5,0),AP=Vector2.new(0,0.5),
            Font=Enum.Font.GothamSemibold,TS=12,
            Col=isFirst and P.hi or P.mid,Z=6,Par=pill})
        local pCL=CL(pill,7)

        -- Tab page
        local tPage=Instance.new("ScrollingFrame")
        tPage.Name=tCfg.Name; tPage.Size=UDim2.new(1,0,1,0)
        tPage.BackgroundTransparency=1; tPage.BorderSizePixel=0
        tPage.ScrollBarThickness=2; tPage.ScrollBarImageColor3=P.wire
        tPage.CanvasSize=UDim2.new(0,0,0,0); tPage.AutomaticCanvasSize=Enum.AutomaticSize.Y
        tPage.ZIndex=3; tPage.Visible=isFirst; tPage.Parent=contentArea
        LL(tPage,8); PD(tPage,16,16,16,16)

        if tCfg.ShowTitle then
            -- Page title with lime accent char
            local titleRow=F({Name="TitleRow",Sz=UDim2.new(1,0,0,28),
                BgA=1,Z=3,Par=tPage})
            T({Txt="<font color='rgb(174,255,94)'>/</font> "..tCfg.Name,
                Sz=UDim2.new(1,0,1,0),
                Font=Enum.Font.GothamBold,TS=18,Col=P.hi,Z=4,Par=titleRow})
        end

        table.insert(W._tabs,{btn=pill,page=tPage,name=tCfg.Name})
        if isFirst then W._activeTab=tCfg.Name; task.delay(0.1,function() MoveIndicator(pill) end) end

        function Tab:Activate()
            for _,td in ipairs(W._tabs) do
                td.page.Visible=false
                local ic=td.btn:FindFirstChildOfClass("ImageLabel")
                local lb=td.btn:FindFirstChildOfClass("TextLabel")
                if ic then tw(ic,{ImageColor3=P.dim},TI_FAST) end
                if lb then tw(lb,{TextColor3=P.mid},TI_FAST) end
            end
            local hp=contentArea:FindFirstChild("HomePage")
            if hp then hp.Visible=false end
            local hT=tabScroll:FindFirstChild("HomeTab")
            if hT then
                local hi=hT:FindFirstChildOfClass("ImageLabel")
                local hl=hT:FindFirstChildOfClass("TextLabel")
                if hi then tw(hi,{ImageColor3=P.dim},TI_FAST) end
                if hl then tw(hl,{TextColor3=P.mid},TI_FAST) end
            end
            tPage.Visible=true
            tw(pIco,{ImageColor3=P.lime},TI_FAST)
            tw(pLbl,{TextColor3=P.hi},TI_FAST)
            MoveIndicator(pill)
            W._activeTab=tCfg.Name
        end

        pCL.MouseButton1Click:Connect(function() Tab:Activate() end)
        pill.MouseEnter:Connect(function()
            if W._activeTab~=tCfg.Name then tw(pLbl,{TextColor3=P.hi},TI_FAST) end
        end)
        pill.MouseLeave:Connect(function()
            if W._activeTab~=tCfg.Name then tw(pLbl,{TextColor3=P.mid},TI_FAST) end
        end)

        -- ════════════════════════════════════════════════════════════════════
        -- CREATE SECTION
        -- ════════════════════════════════════════════════════════════════════
        local _secCount=0

        function Tab:CreateSection(sName)
            sName=sName or ""
            _secCount=_secCount+1
            local Sec={}

            -- Section header row
            local shRow=F({Name="SH_"..sName,Sz=UDim2.new(1,0,0,sName~="" and 24 or 1),
                BgA=1,Z=3,Par=tPage,Ord=#tPage:GetChildren()})

            if sName~="" then
                -- Number prefix + name
                local numStr=string.format("%02d", _secCount)
                T({Txt="<font color='rgb(174,255,94)'>"..numStr.." /</font>  "..sName:upper(),
                    Sz=UDim2.new(1,0,1,0),
                    Font=Enum.Font.GothamBold,TS=10,Col=P.mid,Z=4,Par=shRow})
            else
                -- Hairline only
                HL(shRow,false,P.wire,0.7).Position=UDim2.new(0,0,0.5,0)
            end

            local secCon=F({Name="SC_"..sName,Sz=UDim2.new(1,0,0,0),
                BgA=1,Z=3,AS=true,Ord=shRow.LayoutOrder+1,Par=tPage})
            LL(secCon,4)

            -- ── Shared element base ───────────────────────────────────────────
            local function Elem(h, as)
                local f=F({Sz=UDim2.new(1,0,0,h),Bg=P.deep,BgA=0,
                    S=true,SC=P.wire,SA=0.55,R=UDim.new(0,6),Z=3,Par=secCon})
                if as then f.AutomaticSize=Enum.AutomaticSize.Y end
                return f
            end

            local function HoverElem(f)
                f.MouseEnter:Connect(function()
                    tw(f,{BackgroundTransparency=0},TI_FAST)
                    if f:FindFirstChildOfClass("UIStroke") then
                        tw(f.UIStroke,{Color=P.wireHov,Transparency=0.2},TI_FAST)
                    end
                end)
                f.MouseLeave:Connect(function()
                    tw(f,{BackgroundTransparency=0},TI_FAST)
                    if f:FindFirstChildOfClass("UIStroke") then
                        tw(f.UIStroke,{Color=P.wire,Transparency=0.55},TI_FAST)
                    end
                end)
            end

            -- ── DIVIDER ───────────────────────────────────────────────────────
            function Sec:CreateDivider()
                local d=HL(secCon,false,P.wire,0.6)
                d.Size=UDim2.new(1,0,0,1)
                local DV={}; function DV:Destroy() d:Destroy() end; return DV
            end

            -- ── LABEL ─────────────────────────────────────────────────────────
            function Sec:CreateLabel(lc)
                lc=def({Text="Label",Style=1},lc or {})
                local cMap={[1]=P.mid,[2]=P.info,[3]=P.warn}
                local bgMap={[1]=P.deep,[2]=Color3.fromRGB(12,26,50),[3]=Color3.fromRGB(48,34,10)}
                local f=Elem(28)
                f.BackgroundColor3=bgMap[lc.Style]
                if lc.Style>1 then
                    F({Sz=UDim2.new(0,2,0.65,0),Pos=UDim2.new(0,5,0.175,0),
                        Bg=cMap[lc.Style],R=UDim.new(1,0),Z=4,Par=f})
                end
                local xo=lc.Style>1 and 16 or 10
                local lb=T({Txt=lc.Text,Sz=UDim2.new(1,-xo-6,0,13),
                    Pos=UDim2.new(0,xo,0.5,0),AP=Vector2.new(0,0.5),
                    Font=Enum.Font.GothamSemibold,TS=12,Col=cMap[lc.Style],Z=4,Par=f})
                local LV={}; function LV:Set(t) lb.Text=t end; function LV:Destroy() f:Destroy() end; return LV
            end

            -- ── PARAGRAPH ─────────────────────────────────────────────────────
            function Sec:CreateParagraph(pc)
                pc=def({Title="Title",Content=""},pc or {})
                local f=Elem(0,true)
                PD(f,10,10,12,12); LL(f,4)
                local pt=T({Txt=pc.Title,Sz=UDim2.new(1,0,0,15),
                    Font=Enum.Font.GothamBold,TS=13,Col=P.hi,Z=4,Par=f})
                local pcont=T({Txt=pc.Content,Sz=UDim2.new(1,0,0,0),
                    Font=Enum.Font.Gotham,TS=12,Col=P.mid,Wrap=true,Z=4,AS=true,Par=f})
                local PV={}
                function PV:Set(s) if s.Title then pt.Text=s.Title end; if s.Content then pcont.Text=s.Content end end
                function PV:Destroy() f:Destroy() end; return PV
            end

            -- ── BUTTON ────────────────────────────────────────────────────────
            function Sec:CreateButton(bc)
                bc=def({Name="Button",Description=nil,Callback=function()end},bc or {})
                local h=bc.Description and 50 or 34
                local f=Elem(h); f.ClipsDescendants=true

                -- Hover fill (slides from left)
                local fillBg=F({Name="Fill",Sz=UDim2.new(0,0,1,0),Bg=P.lift,R=UDim.new(0,6),Z=3,Par=f})

                T({Txt=bc.Name,Sz=UDim2.new(1,-44,0,15),
                    Pos=UDim2.new(0,12,0,bc.Description and 8 or 10),
                    Font=Enum.Font.GothamSemibold,TS=13,Col=P.hi,Z=4,Par=f})
                if bc.Description then
                    T({Txt=bc.Description,Sz=UDim2.new(1,-44,0,12),
                        Pos=UDim2.new(0,12,0,26),Font=Enum.Font.Gotham,TS=11,Col=P.mid,Z=4,Par=f})
                end
                -- Lime chevron right
                I({Ico="arr",Sz=UDim2.new(0,12,0,12),
                    Pos=UDim2.new(1,-20,0.5,0),AP=Vector2.new(0,0.5),
                    Col=P.lime,IA=0.5,Z=5,Par=f})

                local cl=CL(f,6)
                f.MouseEnter:Connect(function()
                    tw(fillBg,{Size=UDim2.new(1,0,1,0)},TI_MED)
                    if f:FindFirstChildOfClass("UIStroke") then tw(f.UIStroke,{Color=P.wireHov,Transparency=0.1},TI_FAST) end
                end)
                f.MouseLeave:Connect(function()
                    tw(fillBg,{Size=UDim2.new(0,0,1,0)},TI_MED)
                    if f:FindFirstChildOfClass("UIStroke") then tw(f.UIStroke,{Color=P.wire,Transparency=0.55},TI_FAST) end
                end)
                cl.MouseButton1Click:Connect(function()
                    tw(f,{BackgroundColor3=P.lift},TI_SNAP)
                    task.wait(0.1); tw(f,{BackgroundColor3=P.deep},TI_MED)
                    safe(bc.Callback)
                end)

                local BV={Settings=bc}
                function BV:Set(s) s=def(bc,s or {}); bc=s end
                function BV:Destroy() f:Destroy() end; return BV
            end

            -- ── TOGGLE ────────────────────────────────────────────────────────
            function Sec:CreateToggle(tc)
                tc=def({Name="Toggle",Description=nil,CurrentValue=false,Flag=nil,Callback=function()end},tc or {})
                local h=tc.Description and 50 or 34
                local f=Elem(h)

                T({Txt=tc.Name,Sz=UDim2.new(1,-60,0,15),
                    Pos=UDim2.new(0,12,0,tc.Description and 8 or 10),
                    Font=Enum.Font.GothamSemibold,TS=13,Col=P.hi,Z=4,Par=f})
                if tc.Description then
                    T({Txt=tc.Description,Sz=UDim2.new(1,-60,0,12),
                        Pos=UDim2.new(0,12,0,26),Font=Enum.Font.Gotham,TS=11,Col=P.mid,Z=4,Par=f})
                end

                -- Track (pill)
                local trk=Instance.new("Frame")
                trk.Size=UDim2.new(0,38,0,20); trk.Position=UDim2.new(1,-48,0.5,0)
                trk.AnchorPoint=Vector2.new(0,0.5); trk.BackgroundColor3=P.raised
                trk.BorderSizePixel=0; trk.ZIndex=4; trk.Parent=f
                Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)
                local trkS=Instance.new("UIStroke"); trkS.Color=P.wire; trkS.Transparency=0.4; trkS.Parent=trk

                local knob=Instance.new("Frame")
                knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(0,3,0.5,0)
                knob.AnchorPoint=Vector2.new(0,0.5); knob.BackgroundColor3=P.mid
                knob.BorderSizePixel=0; knob.ZIndex=5; knob.Parent=trk
                Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

                local TV={CurrentValue=tc.CurrentValue,Type="Toggle",Settings=tc}
                local function upd()
                    if TV.CurrentValue then
                        tw(trk,{BackgroundColor3=P.limeDD},TI_MED)
                        tw(trkS,{Color=P.lime,Transparency=0.5},TI_MED)
                        tw(knob,{Position=UDim2.new(0,21,0.5,0),BackgroundColor3=P.lime},TI_SPRING)
                    else
                        tw(trk,{BackgroundColor3=P.raised},TI_MED)
                        tw(trkS,{Color=P.wire,Transparency=0.4},TI_MED)
                        tw(knob,{Position=UDim2.new(0,3,0.5,0),BackgroundColor3=P.mid},TI_SPRING)
                    end
                end
                upd()
                HoverElem(f)
                CL(f,5).MouseButton1Click:Connect(function()
                    TV.CurrentValue=not TV.CurrentValue; upd(); safe(tc.Callback,TV.CurrentValue)
                end)
                function TV:Set(v) TV.CurrentValue=v; upd(); safe(tc.Callback,v) end
                function TV:Destroy() f:Destroy() end
                if tc.Flag then Sentence.Flags[tc.Flag]=TV; Sentence.Options[tc.Flag]=TV end
                return TV
            end

            -- ── SLIDER ────────────────────────────────────────────────────────
            function Sec:CreateSlider(sc)
                sc=def({Name="Slider",Range={0,100},Increment=1,CurrentValue=50,Suffix="",Flag=nil,Callback=function()end},sc or {})
                local f=Elem(50)

                local valL=T({Txt=tostring(sc.CurrentValue)..sc.Suffix,
                    Sz=UDim2.new(0,80,0,15),Pos=UDim2.new(1,-12,0,8),AP=Vector2.new(1,0),
                    Font=Enum.Font.GothamBold,TS=12,Col=P.lime,
                    AX=Enum.TextXAlignment.Right,Z=4,Par=f})
                T({Txt=sc.Name,Sz=UDim2.new(1,-100,0,15),
                    Pos=UDim2.new(0,12,0,8),Font=Enum.Font.GothamSemibold,TS=13,Col=P.hi,Z=4,Par=f})

                -- Track
                local barBg=F({Sz=UDim2.new(1,-24,0,4),Pos=UDim2.new(0,12,0,34),
                    Bg=P.raised,BgA=0,R=UDim.new(1,0),Z=4,Par=f})
                local fillF=F({Sz=UDim2.new(0,0,1,0),Bg=P.lime,R=UDim.new(1,0),Z=5,Par=barBg})
                -- Thumb dot
                local thumb=F({Sz=UDim2.new(0,10,0,10),Pos=UDim2.new(0,0,0.5,0),AP=Vector2.new(0.5,0.5),
                    Bg=P.lime,R=UDim.new(1,0),Z=6,Par=barBg})
                local tS=Instance.new("UIStroke"); tS.Color=P.void; tS.Thickness=2; tS.Transparency=0; tS.Parent=thumb

                local SV={CurrentValue=sc.CurrentValue,Type="Slider",Settings=sc}
                local mn,mx,inc=sc.Range[1],sc.Range[2],sc.Increment

                local function setV(v)
                    v=math.clamp(v,mn,mx)
                    v=math.floor(v/inc+0.5)*inc
                    v=tonumber(string.format("%.10g",v))
                    SV.CurrentValue=v
                    valL.Text=tostring(v)..sc.Suffix
                    local pct=(v-mn)/(mx-mn)
                    tw(fillF,{Size=UDim2.new(pct,0,1,0)},TI_FAST)
                    tw(thumb,{Position=UDim2.new(pct,0,0.5,0)},TI_FAST)
                end
                setV(sc.CurrentValue)

                local drag=false
                local bCL=CL(barBg,7)
                local function fromInp(i)
                    local rel=math.clamp((i.Position.X-barBg.AbsolutePosition.X)/barBg.AbsoluteSize.X,0,1)
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
                HoverElem(f)
                function SV:Set(v) setV(v); safe(sc.Callback,SV.CurrentValue) end
                function SV:Destroy() f:Destroy() end
                if sc.Flag then Sentence.Flags[sc.Flag]=SV; Sentence.Options[sc.Flag]=SV end
                return SV
            end

            -- ── DROPDOWN ──────────────────────────────────────────────────────
            function Sec:CreateDropdown(dc)
                dc=def({Name="Dropdown",Description=nil,Options={},CurrentOption=nil,MultipleOptions=false,SpecialType=nil,Flag=nil,Callback=function()end},dc or {})
                if dc.SpecialType=="Player" then
                    dc.Options={}; for _,p in ipairs(Plrs:GetPlayers()) do table.insert(dc.Options,p.Name) end
                end
                if type(dc.CurrentOption)=="string" then dc.CurrentOption={dc.CurrentOption} end
                dc.CurrentOption=dc.CurrentOption or {dc.Options[1] or ""}

                local cH=dc.Description and 50 or 34
                local f=Elem(cH); f.ClipsDescendants=true

                T({Txt=dc.Name,Sz=UDim2.new(1,-80,0,15),
                    Pos=UDim2.new(0,12,0,dc.Description and 8 or 10),
                    Font=Enum.Font.GothamSemibold,TS=13,Col=P.hi,Z=4,Par=f})
                if dc.Description then
                    T({Txt=dc.Description,Sz=UDim2.new(1,-80,0,12),
                        Pos=UDim2.new(0,12,0,26),Font=Enum.Font.Gotham,TS=11,Col=P.mid,Z=4,Par=f})
                end
                local selL=T({Txt=table.concat(dc.CurrentOption,", "),
                    Sz=UDim2.new(0,100,0,13),Pos=UDim2.new(1,-48,0,dc.Description and 10 or 11),
                    AP=Vector2.new(1,0),Font=Enum.Font.Gotham,TS=11,Col=P.dim,
                    AX=Enum.TextXAlignment.Right,Z=4,Par=f})
                local arrIco=I({Ico="chev_d",Sz=UDim2.new(0,14,0,14),
                    Pos=UDim2.new(1,-24,0,dc.Description and 11 or 10),Col=P.dim,Z=5,Par=f})

                -- Option list
                local optList=Instance.new("Frame")
                optList.Size=UDim2.new(1,-12,0,0); optList.Position=UDim2.new(0,6,0,cH+4)
                optList.BackgroundTransparency=1; optList.AutomaticSize=Enum.AutomaticSize.Y
                optList.ZIndex=4; optList.Parent=f
                LL(optList,2)

                local opened=false
                local sel={}; for _,o in ipairs(dc.CurrentOption) do sel[o]=true end
                local DV={CurrentOption=dc.CurrentOption,Type="Dropdown",Settings=dc}

                local function refOpts()
                    for _,c in ipairs(optList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                    for _,o in ipairs(dc.Options) do
                        local isS=sel[o]
                        local of=F({Sz=UDim2.new(1,0,0,26),
                            Bg=isS and P.surface or P.deep,BgA=isS and 0 or 0.2,
                            S=true,SC=P.wire,SA=0.7,R=UDim.new(0,5),Z=5,Par=optList})
                        if isS then
                            F({Sz=UDim2.new(0,2,0.6,0),Pos=UDim2.new(0,0,0.2,0),
                                Bg=P.lime,R=UDim.new(1,0),Z=6,Par=of})
                        end
                        T({Txt=o,Sz=UDim2.new(1,-28,1,0),Pos=UDim2.new(0,isS and 10 or 8,0,0),
                            Font=Enum.Font.Gotham,TS=12,Col=isS and P.hi or P.mid,Z=6,Par=of})
                        if isS then
                            T({Txt="✓",Sz=UDim2.new(0,16,1,0),Pos=UDim2.new(1,-18,0,0),
                                Font=Enum.Font.GothamBold,TS=11,Col=P.lime,
                                AX=Enum.TextXAlignment.Right,Z=6,Par=of})
                        end
                        CL(of,7).MouseButton1Click:Connect(function()
                            if dc.MultipleOptions then sel[o]=not sel[o]
                            else sel={}; sel[o]=true; opened=false; tw(arrIco,{Rotation=0}); tw(f,{Size=UDim2.new(1,0,0,cH)},TI_MED) end
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
                    tw(arrIco,{Rotation=opened and 180 or 0})
                    tw(f,{Size=UDim2.new(1,0,0,opened and math.min(cH+8+#dc.Options*28,cH+160) or cH)},TI_MED)
                end)
                HoverElem(f)
                function DV:Set(o) if type(o)=="table" then dc.CurrentOption=o else dc.CurrentOption={o} end; sel={}; for _,v in ipairs(dc.CurrentOption) do sel[v]=true end; selL.Text=table.concat(dc.CurrentOption,", "); refOpts() end
                function DV:Refresh(o) dc.Options=o; refOpts() end
                function DV:Destroy() f:Destroy() end
                if dc.Flag then Sentence.Flags[dc.Flag]=DV; Sentence.Options[dc.Flag]=DV end
                return DV
            end

            -- ── INPUT ─────────────────────────────────────────────────────────
            function Sec:CreateInput(ic)
                ic=def({Name="Input",Description=nil,PlaceholderText="Type...",CurrentValue="",RemoveTextAfterFocusLost=false,Numeric=false,MaxCharacters=nil,Enter=false,Flag=nil,Callback=function()end},ic or {})
                local h=ic.Description and 50 or 34
                local f=Elem(h)
                T({Txt=ic.Name,Sz=UDim2.new(1,-148,0,15),
                    Pos=UDim2.new(0,12,0,ic.Description and 8 or 10),
                    Font=Enum.Font.GothamSemibold,TS=13,Col=P.hi,Z=4,Par=f})
                if ic.Description then
                    T({Txt=ic.Description,Sz=UDim2.new(1,-148,0,12),
                        Pos=UDim2.new(0,12,0,26),Font=Enum.Font.Gotham,TS=11,Col=P.mid,Z=4,Par=f})
                end
                local ib=Instance.new("TextBox")
                ib.Size=UDim2.new(0,118,0,22); ib.Position=UDim2.new(1,-10,0.5,0); ib.AnchorPoint=Vector2.new(1,0.5)
                ib.BackgroundColor3=P.raised; ib.BackgroundTransparency=0; ib.BorderSizePixel=0
                ib.Font=Enum.Font.Gotham; ib.TextSize=12; ib.TextColor3=P.hi
                ib.PlaceholderText=ic.PlaceholderText; ib.PlaceholderColor3=P.dim
                ib.Text=ic.CurrentValue; ib.ClearTextOnFocus=false; ib.ZIndex=5; ib.Parent=f
                Instance.new("UICorner",ib).CornerRadius=UDim.new(0,5)
                local ibS=Instance.new("UIStroke"); ibS.Color=P.wire; ibS.Transparency=0.35; ibS.Parent=ib
                PD(ib,0,0,8,8)
                ib.Focused:Connect(function() tw(ibS,{Color=P.lime,Transparency=0.3},TI_FAST) end)
                ib.FocusLost:Connect(function() tw(ibS,{Color=P.wire,Transparency=0.35},TI_FAST) end)

                local IV={CurrentValue=ic.CurrentValue,Type="Input",Settings=ic}
                if ic.Numeric then ib:GetPropertyChangedSignal("Text"):Connect(function() if not tonumber(ib.Text) and ib.Text~="" and ib.Text~="." and ib.Text~="-" then ib.Text=ib.Text:match("[%-0-9.]*") or "" end end) end
                if ic.MaxCharacters then ib:GetPropertyChangedSignal("Text"):Connect(function() if #ib.Text>ic.MaxCharacters then ib.Text=ib.Text:sub(1,ic.MaxCharacters) end end) end
                ib.FocusLost:Connect(function(enter)
                    if ic.Enter and not enter then return end
                    IV.CurrentValue=ib.Text; safe(ic.Callback,ib.Text)
                    if ic.RemoveTextAfterFocusLost then ib.Text="" end
                end)
                if not ic.Enter then ib:GetPropertyChangedSignal("Text"):Connect(function() IV.CurrentValue=ib.Text; safe(ic.Callback,ib.Text) end) end
                HoverElem(f)
                function IV:Set(v) ib.Text=tostring(v); IV.CurrentValue=tostring(v) end
                function IV:Destroy() f:Destroy() end
                if ic.Flag then Sentence.Flags[ic.Flag]=IV; Sentence.Options[ic.Flag]=IV end
                return IV
            end

            -- ── KEYBIND ───────────────────────────────────────────────────────
            function Sec:CreateBind(bc)
                bc=def({Name="Keybind",Description=nil,CurrentBind="E",HoldToInteract=false,Flag=nil,Callback=function()end,OnChangedCallback=function()end},bc or {})
                local h=bc.Description and 50 or 34
                local f=Elem(h)
                T({Txt=bc.Name,Sz=UDim2.new(1,-90,0,15),
                    Pos=UDim2.new(0,12,0,bc.Description and 8 or 10),
                    Font=Enum.Font.GothamSemibold,TS=13,Col=P.hi,Z=4,Par=f})
                if bc.Description then
                    T({Txt=bc.Description,Sz=UDim2.new(1,-90,0,12),
                        Pos=UDim2.new(0,12,0,26),Font=Enum.Font.Gotham,TS=11,Col=P.mid,Z=4,Par=f})
                end
                local bb=Instance.new("TextBox")
                bb.Size=UDim2.new(0,64,0,22); bb.Position=UDim2.new(1,-10,0.5,0); bb.AnchorPoint=Vector2.new(1,0.5)
                bb.BackgroundColor3=P.raised; bb.BackgroundTransparency=0; bb.BorderSizePixel=0
                bb.Font=Enum.Font.GothamBold; bb.TextSize=12; bb.TextColor3=P.lime
                bb.Text=bc.CurrentBind; bb.ClearTextOnFocus=true; bb.ZIndex=5; bb.Parent=f
                Instance.new("UICorner",bb).CornerRadius=UDim.new(0,5)
                local bbS=Instance.new("UIStroke"); bbS.Color=P.wire; bbS.Transparency=0.35; bbS.Parent=bb

                local BV={CurrentBind=bc.CurrentBind,Active=false,Type="Keybind",Settings=bc}
                local checking=false
                bb.Focused:Connect(function() checking=true; bb.Text="..."; tw(bbS,{Color=P.lime,Transparency=0.3},TI_FAST) end)
                bb.FocusLost:Connect(function() checking=false; tw(bbS,{Color=P.wire,Transparency=0.35},TI_FAST); if bb.Text=="..." or bb.Text=="" then bb.Text=BV.CurrentBind end end)
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
                            else safe(bc.Callback,true); local c; c=inp.Changed:Connect(function(pr) if pr=="UserInputState" then c:Disconnect(); safe(bc.Callback,false) end end) end
                        end
                    end
                end))
                HoverElem(f)
                function BV:Set(v) BV.CurrentBind=v; bc.CurrentBind=v; bb.Text=v end
                function BV:Destroy() f:Destroy() end
                Sec.CreateKeybind=Sec.CreateBind
                if bc.Flag then Sentence.Flags[bc.Flag]=BV; Sentence.Options[bc.Flag]=BV end
                return BV
            end
            Sec.CreateKeybind=Sec.CreateBind

            -- ── COLOR PICKER ──────────────────────────────────────────────────
            function Sec:CreateColorPicker(cc)
                cc=def({Name="Color",Color=Color3.fromRGB(174,255,94),Flag=nil,Callback=function()end},cc or {})
                local cH=34
                local f=Elem(cH); f.ClipsDescendants=true
                T({Txt=cc.Name,Sz=UDim2.new(1,-55,0,15),
                    Pos=UDim2.new(0,12,0,10),Font=Enum.Font.GothamSemibold,TS=13,Col=P.hi,Z=4,Par=f})
                local prev=F({Sz=UDim2.new(0,22,0,22),Pos=UDim2.new(1,-32,0,6),
                    Bg=cc.Color,R=UDim.new(0,5),S=true,SC=P.wire,SA=0.4,Z=5,Par=f})

                local pArea=Instance.new("Frame"); pArea.Size=UDim2.new(1,-12,0,128)
                pArea.Position=UDim2.new(0,6,0,40); pArea.BackgroundTransparency=1; pArea.ZIndex=4; pArea.Parent=f

                local svBox=Instance.new("Frame"); svBox.Size=UDim2.new(1,0,0,96)
                svBox.BackgroundColor3=Color3.fromHSV(0,1,1); svBox.BorderSizePixel=0; svBox.ZIndex=5; svBox.Parent=pArea
                Instance.new("UICorner",svBox).CornerRadius=UDim.new(0,6)
                local wG=Instance.new("UIGradient"); wG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}; wG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}; wG.Parent=svBox
                local bOv=Instance.new("Frame"); bOv.Size=UDim2.new(1,0,1,0); bOv.BackgroundColor3=Color3.new(0,0,0); bOv.BorderSizePixel=0; bOv.ZIndex=6; bOv.Parent=svBox
                Instance.new("UICorner",bOv).CornerRadius=UDim.new(0,6)
                local bG=Instance.new("UIGradient"); bG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}; bG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}; bG.Rotation=90; bG.Parent=bOv

                local hBar=Instance.new("Frame"); hBar.Size=UDim2.new(1,0,0,14); hBar.Position=UDim2.new(0,0,0,102); hBar.BackgroundColor3=Color3.new(1,1,1); hBar.BorderSizePixel=0; hBar.ZIndex=5; hBar.Parent=pArea
                Instance.new("UICorner",hBar).CornerRadius=UDim.new(0,4)
                local hG=Instance.new("UIGradient"); hG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))}; hG.Parent=hBar

                local opened=false; local h2,s2,v2=Color3.toHSV(cc.Color)
                local CPV={Color=cc.Color,Type="ColorPicker",Settings=cc}
                local function updCol() CPV.Color=Color3.fromHSV(h2,s2,v2); prev.BackgroundColor3=CPV.Color; svBox.BackgroundColor3=Color3.fromHSV(h2,1,1); safe(cc.Callback,CPV.Color) end
                local hBtn3=Instance.new("TextButton"); hBtn3.Size=UDim2.new(1,0,0,cH); hBtn3.BackgroundTransparency=1; hBtn3.Text=""; hBtn3.ZIndex=8; hBtn3.Parent=f
                hBtn3.MouseButton1Click:Connect(function() opened=not opened; tw(f,{Size=UDim2.new(1,0,0,opened and 175 or cH)},TI_MED) end)

                local svDrg=false; local svCL=CL(bOv,9)
                local function upSV(i) s2=math.clamp((i.Position.X-svBox.AbsolutePosition.X)/svBox.AbsoluteSize.X,0,1); v2=1-math.clamp((i.Position.Y-svBox.AbsolutePosition.Y)/svBox.AbsoluteSize.Y,0,1); updCol() end
                svCL.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrg=true; upSV(i) end end)
                svCL.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrg=false end end)
                local hDrg=false; local hCL3=CL(hBar,9)
                local function upH(i) h2=math.clamp((i.Position.X-hBar.AbsolutePosition.X)/hBar.AbsoluteSize.X,0,1); updCol() end
                hCL3.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hDrg=true; upH(i) end end)
                hCL3.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hDrg=false end end)
                track(UIS.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then if svDrg then upSV(i) end; if hDrg then upH(i) end end end))
                HoverElem(f)
                function CPV:Set(s) if s.Color then h2,s2,v2=Color3.toHSV(s.Color); updCol() end end
                function CPV:Destroy() f:Destroy() end
                if cc.Flag then Sentence.Flags[cc.Flag]=CPV; Sentence.Options[cc.Flag]=CPV end
                return CPV
            end

            function Sec:Set(n) local l=shRow:FindFirstChildOfClass("TextLabel"); if l then l.Text="<font color='rgb(174,255,94)'>"..string.format("%02d",_secCount).." /</font>  "..n:upper() end end
            function Sec:Destroy() shRow:Destroy(); secCon:Destroy() end
            return Sec
        end

        -- Tab-level shortcuts
        local _ds
        local function gds() if not _ds then _ds=Tab:CreateSection("") end return _ds end
        for _,m in ipairs({"CreateButton","CreateLabel","CreateParagraph","CreateToggle","CreateSlider","CreateDivider","CreateDropdown","CreateInput","CreateBind","CreateKeybind","CreateColorPicker"}) do
            Tab[m]=function(self,...) return gds()[m](gds(),...) end
        end
        return Tab
    end

    -- ── Config Save / Load ────────────────────────────────────────────────────
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
            local fld=cfg.ConfigurationSaving.FolderName or "SENTENCE"
            local fn=cfg.ConfigurationSaving.FileName or "config"
            if isfolder and not isfolder(fld) then makefolder(fld) end
            writefile(fld.."/"..fn..".json",HS:JSONEncode(data))
        end)
    end

    function W:LoadConfiguration()
        if not cfg.ConfigurationSaving or not cfg.ConfigurationSaving.Enabled then return end
        pcall(function()
            local fld=cfg.ConfigurationSaving.FolderName or "SENTENCE"
            local fn=cfg.ConfigurationSaving.FileName or "config"
            local path=fld.."/"..fn..".json"
            if isfile and isfile(path) then
                local data=HS:JSONDecode(readfile(path))
                for k,v in pairs(data) do
                    local flag=Sentence.Flags[k]
                    if flag then
                        if flag.Type=="ColorPicker" then flag:Set({Color=Color3.fromRGB(v.R,v.G,v.B)})
                        else flag:Set(v) end
                    end
                end
                Sentence:Notify({Title="Config loaded",Content="Restored successfully.",Icon="save",Type="Success"})
            end
        end)
    end

    return W
end

-- ── Destroy ───────────────────────────────────────────────────────────────────
function Sentence:Destroy()
    for _,c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    self._conns={}
    if self._notifBin and self._notifBin.Parent then
        self._notifBin.Parent:Destroy()
    end
    self.Flags={}; self.Options={}
end

return Sentence
