--[[
    ╔═══════════════════════════════════════╗
    ║         SENTENCE UI LIBRARY           ║
    ║         Glass Morphism Edition        ║
    ║         Theme: OG Sentence            ║
    ╚═══════════════════════════════════════╝

    Original authorship — SENTENCE Project
    Glass-style UI with blur, smooth spring animations,
    and the signature OG Sentence aesthetic.
]]

-- ─── Services ────────────────────────────────────────────────────────────────
local uis           = game:GetService("UserInputService")
local players       = game:GetService("Players")
local ws            = game:GetService("Workspace")
local rs            = game:GetService("ReplicatedStorage")
local http          = game:GetService("HttpService")
local gui_svc       = game:GetService("GuiService")
local lighting      = game:GetService("Lighting")
local run           = game:GetService("RunService")
local tween_svc     = game:GetService("TweenService")
local coregui       = game:GetService("CoreGui")

-- ─── Aliases ─────────────────────────────────────────────────────────────────
local v2            = Vector2.new
local v3            = Vector3.new
local ud2           = UDim2.new
local ud            = UDim.new
local ud2o          = UDim2.fromOffset
local ud2s          = UDim2.fromScale
local cfr           = CFrame.new
local rc            = Rect.new

local c3            = Color3.new
local rgb           = Color3.fromRGB
local hex           = Color3.fromHex
local hsv           = Color3.fromHSV
local cseq          = ColorSequence.new
local ckey          = ColorSequenceKeypoint.new
local nseq          = NumberSequence.new
local nkey          = NumberSequenceKeypoint.new

local floor         = math.floor
local clamp         = math.clamp
local abs           = math.abs
local sin           = math.sin
local pi            = math.pi
local random        = math.random
local max           = math.max
local min           = math.min

local insert        = table.insert
local find          = table.find
local remove        = table.remove
local concat        = table.concat

local camera        = ws.CurrentCamera
local lp            = players.LocalPlayer
local mouse         = lp:GetMouse()
local gui_offset    = gui_svc:GetGuiInset().Y

-- ─── Theme: OG Sentence ──────────────────────────────────────────────────────
local theme = {
    -- Core backgrounds
    bg_primary      = hex("121212"),
    bg_secondary    = hex("161616"),
    bg_tertiary     = hex("1a1a1a"),
    bg_glass        = hex("0d0d0f"),   -- glass base (very dark, used with transparency)
    
    -- Borders
    border          = hex("252525"),
    border_light    = hex("2d2d2d"),
    
    -- Accent
    accent          = hex("5A9FE8"),
    accent_dim      = hex("4580C9"),
    accent_glow     = hex("7BB5ED"),
    
    -- Text
    text_primary    = hex("E8E8E8"),
    text_secondary  = hex("909090"),
    text_muted      = hex("505050"),
    text_accent     = hex("5A9FE8"),
    
    -- Glass tints
    glass_white     = hex("FFFFFF"),   -- used with transparency for shimmer
    glass_surface   = hex("1C1C1E"),   -- slightly elevated glass surface
    
    -- Interactive states
    btn_normal      = hex("1f1f1f"),
    btn_hover       = hex("252525"),
    btn_pressed     = hex("161616"),
    btn_disabled    = hex("141414"),
    
    -- Notification
    notif_bg        = hex("202020"),
    
    -- Special
    shadow          = hex("000000"),
    transparent     = c3(0,0,0),
}

-- ─── Animation Config ─────────────────────────────────────────────────────────
local anim = {
    -- Standard durations
    fast    = 0.12,
    normal  = 0.22,
    slow    = 0.38,
    spring  = 0.45,
    
    -- Easing styles
    out     = Enum.EasingStyle.Quint,
    inout   = Enum.EasingStyle.Quint,
    quad    = Enum.EasingStyle.Quad,
    back    = Enum.EasingStyle.Back,
    elastic = Enum.EasingStyle.Elastic,
    bounce  = Enum.EasingStyle.Bounce,
    linear  = Enum.EasingStyle.Linear,
    
    dir_in  = Enum.EasingDirection.In,
    dir_out = Enum.EasingDirection.Out,
    dir_io  = Enum.EasingDirection.InOut,
}

-- ─── Key map ─────────────────────────────────────────────────────────────────
local keymap = {
    [Enum.KeyCode.LeftShift]        = "LSHIFT",
    [Enum.KeyCode.RightShift]       = "RSHIFT",
    [Enum.KeyCode.LeftControl]      = "LCTRL",
    [Enum.KeyCode.RightControl]     = "RCTRL",
    [Enum.KeyCode.LeftAlt]          = "LALT",
    [Enum.KeyCode.RightAlt]         = "RALT",
    [Enum.KeyCode.Insert]           = "INS",
    [Enum.KeyCode.Backspace]        = "BKSP",
    [Enum.KeyCode.Return]           = "ENTER",
    [Enum.KeyCode.CapsLock]         = "CAPS",
    [Enum.KeyCode.Escape]           = "ESC",
    [Enum.KeyCode.Space]            = "SPACE",
    [Enum.KeyCode.Delete]           = "DEL",
    [Enum.KeyCode.Tab]              = "TAB",
    [Enum.KeyCode.One]              = "1",  [Enum.KeyCode.Two]    = "2",
    [Enum.KeyCode.Three]            = "3",  [Enum.KeyCode.Four]   = "4",
    [Enum.KeyCode.Five]             = "5",  [Enum.KeyCode.Six]    = "6",
    [Enum.KeyCode.Seven]            = "7",  [Enum.KeyCode.Eight]  = "8",
    [Enum.KeyCode.Nine]             = "9",  [Enum.KeyCode.Zero]   = "0",
    [Enum.KeyCode.F1]  = "F1",  [Enum.KeyCode.F2]  = "F2",  [Enum.KeyCode.F3]  = "F3",
    [Enum.KeyCode.F4]  = "F4",  [Enum.KeyCode.F5]  = "F5",  [Enum.KeyCode.F6]  = "F6",
    [Enum.KeyCode.F7]  = "F7",  [Enum.KeyCode.F8]  = "F8",  [Enum.KeyCode.F9]  = "F9",
    [Enum.KeyCode.F10] = "F10", [Enum.KeyCode.F11] = "F11", [Enum.KeyCode.F12] = "F12",
    [Enum.KeyCode.Minus]            = "-",
    [Enum.KeyCode.Equals]           = "=",
    [Enum.KeyCode.LeftBracket]      = "[",
    [Enum.KeyCode.RightBracket]     = "]",
    [Enum.KeyCode.BackSlash]        = "\\",
    [Enum.KeyCode.Semicolon]        = ";",
    [Enum.KeyCode.Quote]            = "'",
    [Enum.KeyCode.Comma]            = ",",
    [Enum.KeyCode.Period]           = ".",
    [Enum.KeyCode.Slash]            = "/",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

-- ─── Library Init ─────────────────────────────────────────────────────────────
getgenv().sentence = {
    directory   = "sentence",
    folders     = { "/configs", "/themes" },
    flags       = {},
    cfg_flags   = {},
    connections = {},
    notifs      = { queue = {} },
    current_open = nil,
    cache       = nil, -- set during window init
    items       = nil,
    overlay     = nil,
    theme       = theme,
}

local lib = sentence
lib.__index = lib

for _, p in lib.folders do
    makefolder(lib.directory .. p)
end

local flags     = lib.flags
local cfg_flags = lib.cfg_flags

-- ─── Font Loader ─────────────────────────────────────────────────────────────
local fonts = {}; do
    local function load_font(id, weight, style, url)
        if not isfile(id) then
            writefile(id, game:HttpGet(url))
        end
        local def = {
            name  = id:gsub("%.ttf", ""),
            faces = {{ name = "Normal", weight = weight, style = style,
                       assetId = getcustomasset(id) }},
        }
        local fpath = id:gsub("%.ttf", ".font")
        if isfile(fpath) then delfile(fpath) end
        writefile(fpath, http:JSONEncode(def))
        return getcustomasset(fpath)
    end

    local inter_reg = load_font("SN_Inter_Regular.ttf", 400, "Normal",
        "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-Medium.ttf")
    local inter_med = load_font("SN_Inter_Medium.ttf",  500, "Normal",
        "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-Medium.ttf")
    local inter_sb  = load_font("SN_Inter_SemiBold.ttf", 600, "Normal",
        "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-SemiBold.ttf")

    fonts.small    = Font.new(inter_reg, Enum.FontWeight.Regular,  Enum.FontStyle.Normal)
    fonts.body     = Font.new(inter_med, Enum.FontWeight.Regular,  Enum.FontStyle.Normal)
    fonts.label    = Font.new(inter_sb,  Enum.FontWeight.Regular,  Enum.FontStyle.Normal)
    fonts.heading  = Font.new(inter_sb,  Enum.FontWeight.Regular,  Enum.FontStyle.Normal)
end

-- ─── Core Utilities ──────────────────────────────────────────────────────────

-- Smooth tween wrapper
function lib:tween(obj, props, style, duration, dir)
    local info = TweenInfo.new(
        duration or anim.normal,
        style    or anim.out,
        dir      or anim.dir_out,
        0, false, 0
    )
    tween_svc:Create(obj, info, props):Play()
end

-- Spring-feel tween (overshoots slightly, settles)
function lib:spring(obj, props, duration)
    local info = TweenInfo.new(
        duration or anim.spring,
        anim.back,
        anim.dir_out,
        0, false, 0
    )
    tween_svc:Create(obj, info, props):Play()
end

-- Instance factory
function lib:new(class, props)
    local inst = Instance.new(class)
    for k, v in props do inst[k] = v end
    return inst
end

-- Connection tracker
function lib:connect(sig, fn)
    local c = sig:Connect(fn)
    insert(lib.connections, c)
    return c
end

-- Round helper
function lib:round(n, interval)
    interval = interval or 1
    return floor(n / interval + 0.5) * interval
end

-- Mouse-in-frame test
function lib:in_bounds(ui)
    local ap = ui.AbsolutePosition
    local as = ui.AbsoluteSize
    return mouse.X >= ap.X and mouse.X <= ap.X + as.X
       and mouse.Y >= ap.Y and mouse.Y <= ap.Y + as.Y
end

-- Flag counter
function lib:next_flag()
    local n = 0
    for _ in flags do n += 1 end
    return ("sn_flag_%d"):format(n + 1)
end

-- Enum string → Enum value
function lib:str_to_enum(s)
    local parts = {}
    for p in s:gmatch("[%w_]+") do insert(parts, p) end
    local t = Enum
    for i = 2, #parts do t = t[parts[i]] end
    return t
end

-- Open/close element manager
function lib:close_element(next_path)
    local open = lib.current_open
    if open and open ~= next_path then
        open.set_visible(false)
        open.open = false
    end
    if next_path ~= open then
        lib.current_open = next_path or nil
    end
end

-- Drag handler
function lib:draggify(frame, handle)
    handle = handle or frame
    local dragging, start_pos, start_input = false, nil, nil

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging   = true
            start_pos  = frame.Position
            start_input = i.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    lib:connect(uis.InputChanged, function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local vp = camera.ViewportSize
        local new = ud2(0,
            clamp(start_pos.X.Offset + (i.Position.X - start_input.X), 0, vp.X - frame.AbsoluteSize.X),
            0,
            clamp(start_pos.Y.Offset + (i.Position.Y - start_input.Y), 0, vp.Y - frame.AbsoluteSize.Y)
        )
        lib:tween(frame, { Position = new }, anim.linear, 0.04)
        lib:close_element()
    end)
end

-- Resize handler (bottom-right corner)
function lib:resizify(frame, min_size)
    min_size = min_size or v2(400, 300)

    local grip = lib:new("TextButton", {
        Parent              = frame,
        Size                = ud2(0, 14, 0, 14),
        Position            = ud2(1, -14, 1, -14),
        BackgroundColor3    = theme.accent,
        BackgroundTransparency = 0.7,
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 50,
    })
    lib:new("UICorner", { Parent = grip, CornerRadius = ud(0, 3) })

    local resizing, start_sz, start_in = false, nil, nil

    grip.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            start_sz = frame.Size
            start_in = i.Position
        end
    end)
    grip.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    lib:connect(uis.InputChanged, function(i)
        if not resizing then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local vp = camera.ViewportSize
        local new = ud2(0,
            clamp(start_sz.X.Offset + (i.Position.X - start_in.X), min_size.X, vp.X),
            0,
            clamp(start_sz.Y.Offset + (i.Position.Y - start_in.Y), min_size.Y, vp.Y)
        )
        lib:tween(frame, { Size = new }, anim.linear, 0.04)
    end)
end

-- Ripple effect on click (glass aesthetic)
function lib:ripple(button, color)
    color = color or theme.accent
    local ap  = button.AbsolutePosition
    local as  = button.AbsoluteSize

    local mx  = clamp(mouse.X - ap.X, 0, as.X)
    local my  = clamp(mouse.Y - ap.Y, 0, as.Y)

    local diameter = max(as.X, as.Y) * 1.6

    local circle = lib:new("Frame", {
        Parent              = button,
        Size                = ud2(0, 0, 0, 0),
        Position            = ud2(0, mx, 0, my),
        AnchorPoint         = v2(0.5, 0.5),
        BackgroundColor3    = color,
        BackgroundTransparency = 0.75,
        BorderSizePixel     = 0,
        ZIndex              = button.ZIndex + 1,
        ClipsDescendants    = false,
    })
    lib:new("UICorner", { Parent = circle, CornerRadius = ud(0, 9999) })

    lib:tween(circle, { Size = ud2(0, diameter, 0, diameter), BackgroundTransparency = 1 }, anim.quad, 0.5)
    task.delay(0.5, function() circle:Destroy() end)
end

-- Hover highlight helper
function lib:hoverable(btn, normal_col, hover_col, press_col)
    normal_col = normal_col or theme.btn_normal
    hover_col  = hover_col  or theme.btn_hover
    press_col  = press_col  or theme.btn_pressed

    btn.MouseEnter:Connect(function()
        lib:tween(btn, { BackgroundColor3 = hover_col }, anim.quad, anim.fast)
    end)
    btn.MouseLeave:Connect(function()
        lib:tween(btn, { BackgroundColor3 = normal_col }, anim.quad, anim.fast)
    end)
    btn.MouseButton1Down:Connect(function()
        lib:tween(btn, { BackgroundColor3 = press_col }, anim.quad, 0.05)
        lib:ripple(btn)
    end)
    btn.MouseButton1Up:Connect(function()
        lib:tween(btn, { BackgroundColor3 = hover_col }, anim.quad, anim.fast)
    end)
end

-- Glass frame factory (core visual building block)
function lib:glass_frame(props)
    -- props: Parent, Size, Position, Transparency, ZIndex, Radius, BorderAlpha
    local transparency  = props.Transparency  or 0.55
    local border_alpha  = props.BorderAlpha   or 0.6
    local radius        = props.Radius        or 10
    local z             = props.ZIndex        or 1

    local outer = lib:new("Frame", {
        Parent              = props.Parent,
        Size                = props.Size   or ud2(1, 0, 1, 0),
        Position            = props.Position or ud2(0,0,0,0),
        BackgroundColor3    = theme.bg_glass,
        BackgroundTransparency = transparency,
        BorderSizePixel     = 0,
        ZIndex              = z,
        Name                = props.Name or "\0",
        ClipsDescendants    = props.ClipsDescendants or false,
    })
    lib:new("UICorner", { Parent = outer, CornerRadius = ud(0, radius) })

    -- Border stroke (glass edge)
    lib:new("UIStroke", {
        Parent              = outer,
        Color               = theme.border_light,
        Transparency        = border_alpha,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
        Thickness           = 1,
    })

    -- Top-edge shimmer (glass highlight)
    local shimmer = lib:new("Frame", {
        Parent              = outer,
        Size                = ud2(0.6, 0, 0, 1),
        Position            = ud2(0.2, 0, 0, 0),
        BackgroundColor3    = theme.glass_white,
        BackgroundTransparency = 0.92,
        BorderSizePixel     = 0,
        ZIndex              = z + 1,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = shimmer, CornerRadius = ud(0, 999) })
    lib:new("UIGradient", {
        Parent      = shimmer,
        Transparency = nseq{ nkey(0,1), nkey(0.3,0), nkey(0.7,0), nkey(1,1) },
    })

    return outer
end

-- Config helpers
function lib:get_config()
    local out = {}
    for k, v in flags do
        if type(v) == "table" and v.key then
            out[k] = { active = v.active, mode = v.mode, key = tostring(v.key) }
        elseif type(v) == "table" and v.Color then
            out[k] = { Color = v.Color:ToHex(), Transparency = v.Transparency }
        else
            out[k] = v
        end
    end
    return http:JSONEncode(out)
end

function lib:load_config(json)
    local data = http:JSONDecode(json)
    for k, v in data do
        if k == "config_name_list" then continue end
        local fn = cfg_flags[k]
        if fn then
            if type(v) == "table" and v.Color then
                fn(hex(v.Color), v.Transparency)
            else
                fn(v)
            end
        end
    end
end

-- ─── Unload ──────────────────────────────────────────────────────────────────
function lib:unload()
    if lib.items  then lib.items:Destroy()   end
    if lib.overlay then lib.overlay:Destroy() end
    for _, c in lib.connections do pcall(function() c:Disconnect() end) end
    lib.connections = {}
    lib = nil
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:window(props)
    local cfg = {
        name        = props.name     or "SENTENCE",
        subtitle    = props.subtitle or "v1.0",
        game_info   = props.game_info or "SENTENCE Executor",
        size        = props.size     or ud2(0, 680, 0, 540),
        selected_tab = nil,
        items       = {},
    }

    -- ── Root ScreenGuis ────────────────────────────────────────────────────
    lib.items = lib:new("ScreenGui", {
        Parent          = coregui,
        Name            = "\0",
        Enabled         = true,
        ZIndexBehavior  = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset  = true,
        ResetOnSpawn    = false,
    })

    -- Off-screen cache for hidden tabs/elements
    lib.cache = lib:new("Frame", {
        Parent              = lib.items,
        Size                = ud2(0,1,0,1),
        Position            = ud2(0,-9999,0,-9999),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    -- Overlay ScreenGui (for dropdowns, colorpickers)
    lib.overlay = lib:new("ScreenGui", {
        Parent          = coregui,
        Name            = "\0",
        Enabled         = true,
        ZIndexBehavior  = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset  = true,
        ResetOnSpawn    = false,
    })

    -- ── Drop shadow ───────────────────────────────────────────────────────
    local shadow_img = lib:new("ImageLabel", {
        Parent              = lib.items,
        Size                = ud2(cfg.size.X.Scale, cfg.size.X.Offset + 80,
                                  cfg.size.Y.Scale, cfg.size.Y.Offset + 80),
        AnchorPoint         = v2(0.5, 0.5),
        Position            = ud2(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Image               = "rbxassetid://112971167999062",  -- soft shadow asset
        ImageColor3         = hex("000000"),
        ImageTransparency   = 0.5,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = rc(v2(100,100), v2(156,156)),
        SliceScale          = 0.8,
        ZIndex              = -10,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    -- ── Main Frame (glass) ────────────────────────────────────────────────
    local start_x = 0.5
    local start_y = 0.5

    local main = lib:new("Frame", {
        Parent              = lib.items,
        Size                = cfg.size,
        Position            = ud2(0.5, -cfg.size.X.Offset/2, 0.5, -cfg.size.Y.Offset/2),
        BackgroundColor3    = theme.bg_primary,
        BackgroundTransparency = 0.08,
        BorderSizePixel     = 0,
        Name                = "\0",
        ClipsDescendants    = false,
    })
    lib:new("UICorner", { Parent = main, CornerRadius = ud(0, 12) })

    -- Convert to offset position
    main.Position = ud2(0, main.AbsolutePosition.X, 0, main.AbsolutePosition.Y)
    shadow_img.Position = ud2(0, main.AbsolutePosition.X + cfg.size.X.Offset/2,
                               0, main.AbsolutePosition.Y + cfg.size.Y.Offset/2)

    -- Outer border glow
    lib:new("UIStroke", {
        Parent              = main,
        Color               = theme.border,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
        Thickness           = 1,
    })

    -- Inner top shimmer (glass refraction effect)
    local top_shimmer = lib:new("Frame", {
        Parent              = main,
        Size                = ud2(0.7, 0, 0, 1),
        Position            = ud2(0.15, 0, 0, 0),
        BackgroundColor3    = theme.glass_white,
        BackgroundTransparency = 0.94,
        BorderSizePixel     = 0,
        ZIndex              = 2,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = top_shimmer, CornerRadius = ud(0, 999) })
    lib:new("UIGradient", {
        Parent      = top_shimmer,
        Transparency = nseq{ nkey(0,1), nkey(0.25,0.2), nkey(0.75,0.2), nkey(1,1) },
    })

    cfg.items.main = main

    -- ── Sidebar ───────────────────────────────────────────────────────────
    local sidebar = lib:new("Frame", {
        Parent              = main,
        Size                = ud2(0, 188, 1, 0),
        Position            = ud2(0, 0, 0, 0),
        BackgroundColor3    = theme.bg_secondary,
        BackgroundTransparency = 0.1,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 2,
    })
    lib:new("UICorner", { Parent = sidebar, CornerRadius = ud(0, 12) })
    cfg.items.sidebar = sidebar

    -- Sidebar right edge line
    lib:new("Frame", {
        Parent              = sidebar,
        Size                = ud2(0, 1, 1, 0),
        Position            = ud2(1, -1, 0, 0),
        BackgroundColor3    = theme.border,
        BackgroundTransparency = 0.3,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 3,
    })

    -- Sidebar fill patch (cover corner radius on right side only)
    lib:new("Frame", {
        Parent              = sidebar,
        Size                = ud2(0, 12, 1, 0),
        Position            = ud2(1, -12, 0, 0),
        BackgroundColor3    = theme.bg_secondary,
        BackgroundTransparency = 0.1,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 1,
    })

    -- ── Logo / Title ──────────────────────────────────────────────────────
    local logo_area = lib:new("Frame", {
        Parent              = sidebar,
        Size                = ud2(1, 0, 0, 70),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 3,
    })

    -- Accent bar (left edge)
    local accent_bar = lib:new("Frame", {
        Parent              = logo_area,
        Size                = ud2(0, 3, 0, 30),
        Position            = ud2(0, 14, 0.5, -15),
        BackgroundColor3    = theme.accent,
        BackgroundTransparency = 0,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 4,
    })
    lib:new("UICorner", { Parent = accent_bar, CornerRadius = ud(0, 999) })

    -- Glow behind accent bar
    lib:new("ImageLabel", {
        Parent              = accent_bar,
        Size                = ud2(4, 0, 2, 0),
        Position            = ud2(-1.5, 0, -0.5, 0),
        BackgroundTransparency = 1,
        Image               = "rbxassetid://112971167999062",
        ImageColor3         = theme.accent,
        ImageTransparency   = 0.6,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = rc(v2(100,100), v2(156,156)),
        BorderSizePixel     = 0,
        ZIndex              = 3,
        Name                = "\0",
    })

    lib:new("TextLabel", {
        Parent              = logo_area,
        Position            = ud2(0, 26, 0.5, -12),
        Size                = ud2(1, -30, 0, 16),
        BackgroundTransparency = 1,
        FontFace            = fonts.heading,
        Text                = cfg.name,
        TextColor3          = theme.text_primary,
        TextSize            = 16,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })
    lib:new("TextLabel", {
        Parent              = logo_area,
        Position            = ud2(0, 27, 0.5, 3),
        Size                = ud2(1, -30, 0, 12),
        BackgroundTransparency = 1,
        FontFace            = fonts.body,
        Text                = cfg.subtitle,
        TextColor3          = theme.accent,
        TextSize            = 11,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })

    -- Thin divider under logo
    lib:new("Frame", {
        Parent              = logo_area,
        Size                = ud2(1, -28, 0, 1),
        Position            = ud2(0, 14, 1, -1),
        BackgroundColor3    = theme.border,
        BackgroundTransparency = 0.4,
        BorderSizePixel     = 0,
        ZIndex              = 3,
        Name                = "\0",
    })

    -- ── Tab button holder ────────────────────────────────────────────────
    local btn_holder = lib:new("Frame", {
        Parent              = sidebar,
        Size                = ud2(1, 0, 1, -70),
        Position            = ud2(0, 0, 0, 70),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 3,
    })
    lib:new("UIListLayout", {
        Parent              = btn_holder,
        Padding             = ud(0, 4),
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })
    lib:new("UIPadding", {
        Parent              = btn_holder,
        PaddingTop          = ud(0, 10),
        PaddingLeft         = ud(0, 10),
        PaddingRight        = ud(0, 10),
        PaddingBottom       = ud(0, 10),
    })
    cfg.items.btn_holder = btn_holder

    -- ── Content area ──────────────────────────────────────────────────────
    local content_area = lib:new("Frame", {
        Parent              = main,
        Size                = ud2(1, -188, 1, -50),
        Position            = ud2(0, 188, 0, 46),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 2,
    })
    cfg.items.content_area = content_area

    -- ── Multi-tab bar (top of content) ────────────────────────────────────
    local multi_bar = lib:new("Frame", {
        Parent              = main,
        Size                = ud2(1, -188, 0, 46),
        Position            = ud2(0, 188, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 4,
    })
    lib:new("Frame", {
        Parent              = multi_bar,
        Size                = ud2(1, 0, 0, 1),
        Position            = ud2(0, 0, 1, -1),
        BackgroundColor3    = theme.border,
        BackgroundTransparency = 0.4,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })
    lib:new("UIListLayout", {
        Parent              = multi_bar,
        Padding             = ud(0, 2),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        FillDirection       = Enum.FillDirection.Horizontal,
    })
    lib:new("UIPadding", {
        Parent              = multi_bar,
        PaddingLeft         = ud(0, 12),
        PaddingTop          = ud(0, 8),
        PaddingBottom       = ud(0, 0),
    })
    cfg.items.multi_bar = multi_bar

    -- ── Global fade overlay (for tab transitions) ─────────────────────────
    local fade_overlay = lib:new("Frame", {
        Parent              = main,
        Size                = ud2(1, -188, 1, -50),
        Position            = ud2(0, 188, 0, 46),
        BackgroundColor3    = theme.bg_primary,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        ZIndex              = 10,
        Name                = "\0",
    })
    cfg.items.fade_overlay = fade_overlay

    -- ── Bottom info bar ───────────────────────────────────────────────────
    local info_bar = lib:new("Frame", {
        Parent              = main,
        Size                = ud2(1, 0, 0, 24),
        Position            = ud2(0, 0, 1, -24),
        BackgroundColor3    = theme.bg_secondary,
        BackgroundTransparency = 0.1,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 3,
    })
    lib:new("UICorner", { Parent = info_bar, CornerRadius = ud(0, 12) })
    lib:new("Frame", {
        Parent              = info_bar,
        Size                = ud2(1, 0, 0, 6),
        BackgroundColor3    = theme.bg_secondary,
        BackgroundTransparency = 0.1,
        BorderSizePixel     = 0,
        Name                = "\0",
        ZIndex              = 3,
    })
    lib:new("TextLabel", {
        Parent              = info_bar,
        Size                = ud2(0.5, 0, 1, 0),
        Position            = ud2(0, 10, 0, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.small,
        Text                = cfg.game_info,
        TextColor3          = theme.text_muted,
        TextSize            = 11,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })

    -- ── Dragging & resizing ───────────────────────────────────────────────
    lib:draggify(main, logo_area)
    lib:resizify(main, v2(520, 380))

    -- ── Entrance animation ────────────────────────────────────────────────
    main.BackgroundTransparency = 1
    main.Size = ud2(cfg.size.X.Scale, cfg.size.X.Offset - 24,
                    cfg.size.Y.Scale, cfg.size.Y.Offset - 24)

    task.spawn(function()
        task.wait()
        lib:tween(main, {
            BackgroundTransparency = 0.08,
            Size = cfg.size,
        }, anim.back, anim.spring)
    end)

    -- ── Toggle visibility ─────────────────────────────────────────────────
    function cfg.toggle_menu(visible)
        if visible then
            lib.items.Enabled = true
            main.BackgroundTransparency = 1
            main.Size = ud2(cfg.size.X.Scale, cfg.size.X.Offset - 20,
                            cfg.size.Y.Scale, cfg.size.Y.Offset - 20)
            lib:tween(main, { BackgroundTransparency = 0.08, Size = cfg.size }, anim.back, anim.spring)
        else
            lib:tween(main, {
                BackgroundTransparency = 1,
                Size = ud2(cfg.size.X.Scale, cfg.size.X.Offset - 20,
                           cfg.size.Y.Scale, cfg.size.Y.Offset - 20),
            }, anim.out, anim.normal)
            task.delay(anim.normal, function() lib.items.Enabled = false end)
        end
    end

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  TAB
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:tab(props)
    local cfg = {
        name    = props.name   or "Tab",
        icon    = props.icon   or "rbxassetid://6034767608",
        tabs    = props.tabs   or { "Main" },
        pages   = {},
        current_multi = nil,
        items   = {},
    }

    local items = cfg.items

    -- ── Content holder ────────────────────────────────────────────────────
    items.tab_holder = lib:new("Frame", {
        Parent              = lib.cache,
        Size                = ud2(1, -20, 1, -20),
        Position            = ud2(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Visible             = false,
        Name                = "\0",
    })

    -- Multi-bar button holder (placed in parent multi_bar on open)
    items.multi_buttons = lib:new("Frame", {
        Parent              = lib.cache,
        Size                = ud2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Visible             = false,
        Name                = "\0",
    })
    lib:new("UIListLayout", {
        Parent              = items.multi_buttons,
        FillDirection       = Enum.FillDirection.Horizontal,
        Padding             = ud(0, 4),
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })

    -- ── Sidebar button ────────────────────────────────────────────────────
    items.button = lib:new("TextButton", {
        Parent              = self.items.btn_holder,
        Size                = ud2(1, 0, 0, 34),
        BackgroundColor3    = theme.btn_normal,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 4,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.button, CornerRadius = ud(0, 8) })

    -- Left accent indicator (hidden by default)
    items.btn_accent = lib:new("Frame", {
        Parent              = items.button,
        Size                = ud2(0, 3, 0, 18),
        Position            = ud2(0, 0, 0.5, -9),
        BackgroundColor3    = theme.accent,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        ZIndex              = 5,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.btn_accent, CornerRadius = ud(0, 999) })

    -- Button icon
    items.btn_icon = lib:new("ImageLabel", {
        Parent              = items.button,
        Size                = ud2(0, 18, 0, 18),
        Position            = ud2(0, 11, 0.5, -9),
        BackgroundTransparency = 1,
        Image               = cfg.icon,
        ImageColor3         = theme.text_muted,
        BorderSizePixel     = 0,
        ZIndex              = 5,
        Name                = "\0",
    })

    -- Button label
    items.btn_label = lib:new("TextLabel", {
        Parent              = items.button,
        Size                = ud2(1, -40, 1, 0),
        Position            = ud2(0, 36, 0, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.body,
        Text                = cfg.name,
        TextColor3          = theme.text_muted,
        TextSize            = 13,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        ZIndex              = 5,
        Name                = "\0",
    })

    -- Subtle hover bg
    items.button.MouseEnter:Connect(function()
        if self.selected_tab and self.selected_tab[1] == items.button then return end
        lib:tween(items.button,    { BackgroundTransparency = 0.88 }, anim.quad, anim.fast)
        lib:tween(items.btn_icon,  { ImageColor3 = theme.text_secondary }, anim.quad, anim.fast)
        lib:tween(items.btn_label, { TextColor3  = theme.text_secondary }, anim.quad, anim.fast)
    end)
    items.button.MouseLeave:Connect(function()
        if self.selected_tab and self.selected_tab[1] == items.button then return end
        lib:tween(items.button,    { BackgroundTransparency = 1 }, anim.quad, anim.fast)
        lib:tween(items.btn_icon,  { ImageColor3 = theme.text_muted }, anim.quad, anim.fast)
        lib:tween(items.btn_label, { TextColor3  = theme.text_muted }, anim.quad, anim.fast)
    end)

    -- ── Multi-tab pages ───────────────────────────────────────────────────
    for _, section_name in cfg.tabs do
        local pd = { items = {} }

        -- Content frame
        pd.items.tab = lib:new("Frame", {
            Parent              = lib.cache,
            Size                = ud2(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel     = 0,
            Visible             = false,
            Name                = "\0",
        })
        lib:new("UIListLayout", {
            Parent              = pd.items.tab,
            FillDirection       = Enum.FillDirection.Horizontal,
            HorizontalFlex      = Enum.UIFlexAlignment.Fill,
            VerticalFlex        = Enum.UIFlexAlignment.Fill,
            Padding             = ud(0, 8),
            SortOrder           = Enum.SortOrder.LayoutOrder,
        })
        lib:new("UIPadding", {
            Parent              = pd.items.tab,
            PaddingTop          = ud(0, 8), PaddingBottom = ud(0, 8),
            PaddingLeft         = ud(0, 8), PaddingRight  = ud(0, 8),
        })

        -- Multi-bar button
        pd.items.btn = lib:new("TextButton", {
            Parent              = items.multi_buttons,
            Size                = ud2(0, 0, 1, -8),
            AutomaticSize       = Enum.AutomaticSize.X,
            BackgroundColor3    = theme.bg_tertiary,
            BackgroundTransparency = 1,
            BorderSizePixel     = 0,
            Text                = "",
            AutoButtonColor     = false,
            ZIndex              = 5,
            Name                = "\0",
            ClipsDescendants    = true,
        })
        lib:new("UICorner", { Parent = pd.items.btn, CornerRadius = ud(0, 6) })

        pd.items.btn_label = lib:new("TextLabel", {
            Parent              = pd.items.btn,
            Size                = ud2(1, -16, 1, 0),
            Position            = ud2(0, 8, 0, 0),
            BackgroundTransparency = 1,
            FontFace            = fonts.body,
            Text                = section_name,
            TextColor3          = theme.text_muted,
            TextSize            = 12,
            BorderSizePixel     = 0,
            ZIndex              = 6,
            Name                = "\0",
            AutomaticSize       = Enum.AutomaticSize.X,
        })

        -- Bottom accent line
        pd.items.btn_line = lib:new("Frame", {
            Parent              = pd.items.btn,
            Size                = ud2(0.6, 0, 0, 2),
            Position            = ud2(0.2, 0, 1, -2),
            BackgroundColor3    = theme.accent,
            BackgroundTransparency = 1,
            BorderSizePixel     = 0,
            ZIndex              = 6,
            Name                = "\0",
        })
        lib:new("UICorner", { Parent = pd.items.btn_line, CornerRadius = ud(0, 999) })

        -- Sub-tab parent (columns go inside here)
        pd.parent = setmetatable(pd, lib):sub_tab({}).items.tab_parent

        -- Store handles
        pd.text       = pd.items.btn_label
        pd.accent     = pd.items.btn_line
        pd.button     = pd.items.btn
        pd.page       = pd.items.tab

        function pd.open_page()
            local prev = cfg.current_multi
            if prev and prev ~= pd then
                -- Fade transition
                self.items.fade_overlay.BackgroundTransparency = 0
                lib:tween(self.items.fade_overlay, { BackgroundTransparency = 1 }, anim.quad, 0.3)

                lib:tween(prev.text,   { TextColor3 = theme.text_muted }, anim.quad, anim.fast)
                lib:tween(prev.accent, { BackgroundTransparency = 1 },    anim.quad, anim.fast)
                lib:tween(prev.button, { BackgroundTransparency = 1 },    anim.quad, anim.fast)

                prev.page.Parent  = lib.cache
                prev.page.Visible = false
            end

            lib:tween(pd.text,   { TextColor3 = theme.text_primary }, anim.quad, anim.fast)
            lib:tween(pd.accent, { BackgroundTransparency = 0 },      anim.quad, anim.fast)
            lib:tween(pd.button, { BackgroundColor3 = theme.bg_glass,
                                   BackgroundTransparency = 0.55 },   anim.quad, anim.fast)

            pd.page.Parent  = items.tab_holder
            pd.page.Visible = true

            cfg.current_multi = pd
            lib:close_element()
        end

        pd.items.btn.MouseButton1Down:Connect(pd.open_page)

        -- Hover effects
        pd.items.btn.MouseEnter:Connect(function()
            if cfg.current_multi == pd then return end
            lib:tween(pd.items.btn, { BackgroundColor3 = theme.bg_glass,
                                      BackgroundTransparency = 0.78 }, anim.quad, anim.fast)
            lib:tween(pd.text, { TextColor3 = theme.text_secondary }, anim.quad, anim.fast)
        end)
        pd.items.btn.MouseLeave:Connect(function()
            if cfg.current_multi == pd then return end
            lib:tween(pd.items.btn, { BackgroundTransparency = 1 }, anim.quad, anim.fast)
            lib:tween(pd.text, { TextColor3 = theme.text_muted }, anim.quad, anim.fast)
        end)

        cfg.pages[#cfg.pages + 1] = setmetatable(pd, lib)
    end

    cfg.pages[1].open_page()

    -- ── Open tab function ─────────────────────────────────────────────────
    function cfg.open_tab()
        local prev = self.selected_tab
        if prev then
            if prev[4] ~= items.tab_holder then
                self.items.fade_overlay.BackgroundTransparency = 0
                lib:tween(self.items.fade_overlay, { BackgroundTransparency = 1 }, anim.quad, 0.3)
                prev[4].Size = ud2(1, -20, 1, -20)
            end

            lib:tween(prev[1], { BackgroundTransparency = 1, BackgroundColor3 = theme.btn_normal }, anim.quad, anim.fast)
            lib:tween(prev[2], { BackgroundTransparency = 1 }, anim.quad, anim.fast)
            lib:tween(prev[3], { ImageColor3 = theme.text_muted },  anim.quad, anim.fast)
            lib:tween(prev[4], { TextColor3  = theme.text_muted }, anim.quad, anim.fast)

            prev[4].Parent  = lib.cache
            prev[4].Visible = false
            prev[5].Parent  = lib.cache
            prev[5].Visible = false
        end

        lib:tween(items.button,    { BackgroundColor3 = theme.bg_glass,
                                     BackgroundTransparency = 0.5 }, anim.quad, anim.normal)
        lib:tween(items.btn_accent, { BackgroundTransparency = 0 },   anim.quad, anim.normal)
        lib:tween(items.btn_icon,   { ImageColor3 = theme.accent },   anim.quad, anim.normal)
        lib:tween(items.btn_label,  { TextColor3  = theme.text_primary }, anim.quad, anim.normal)

        items.tab_holder.Parent  = self.items.content_area
        items.tab_holder.Visible = true
        items.multi_buttons.Parent  = self.items.multi_bar
        items.multi_buttons.Visible = true

        self.selected_tab = {
            items.button,
            items.btn_accent,
            items.btn_icon,
            items.tab_holder,
            items.multi_buttons,
            items.btn_label,
        }

        lib:close_element()
    end

    items.button.MouseButton1Down:Connect(cfg.open_tab)

    if not self.selected_tab then
        cfg.open_tab()
    end

    return unpack(cfg.pages)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SUB-TAB  (column row)
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:sub_tab(props)
    local cfg = { items = {}, size = props.size or 1 }

    cfg.items.tab_parent = lib:new("Frame", {
        Parent              = self.items and self.items.tab or self.page,
        Size                = ud2(0, 0, cfg.size, 0),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })
    lib:new("UIListLayout", {
        Parent              = cfg.items.tab_parent,
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalFlex      = Enum.UIFlexAlignment.Fill,
        VerticalFlex        = Enum.UIFlexAlignment.Fill,
        Padding             = ud(0, 8),
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  COLUMN
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:column(props)
    local cfg = { items = {}, size = props.size or 1 }

    cfg.items.column = lib:new("Frame", {
        Parent              = self.parent or self.items.tab_parent,
        Size                = ud2(0, 0, cfg.size, 0),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })
    lib:new("UIListLayout", {
        Parent              = cfg.items.column,
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalFlex      = Enum.UIFlexAlignment.Fill,
        Padding             = ud(0, 8),
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })
    lib:new("UIPadding", {
        Parent              = cfg.items.column,
        PaddingBottom       = ud(0, 8),
    })

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECTION  (glass card)
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:section(props)
    local cfg = {
        name    = props.name   or "Section",
        icon    = props.icon   or "rbxassetid://6022668898",
        size    = props.size   or self.size or 0.5,
        fading  = props.fading or false,
        default = props.default or (not props.fading),
        items   = {},
    }

    local items = cfg.items

    -- ── Card frame ────────────────────────────────────────────────────────
    items.card = lib:new("Frame", {
        Parent              = self.items.column,
        Size                = ud2(0, 0, cfg.size, -3),
        BackgroundColor3    = theme.bg_secondary,
        BackgroundTransparency = 0.15,
        BorderSizePixel     = 0,
        Name                = "\0",
        ClipsDescendants    = false,
    })
    lib:new("UICorner", { Parent = items.card, CornerRadius = ud(0, 10) })
    lib:new("UIStroke", {
        Parent              = items.card,
        Color               = theme.border,
        Transparency        = 0.3,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
        Thickness           = 1,
    })

    -- Top shimmer
    local card_shimmer = lib:new("Frame", {
        Parent              = items.card,
        Size                = ud2(0.8, 0, 0, 1),
        Position            = ud2(0.1, 0, 0, 0),
        BackgroundColor3    = theme.glass_white,
        BackgroundTransparency = 0.95,
        BorderSizePixel     = 0,
        ZIndex              = 2,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = card_shimmer, CornerRadius = ud(0, 999) })
    lib:new("UIGradient", {
        Parent      = card_shimmer,
        Transparency = nseq{ nkey(0,1), nkey(0.3,0.3), nkey(0.7,0.3), nkey(1,1) },
    })

    -- ── Header button ─────────────────────────────────────────────────────
    items.header = lib:new("TextButton", {
        Parent              = items.card,
        Size                = ud2(1, 0, 0, 36),
        BackgroundColor3    = theme.bg_tertiary,
        BackgroundTransparency = 0.15,
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 3,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.header, CornerRadius = ud(0, 10) })

    -- Header bottom fill (so rounded corners don't gap)
    lib:new("Frame", {
        Parent              = items.header,
        Size                = ud2(1, 0, 0, 10),
        Position            = ud2(0, 0, 1, -10),
        BackgroundColor3    = theme.bg_tertiary,
        BackgroundTransparency = 0.15,
        BorderSizePixel     = 0,
        ZIndex              = 2,
        Name                = "\0",
    })

    -- Accent icon bg pill
    local icon_bg = lib:new("Frame", {
        Parent              = items.header,
        Size                = ud2(0, 24, 0, 24),
        Position            = ud2(0, 8, 0.5, -12),
        BackgroundColor3    = theme.accent,
        BackgroundTransparency = 0.85,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = icon_bg, CornerRadius = ud(0, 6) })

    lib:new("ImageLabel", {
        Parent              = icon_bg,
        Size                = ud2(1, -6, 1, -6),
        Position            = ud2(0, 3, 0, 3),
        BackgroundTransparency = 1,
        Image               = cfg.icon,
        ImageColor3         = theme.accent,
        BorderSizePixel     = 0,
        ZIndex              = 5,
        Name                = "\0",
    })

    lib:new("TextLabel", {
        Parent              = items.header,
        Size                = ud2(1, -80, 1, 0),
        Position            = ud2(0, 40, 0, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.label,
        Text                = cfg.name,
        TextColor3          = theme.text_primary,
        TextSize            = 13,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })

    -- Header divider
    items.header_line = lib:new("Frame", {
        Parent              = items.card,
        Size                = ud2(1, -16, 0, 1),
        Position            = ud2(0, 8, 0, 36),
        BackgroundColor3    = theme.border,
        BackgroundTransparency = 0.5,
        BorderSizePixel     = 0,
        ZIndex              = 3,
        Name                = "\0",
    })

    -- ── Scroll / Element area ─────────────────────────────────────────────
    items.scroll = lib:new("ScrollingFrame", {
        Parent              = items.card,
        Size                = ud2(1, 0, 1, -38),
        Position            = ud2(0, 0, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        ScrollBarThickness  = 2,
        ScrollBarImageColor3 = theme.accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize          = ud2(0,0,0,0),
        ZIndex              = 3,
        Name                = "\0",
    })

    items.elements = lib:new("Frame", {
        Parent              = items.scroll,
        Size                = ud2(1, -20, 0, 0),
        Position            = ud2(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        AutomaticSize       = Enum.AutomaticSize.Y,
        ZIndex              = 3,
        Name                = "\0",
    })
    lib:new("UIListLayout", {
        Parent              = items.elements,
        Padding             = ud(0, 9),
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })
    lib:new("UIPadding", {
        Parent              = items.elements,
        PaddingBottom       = ud(0, 12),
    })

    -- ── Fading toggle ─────────────────────────────────────────────────────
    if cfg.fading then
        -- Toggle switch in header
        items.toggle_track = lib:new("TextButton", {
            Parent              = items.header,
            Size                = ud2(0, 32, 0, 16),
            Position            = ud2(1, -42, 0.5, -8),
            BackgroundColor3    = theme.border_light,
            BorderSizePixel     = 0,
            Text                = "",
            AutoButtonColor     = false,
            ZIndex              = 5,
            Name                = "\0",
        })
        lib:new("UICorner", { Parent = items.toggle_track, CornerRadius = ud(0, 999) })

        items.toggle_thumb = lib:new("Frame", {
            Parent              = items.toggle_track,
            Size                = ud2(0, 11, 0, 11),
            Position            = ud2(0, 2, 0.5, -5.5),
            BackgroundColor3    = theme.text_muted,
            BorderSizePixel     = 0,
            ZIndex              = 6,
            Name                = "\0",
        })
        lib:new("UICorner", { Parent = items.toggle_thumb, CornerRadius = ud(0, 999) })

        -- Fade overlay
        items.fade_panel = lib:new("Frame", {
            Parent              = items.card,
            Size                = ud2(1, 0, 1, 0),
            BackgroundColor3    = theme.bg_primary,
            BackgroundTransparency = cfg.default and 1 or 0.25,
            BorderSizePixel     = 0,
            ZIndex              = 8,
            Name                = "\0",
        })
        lib:new("UICorner", { Parent = items.fade_panel, CornerRadius = ud(0, 10) })

        function cfg.toggle_section(bool)
            lib:tween(items.toggle_track, { BackgroundColor3 = bool and theme.accent or theme.border_light }, anim.quad, anim.fast)
            lib:tween(items.toggle_thumb, {
                BackgroundColor3 = bool and hex("FFFFFF") or theme.text_muted,
                Position = bool and ud2(1, -13, 0.5, -5.5) or ud2(0, 2, 0.5, -5.5),
            }, anim.quad, anim.fast)
            lib:tween(items.fade_panel, { BackgroundTransparency = bool and 1 or 0.25 }, anim.quad, anim.normal)
        end

        items.header.MouseButton1Click:Connect(function()
            cfg.default = not cfg.default
            cfg.toggle_section(cfg.default)
        end)
        items.toggle_track.MouseButton1Click:Connect(function()
            cfg.default = not cfg.default
            cfg.toggle_section(cfg.default)
        end)

        cfg.toggle_section(cfg.default)
    end

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:toggle(props)
    local cfg = {
        name     = props.name     or "Toggle",
        info     = props.info     or nil,
        flag     = props.flag     or lib:next_flag(),
        default  = props.default  or false,
        enabled  = props.default  or false,
        style    = props.style    or "switch",  -- "switch" | "check"
        callback = props.callback or function() end,
        sep      = props.sep      or false,
        items    = {},
    }

    flags[cfg.flag] = cfg.default

    local items = cfg.items

    items.root = lib:new("TextButton", {
        Parent              = self.items.elements,
        Size                = ud2(1, 0, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        Name                = "\0",
    })

    items.label = lib:new("TextLabel", {
        Parent              = items.root,
        Size                = ud2(1, -50, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        FontFace            = fonts.body,
        Text                = cfg.name,
        TextColor3          = theme.text_primary,
        TextSize            = 13,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        ZIndex              = 3,
        Name                = "\0",
    })
    lib:new("UIPadding", {
        Parent              = items.label,
        PaddingLeft         = ud(0, 2),
    })

    if cfg.info then
        items.info_label = lib:new("TextLabel", {
            Parent              = items.root,
            Size                = ud2(1, -10, 0, 0),
            Position            = ud2(0, 5, 0, 16),
            AutomaticSize       = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            FontFace            = fonts.small,
            Text                = cfg.info,
            TextColor3          = theme.text_secondary,
            TextSize            = 11,
            TextXAlignment      = Enum.TextXAlignment.Left,
            TextWrapped         = true,
            BorderSizePixel     = 0,
            Name                = "\0",
        })
    end

    -- ── Switch style ──────────────────────────────────────────────────────
    if cfg.style == "switch" then
        items.track = lib:new("TextButton", {
            Parent              = items.root,
            Size                = ud2(0, 34, 0, 18),
            Position            = ud2(1, -34, 0, 0),
            BackgroundColor3    = theme.border_light,
            BorderSizePixel     = 0,
            Text                = "",
            AutoButtonColor     = false,
            ZIndex              = 4,
            Name                = "\0",
        })
        lib:new("UICorner", { Parent = items.track, CornerRadius = ud(0, 999) })
        -- Track inner shadow
        lib:new("UIGradient", {
            Parent      = items.track,
            Rotation    = 90,
            Color       = cseq{ ckey(0, hex("000000")), ckey(1, hex("000000")) },
            Transparency = nseq{ nkey(0, 0.85), nkey(1, 0.95) },
        })

        items.thumb = lib:new("Frame", {
            Parent              = items.track,
            Size                = ud2(0, 13, 0, 13),
            Position            = ud2(0, 2, 0.5, -6.5),
            BackgroundColor3    = theme.text_muted,
            BorderSizePixel     = 0,
            ZIndex              = 5,
            Name                = "\0",
        })
        lib:new("UICorner", { Parent = items.thumb, CornerRadius = ud(0, 999) })

        -- Thumb glow (visible when on)
        items.thumb_glow = lib:new("ImageLabel", {
            Parent              = items.thumb,
            Size                = ud2(3.5, 0, 3.5, 0),
            Position            = ud2(-1.25, 0, -1.25, 0),
            BackgroundTransparency = 1,
            Image               = "rbxassetid://112971167999062",
            ImageColor3         = theme.accent,
            ImageTransparency   = 1,
            ScaleType           = Enum.ScaleType.Slice,
            SliceCenter         = rc(v2(100,100), v2(156,156)),
            BorderSizePixel     = 0,
            ZIndex              = 4,
            Name                = "\0",
        })

        function cfg.set(bool)
            cfg.enabled = bool
            flags[cfg.flag] = bool

            lib:tween(items.track, {
                BackgroundColor3 = bool and theme.accent or theme.border_light,
            }, anim.quad, anim.fast)
            lib:tween(items.thumb, {
                BackgroundColor3 = bool and hex("FFFFFF") or theme.text_muted,
                Position = bool and ud2(1, -15, 0.5, -6.5) or ud2(0, 2, 0.5, -6.5),
            }, anim.back, anim.normal)
            lib:tween(items.thumb_glow, {
                ImageTransparency = bool and 0.7 or 1,
            }, anim.quad, anim.normal)

            cfg.callback(bool)
        end

        items.track.MouseButton1Click:Connect(function()
            cfg.set(not cfg.enabled)
        end)
        items.root.MouseButton1Click:Connect(function()
            cfg.set(not cfg.enabled)
        end)

    else  -- "check" style
        items.track = lib:new("TextButton", {
            Parent              = items.root,
            Size                = ud2(0, 16, 0, 16),
            Position            = ud2(1, -16, 0, 0),
            BackgroundColor3    = theme.bg_tertiary,
            BorderSizePixel     = 0,
            Text                = "",
            AutoButtonColor     = false,
            ZIndex              = 4,
            Name                = "\0",
        })
        lib:new("UICorner", { Parent = items.track, CornerRadius = ud(0, 5) })
        lib:new("UIStroke", {
            Parent              = items.track,
            Color               = theme.border_light,
            Transparency        = 0.4,
            ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
        })

        items.check = lib:new("ImageLabel", {
            Parent              = items.track,
            Size                = ud2(1, -2, 1, -2),
            Position            = ud2(0, 1, 0, 1),
            BackgroundTransparency = 1,
            Image               = "rbxassetid://111862698467575",
            ImageColor3         = hex("FFFFFF"),
            ImageTransparency   = 1,
            BorderSizePixel     = 0,
            ZIndex              = 5,
            Name                = "\0",
        })

        function cfg.set(bool)
            cfg.enabled = bool
            flags[cfg.flag] = bool

            lib:tween(items.track, {
                BackgroundColor3 = bool and theme.accent or theme.bg_tertiary,
            }, anim.quad, anim.fast)
            lib:tween(items.check, {
                ImageTransparency = bool and 0 or 1,
                Rotation          = bool and 0 or 15,
            }, anim.back, anim.normal)

            cfg.callback(bool)
        end

        items.track.MouseButton1Click:Connect(function()
            cfg.set(not cfg.enabled)
        end)
        items.root.MouseButton1Click:Connect(function()
            cfg.set(not cfg.enabled)
        end)
    end

    if cfg.sep then
        lib:new("Frame", {
            Parent              = self.items.elements,
            Size                = ud2(1, 0, 0, 1),
            BackgroundColor3    = theme.border,
            BackgroundTransparency = 0.5,
            BorderSizePixel     = 0,
            Name                = "\0",
        })
    end

    cfg.set(cfg.default)
    cfg_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SLIDER
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:slider(props)
    local cfg = {
        name     = props.name     or "Slider",
        info     = props.info     or nil,
        suffix   = props.suffix   or "",
        flag     = props.flag     or lib:next_flag(),
        min      = props.min      or 0,
        max      = props.max      or 100,
        interval = props.interval or 1,
        default  = props.default  or 0,
        value    = props.default  or 0,
        callback = props.callback or function() end,
        dragging = false,
        sep      = props.sep      ~= false,
        items    = {},
    }

    flags[cfg.flag] = cfg.default

    local items = cfg.items

    items.root = lib:new("Frame", {
        Parent              = self.items.elements,
        Size                = ud2(1, 0, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    -- Top row: name + value display
    local top_row = lib:new("Frame", {
        Parent              = items.root,
        Size                = ud2(1, 0, 0, 16),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    lib:new("TextLabel", {
        Parent              = top_row,
        Size                = ud2(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.body,
        Text                = cfg.name,
        TextColor3          = theme.text_primary,
        TextSize            = 13,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    items.value_label = lib:new("TextLabel", {
        Parent              = top_row,
        Size                = ud2(0.4, 0, 1, 0),
        Position            = ud2(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.small,
        Text                = tostring(cfg.default) .. cfg.suffix,
        TextColor3          = theme.text_secondary,
        TextSize            = 11,
        TextXAlignment      = Enum.TextXAlignment.Right,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    if cfg.info then
        lib:new("TextLabel", {
            Parent              = items.root,
            Size                = ud2(1, 0, 0, 0),
            Position            = ud2(0, 0, 0, 18),
            AutomaticSize       = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            FontFace            = fonts.small,
            Text                = cfg.info,
            TextColor3          = theme.text_secondary,
            TextSize            = 11,
            TextXAlignment      = Enum.TextXAlignment.Left,
            TextWrapped         = true,
            BorderSizePixel     = 0,
            Name                = "\0",
        })
    end

    -- Track
    items.track = lib:new("TextButton", {
        Parent              = items.root,
        Size                = ud2(1, 0, 0, 4),
        Position            = ud2(0, 0, 0, 22),
        BackgroundColor3    = theme.bg_glass,
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 3,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.track, CornerRadius = ud(0, 999) })
    lib:new("UIStroke", {
        Parent              = items.track,
        Color               = theme.border,
        Transparency        = 0.4,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })

    -- Fill
    items.fill = lib:new("Frame", {
        Parent              = items.track,
        Size                = ud2(0.5, 0, 1, 0),
        BackgroundColor3    = theme.accent,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.fill, CornerRadius = ud(0, 999) })
    -- Accent gradient on fill
    lib:new("UIGradient", {
        Parent              = items.fill,
        Color               = cseq{ ckey(0, theme.accent_glow), ckey(1, theme.accent_dim) },
    })

    -- Thumb
    items.thumb = lib:new("Frame", {
        Parent              = items.fill,
        Size                = ud2(0, 14, 0, 14),
        Position            = ud2(1, -7, 0.5, -7),
        BackgroundColor3    = hex("FFFFFF"),
        BorderSizePixel     = 0,
        ZIndex              = 5,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.thumb, CornerRadius = ud(0, 999) })
    -- Thumb accent ring (visible on drag)
    items.thumb_ring = lib:new("UIStroke", {
        Parent              = items.thumb,
        Color               = theme.accent,
        Transparency        = 1,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
        Thickness           = 2,
    })

    -- Glow behind thumb
    lib:new("ImageLabel", {
        Parent              = items.thumb,
        Size                = ud2(3, 0, 3, 0),
        Position            = ud2(-1, 0, -1, 0),
        BackgroundTransparency = 1,
        Image               = "rbxassetid://112971167999062",
        ImageColor3         = theme.accent,
        ImageTransparency   = 0.8,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = rc(v2(100,100), v2(156,156)),
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })

    -- Padding for root auto-size
    lib:new("UIPadding", {
        Parent              = items.root,
        PaddingBottom       = ud(0, 8),
    })

    function cfg.set(val)
        cfg.value = clamp(lib:round(val, cfg.interval), cfg.min, cfg.max)
        local pct = (cfg.value - cfg.min) / (cfg.max - cfg.min)
        lib:tween(items.fill, { Size = ud2(pct, pct == 0 and 0 or -4, 1, 0) }, anim.linear, 0.04)
        items.value_label.Text = tostring(cfg.value) .. cfg.suffix
        flags[cfg.flag] = cfg.value
        cfg.callback(cfg.value)
    end

    items.track.MouseButton1Down:Connect(function()
        cfg.dragging = true
        lib:tween(items.thumb_ring, { Transparency = 0.4 }, anim.quad, anim.fast)
        lib:tween(items.thumb, { Size = ud2(0, 16, 0, 16), Position = ud2(1, -8, 0.5, -8) }, anim.back, anim.fast)
        lib:tween(items.value_label, { TextColor3 = theme.accent }, anim.quad, anim.fast)
    end)

    lib:connect(uis.InputChanged, function(inp)
        if cfg.dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local raw = (inp.Position.X - items.track.AbsolutePosition.X) / items.track.AbsoluteSize.X
            cfg.set(cfg.min + (cfg.max - cfg.min) * raw)
        end
    end)
    lib:connect(uis.InputEnded, function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and cfg.dragging then
            cfg.dragging = false
            lib:tween(items.thumb_ring, { Transparency = 1 }, anim.quad, anim.fast)
            lib:tween(items.thumb, { Size = ud2(0, 14, 0, 14), Position = ud2(1, -7, 0.5, -7) }, anim.quad, anim.fast)
            lib:tween(items.value_label, { TextColor3 = theme.text_secondary }, anim.quad, anim.fast)
        end
    end)

    if cfg.sep then
        lib:new("Frame", {
            Parent              = self.items.elements,
            Size                = ud2(1, 0, 0, 1),
            BackgroundColor3    = theme.border,
            BackgroundTransparency = 0.5,
            BorderSizePixel     = 0,
            Name                = "\0",
        })
    end

    cfg.set(cfg.default)
    cfg_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  DROPDOWN
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:dropdown(props)
    local cfg = {
        name      = props.name     or "Dropdown",
        info      = props.info     or nil,
        flag      = props.flag     or lib:next_flag(),
        options   = props.items    or {},
        default   = props.default  or nil,
        multi     = props.multi    or false,
        callback  = props.callback or function() end,
        width     = props.width    or 140,
        sep       = props.sep      ~= false,

        open            = false,
        y_size          = 0,
        option_frames   = {},
        selected_multi  = {},
        items           = {},
    }

    if cfg.multi then
        cfg.default = cfg.default or {}
    else
        cfg.default = cfg.default or cfg.options[1] or ""
    end
    flags[cfg.flag] = cfg.multi and {} or cfg.default

    local items = cfg.items

    items.root = lib:new("Frame", {
        Parent              = self.items.elements,
        Size                = ud2(1, 0, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    lib:new("TextLabel", {
        Parent              = items.root,
        Size                = ud2(1, -cfg.width - 6, 0, 18),
        BackgroundTransparency = 1,
        FontFace            = fonts.body,
        Text                = cfg.name,
        TextColor3          = theme.text_primary,
        TextSize            = 13,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    -- Dropdown pill button
    items.pill = lib:new("TextButton", {
        Parent              = items.root,
        Size                = ud2(0, cfg.width, 0, 20),
        Position            = ud2(1, -cfg.width, 0, -1),
        BackgroundColor3    = theme.btn_normal,
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 3,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.pill, CornerRadius = ud(0, 5) })
    lib:new("UIStroke", {
        Parent              = items.pill,
        Color               = theme.border_light,
        Transparency        = 0.5,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })

    items.selected_text = lib:new("TextLabel", {
        Parent              = items.pill,
        Size                = ud2(1, -24, 1, 0),
        Position            = ud2(0, 6, 0, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.small,
        Text                = cfg.multi and "None" or (cfg.default or "Select..."),
        TextColor3          = theme.text_secondary,
        TextSize            = 11,
        TextXAlignment      = Enum.TextXAlignment.Left,
        TextTruncate        = Enum.TextTruncate.AtEnd,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })

    -- Chevron
    items.chevron = lib:new("ImageLabel", {
        Parent              = items.pill,
        Size                = ud2(0, 10, 0, 10),
        Position            = ud2(1, -16, 0.5, -5),
        BackgroundTransparency = 1,
        Image               = "rbxassetid://101025591575185",
        ImageColor3         = theme.text_muted,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })

    -- Popup panel (in overlay)
    items.popup = lib:new("Frame", {
        Parent              = lib.overlay,
        Size                = ud2(0, cfg.width, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        ZIndex              = 20,
        Visible             = true,
        Name                = "\0",
        ClipsDescendants    = true,
    })

    items.popup_inner = lib:new("Frame", {
        Parent              = items.popup,
        Size                = ud2(1, 0, 1, 0),
        BackgroundColor3    = theme.bg_glass,
        BackgroundTransparency = 0.08,
        BorderSizePixel     = 0,
        ZIndex              = 20,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.popup_inner, CornerRadius = ud(0, 6) })
    lib:new("UIStroke", {
        Parent              = items.popup_inner,
        Color               = theme.border_light,
        Transparency        = 0.35,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })
    lib:new("UIPadding", {
        Parent              = items.popup_inner,
        PaddingTop          = ud(0, 4), PaddingBottom = ud(0, 4),
        PaddingLeft         = ud(0, 4), PaddingRight  = ud(0, 4),
    })
    lib:new("UIListLayout", {
        Parent              = items.popup_inner,
        Padding             = ud(0, 3),
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })

    function cfg.set_visible(bool)
        local ap = items.pill.AbsolutePosition
        local as = items.pill.AbsoluteSize
        items.popup.Position = ud2o(ap.X, ap.Y + as.Y + 4)

        lib:tween(items.popup, { Size = ud2(0, cfg.width, 0, bool and cfg.y_size or 0) }, anim.back, anim.normal)
        lib:tween(items.chevron, { Rotation = bool and 180 or 0 }, anim.quad, anim.fast)

        if not (self.sanity and lib.current_open == cfg) then
            lib:close_element(cfg)
        end
    end

    function cfg.set(val)
        local sel = {}
        local is_tbl = type(val) == "table"

        for _, frame_data in cfg.option_frames do
            local match = frame_data.text == val or (is_tbl and find(val, frame_data.text))
            lib:tween(frame_data.btn, {
                BackgroundColor3    = match and theme.accent or theme.btn_normal,
                BackgroundTransparency = match and 0.8 or 0,
            }, anim.quad, anim.fast)
            lib:tween(frame_data.label, {
                TextColor3 = match and theme.accent or theme.text_secondary,
            }, anim.quad, anim.fast)
            if match then insert(sel, frame_data.text) end
        end

        cfg.selected_multi = sel
        items.selected_text.Text = is_tbl and (concat(sel, ", ") ~= "" and concat(sel, ", ") or "None") or (sel[1] or "Select...")
        flags[cfg.flag] = is_tbl and sel or sel[1]
        cfg.callback(flags[cfg.flag])
    end

    function cfg.refresh_options(list)
        cfg.y_size = 0
        for _, fd in cfg.option_frames do fd.btn:Destroy() end
        cfg.option_frames = {}

        for _, opt in list do
            local btn = lib:new("TextButton", {
                Parent              = items.popup_inner,
                Size                = ud2(1, -2, 0, 22),
                BackgroundColor3    = theme.btn_normal,
                BackgroundTransparency = 0,
                BorderSizePixel     = 0,
                Text                = "",
                AutoButtonColor     = false,
                ZIndex              = 21,
                Name                = "\0",
            })
            lib:new("UICorner", { Parent = btn, CornerRadius = ud(0, 4) })

            local lbl = lib:new("TextLabel", {
                Parent              = btn,
                Size                = ud2(1, -10, 1, 0),
                Position            = ud2(0, 6, 0, 0),
                BackgroundTransparency = 1,
                FontFace            = fonts.small,
                Text                = opt,
                TextColor3          = theme.text_secondary,
                TextSize            = 11,
                TextXAlignment      = Enum.TextXAlignment.Left,
                BorderSizePixel     = 0,
                ZIndex              = 22,
                Name                = "\0",
            })

            btn.MouseEnter:Connect(function()
                lib:tween(btn, { BackgroundColor3 = theme.btn_hover, BackgroundTransparency = 0.5 }, anim.quad, anim.fast)
            end)
            btn.MouseLeave:Connect(function()
                -- keep selected style if applicable
                local is_sel = find(cfg.selected_multi, opt)
                lib:tween(btn, {
                    BackgroundColor3    = is_sel and theme.accent or theme.btn_normal,
                    BackgroundTransparency = is_sel and 0.8 or 0,
                }, anim.quad, anim.fast)
            end)

            btn.MouseButton1Down:Connect(function()
                if cfg.multi then
                    local idx = find(cfg.selected_multi, opt)
                    if idx then remove(cfg.selected_multi, idx)
                    else insert(cfg.selected_multi, opt) end
                    cfg.set(cfg.selected_multi)
                else
                    cfg.set_visible(false)
                    cfg.open = false
                    cfg.set(opt)
                end
            end)

            cfg.y_size += 25
            insert(cfg.option_frames, { btn = btn, label = lbl, text = opt })
        end
    end

    items.pill.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open
        cfg.set_visible(cfg.open)
    end)

    lib:hoverable(items.pill, theme.btn_normal, theme.btn_hover, theme.btn_pressed)

    if cfg.sep then
        lib:new("Frame", {
            Parent              = self.items.elements,
            Size                = ud2(1, 0, 0, 1),
            BackgroundColor3    = theme.border,
            BackgroundTransparency = 0.5,
            BorderSizePixel     = 0,
            Name                = "\0",
        })
    end

    cfg.refresh_options(cfg.options)
    cfg.set(cfg.default)
    cfg_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  BUTTON
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:button(props)
    local cfg = {
        name     = props.name     or "Button",
        callback = props.callback or function() end,
        items    = {},
    }

    local items = cfg.items

    items.root = lib:new("Frame", {
        Parent              = self.items.elements,
        Size                = ud2(1, 0, 0, 32),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    items.btn = lib:new("TextButton", {
        Parent              = items.root,
        Size                = ud2(1, 0, 1, 0),
        BackgroundColor3    = theme.btn_normal,
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 3,
        Name                = "\0",
        ClipsDescendants    = true,
    })
    lib:new("UICorner", { Parent = items.btn, CornerRadius = ud(0, 7) })
    lib:new("UIStroke", {
        Parent              = items.btn,
        Color               = theme.border_light,
        Transparency        = 0.55,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })

    -- Top glass shimmer on button
    local btn_shimmer = lib:new("Frame", {
        Parent              = items.btn,
        Size                = ud2(0.6, 0, 0, 1),
        Position            = ud2(0.2, 0, 0, 0),
        BackgroundColor3    = theme.glass_white,
        BackgroundTransparency = 0.93,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = btn_shimmer, CornerRadius = ud(0, 999) })
    lib:new("UIGradient", {
        Parent      = btn_shimmer,
        Transparency = nseq{ nkey(0,1), nkey(0.4,0.2), nkey(0.6,0.2), nkey(1,1) },
    })

    items.label = lib:new("TextLabel", {
        Parent              = items.btn,
        Size                = ud2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.body,
        Text                = cfg.name,
        TextColor3          = theme.text_primary,
        TextSize            = 13,
        BorderSizePixel     = 0,
        ZIndex              = 5,
        Name                = "\0",
    })

    items.btn.MouseEnter:Connect(function()
        lib:tween(items.btn,   { BackgroundColor3 = theme.btn_hover },    anim.quad, anim.fast)
        lib:tween(items.label, { TextColor3       = theme.text_primary }, anim.quad, anim.fast)
    end)
    items.btn.MouseLeave:Connect(function()
        lib:tween(items.btn,   { BackgroundColor3 = theme.btn_normal },  anim.quad, anim.fast)
        lib:tween(items.label, { TextColor3       = theme.text_primary }, anim.quad, anim.fast)
    end)
    items.btn.MouseButton1Down:Connect(function()
        lib:tween(items.btn, { BackgroundColor3 = theme.btn_pressed }, anim.quad, 0.05)
        lib:ripple(items.btn, theme.accent)
    end)
    items.btn.MouseButton1Up:Connect(function()
        lib:tween(items.btn, { BackgroundColor3 = theme.btn_hover }, anim.quad, anim.fast)
    end)
    items.btn.MouseButton1Click:Connect(function()
        lib:tween(items.label, { TextColor3 = theme.accent }, anim.quad, 0.05)
        lib:tween(items.label, { TextColor3 = theme.text_primary }, anim.quad, anim.normal)
        cfg.callback()
    end)

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  LABEL
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:label(props)
    local cfg = {
        name  = props.name  or "Label",
        info  = props.info  or nil,
        sep   = props.sep   or false,
        items = {},
    }

    local items = cfg.items

    items.root = lib:new("Frame", {
        Parent              = self.items and self.items.elements or self,
        Size                = ud2(1, 0, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    items.label_text = lib:new("TextLabel", {
        Parent              = items.root,
        Size                = ud2(1, -50, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        FontFace            = fonts.body,
        Text                = cfg.name,
        TextColor3          = theme.text_primary,
        TextSize            = 13,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    if cfg.info then
        lib:new("TextLabel", {
            Parent              = items.root,
            Size                = ud2(1, 0, 0, 0),
            Position            = ud2(0, 0, 0, 16),
            AutomaticSize       = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            FontFace            = fonts.small,
            Text                = cfg.info,
            TextColor3          = theme.text_secondary,
            TextSize            = 11,
            TextXAlignment      = Enum.TextXAlignment.Left,
            TextWrapped         = true,
            BorderSizePixel     = 0,
            Name                = "\0",
        })
    end

    items.right_components = lib:new("Frame", {
        Parent              = items.root,
        Size                = ud2(0, 0, 0, 18),
        Position            = ud2(1, 0, 0, -1),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })
    lib:new("UIListLayout", {
        Parent              = items.right_components,
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding             = ud(0, 6),
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })

    if cfg.sep then
        lib:new("Frame", {
            Parent              = self.items.elements,
            Size                = ud2(1, 0, 0, 1),
            BackgroundColor3    = theme.border,
            BackgroundTransparency = 0.5,
            BorderSizePixel     = 0,
            Name                = "\0",
        })
    end

    function cfg.set_text(t) items.label_text.Text = t end

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  COLORPICKER
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:colorpicker(props)
    local cfg = {
        name     = props.name     or "Color",
        flag     = props.flag     or lib:next_flag(),
        color    = props.color    or c3(1, 1, 1),
        alpha    = props.alpha    and (1 - props.alpha) or 0,
        callback = props.callback or function() end,
        sep      = props.sep      or false,
        open     = false,
        items    = {},
    }

    local h, s, v = cfg.color:ToHSV()
    local a = cfg.alpha

    flags[cfg.flag] = { Color = cfg.color, Transparency = cfg.alpha }

    local drag_sv, drag_hue, drag_alpha = false, false, false

    -- Host label
    local lbl
    if not (self.items and self.items.right_components) then
        lbl = self:label({ name = cfg.name, sep = cfg.sep })
    end

    local items = cfg.items

    -- ── Swatch button ────────────────────────────────────────────────────
    items.swatch = lib:new("TextButton", {
        Parent              = lbl and lbl.items.right_components or self.items.right_components,
        Size                = ud2(0, 18, 0, 18),
        BackgroundColor3    = cfg.color,
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 4,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.swatch, CornerRadius = ud(0, 5) })
    lib:new("UIStroke", {
        Parent              = items.swatch,
        Color               = theme.border_light,
        Transparency        = 0.4,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })

    -- ── Picker panel ─────────────────────────────────────────────────────
    items.panel = lib:new("Frame", {
        Parent              = lib.overlay,
        Size                = ud2(0, 180, 0, 210),
        BackgroundColor3    = theme.bg_glass,
        BackgroundTransparency = 0.06,
        BorderSizePixel     = 0,
        Visible             = true,
        ZIndex              = 30,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.panel, CornerRadius = ud(0, 8) })
    lib:new("UIStroke", {
        Parent              = items.panel,
        Color               = theme.border_light,
        Transparency        = 0.3,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })

    items.panel_fade = lib:new("Frame", {
        Parent              = items.panel,
        Size                = ud2(1, 0, 1, 0),
        BackgroundColor3    = theme.bg_primary,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        ZIndex              = 50,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.panel_fade, CornerRadius = ud(0, 8) })

    -- SV field
    items.sv_area = lib:new("TextButton", {
        Parent              = items.panel,
        Size                = ud2(1, -14, 0, 110),
        Position            = ud2(0, 7, 0, 7),
        BackgroundColor3    = rgb(255, 39, 39),
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 31,
        Name                = "\0",
        ClipsDescendants    = false,
    })
    lib:new("UICorner", { Parent = items.sv_area, CornerRadius = ud(0, 5) })

    -- White gradient (saturation)
    local sat_grad = lib:new("Frame", {
        Parent              = items.sv_area,
        Size                = ud2(1, 0, 1, 0),
        BackgroundColor3    = c3(1,1,1),
        BorderSizePixel     = 0,
        ZIndex              = 32,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = sat_grad, CornerRadius = ud(0, 5) })
    lib:new("UIGradient", {
        Parent      = sat_grad,
        Transparency = nseq{ nkey(0,0), nkey(1,1) },
    })

    -- Black gradient (value)
    local val_grad = lib:new("Frame", {
        Parent              = items.sv_area,
        Size                = ud2(1, 0, 1, 0),
        BackgroundColor3    = c3(0,0,0),
        BorderSizePixel     = 0,
        ZIndex              = 33,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = val_grad, CornerRadius = ud(0, 5) })
    lib:new("UIGradient", {
        Parent      = val_grad,
        Rotation    = 270,
        Transparency = nseq{ nkey(0,0), nkey(1,1) },
    })

    -- SV cursor
    items.sv_cursor = lib:new("TextButton", {
        Parent              = items.sv_area,
        Size                = ud2(0, 10, 0, 10),
        AnchorPoint         = v2(0.5, 0.5),
        Position            = ud2(0, 0, 1, 0),
        BackgroundColor3    = c3(1,1,1),
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 35,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.sv_cursor, CornerRadius = ud(0, 999) })
    lib:new("UIStroke", {
        Parent              = items.sv_cursor,
        Color               = c3(1,1,1),
        Transparency        = 0,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
        Thickness           = 2,
    })

    -- Hue bar
    items.hue_bar = lib:new("TextButton", {
        Parent              = items.panel,
        Size                = ud2(1, -14, 0, 8),
        Position            = ud2(0, 7, 0, 124),
        BackgroundColor3    = c3(1,1,1),
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 31,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.hue_bar, CornerRadius = ud(0, 4) })
    lib:new("UIGradient", {
        Parent  = items.hue_bar,
        Color   = cseq{
            ckey(0,    rgb(255,0,0)),    ckey(0.17, rgb(255,255,0)),
            ckey(0.33, rgb(0,255,0)),    ckey(0.5,  rgb(0,255,255)),
            ckey(0.67, rgb(0,0,255)),    ckey(0.83, rgb(255,0,255)),
            ckey(1,    rgb(255,0,0)),
        },
    })

    items.hue_cursor = lib:new("Frame", {
        Parent              = items.hue_bar,
        Size                = ud2(0, 8, 0, 8),
        AnchorPoint         = v2(0.5, 0.5),
        Position            = ud2(0, 0, 0.5, 0),
        BackgroundColor3    = c3(1,1,1),
        BorderSizePixel     = 0,
        ZIndex              = 33,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.hue_cursor, CornerRadius = ud(0, 999) })
    lib:new("UIStroke", { Parent = items.hue_cursor, Color = c3(1,1,1), Transparency = 0 })

    -- Alpha bar
    items.alpha_bar = lib:new("TextButton", {
        Parent              = items.panel,
        Size                = ud2(1, -14, 0, 8),
        Position            = ud2(0, 7, 0, 140),
        BackgroundColor3    = c3(0,0,0),
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 31,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.alpha_bar, CornerRadius = ud(0, 4) })
    items.alpha_grad_inst = lib:new("UIGradient", {
        Parent  = items.alpha_bar,
        Color   = cseq{ ckey(0, rgb(70,70,70)), ckey(1, rgb(255,0,0)) },
        Transparency = nseq{ nkey(0, 0.6), nkey(1, 0) },
    })

    items.alpha_cursor = lib:new("Frame", {
        Parent              = items.alpha_bar,
        Size                = ud2(0, 8, 0, 8),
        AnchorPoint         = v2(0.5, 0.5),
        Position            = ud2(1, 0, 0.5, 0),
        BackgroundColor3    = c3(1,1,1),
        BorderSizePixel     = 0,
        ZIndex              = 33,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.alpha_cursor, CornerRadius = ud(0, 999) })
    lib:new("UIStroke", { Parent = items.alpha_cursor, Color = c3(1,1,1), Transparency = 0 })

    -- Hex input
    items.hex_input = lib:new("TextBox", {
        Parent              = items.panel,
        Size                = ud2(1, -14, 0, 22),
        Position            = ud2(0, 7, 0, 158),
        BackgroundColor3    = theme.bg_tertiary,
        BackgroundTransparency = 0.2,
        BorderSizePixel     = 0,
        FontFace            = fonts.small,
        Text                = "",
        TextColor3          = theme.text_secondary,
        PlaceholderColor3   = theme.text_muted,
        PlaceholderText     = "R, G, B, A",
        TextSize            = 11,
        ClearTextOnFocus    = false,
        ZIndex              = 32,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.hex_input, CornerRadius = ud(0, 4) })
    lib:new("UIPadding", {
        Parent              = items.hex_input,
        PaddingLeft         = ud(0, 5), PaddingRight = ud(0, 5),
    })

    function cfg.set_visible(bool)
        items.panel_fade.BackgroundTransparency = 0
        local ap = items.swatch.AbsolutePosition
        local as = items.swatch.AbsoluteSize
        items.panel.Position = ud2o(ap.X - items.panel.AbsoluteSize.X / 2 + as.X / 2,
                                    ap.Y + as.Y + 6)
        lib:tween(items.panel_fade, { BackgroundTransparency = 1 }, anim.quad, 0.3)
        lib:tween(items.swatch, { Size = bool and ud2(0,20,0,20) or ud2(0,18,0,18) }, anim.back, anim.fast)

        if not (self.sanity and lib.current_open == cfg and self.open) then
            lib:close_element(cfg)
        end
    end

    function cfg.set(col, alp)
        if type(col) == "boolean" then return end
        if col then h, s, v = col:ToHSV() end
        if alp then a = alp end

        local Color = hsv(h, s, v)

        lib:tween(items.hue_cursor,   { Position = ud2(h, -4, 0.5, 0) }, anim.linear, 0.04)
        lib:tween(items.alpha_cursor, { Position = ud2(1-a, -4, 0.5, 0) }, anim.linear, 0.04)
        lib:tween(items.sv_cursor, {
            Position = ud2(
                s,
                s * (items.sv_area.AbsoluteSize.X - items.sv_cursor.AbsoluteSize.X) - items.sv_cursor.AbsoluteSize.X * 0.5,
                1-v,
                (1-v) * (items.sv_area.AbsoluteSize.Y - items.sv_cursor.AbsoluteSize.Y) - items.sv_cursor.AbsoluteSize.Y * 0.5 + items.sv_cursor.AbsoluteSize.Y
            )
        }, anim.linear, 0.04)

        items.sv_area.BackgroundColor3 = hsv(h, 1, 1)
        items.alpha_grad_inst.Color    = cseq{ ckey(0, rgb(70,70,70)), ckey(1, hsv(h,1,1)) }
        items.hue_cursor.BackgroundColor3   = hsv(h, 1, 1)
        items.alpha_cursor.BackgroundColor3 = hsv(h, 1, 1-a)
        items.sv_cursor.BackgroundColor3    = Color

        lib:tween(items.swatch, { BackgroundColor3 = Color }, anim.linear, 0.04)

        flags[cfg.flag] = { Color = Color, Transparency = a }
        items.hex_input.Text = string.format("%d, %d, %d, %.2f",
            lib:round(Color.R * 255), lib:round(Color.G * 255), lib:round(Color.B * 255), 1-a)

        cfg.callback(Color, a)
    end

    function cfg.update_drag()
        local mpos = uis:GetMouseLocation()
        local off  = v2(mpos.X, mpos.Y - gui_offset)

        if drag_sv then
            local ap = items.sv_area.AbsolutePosition
            local as = items.sv_area.AbsoluteSize
            s = clamp((off.X - ap.X) / as.X, 0, 1)
            v = 1 - clamp((off.Y - ap.Y) / as.Y, 0, 1)
        elseif drag_hue then
            local ap = items.hue_bar.AbsolutePosition
            h = clamp((off.X - ap.X) / items.hue_bar.AbsoluteSize.X, 0, 1)
        elseif drag_alpha then
            local ap = items.alpha_bar.AbsolutePosition
            a = 1 - clamp((off.X - ap.X) / items.alpha_bar.AbsoluteSize.X, 0, 1)
        end
        cfg.set()
    end

    items.swatch.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open
        cfg.set_visible(cfg.open)
    end)
    items.sv_area.MouseButton1Down:Connect(function()   drag_sv    = true end)
    items.hue_bar.MouseButton1Down:Connect(function()   drag_hue   = true end)
    items.alpha_bar.MouseButton1Down:Connect(function() drag_alpha = true end)

    uis.InputChanged:Connect(function(inp)
        if (drag_sv or drag_hue or drag_alpha) and inp.UserInputType == Enum.UserInputType.MouseMovement then
            cfg.update_drag()
        end
    end)
    lib:connect(uis.InputEnded, function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag_sv = false; drag_hue = false; drag_alpha = false
        end
    end)

    items.hex_input.FocusLost:Connect(function()
        local parts = {}
        for n in items.hex_input.Text:gmatch("[%d%.]+") do insert(parts, tonumber(n)) end
        if #parts == 4 then cfg.set(rgb(parts[1], parts[2], parts[3]), 1 - parts[4]) end
    end)

    cfg.set(cfg.color, cfg.alpha)
    cfg_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  TEXTBOX
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:textbox(props)
    local cfg = {
        name        = props.name        or "Textbox",
        placeholder = props.placeholder or "Type here...",
        default     = props.default     or "",
        flag        = props.flag        or lib:next_flag(),
        callback    = props.callback    or function() end,
        items       = {},
    }

    flags[cfg.flag] = cfg.default

    local items = cfg.items

    items.root = lib:new("Frame", {
        Parent              = self.items.elements,
        Size                = ud2(1, 0, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    lib:new("TextLabel", {
        Parent              = items.root,
        Size                = ud2(1, 0, 0, 16),
        BackgroundTransparency = 1,
        FontFace            = fonts.body,
        Text                = cfg.name,
        TextColor3          = theme.text_primary,
        TextSize            = 13,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    items.input_bg = lib:new("Frame", {
        Parent              = items.root,
        Size                = ud2(1, 0, 0, 28),
        Position            = ud2(0, 0, 0, 20),
        BackgroundColor3    = theme.btn_normal,
        BackgroundTransparency = 0.1,
        BorderSizePixel     = 0,
        ZIndex              = 3,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.input_bg, CornerRadius = ud(0, 6) })
    items.input_stroke = lib:new("UIStroke", {
        Parent              = items.input_bg,
        Color               = theme.border_light,
        Transparency        = 0.5,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })

    items.input = lib:new("TextBox", {
        Parent              = items.input_bg,
        Size                = ud2(1, -14, 1, 0),
        Position            = ud2(0, 7, 0, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.small,
        Text                = cfg.default,
        TextColor3          = theme.text_secondary,
        PlaceholderColor3   = theme.text_muted,
        PlaceholderText     = cfg.placeholder,
        TextSize            = 12,
        ClearTextOnFocus    = false,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        Name                = "\0",
    })

    lib:new("UIPadding", {
        Parent              = items.root,
        PaddingBottom       = ud(0, 6),
    })

    items.input.Focused:Connect(function()
        lib:tween(items.input_stroke, { Transparency = 0 }, anim.quad, anim.fast)
        lib:tween(items.input_stroke, { Color = theme.accent }, anim.quad, anim.fast)
        lib:tween(items.input, { TextColor3 = theme.text_primary }, anim.quad, anim.fast)
    end)
    items.input.FocusLost:Connect(function()
        lib:tween(items.input_stroke, { Transparency = 0.5 }, anim.quad, anim.fast)
        lib:tween(items.input_stroke, { Color = theme.border_light }, anim.quad, anim.fast)
        lib:tween(items.input, { TextColor3 = theme.text_secondary }, anim.quad, anim.fast)
    end)

    function cfg.set(text)
        items.input.Text = text
        flags[cfg.flag] = text
        cfg.callback(text)
    end

    items.input:GetPropertyChangedSignal("Text"):Connect(function()
        flags[cfg.flag] = items.input.Text
        cfg.callback(items.input.Text)
    end)

    cfg.set(cfg.default)
    cfg_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  KEYBIND
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:keybind(props)
    local cfg = {
        name     = props.name     or "Keybind",
        flag     = props.flag     or lib:next_flag(),
        key      = props.key      or nil,
        mode     = props.mode     or "Toggle",
        active   = props.default  or false,
        callback = props.callback or function() end,

        open     = false,
        binding  = nil,
        mode_btns = {},
        items    = {},
    }

    flags[cfg.flag] = { key = cfg.key, mode = cfg.mode, active = cfg.active }

    local items = cfg.items

    items.root = lib:new("Frame", {
        Parent              = self.items.elements,
        Size                = ud2(1, 0, 0, 18),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    lib:new("TextLabel", {
        Parent              = items.root,
        Size                = ud2(1, -90, 1, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.body,
        Text                = cfg.name,
        TextColor3          = theme.text_primary,
        TextSize            = 13,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        Name                = "\0",
    })

    -- Key display pill
    items.key_btn = lib:new("TextButton", {
        Parent              = items.root,
        Size                = ud2(0, 0, 1, -2),
        Position            = ud2(1, -80, 0, 1),
        AutomaticSize       = Enum.AutomaticSize.X,
        BackgroundColor3    = theme.btn_normal,
        BorderSizePixel     = 0,
        Text                = "",
        AutoButtonColor     = false,
        ZIndex              = 3,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.key_btn, CornerRadius = ud(0, 5) })
    lib:new("UIStroke", {
        Parent              = items.key_btn,
        Color               = theme.border_light,
        Transparency        = 0.5,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })

    items.key_label = lib:new("TextLabel", {
        Parent              = items.key_btn,
        Size                = ud2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        FontFace            = fonts.small,
        Text                = "NONE",
        TextColor3          = theme.text_muted,
        TextSize            = 11,
        BorderSizePixel     = 0,
        ZIndex              = 4,
        AutomaticSize       = Enum.AutomaticSize.X,
        Name                = "\0",
    })
    lib:new("UIPadding", {
        Parent              = items.key_label,
        PaddingLeft         = ud(0, 6), PaddingRight = ud(0, 6),
    })

    -- Mode dropdown popup
    items.mode_popup = lib:new("Frame", {
        Parent              = lib.overlay,
        Size                = ud2(0, 80, 0, 0),
        BackgroundColor3    = theme.bg_glass,
        BackgroundTransparency = 0.06,
        BorderSizePixel     = 0,
        ZIndex              = 30,
        ClipsDescendants    = true,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = items.mode_popup, CornerRadius = ud(0, 6) })
    lib:new("UIStroke", {
        Parent              = items.mode_popup,
        Color               = theme.border_light,
        Transparency        = 0.35,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })
    lib:new("UIPadding", {
        Parent              = items.mode_popup,
        PaddingTop          = ud(0, 4), PaddingBottom = ud(0, 4),
        PaddingLeft         = ud(0, 4), PaddingRight  = ud(0, 4),
    })
    lib:new("UIListLayout", {
        Parent              = items.mode_popup,
        Padding             = ud(0, 3),
        SortOrder           = Enum.SortOrder.LayoutOrder,
    })

    local mode_y = 0
    for _, m in { "Toggle", "Hold", "Always" } do
        local mb = lib:new("TextButton", {
            Parent              = items.mode_popup,
            Size                = ud2(1, -2, 0, 20),
            BackgroundColor3    = theme.btn_normal,
            BackgroundTransparency = 0,
            BorderSizePixel     = 0,
            Text                = "",
            AutoButtonColor     = false,
            ZIndex              = 31,
            Name                = "\0",
        })
        lib:new("UICorner", { Parent = mb, CornerRadius = ud(0, 4) })
        local ml = lib:new("TextLabel", {
            Parent              = mb,
            Size                = ud2(1, -10, 1, 0),
            Position            = ud2(0, 6, 0, 0),
            BackgroundTransparency = 1,
            FontFace            = fonts.small,
            Text                = m,
            TextColor3          = theme.text_secondary,
            TextSize            = 11,
            TextXAlignment      = Enum.TextXAlignment.Left,
            BorderSizePixel     = 0,
            ZIndex              = 32,
            Name                = "\0",
        })
        cfg.mode_btns[m] = ml
        mb.MouseButton1Click:Connect(function()
            cfg.set_mode(m)
            cfg.set_visible(false)
            cfg.open = false
        end)
        mb.MouseEnter:Connect(function()
            lib:tween(mb, { BackgroundColor3 = theme.btn_hover, BackgroundTransparency = 0.5 }, anim.quad, anim.fast)
        end)
        mb.MouseLeave:Connect(function()
            lib:tween(mb, { BackgroundColor3 = theme.btn_normal, BackgroundTransparency = 0 }, anim.quad, anim.fast)
        end)
        mode_y += 23
    end

    function cfg.set_visible(bool)
        local ap = items.key_btn.AbsolutePosition
        local as = items.key_btn.AbsoluteSize
        items.mode_popup.Position = ud2o(ap.X, ap.Y + as.Y + 4)
        lib:tween(items.mode_popup, { Size = ud2(0, 80, 0, bool and mode_y or 0) }, anim.back, anim.normal)
        lib:close_element(cfg)
    end

    function cfg.set_mode(mode)
        cfg.mode = mode
        for k, lbl in cfg.mode_btns do
            lib:tween(lbl, { TextColor3 = k == mode and theme.accent or theme.text_secondary }, anim.quad, anim.fast)
        end
        if mode == "Always" then cfg.set(true)
        elseif mode == "Hold" then cfg.set(false) end
        flags[cfg.flag].mode = mode
    end

    function cfg.set(inp)
        if type(inp) == "boolean" then
            cfg.active = cfg.mode == "Always" and true or inp
        elseif type(inp) == "table" then
            if inp.key then
                inp.key = type(inp.key) == "string" and inp.key ~= "NONE"
                    and lib:str_to_enum(inp.key) or inp.key
            end
            cfg.key    = inp.key or cfg.key
            cfg.mode   = inp.mode or cfg.mode
            cfg.active = inp.active or cfg.active
            cfg.set_mode(cfg.mode)
        elseif tostring(inp):find("Enum") then
            cfg.key = inp.Name == "Escape" and nil or inp
        end

        local k = cfg.key
        local txt = k and (keymap[k] or tostring(k):gsub("Enum%.KeyCode%.", ""):gsub("Enum%.UserInputType%.", "")) or "NONE"
        items.key_label.Text = txt
        lib:tween(items.key_label, { TextColor3 = k and theme.text_primary or theme.text_muted }, anim.quad, anim.fast)

        flags[cfg.flag] = { key = cfg.key, mode = cfg.mode, active = cfg.active }
        cfg.callback(cfg.active)
    end

    -- Click to bind
    items.key_btn.MouseButton1Click:Connect(function()
        if cfg.binding then return end
        items.key_label.Text = "..."
        lib:tween(items.key_label, { TextColor3 = theme.accent }, anim.quad, anim.fast)

        cfg.binding = lib:connect(uis.InputBegan, function(inp, gev)
            if gev then return end
            local k = inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode or inp.UserInputType
            cfg.set(k)
            cfg.binding:Disconnect()
            cfg.binding = nil
        end)
    end)

    -- Right click for mode
    items.key_btn.MouseButton2Click:Connect(function()
        cfg.open = not cfg.open
        cfg.set_visible(cfg.open)
    end)

    lib:connect(uis.InputBegan, function(inp, gev)
        if gev then return end
        local k = inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode or inp.UserInputType
        if k == cfg.key then
            if cfg.mode == "Toggle" then
                cfg.active = not cfg.active
                cfg.set(cfg.active)
            elseif cfg.mode == "Hold" then
                cfg.set(true)
            end
        end
    end)
    lib:connect(uis.InputEnded, function(inp, gev)
        if gev then return end
        local k = inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode or inp.UserInputType
        if k == cfg.key and cfg.mode == "Hold" then
            cfg.set(false)
        end
    end)

    cfg.set({ key = cfg.key, mode = cfg.mode, active = cfg.active })
    cfg_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SEPARATOR LABEL  (inside sidebar tab list)
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:separator(props)
    local cfg = { name = props.name or "General", items = {} }

    lib:new("TextLabel", {
        Parent              = self.items.btn_holder,
        Size                = ud2(1, 0, 0, 16),
        BackgroundTransparency = 1,
        FontFace            = fonts.small,
        Text                = cfg.name:upper(),
        TextColor3          = theme.text_muted,
        TextSize            = 10,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        Name                = "\0",
    })
    lib:new("UIPadding", { Parent = cfg.items, PaddingLeft = ud(0, 2) })

    return setmetatable(cfg, lib)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════════════════════
local notif_queue = {}

local function reflow_notifs()
    local off = 16
    for _, frame in notif_queue do
        lib:tween(frame, { Position = ud2(1, -226, 0, off) }, anim.quad, anim.spring)
        off += frame.AbsoluteSize.Y + 8
    end
end

function lib:notify(props)
    if not lib.items then return end

    local cfg = {
        title    = props.title    or "Sentence",
        body     = props.body     or "",
        lifetime = props.lifetime or 4,
    }

    local notif = lib:new("Frame", {
        Parent              = lib.items,
        Size                = ud2(0, 220, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        Position            = ud2(1, -226, 0, 16),
        AnchorPoint         = v2(0, 0),
        BackgroundColor3    = theme.notif_bg,
        BackgroundTransparency = 0.06,
        BorderSizePixel     = 0,
        ZIndex              = 100,
        Name                = "\0",
        ClipsDescendants    = true,
    })
    lib:new("UICorner", { Parent = notif, CornerRadius = ud(0, 8) })
    lib:new("UIStroke", {
        Parent              = notif,
        Color               = theme.border_light,
        Transparency        = 0.4,
        ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
    })

    -- Accent left edge
    local edge = lib:new("Frame", {
        Parent              = notif,
        Size                = ud2(0, 3, 1, 0),
        BackgroundColor3    = theme.accent,
        BorderSizePixel     = 0,
        ZIndex              = 101,
        Name                = "\0",
    })
    lib:new("UICorner", { Parent = edge, CornerRadius = ud(0, 8) })
    lib:new("ImageLabel", {
        Parent              = edge,
        Size                = ud2(6, 0, 1, 0),
        Position            = ud2(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Image               = "rbxassetid://112971167999062",
        ImageColor3         = theme.accent,
        ImageTransparency   = 0.75,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = rc(v2(100,100), v2(156,156)),
        BorderSizePixel     = 0,
        ZIndex              = 100,
        Name                = "\0",
    })

    lib:new("TextLabel", {
        Parent              = notif,
        Size                = ud2(1, -20, 0, 0),
        Position            = ud2(0, 14, 0, 8),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        FontFace            = fonts.label,
        Text                = cfg.title,
        TextColor3          = theme.text_primary,
        TextSize            = 12,
        TextXAlignment      = Enum.TextXAlignment.Left,
        BorderSizePixel     = 0,
        ZIndex              = 101,
        Name                = "\0",
    })

    if cfg.body ~= "" then
        lib:new("TextLabel", {
            Parent              = notif,
            Size                = ud2(1, -20, 0, 0),
            Position            = ud2(0, 14, 0, 24),
            AutomaticSize       = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            FontFace            = fonts.small,
            Text                = cfg.body,
            TextColor3          = theme.text_secondary,
            TextSize            = 11,
            TextXAlignment      = Enum.TextXAlignment.Left,
            TextWrapped         = true,
            BorderSizePixel     = 0,
            ZIndex              = 101,
            Name                = "\0",
        })
    end

    -- Progress bar
    local prog_track = lib:new("Frame", {
        Parent              = notif,
        Size                = ud2(1, 0, 0, 2),
        Position            = ud2(0, 0, 1, -2),
        BackgroundColor3    = theme.border,
        BorderSizePixel     = 0,
        ZIndex              = 102,
        Name                = "\0",
    })
    local prog_fill = lib:new("Frame", {
        Parent              = prog_track,
        Size                = ud2(1, 0, 1, 0),
        BackgroundColor3    = theme.accent,
        BorderSizePixel     = 0,
        ZIndex              = 103,
        Name                = "\0",
    })
    lib:new("UIGradient", {
        Parent  = prog_fill,
        Color   = cseq{ ckey(0, theme.accent_glow), ckey(1, theme.accent_dim) },
    })

    -- Padding for auto size
    lib:new("UIPadding", {
        Parent              = notif,
        PaddingBottom       = ud(0, 14),
    })

    -- Entrance
    notif.Position = ud2(1, 40, 0, 16)
    insert(notif_queue, notif)
    reflow_notifs()
    lib:tween(notif, { Position = ud2(1, -226, 0, 16) }, anim.back, anim.spring)
    lib:tween(prog_fill, { Size = ud2(0, 0, 1, 0) }, anim.linear, cfg.lifetime)

    task.spawn(function()
        task.wait(cfg.lifetime)
        local idx = find(notif_queue, notif)
        if idx then remove(notif_queue, idx) end
        lib:tween(notif, { Position = ud2(1, 40, 0, notif.Position.Y.Offset) }, anim.out, anim.normal)
        task.wait(anim.normal + 0.05)
        notif:Destroy()
        reflow_notifs()
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  CONFIG SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════
function lib:init_config(window)
    window:separator({ name = "Settings" })
    local cfg_tab = window:tab({ name = "Config", icon = "rbxassetid://139628202576511", tabs = { "Manage" } })

    local col = cfg_tab:column({})
    local sec = col:section({ name = "Saved Configs", size = 0.55, icon = "rbxassetid://139628202576511" })

    local config_list = sec:dropdown({
        name     = "Config file",
        items    = { "none" },
        flag     = "config_name_list",
        callback = function() end,
    })

    lib:update_config_list(config_list)

    local sec2 = col:section({ name = "Actions", size = 0.45, icon = "rbxassetid://129380150574313" })
    sec2:textbox({ name = "File name", placeholder = "my_config", flag = "config_name_input" })

    sec2:button({ name = "Save Config", callback = function()
        local fname = flags["config_name_input"] ~= "" and flags["config_name_input"] or "config"
        writefile(lib.directory .. "/configs/" .. fname .. ".cfg", lib:get_config())
        lib:update_config_list(config_list)
        lib:notify({ title = "Config Saved", body = "Saved as: " .. fname })
    end })

    sec2:button({ name = "Load Config", callback = function()
        local sel = flags["config_name_list"]
        if not sel or sel == "" then return end
        lib:load_config(readfile(lib.directory .. "/configs/" .. sel .. ".cfg"))
        lib:notify({ title = "Config Loaded", body = sel })
    end })

    sec2:button({ name = "Delete Config", callback = function()
        local sel = flags["config_name_list"]
        if not sel or sel == "" then return end
        delfile(lib.directory .. "/configs/" .. sel .. ".cfg")
        lib:update_config_list(config_list)
        lib:notify({ title = "Config Deleted", body = sel })
    end })

    -- Appearance
    local col2 = cfg_tab:column({})
    local sec3 = col2:section({ name = "Appearance", size = 0.5, icon = "rbxassetid://129380150574313" })
    sec3:colorpicker({
        name     = "Accent Color",
        color    = theme.accent,
        callback = function(col)
            theme.accent = col
        end,
    })
    sec3:keybind({
        name     = "Menu Keybind",
        key      = Enum.KeyCode.RightShift,
        callback = function(active) window.toggle_menu(active) end,
        default  = true,
    })
end

function lib:update_config_list(dropdown_element)
    if not dropdown_element then return end
    local list = {}
    for _, file in listfiles(lib.directory .. "/configs") do
        local name = file
            :gsub(lib.directory .. "/configs\\", "")
            :gsub(lib.directory .. "\\configs\\", "")
            :gsub("%.cfg$", "")
        insert(list, name)
    end
    if #list == 0 then list = { "No configs found" } end
    dropdown_element.refresh_options(list)
end

-- ─── Return library ───────────────────────────────────────────────────────────
return lib
