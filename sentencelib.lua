cat > /mnt/user-data/outputs/sentencelib_v2.lua << 'ENDOFLIB'
--[[
    SENTENCE UI  ·  v2.0
    Glass Morphism  ·  OG Sentence Theme
    – No shadow, no subtabs –
]]

-- ── Services & aliases ────────────────────────────────────────────────────────
local uis      = game:GetService("UserInputService")
local tween_s  = game:GetService("TweenService")
local players  = game:GetService("Players")
local http     = game:GetService("HttpService")
local gui_svc  = game:GetService("GuiService")
local coregui  = game:GetService("CoreGui")

local v2, ud2, ud = Vector2.new, UDim2.new, UDim.new
local ud2o = UDim2.fromOffset
local c3, rgb, hex, hsv = Color3.new, Color3.fromRGB, Color3.fromHex, Color3.fromHSV
local cseq, ckey = ColorSequence.new, ColorSequenceKeypoint.new
local nseq, nkey = NumberSequence.new, NumberSequenceKeypoint.new
local floor, clamp, max = math.floor, math.clamp, math.max
local insert, find, remove, concat = table.insert, table.find, table.remove, table.concat

local lp         = players.LocalPlayer
local mouse      = lp:GetMouse()
local camera     = workspace.CurrentCamera
local gui_offset = gui_svc:GetGuiInset().Y

-- ── Theme ─────────────────────────────────────────────────────────────────────
local T = {
    bg0=hex"121212", bg1=hex"161616", bg2=hex"1a1a1a",
    glass=hex"0d0d0f", border=hex"252525", bord2=hex"2d2d2d",
    accent=hex"5A9FE8", acc_lo=hex"4580C9", acc_hi=hex"7BB5ED",
    txt0=hex"E8E8E8", txt1=hex"909090", txt2=hex"505050",
    white=hex"FFFFFF", notif=hex"202020",
    btn=hex"1f1f1f", btnH=hex"252525", btnP=hex"161616",
}

-- ── Animation ─────────────────────────────────────────────────────────────────
local A = {
    fast=.12, normal=.22, spring=.45,
    out=Enum.EasingStyle.Quint, quad=Enum.EasingStyle.Quad,
    back=Enum.EasingStyle.Back, lin=Enum.EasingStyle.Linear,
    dout=Enum.EasingDirection.Out,
}

-- ── Key labels ────────────────────────────────────────────────────────────────
local KEYMAP = {
    [Enum.KeyCode.LeftShift]="LSHIFT",[Enum.KeyCode.RightShift]="RSHIFT",
    [Enum.KeyCode.LeftControl]="LCTRL",[Enum.KeyCode.RightControl]="RCTRL",
    [Enum.KeyCode.Return]="ENTER",[Enum.KeyCode.Space]="SPACE",
    [Enum.KeyCode.Escape]="ESC",[Enum.KeyCode.Tab]="TAB",
    [Enum.KeyCode.F1]="F1",[Enum.KeyCode.F2]="F2",[Enum.KeyCode.F3]="F3",
    [Enum.KeyCode.F4]="F4",[Enum.KeyCode.F5]="F5",[Enum.KeyCode.F6]="F6",
    [Enum.KeyCode.F7]="F7",[Enum.KeyCode.F8]="F8",[Enum.KeyCode.F9]="F9",
    [Enum.KeyCode.F10]="F10",[Enum.KeyCode.F11]="F11",[Enum.KeyCode.F12]="F12",
    [Enum.UserInputType.MouseButton1]="MB1",
    [Enum.UserInputType.MouseButton2]="MB2",
    [Enum.UserInputType.MouseButton3]="MB3",
}

-- ═════════════════════════════════════════════════════════════════════════════
--  LIBRARY INIT
-- ═════════════════════════════════════════════════════════════════════════════
getgenv().sentence = {
    directory="sentence", folders={"/configs","/themes"},
    flags={}, cfg_flags={}, connections={},
    current_open=nil, cache=nil, items=nil, overlay=nil,
    notif_queue={},
}
local lib = sentence; lib.__index = lib
local flags, cfg_flags = lib.flags, lib.cfg_flags

for _,p in lib.folders do makefolder(lib.directory..p) end

-- ── Font loader ───────────────────────────────────────────────────────────────
local fonts = {}; do
    local function load(id, w, s, url)
        if not isfile(id) then writefile(id, game:HttpGet(url)) end
        local fp = id:gsub("%.ttf",".font")
        if isfile(fp) then delfile(fp) end
        writefile(fp, http:JSONEncode{
            name=id:gsub("%.ttf",""),
            faces={{name="Normal",weight=w,style=s,assetId=getcustomasset(id)}}
        })
        return getcustomasset(fp)
    end
    local BASE = "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/"
    local reg = load("SN_R.ttf",400,"Normal",BASE.."Inter_28pt-Medium.ttf")
    local med = load("SN_M.ttf",500,"Normal",BASE.."Inter_28pt-Medium.ttf")
    local sb  = load("SN_S.ttf",600,"Normal",BASE.."Inter_28pt-SemiBold.ttf")
    fonts.sm   = Font.new(reg,Enum.FontWeight.Regular,Enum.FontStyle.Normal)
    fonts.body = Font.new(med,Enum.FontWeight.Regular,Enum.FontStyle.Normal)
    fonts.lbl  = Font.new(sb, Enum.FontWeight.Regular,Enum.FontStyle.Normal)
end

-- ── Core utils ────────────────────────────────────────────────────────────────
function lib:tw(obj,props,style,dur,dir)
    tween_s:Create(obj,TweenInfo.new(dur or A.normal,style or A.out,dir or A.dout,0,false,0),props):Play()
end
function lib:mk(class,props)
    local i=Instance.new(class); for k,v in props do i[k]=v end; return i
end
function lib:conn(sig,fn)
    local c=sig:Connect(fn); insert(lib.connections,c); return c
end
function lib:round(n,i) i=i or 1; return floor(n/i+.5)*i end
function lib:next_flag()
    local n=0; for _ in flags do n+=1 end; return("sf_%d"):format(n+1)
end
function lib:str_enum(s)
    local p={}; for x in s:gmatch("[%w_]+") do insert(p,x) end
    local t=Enum; for i=2,#p do t=t[p[i]] end; return t
end
function lib:close_el(next)
    local o=lib.current_open
    if o and o~=next then o.set_visible(false); o.open=false end
    if next~=o then lib.current_open=next or nil end
end
function lib:ripple(btn,col)
    col=col or T.accent
    local ap,as=btn.AbsolutePosition,btn.AbsoluteSize
    local c=lib:mk("Frame",{
        Parent=btn,Size=ud2(0,0,0,0),
        Position=ud2(0,clamp(mouse.X-ap.X,0,as.X),0,clamp(mouse.Y-ap.Y,0,as.Y)),
        AnchorPoint=v2(.5,.5),BackgroundColor3=col,
        BackgroundTransparency=.75,BorderSizePixel=0,ZIndex=btn.ZIndex+1
    })
    lib:mk("UICorner",{Parent=c,CornerRadius=ud(0,9999)})
    lib:tw(c,{Size=ud2(0,max(as.X,as.Y)*1.6,0,max(as.X,as.Y)*1.6),BackgroundTransparency=1},A.quad,.5)
    task.delay(.5,function() c:Destroy() end)
end
function lib:drag(frame,handle)
    handle=handle or frame
    local drag,sp,si=false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; sp=frame.Position; si=i.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    lib:conn(uis.InputChanged,function(i)
        if not drag or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local vp=camera.ViewportSize
        lib:tw(frame,{Position=ud2(0,
            clamp(sp.X.Offset+(i.Position.X-si.X),0,vp.X-frame.AbsoluteSize.X),0,
            clamp(sp.Y.Offset+(i.Position.Y-si.Y),0,vp.Y-frame.AbsoluteSize.Y)
        )},A.lin,.04)
        lib:close_el()
    end)
end

local function shimmer(parent,z)
    local s=lib:mk("Frame",{
        Parent=parent,Size=ud2(.65,0,0,1),Position=ud2(.175,0,0,0),
        BackgroundColor3=T.white,BackgroundTransparency=.93,BorderSizePixel=0,ZIndex=z or 2
    })
    lib:mk("UICorner",{Parent=s,CornerRadius=ud(0,999)})
    lib:mk("UIGradient",{Parent=s,Transparency=nseq{nkey(0,1),nkey(.25,.1),nkey(.75,.1),nkey(1,1)}})
end

-- ── Config helpers ────────────────────────────────────────────────────────────
function lib:get_config()
    local out={}
    for k,v in flags do
        if type(v)=="table" and v.key then
            out[k]={active=v.active,mode=v.mode,key=tostring(v.key)}
        elseif type(v)=="table" and v.Color then
            out[k]={Color=v.Color:ToHex(),Transparency=v.Transparency}
        else out[k]=v end
    end
    return http:JSONEncode(out)
end
function lib:load_config(json)
    for k,v in http:JSONDecode(json) do
        if k=="config_name_list" then continue end
        local fn=cfg_flags[k]
        if fn then fn(type(v)=="table" and v.Color and hex(v.Color) or v,
                      type(v)=="table" and v.Transparency or nil) end
    end
end
function lib:unload()
    if lib.items then lib.items:Destroy() end
    if lib.overlay then lib.overlay:Destroy() end
    for _,c in lib.connections do pcall(function() c:Disconnect() end) end
    lib.connections={}
end

-- ═════════════════════════════════════════════════════════════════════════════
--  WINDOW
-- ═════════════════════════════════════════════════════════════════════════════
function lib:window(p)
    local cfg={
        name=p.name or "SENTENCE", sub=p.subtitle or "v2.0",
        info=p.game_info or "Universal", size=p.size or ud2(0,680,0,540),
        selected_tab=nil, items={},
    }

    lib.items=lib:mk("ScreenGui",{Parent=coregui,Enabled=true,
        ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=true,ResetOnSpawn=false})
    lib.cache=lib:mk("Frame",{Parent=lib.items,Size=ud2(0,1,0,1),
        Position=ud2(0,-9999,0,-9999),BackgroundTransparency=1,BorderSizePixel=0})
    lib.overlay=lib:mk("ScreenGui",{Parent=coregui,Enabled=true,
        ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=true,ResetOnSpawn=false})

    -- Main frame (no shadow)
    local main=lib:mk("Frame",{
        Parent=lib.items, Size=cfg.size,
        Position=ud2(.5,-cfg.size.X.Offset/2,.5,-cfg.size.Y.Offset/2),
        BackgroundColor3=T.bg0, BackgroundTransparency=.08, BorderSizePixel=0,
    })
    lib:mk("UICorner",{Parent=main,CornerRadius=ud(0,12)})
    lib:mk("UIStroke",{Parent=main,Color=T.border,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1})
    shimmer(main,2)
    main.Position=ud2(0,main.AbsolutePosition.X,0,main.AbsolutePosition.Y)
    cfg.items.main=main

    -- Sidebar
    local sidebar=lib:mk("Frame",{
        Parent=main,Size=ud2(0,186,1,0),BackgroundColor3=T.bg1,
        BackgroundTransparency=.1,BorderSizePixel=0,ZIndex=2,
    })
    lib:mk("UICorner",{Parent=sidebar,CornerRadius=ud(0,12)})
    lib:mk("Frame",{Parent=sidebar,Size=ud2(0,12,1,0),Position=ud2(1,-12,0,0),
        BackgroundColor3=T.bg1,BackgroundTransparency=.1,BorderSizePixel=0,ZIndex=1})
    lib:mk("Frame",{Parent=sidebar,Size=ud2(0,1,1,0),Position=ud2(1,-1,0,0),
        BackgroundColor3=T.border,BackgroundTransparency=.3,BorderSizePixel=0,ZIndex=3})

    -- Logo
    local logo=lib:mk("Frame",{Parent=sidebar,Size=ud2(1,0,0,68),BackgroundTransparency=1,ZIndex=3})
    local bar=lib:mk("Frame",{Parent=logo,Size=ud2(0,3,0,28),Position=ud2(0,13,.5,-14),
        BackgroundColor3=T.accent,BorderSizePixel=0,ZIndex=4})
    lib:mk("UICorner",{Parent=bar,CornerRadius=ud(0,999)})
    lib:mk("TextLabel",{Parent=logo,Position=ud2(0,24,.5,-12),Size=ud2(1,-28,0,16),
        BackgroundTransparency=1,FontFace=fonts.lbl,Text=cfg.name,
        TextColor3=T.txt0,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4})
    lib:mk("TextLabel",{Parent=logo,Position=ud2(0,25,.5,3),Size=ud2(1,-28,0,11),
        BackgroundTransparency=1,FontFace=fonts.body,Text=cfg.sub,
        TextColor3=T.accent,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4})
    lib:mk("Frame",{Parent=logo,Size=ud2(1,-26,0,1),Position=ud2(0,13,1,-1),
        BackgroundColor3=T.border,BackgroundTransparency=.4,BorderSizePixel=0,ZIndex=3})

    -- Tab button holder
    local btn_holder=lib:mk("Frame",{
        Parent=sidebar,Size=ud2(1,0,1,-68),Position=ud2(0,0,0,68),
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=3,
    })
    lib:mk("UIListLayout",{Parent=btn_holder,Padding=ud(0,3),SortOrder=Enum.SortOrder.LayoutOrder})
    lib:mk("UIPadding",{Parent=btn_holder,PaddingTop=ud(0,8),PaddingLeft=ud(0,8),
        PaddingRight=ud(0,8),PaddingBottom=ud(0,8)})
    cfg.items.btn_holder=btn_holder

    -- Content area (full height, no multi-bar gap)
    local content=lib:mk("Frame",{
        Parent=main,Size=ud2(1,-186,1,-16),Position=ud2(0,186,0,8),
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2
    })
    cfg.items.content_area=content

    -- Fade overlay
    local fade=lib:mk("Frame",{
        Parent=main,Size=ud2(1,-186,1,-16),Position=ud2(0,186,0,8),
        BackgroundColor3=T.bg0,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=10
    })
    cfg.items.fade_overlay=fade

    -- Bottom bar
    local bot=lib:mk("Frame",{Parent=main,Size=ud2(1,0,0,22),Position=ud2(0,0,1,-22),
        BackgroundColor3=T.bg1,BackgroundTransparency=.1,BorderSizePixel=0,ZIndex=3})
    lib:mk("UICorner",{Parent=bot,CornerRadius=ud(0,12)})
    lib:mk("Frame",{Parent=bot,Size=ud2(1,0,0,6),BackgroundColor3=T.bg1,
        BackgroundTransparency=.1,BorderSizePixel=0,ZIndex=3})
    lib:mk("TextLabel",{Parent=bot,Size=ud2(.5,0,1,0),Position=ud2(0,10,0,0),
        BackgroundTransparency=1,FontFace=fonts.sm,Text=cfg.info,
        TextColor3=T.txt2,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4})

    lib:drag(main,logo)

    -- Entrance animation
    main.BackgroundTransparency=1
    main.Size=ud2(cfg.size.X.Scale,cfg.size.X.Offset-22,cfg.size.Y.Scale,cfg.size.Y.Offset-22)
    task.spawn(function()
        task.wait()
        lib:tw(main,{BackgroundTransparency=.08,Size=cfg.size},A.back,A.spring)
    end)

    function cfg.toggle_menu(vis)
        if vis then
            lib.items.Enabled=true
            main.BackgroundTransparency=1
            main.Size=ud2(cfg.size.X.Scale,cfg.size.X.Offset-18,cfg.size.Y.Scale,cfg.size.Y.Offset-18)
            lib:tw(main,{BackgroundTransparency=.08,Size=cfg.size},A.back,A.spring)
        else
            lib:tw(main,{BackgroundTransparency=1,
                Size=ud2(cfg.size.X.Scale,cfg.size.X.Offset-18,cfg.size.Y.Scale,cfg.size.Y.Offset-18)
            },A.out,A.normal)
            task.delay(A.normal,function() lib.items.Enabled=false end)
        end
    end

    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  TAB  (no subtabs — content goes directly into tab frame)
-- ═════════════════════════════════════════════════════════════════════════════
function lib:tab(p)
    local cfg={
        name=p.name or "Tab", icon=p.icon or "rbxassetid://6034767608",
        items={}, open=false,
    }
    local items=cfg.items

    -- Content holder (lives in cache until opened)
    items.holder=lib:mk("Frame",{
        Parent=lib.cache,
        Size=ud2(1,0,1,0),
        BackgroundTransparency=1,BorderSizePixel=0,Visible=false,
    })
    lib:mk("UIListLayout",{
        Parent=items.holder,
        FillDirection=Enum.FillDirection.Horizontal,
        HorizontalFlex=Enum.UIFlexAlignment.Fill,
        VerticalFlex=Enum.UIFlexAlignment.Fill,
        Padding=ud(0,7),SortOrder=Enum.SortOrder.LayoutOrder,
    })
    lib:mk("UIPadding",{
        Parent=items.holder,
        PaddingTop=ud(0,7),PaddingBottom=ud(0,7),
        PaddingLeft=ud(0,7),PaddingRight=ud(0,7),
    })

    -- Sidebar button
    items.button=lib:mk("TextButton",{
        Parent=self.items.btn_holder,Size=ud2(1,0,0,32),
        BackgroundColor3=T.btn,BackgroundTransparency=1,
        BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=4,
    })
    lib:mk("UICorner",{Parent=items.button,CornerRadius=ud(0,7)})

    items.btn_accent=lib:mk("Frame",{
        Parent=items.button,Size=ud2(0,3,0,16),Position=ud2(0,0,.5,-8),
        BackgroundColor3=T.accent,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5,
    })
    lib:mk("UICorner",{Parent=items.btn_accent,CornerRadius=ud(0,999)})

    items.btn_icon=lib:mk("ImageLabel",{
        Parent=items.button,Size=ud2(0,16,0,16),Position=ud2(0,10,.5,-8),
        BackgroundTransparency=1,Image=cfg.icon,ImageColor3=T.txt2,BorderSizePixel=0,ZIndex=5,
    })
    items.btn_label=lib:mk("TextLabel",{
        Parent=items.button,Size=ud2(1,-36,1,0),Position=ud2(0,32,0,0),
        BackgroundTransparency=1,FontFace=fonts.body,Text=cfg.name,
        TextColor3=T.txt2,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
        BorderSizePixel=0,ZIndex=5,
    })

    items.button.MouseEnter:Connect(function()
        if self.selected_tab==cfg then return end
        lib:tw(items.button,{BackgroundTransparency=.88},A.quad,A.fast)
        lib:tw(items.btn_icon,{ImageColor3=T.txt1},A.quad,A.fast)
        lib:tw(items.btn_label,{TextColor3=T.txt1},A.quad,A.fast)
    end)
    items.button.MouseLeave:Connect(function()
        if self.selected_tab==cfg then return end
        lib:tw(items.button,{BackgroundTransparency=1},A.quad,A.fast)
        lib:tw(items.btn_icon,{ImageColor3=T.txt2},A.quad,A.fast)
        lib:tw(items.btn_label,{TextColor3=T.txt2},A.quad,A.fast)
    end)

    function cfg.open_tab()
        local prev=self.selected_tab
        if prev and prev~=cfg then
            self.items.fade_overlay.BackgroundTransparency=0
            lib:tw(self.items.fade_overlay,{BackgroundTransparency=1},A.quad,.22)
            lib:tw(prev.items.button,{BackgroundTransparency=1,BackgroundColor3=T.btn},A.quad,A.fast)
            lib:tw(prev.items.btn_accent,{BackgroundTransparency=1},A.quad,A.fast)
            lib:tw(prev.items.btn_icon,{ImageColor3=T.txt2},A.quad,A.fast)
            lib:tw(prev.items.btn_label,{TextColor3=T.txt2},A.quad,A.fast)
            prev.items.holder.Parent=lib.cache
            prev.items.holder.Visible=false
        end
        lib:tw(items.button,{BackgroundColor3=T.glass,BackgroundTransparency=.5},A.quad,A.normal)
        lib:tw(items.btn_accent,{BackgroundTransparency=0},A.quad,A.normal)
        lib:tw(items.btn_icon,{ImageColor3=T.accent},A.quad,A.normal)
        lib:tw(items.btn_label,{TextColor3=T.txt0},A.quad,A.normal)
        items.holder.Parent=self.items.content_area
        items.holder.Visible=true
        self.selected_tab=cfg
        lib:close_el()
    end

    items.button.MouseButton1Down:Connect(cfg.open_tab)
    if not self.selected_tab then cfg.open_tab() end

    -- Return a page object that accepts :column()
    local page={items={holder=items.holder}}
    function page:column(props)
        local col_cfg={items={}}
        col_cfg.items.column=lib:mk("Frame",{
            Parent=items.holder,
            Size=ud2(0,0,1,0),
            BackgroundTransparency=1,BorderSizePixel=0,
        })
        lib:mk("UIListLayout",{
            Parent=col_cfg.items.column,
            FillDirection=Enum.FillDirection.Vertical,
            HorizontalFlex=Enum.UIFlexAlignment.Fill,
            Padding=ud(0,7),SortOrder=Enum.SortOrder.LayoutOrder,
        })
        lib:mk("UIPadding",{Parent=col_cfg.items.column,PaddingBottom=ud(0,7)})
        return setmetatable(col_cfg,lib)
    end
    return page
end

-- ═════════════════════════════════════════════════════════════════════════════
--  SECTION
-- ═════════════════════════════════════════════════════════════════════════════
function lib:section(p)
    local cfg={
        name=p.name or "Section",icon=p.icon or "rbxassetid://6022668898",
        size=p.size or .5,fading=p.fading or false,
        default=p.default~=nil and p.default or (not p.fading),items={},
    }
    local items=cfg.items

    items.card=lib:mk("Frame",{
        Parent=self.items.column,Size=ud2(0,0,cfg.size,-4),
        BackgroundColor3=T.bg1,BackgroundTransparency=.12,BorderSizePixel=0,
    })
    lib:mk("UICorner",{Parent=items.card,CornerRadius=ud(0,9)})
    lib:mk("UIStroke",{Parent=items.card,Color=T.border,Transparency=.25,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1})
    shimmer(items.card,2)

    -- Header
    items.header=lib:mk("TextButton",{
        Parent=items.card,Size=ud2(1,0,0,34),
        BackgroundColor3=T.bg2,BackgroundTransparency=.12,BorderSizePixel=0,
        Text="",AutoButtonColor=false,ZIndex=3,
    })
    lib:mk("UICorner",{Parent=items.header,CornerRadius=ud(0,9)})
    lib:mk("Frame",{Parent=items.header,Size=ud2(1,0,0,9),Position=ud2(0,0,1,-9),
        BackgroundColor3=T.bg2,BackgroundTransparency=.12,BorderSizePixel=0,ZIndex=2})

    local icon_bg=lib:mk("Frame",{Parent=items.header,Size=ud2(0,22,0,22),Position=ud2(0,7,.5,-11),
        BackgroundColor3=T.accent,BackgroundTransparency=.85,BorderSizePixel=0,ZIndex=4})
    lib:mk("UICorner",{Parent=icon_bg,CornerRadius=ud(0,5)})
    lib:mk("ImageLabel",{Parent=icon_bg,Size=ud2(1,-4,1,-4),Position=ud2(0,2,0,2),
        BackgroundTransparency=1,Image=cfg.icon,ImageColor3=T.accent,BorderSizePixel=0,ZIndex=5})
    lib:mk("TextLabel",{Parent=items.header,Size=ud2(1,-76,1,0),Position=ud2(0,36,0,0),
        BackgroundTransparency=1,FontFace=fonts.lbl,Text=cfg.name,TextColor3=T.txt0,
        TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,ZIndex=4})
    lib:mk("Frame",{Parent=items.card,Size=ud2(1,-14,0,1),Position=ud2(0,7,0,34),
        BackgroundColor3=T.border,BackgroundTransparency=.45,BorderSizePixel=0,ZIndex=3})

    -- Scroll/elements area
    items.scroll=lib:mk("ScrollingFrame",{
        Parent=items.card,Size=ud2(1,0,1,-36),Position=ud2(0,0,0,36),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,
        ScrollBarImageColor3=T.accent,AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=ud2(0,0,0,0),ZIndex=3,
    })
    items.elements=lib:mk("Frame",{
        Parent=items.scroll,Size=ud2(1,-18,0,0),Position=ud2(0,9,0,9),
        BackgroundTransparency=1,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=3,
    })
    lib:mk("UIListLayout",{Parent=items.elements,Padding=ud(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
    lib:mk("UIPadding",{Parent=items.elements,PaddingBottom=ud(0,10)})

    -- Fading toggle
    if cfg.fading then
        items.track=lib:mk("TextButton",{
            Parent=items.header,Size=ud2(0,30,0,15),Position=ud2(1,-38,.5,-7.5),
            BackgroundColor3=T.bord2,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=5,
        })
        lib:mk("UICorner",{Parent=items.track,CornerRadius=ud(0,999)})
        items.thumb=lib:mk("Frame",{Parent=items.track,Size=ud2(0,10,0,10),
            Position=ud2(0,2,.5,-5),BackgroundColor3=T.txt2,BorderSizePixel=0,ZIndex=6})
        lib:mk("UICorner",{Parent=items.thumb,CornerRadius=ud(0,999)})
        items.fade_panel=lib:mk("Frame",{Parent=items.card,Size=ud2(1,0,1,0),
            BackgroundColor3=T.bg0,BackgroundTransparency=cfg.default and 1 or .22,
            BorderSizePixel=0,ZIndex=8})
        lib:mk("UICorner",{Parent=items.fade_panel,CornerRadius=ud(0,9)})
        function cfg.toggle_section(b)
            lib:tw(items.track,{BackgroundColor3=b and T.accent or T.bord2},A.quad,A.fast)
            lib:tw(items.thumb,{BackgroundColor3=b and T.white or T.txt2,
                Position=b and ud2(1,-12,.5,-5) or ud2(0,2,.5,-5)},A.quad,A.fast)
            lib:tw(items.fade_panel,{BackgroundTransparency=b and 1 or .22},A.quad,A.normal)
        end
        items.header.MouseButton1Click:Connect(function()
            cfg.default=not cfg.default; cfg.toggle_section(cfg.default)
        end)
        items.track.MouseButton1Click:Connect(function()
            cfg.default=not cfg.default; cfg.toggle_section(cfg.default)
        end)
        cfg.toggle_section(cfg.default)
    end

    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  TOGGLE
-- ═════════════════════════════════════════════════════════════════════════════
function lib:toggle(p)
    local cfg={
        name=p.name or "Toggle",flag=p.flag or lib:next_flag(),
        default=p.default or false,enabled=p.default or false,
        style=p.style or "switch",callback=p.callback or function()end,
        sep=p.sep or false,info=p.info,items={},
    }
    flags[cfg.flag]=cfg.default
    local items=cfg.items

    items.root=lib:mk("TextButton",{
        Parent=self.items.elements,Size=ud2(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,
    })
    items.label=lib:mk("TextLabel",{
        Parent=items.root,Size=ud2(1,-46,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,FontFace=fonts.body,Text=cfg.name,TextColor3=T.txt0,
        TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,ZIndex=3,
    })
    lib:mk("UIPadding",{Parent=items.label,PaddingLeft=ud(0,2)})
    if cfg.info then
        lib:mk("TextLabel",{
            Parent=items.root,Size=ud2(1,-8,0,0),Position=ud2(0,4,0,15),
            AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,FontFace=fonts.sm,
            Text=cfg.info,TextColor3=T.txt1,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true,BorderSizePixel=0,
        })
    end

    if cfg.style=="switch" then
        items.track=lib:mk("TextButton",{
            Parent=items.root,Size=ud2(0,32,0,17),Position=ud2(1,-32,0,0),
            BackgroundColor3=T.bord2,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=4,
        })
        lib:mk("UICorner",{Parent=items.track,CornerRadius=ud(0,999)})
        items.thumb=lib:mk("Frame",{Parent=items.track,Size=ud2(0,12,0,12),
            Position=ud2(0,2,.5,-6),BackgroundColor3=T.txt2,BorderSizePixel=0,ZIndex=5})
        lib:mk("UICorner",{Parent=items.thumb,CornerRadius=ud(0,999)})
        items.glow=lib:mk("ImageLabel",{
            Parent=items.thumb,Size=ud2(3.5,0,3.5,0),Position=ud2(-1.25,0,-1.25,0),
            BackgroundTransparency=1,Image="rbxassetid://112971167999062",ImageColor3=T.accent,
            ImageTransparency=1,ScaleType=Enum.ScaleType.Slice,
            SliceCenter=Rect.new(v2(100,100),v2(156,156)),BorderSizePixel=0,ZIndex=4,
        })
        function cfg.set(b)
            cfg.enabled=b; flags[cfg.flag]=b
            lib:tw(items.track,{BackgroundColor3=b and T.accent or T.bord2},A.quad,A.fast)
            lib:tw(items.thumb,{BackgroundColor3=b and T.white or T.txt2,
                Position=b and ud2(1,-14,.5,-6) or ud2(0,2,.5,-6)},A.back,A.normal)
            lib:tw(items.glow,{ImageTransparency=b and .65 or 1},A.quad,A.normal)
            cfg.callback(b)
        end
        items.track.MouseButton1Click:Connect(function() cfg.set(not cfg.enabled) end)
        items.root.MouseButton1Click:Connect(function() cfg.set(not cfg.enabled) end)
    else
        items.track=lib:mk("TextButton",{
            Parent=items.root,Size=ud2(0,15,0,15),Position=ud2(1,-15,0,0),
            BackgroundColor3=T.bg2,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=4,
        })
        lib:mk("UICorner",{Parent=items.track,CornerRadius=ud(0,4)})
        lib:mk("UIStroke",{Parent=items.track,Color=T.bord2,Transparency=.4,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
        items.check=lib:mk("ImageLabel",{
            Parent=items.track,Size=ud2(1,-2,1,-2),Position=ud2(0,1,0,1),
            BackgroundTransparency=1,Image="rbxassetid://111862698467575",
            ImageColor3=T.white,ImageTransparency=1,BorderSizePixel=0,ZIndex=5,
        })
        function cfg.set(b)
            cfg.enabled=b; flags[cfg.flag]=b
            lib:tw(items.track,{BackgroundColor3=b and T.accent or T.bg2},A.quad,A.fast)
            lib:tw(items.check,{ImageTransparency=b and 0 or 1,Rotation=b and 0 or 15},A.back,A.normal)
            cfg.callback(b)
        end
        items.track.MouseButton1Click:Connect(function() cfg.set(not cfg.enabled) end)
        items.root.MouseButton1Click:Connect(function() cfg.set(not cfg.enabled) end)
    end

    if cfg.sep then
        lib:mk("Frame",{Parent=self.items.elements,Size=ud2(1,0,0,1),
            BackgroundColor3=T.border,BackgroundTransparency=.5,BorderSizePixel=0})
    end
    cfg.set(cfg.default); cfg_flags[cfg.flag]=cfg.set
    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  SLIDER
-- ═════════════════════════════════════════════════════════════════════════════
function lib:slider(p)
    local cfg={
        name=p.name or "Slider",flag=p.flag or lib:next_flag(),
        min=p.min or 0,max=p.max or 100,interval=p.interval or 1,
        default=p.default or 0,value=p.default or 0,suffix=p.suffix or "",
        callback=p.callback or function()end,sep=p.sep~=false,dragging=false,items={},
    }
    flags[cfg.flag]=cfg.default
    local items=cfg.items

    items.root=lib:mk("Frame",{Parent=self.items.elements,Size=ud2(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0})

    local row=lib:mk("Frame",{Parent=items.root,Size=ud2(1,0,0,15),
        BackgroundTransparency=1,BorderSizePixel=0})
    lib:mk("TextLabel",{Parent=row,Size=ud2(.6,0,1,0),BackgroundTransparency=1,
        FontFace=fonts.body,Text=cfg.name,TextColor3=T.txt0,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0})
    items.val=lib:mk("TextLabel",{Parent=row,Size=ud2(.4,0,1,0),Position=ud2(.6,0,0,0),
        BackgroundTransparency=1,FontFace=fonts.sm,Text=tostring(cfg.default)..cfg.suffix,
        TextColor3=T.txt1,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,BorderSizePixel=0})

    items.track=lib:mk("TextButton",{Parent=items.root,Size=ud2(1,0,0,4),Position=ud2(0,0,0,20),
        BackgroundColor3=T.glass,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=3})
    lib:mk("UICorner",{Parent=items.track,CornerRadius=ud(0,999)})
    lib:mk("UIStroke",{Parent=items.track,Color=T.border,Transparency=.4,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})

    items.fill=lib:mk("Frame",{Parent=items.track,Size=ud2(.5,0,1,0),
        BackgroundColor3=T.accent,BorderSizePixel=0,ZIndex=4})
    lib:mk("UICorner",{Parent=items.fill,CornerRadius=ud(0,999)})
    lib:mk("UIGradient",{Parent=items.fill,Color=cseq{ckey(0,T.acc_hi),ckey(1,T.acc_lo)}})

    items.thumb=lib:mk("Frame",{Parent=items.fill,Size=ud2(0,13,0,13),
        Position=ud2(1,-6.5,.5,-6.5),BackgroundColor3=T.white,BorderSizePixel=0,ZIndex=5})
    lib:mk("UICorner",{Parent=items.thumb,CornerRadius=ud(0,999)})
    items.ring=lib:mk("UIStroke",{Parent=items.thumb,Color=T.accent,Transparency=1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=2})
    lib:mk("UIPadding",{Parent=items.root,PaddingBottom=ud(0,7)})

    function cfg.set(val)
        cfg.value=clamp(lib:round(val,cfg.interval),cfg.min,cfg.max)
        local pct=(cfg.value-cfg.min)/(cfg.max-cfg.min)
        lib:tw(items.fill,{Size=ud2(pct,pct==0 and 0 or -3,1,0)},A.lin,.04)
        items.val.Text=tostring(cfg.value)..cfg.suffix
        flags[cfg.flag]=cfg.value; cfg.callback(cfg.value)
    end

    items.track.MouseButton1Down:Connect(function()
        cfg.dragging=true
        lib:tw(items.ring,{Transparency=.4},A.quad,A.fast)
        lib:tw(items.thumb,{Size=ud2(0,15,0,15),Position=ud2(1,-7.5,.5,-7.5)},A.back,A.fast)
        lib:tw(items.val,{TextColor3=T.accent},A.quad,A.fast)
    end)
    lib:conn(uis.InputChanged,function(i)
        if cfg.dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            cfg.set(cfg.min+(cfg.max-cfg.min)*((i.Position.X-items.track.AbsolutePosition.X)/items.track.AbsoluteSize.X))
        end
    end)
    lib:conn(uis.InputEnded,function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 and cfg.dragging then
            cfg.dragging=false
            lib:tw(items.ring,{Transparency=1},A.quad,A.fast)
            lib:tw(items.thumb,{Size=ud2(0,13,0,13),Position=ud2(1,-6.5,.5,-6.5)},A.quad,A.fast)
            lib:tw(items.val,{TextColor3=T.txt1},A.quad,A.fast)
        end
    end)

    if cfg.sep then
        lib:mk("Frame",{Parent=self.items.elements,Size=ud2(1,0,0,1),
            BackgroundColor3=T.border,BackgroundTransparency=.5,BorderSizePixel=0})
    end
    cfg.set(cfg.default); cfg_flags[cfg.flag]=cfg.set
    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  DROPDOWN
-- ═════════════════════════════════════════════════════════════════════════════
function lib:dropdown(p)
    local cfg={
        name=p.name or "Dropdown",flag=p.flag or lib:next_flag(),
        options=p.items or {},default=p.default,multi=p.multi or false,
        callback=p.callback or function()end,width=p.width or 138,sep=p.sep~=false,
        open=false,y_size=0,option_frames={},selected_multi={},items={},
    }
    if cfg.multi then cfg.default=cfg.default or {}
    else cfg.default=cfg.default or cfg.options[1] or "" end
    flags[cfg.flag]=cfg.multi and {} or cfg.default
    local items=cfg.items

    items.root=lib:mk("Frame",{Parent=self.items.elements,Size=ud2(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0})
    lib:mk("TextLabel",{Parent=items.root,Size=ud2(1,-cfg.width-4,0,18),
        BackgroundTransparency=1,FontFace=fonts.body,Text=cfg.name,TextColor3=T.txt0,
        TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0})

    items.pill=lib:mk("TextButton",{Parent=items.root,Size=ud2(0,cfg.width,0,20),
        Position=ud2(1,-cfg.width,0,-1),BackgroundColor3=T.btn,BorderSizePixel=0,
        Text="",AutoButtonColor=false,ZIndex=3})
    lib:mk("UICorner",{Parent=items.pill,CornerRadius=ud(0,5)})
    lib:mk("UIStroke",{Parent=items.pill,Color=T.bord2,Transparency=.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})

    items.sel=lib:mk("TextLabel",{Parent=items.pill,Size=ud2(1,-22,1,0),Position=ud2(0,5,0,0),
        BackgroundTransparency=1,FontFace=fonts.sm,
        Text=cfg.multi and "None" or(cfg.default or "Select..."),
        TextColor3=T.txt1,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,BorderSizePixel=0,ZIndex=4})
    items.chev=lib:mk("ImageLabel",{Parent=items.pill,Size=ud2(0,9,0,9),Position=ud2(1,-14,.5,-4.5),
        BackgroundTransparency=1,Image="rbxassetid://101025591575185",ImageColor3=T.txt2,
        BorderSizePixel=0,ZIndex=4})

    items.popup=lib:mk("Frame",{Parent=lib.overlay,Size=ud2(0,cfg.width,0,0),
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=20,ClipsDescendants=true})
    items.popup_inner=lib:mk("Frame",{Parent=items.popup,Size=ud2(1,0,1,0),
        BackgroundColor3=T.glass,BackgroundTransparency=.06,BorderSizePixel=0,ZIndex=20})
    lib:mk("UICorner",{Parent=items.popup_inner,CornerRadius=ud(0,6)})
    lib:mk("UIStroke",{Parent=items.popup_inner,Color=T.bord2,Transparency=.35,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    lib:mk("UIPadding",{Parent=items.popup_inner,PaddingTop=ud(0,4),PaddingBottom=ud(0,4),
        PaddingLeft=ud(0,4),PaddingRight=ud(0,4)})
    lib:mk("UIListLayout",{Parent=items.popup_inner,Padding=ud(0,3),SortOrder=Enum.SortOrder.LayoutOrder})

    function cfg.set_visible(b)
        local ap,as=items.pill.AbsolutePosition,items.pill.AbsoluteSize
        items.popup.Position=ud2o(ap.X,ap.Y+as.Y+3)
        lib:tw(items.popup,{Size=ud2(0,cfg.width,0,b and cfg.y_size or 0)},A.back,A.normal)
        lib:tw(items.chev,{Rotation=b and 180 or 0},A.quad,A.fast)
        lib:close_el(cfg)
    end

    function cfg.set(val)
        local sel,is_tbl={},type(val)=="table"
        for _,fd in cfg.option_frames do
            local m=fd.text==val or(is_tbl and find(val,fd.text))
            lib:tw(fd.btn,{BackgroundColor3=m and T.accent or T.btn,BackgroundTransparency=m and .8 or 0},A.quad,A.fast)
            lib:tw(fd.lbl,{TextColor3=m and T.accent or T.txt1},A.quad,A.fast)
            if m then insert(sel,fd.text) end
        end
        cfg.selected_multi=sel
        items.sel.Text=is_tbl and(concat(sel,", ")~="" and concat(sel,", ")or"None")or(sel[1] or "Select...")
        flags[cfg.flag]=is_tbl and sel or sel[1]; cfg.callback(flags[cfg.flag])
    end

    function cfg.refresh_options(list)
        cfg.y_size=0
        for _,fd in cfg.option_frames do fd.btn:Destroy() end
        cfg.option_frames={}
        for _,opt in list do
            local btn=lib:mk("TextButton",{Parent=items.popup_inner,Size=ud2(1,-2,0,21),
                BackgroundColor3=T.btn,BackgroundTransparency=0,BorderSizePixel=0,
                Text="",AutoButtonColor=false,ZIndex=21})
            lib:mk("UICorner",{Parent=btn,CornerRadius=ud(0,4)})
            local lbl=lib:mk("TextLabel",{Parent=btn,Size=ud2(1,-10,1,0),Position=ud2(0,5,0,0),
                BackgroundTransparency=1,FontFace=fonts.sm,Text=opt,TextColor3=T.txt1,
                TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,ZIndex=22})
            btn.MouseEnter:Connect(function() lib:tw(btn,{BackgroundColor3=T.btnH,BackgroundTransparency=.5},A.quad,A.fast) end)
            btn.MouseLeave:Connect(function()
                local is_sel=find(cfg.selected_multi,opt)
                lib:tw(btn,{BackgroundColor3=is_sel and T.accent or T.btn,BackgroundTransparency=is_sel and .8 or 0},A.quad,A.fast)
            end)
            btn.MouseButton1Down:Connect(function()
                if cfg.multi then
                    local idx=find(cfg.selected_multi,opt)
                    if idx then remove(cfg.selected_multi,idx) else insert(cfg.selected_multi,opt) end
                    cfg.set(cfg.selected_multi)
                else cfg.set_visible(false); cfg.open=false; cfg.set(opt) end
            end)
            cfg.y_size+=24; insert(cfg.option_frames,{btn=btn,lbl=lbl,text=opt})
        end
    end

    items.pill.MouseButton1Click:Connect(function() cfg.open=not cfg.open; cfg.set_visible(cfg.open) end)
    items.pill.MouseEnter:Connect(function() lib:tw(items.pill,{BackgroundColor3=T.btnH},A.quad,A.fast) end)
    items.pill.MouseLeave:Connect(function() lib:tw(items.pill,{BackgroundColor3=T.btn},A.quad,A.fast) end)

    if cfg.sep then
        lib:mk("Frame",{Parent=self.items.elements,Size=ud2(1,0,0,1),
            BackgroundColor3=T.border,BackgroundTransparency=.5,BorderSizePixel=0})
    end
    cfg.refresh_options(cfg.options); cfg.set(cfg.default); cfg_flags[cfg.flag]=cfg.set
    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  BUTTON
-- ═════════════════════════════════════════════════════════════════════════════
function lib:button(p)
    local cfg={name=p.name or "Button",callback=p.callback or function()end,items={}}
    local items=cfg.items

    items.root=lib:mk("Frame",{Parent=self.items.elements,Size=ud2(1,0,0,30),
        BackgroundTransparency=1,BorderSizePixel=0})
    items.btn=lib:mk("TextButton",{Parent=items.root,Size=ud2(1,0,1,0),
        BackgroundColor3=T.btn,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=3,ClipsDescendants=true})
    lib:mk("UICorner",{Parent=items.btn,CornerRadius=ud(0,7)})
    lib:mk("UIStroke",{Parent=items.btn,Color=T.bord2,Transparency=.55,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    shimmer(items.btn,4)
    items.lbl=lib:mk("TextLabel",{Parent=items.btn,Size=ud2(1,0,1,0),BackgroundTransparency=1,
        FontFace=fonts.body,Text=cfg.name,TextColor3=T.txt0,TextSize=13,BorderSizePixel=0,ZIndex=5})

    items.btn.MouseEnter:Connect(function() lib:tw(items.btn,{BackgroundColor3=T.btnH},A.quad,A.fast) end)
    items.btn.MouseLeave:Connect(function() lib:tw(items.btn,{BackgroundColor3=T.btn},A.quad,A.fast) end)
    items.btn.MouseButton1Down:Connect(function()
        lib:tw(items.btn,{BackgroundColor3=T.btnP},A.quad,.05); lib:ripple(items.btn,T.accent)
    end)
    items.btn.MouseButton1Up:Connect(function() lib:tw(items.btn,{BackgroundColor3=T.btnH},A.quad,A.fast) end)
    items.btn.MouseButton1Click:Connect(function()
        lib:tw(items.lbl,{TextColor3=T.accent},A.quad,.05)
        lib:tw(items.lbl,{TextColor3=T.txt0},A.quad,A.normal)
        cfg.callback()
    end)
    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  LABEL
-- ═════════════════════════════════════════════════════════════════════════════
function lib:label(p)
    local cfg={name=p.name or "Label",info=p.info,sep=p.sep or false,items={}}
    local items=cfg.items

    items.root=lib:mk("Frame",{Parent=self.items and self.items.elements or self,
        Size=ud2(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,BorderSizePixel=0})
    items.lbl=lib:mk("TextLabel",{Parent=items.root,Size=ud2(1,-46,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,FontFace=fonts.body,
        Text=cfg.name,TextColor3=T.txt0,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0})
    if cfg.info then
        lib:mk("TextLabel",{Parent=items.root,Size=ud2(1,0,0,0),Position=ud2(0,0,0,15),
            AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,FontFace=fonts.sm,
            Text=cfg.info,TextColor3=T.txt1,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true,BorderSizePixel=0})
    end
    items.right=lib:mk("Frame",{Parent=items.root,Size=ud2(0,0,0,18),Position=ud2(1,0,0,-1),
        BackgroundTransparency=1,BorderSizePixel=0})
    lib:mk("UIListLayout",{Parent=items.right,FillDirection=Enum.FillDirection.Horizontal,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=ud(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
    if cfg.sep then
        lib:mk("Frame",{Parent=self.items.elements,Size=ud2(1,0,0,1),
            BackgroundColor3=T.border,BackgroundTransparency=.5,BorderSizePixel=0})
    end
    function cfg.set_text(t) items.lbl.Text=t end
    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  COLORPICKER
-- ═════════════════════════════════════════════════════════════════════════════
function lib:colorpicker(p)
    local cfg={
        name=p.name or "Color",flag=p.flag or lib:next_flag(),
        color=p.color or c3(1,1,1),alpha=p.alpha and(1-p.alpha)or 0,
        callback=p.callback or function()end,sep=p.sep or false,open=false,items={},
    }
    local h,s,v=cfg.color:ToHSV(); local a=cfg.alpha
    flags[cfg.flag]={Color=cfg.color,Transparency=cfg.alpha}
    local dsv,dhue,dalpha=false,false,false

    local lbl
    if not(self.items and self.items.right) then lbl=self:label({name=cfg.name,sep=cfg.sep}) end
    local items=cfg.items

    items.swatch=lib:mk("TextButton",{
        Parent=lbl and lbl.items.right or self.items.right,
        Size=ud2(0,18,0,18),BackgroundColor3=cfg.color,BorderSizePixel=0,
        Text="",AutoButtonColor=false,ZIndex=4,
    })
    lib:mk("UICorner",{Parent=items.swatch,CornerRadius=ud(0,5)})
    lib:mk("UIStroke",{Parent=items.swatch,Color=T.bord2,Transparency=.4,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})

    items.panel=lib:mk("Frame",{Parent=lib.overlay,Size=ud2(0,178,0,208),
        BackgroundColor3=T.glass,BackgroundTransparency=.06,BorderSizePixel=0,Visible=true,ZIndex=30})
    lib:mk("UICorner",{Parent=items.panel,CornerRadius=ud(0,8)})
    lib:mk("UIStroke",{Parent=items.panel,Color=T.bord2,Transparency=.3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    items.pfade=lib:mk("Frame",{Parent=items.panel,Size=ud2(1,0,1,0),BackgroundColor3=T.bg0,
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=50})
    lib:mk("UICorner",{Parent=items.pfade,CornerRadius=ud(0,8)})

    items.sv=lib:mk("TextButton",{Parent=items.panel,Size=ud2(1,-14,0,108),Position=ud2(0,7,0,7),
        BackgroundColor3=rgb(255,39,39),BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=31})
    lib:mk("UICorner",{Parent=items.sv,CornerRadius=ud(0,5)})
    local sg=lib:mk("Frame",{Parent=items.sv,Size=ud2(1,0,1,0),BackgroundColor3=c3(1,1,1),BorderSizePixel=0,ZIndex=32})
    lib:mk("UICorner",{Parent=sg,CornerRadius=ud(0,5)}); lib:mk("UIGradient",{Parent=sg,Transparency=nseq{nkey(0,0),nkey(1,1)}})
    local vg=lib:mk("Frame",{Parent=items.sv,Size=ud2(1,0,1,0),BackgroundColor3=c3(0,0,0),BorderSizePixel=0,ZIndex=33})
    lib:mk("UICorner",{Parent=vg,CornerRadius=ud(0,5)}); lib:mk("UIGradient",{Parent=vg,Rotation=270,Transparency=nseq{nkey(0,0),nkey(1,1)}})
    items.svc=lib:mk("TextButton",{Parent=items.sv,Size=ud2(0,10,0,10),AnchorPoint=v2(.5,.5),
        Position=ud2(0,0,1,0),BackgroundColor3=c3(1,1,1),BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=35})
    lib:mk("UICorner",{Parent=items.svc,CornerRadius=ud(0,999)})
    lib:mk("UIStroke",{Parent=items.svc,Color=c3(1,1,1),Transparency=0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=2})

    items.hue=lib:mk("TextButton",{Parent=items.panel,Size=ud2(1,-14,0,8),Position=ud2(0,7,0,122),
        BackgroundColor3=c3(1,1,1),BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=31})
    lib:mk("UICorner",{Parent=items.hue,CornerRadius=ud(0,4)})
    lib:mk("UIGradient",{Parent=items.hue,Color=cseq{ckey(0,rgb(255,0,0)),ckey(.17,rgb(255,255,0)),
        ckey(.33,rgb(0,255,0)),ckey(.5,rgb(0,255,255)),ckey(.67,rgb(0,0,255)),
        ckey(.83,rgb(255,0,255)),ckey(1,rgb(255,0,0))}})
    items.hc=lib:mk("Frame",{Parent=items.hue,Size=ud2(0,8,0,8),AnchorPoint=v2(.5,.5),
        Position=ud2(0,0,.5,0),BackgroundColor3=c3(1,1,1),BorderSizePixel=0,ZIndex=33})
    lib:mk("UICorner",{Parent=items.hc,CornerRadius=ud(0,999)})
    lib:mk("UIStroke",{Parent=items.hc,Color=c3(1,1,1),Transparency=0})

    items.al=lib:mk("TextButton",{Parent=items.panel,Size=ud2(1,-14,0,8),Position=ud2(0,7,0,137),
        BackgroundColor3=c3(0,0,0),BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=31})
    lib:mk("UICorner",{Parent=items.al,CornerRadius=ud(0,4)})
    items.alg=lib:mk("UIGradient",{Parent=items.al,Color=cseq{ckey(0,rgb(70,70,70)),ckey(1,rgb(255,0,0))},
        Transparency=nseq{nkey(0,.6),nkey(1,0)}})
    items.ac=lib:mk("Frame",{Parent=items.al,Size=ud2(0,8,0,8),AnchorPoint=v2(.5,.5),
        Position=ud2(1,0,.5,0),BackgroundColor3=c3(1,1,1),BorderSizePixel=0,ZIndex=33})
    lib:mk("UICorner",{Parent=items.ac,CornerRadius=ud(0,999)})
    lib:mk("UIStroke",{Parent=items.ac,Color=c3(1,1,1),Transparency=0})

    items.hex=lib:mk("TextBox",{Parent=items.panel,Size=ud2(1,-14,0,22),Position=ud2(0,7,0,152),
        BackgroundColor3=T.bg2,BackgroundTransparency=.2,BorderSizePixel=0,FontFace=fonts.sm,
        Text="",TextColor3=T.txt1,PlaceholderText="R, G, B, A",PlaceholderColor3=T.txt2,
        TextSize=11,ClearTextOnFocus=false,ZIndex=32})
    lib:mk("UICorner",{Parent=items.hex,CornerRadius=ud(0,4)})
    lib:mk("UIPadding",{Parent=items.hex,PaddingLeft=ud(0,5),PaddingRight=ud(0,5)})

    function cfg.set_visible(b)
        items.pfade.BackgroundTransparency=0
        local ap,as=items.swatch.AbsolutePosition,items.swatch.AbsoluteSize
        items.panel.Position=ud2o(ap.X-89+as.X/2,ap.Y+as.Y+5)
        lib:tw(items.pfade,{BackgroundTransparency=1},A.quad,.25)
        lib:tw(items.swatch,{Size=b and ud2(0,20,0,20) or ud2(0,18,0,18)},A.back,A.fast)
        lib:close_el(cfg)
    end

    function cfg.set(col,alp)
        if type(col)=="boolean" then return end
        if col then h,s,v=col:ToHSV() end
        if alp then a=alp end
        local C=hsv(h,s,v)
        lib:tw(items.hc,{Position=ud2(h,-4,.5,0)},A.lin,.04)
        lib:tw(items.ac,{Position=ud2(1-a,-4,.5,0)},A.lin,.04)
        lib:tw(items.svc,{Position=ud2(s,s*(items.sv.AbsoluteSize.X-10)-5,1-v,(1-v)*(items.sv.AbsoluteSize.Y-10)-5+10)},A.lin,.04)
        items.sv.BackgroundColor3=hsv(h,1,1)
        items.alg.Color=cseq{ckey(0,rgb(70,70,70)),ckey(1,hsv(h,1,1))}
        items.hc.BackgroundColor3=hsv(h,1,1); items.ac.BackgroundColor3=hsv(h,1,1-a)
        items.svc.BackgroundColor3=C
        lib:tw(items.swatch,{BackgroundColor3=C},A.lin,.04)
        flags[cfg.flag]={Color=C,Transparency=a}
        items.hex.Text=("%d, %d, %d, %.2f"):format(lib:round(C.R*255),lib:round(C.G*255),lib:round(C.B*255),1-a)
        cfg.callback(C,a)
    end

    function cfg.update_drag()
        local m=uis:GetMouseLocation(); local o=v2(m.X,m.Y-gui_offset)
        if dsv then
            local ap,as=items.sv.AbsolutePosition,items.sv.AbsoluteSize
            s=clamp((o.X-ap.X)/as.X,0,1); v=1-clamp((o.Y-ap.Y)/as.Y,0,1)
        elseif dhue then
            h=clamp((o.X-items.hue.AbsolutePosition.X)/items.hue.AbsoluteSize.X,0,1)
        elseif dalpha then
            a=1-clamp((o.X-items.al.AbsolutePosition.X)/items.al.AbsoluteSize.X,0,1)
        end
        cfg.set()
    end

    items.swatch.MouseButton1Click:Connect(function() cfg.open=not cfg.open; cfg.set_visible(cfg.open) end)
    items.sv.MouseButton1Down:Connect(function() dsv=true end)
    items.hue.MouseButton1Down:Connect(function() dhue=true end)
    items.al.MouseButton1Down:Connect(function() dalpha=true end)
    uis.InputChanged:Connect(function(i)
        if(dsv or dhue or dalpha)and i.UserInputType==Enum.UserInputType.MouseMovement then cfg.update_drag() end
    end)
    lib:conn(uis.InputEnded,function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dsv=false;dhue=false;dalpha=false end
    end)
    items.hex.FocusLost:Connect(function()
        local pts={}; for n in items.hex.Text:gmatch("[%d%.]+") do insert(pts,tonumber(n)) end
        if #pts==4 then cfg.set(rgb(pts[1],pts[2],pts[3]),1-pts[4]) end
    end)

    cfg.set(cfg.color,cfg.alpha); cfg_flags[cfg.flag]=cfg.set
    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  TEXTBOX
-- ═════════════════════════════════════════════════════════════════════════════
function lib:textbox(p)
    local cfg={
        name=p.name or "Textbox",placeholder=p.placeholder or "Type...",
        default=p.default or "",flag=p.flag or lib:next_flag(),
        callback=p.callback or function()end,items={},
    }
    flags[cfg.flag]=cfg.default
    local items=cfg.items

    items.root=lib:mk("Frame",{Parent=self.items.elements,Size=ud2(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0})
    lib:mk("TextLabel",{Parent=items.root,Size=ud2(1,0,0,15),BackgroundTransparency=1,
        FontFace=fonts.body,Text=cfg.name,TextColor3=T.txt0,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0})
    items.bg=lib:mk("Frame",{Parent=items.root,Size=ud2(1,0,0,26),Position=ud2(0,0,0,18),
        BackgroundColor3=T.btn,BackgroundTransparency=.1,BorderSizePixel=0,ZIndex=3})
    lib:mk("UICorner",{Parent=items.bg,CornerRadius=ud(0,6)})
    items.stroke=lib:mk("UIStroke",{Parent=items.bg,Color=T.bord2,Transparency=.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    items.input=lib:mk("TextBox",{Parent=items.bg,Size=ud2(1,-12,1,0),Position=ud2(0,6,0,0),
        BackgroundTransparency=1,FontFace=fonts.sm,Text=cfg.default,TextColor3=T.txt1,
        PlaceholderText=cfg.placeholder,PlaceholderColor3=T.txt2,TextSize=12,
        ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,ZIndex=4})
    lib:mk("UIPadding",{Parent=items.root,PaddingBottom=ud(0,5)})

    items.input.Focused:Connect(function()
        lib:tw(items.stroke,{Transparency=0,Color=T.accent},A.quad,A.fast)
        lib:tw(items.input,{TextColor3=T.txt0},A.quad,A.fast)
    end)
    items.input.FocusLost:Connect(function()
        lib:tw(items.stroke,{Transparency=.5,Color=T.bord2},A.quad,A.fast)
        lib:tw(items.input,{TextColor3=T.txt1},A.quad,A.fast)
    end)
    function cfg.set(t) items.input.Text=t; flags[cfg.flag]=t; cfg.callback(t) end
    items.input:GetPropertyChangedSignal("Text"):Connect(function()
        flags[cfg.flag]=items.input.Text; cfg.callback(items.input.Text)
    end)
    cfg.set(cfg.default); cfg_flags[cfg.flag]=cfg.set
    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  KEYBIND
-- ═════════════════════════════════════════════════════════════════════════════
function lib:keybind(p)
    local cfg={
        name=p.name or "Keybind",flag=p.flag or lib:next_flag(),
        key=p.key,mode=p.mode or "Toggle",active=p.default or false,
        callback=p.callback or function()end,open=false,binding=nil,mode_btns={},items={},
    }
    flags[cfg.flag]={key=cfg.key,mode=cfg.mode,active=cfg.active}
    local items=cfg.items

    items.root=lib:mk("Frame",{Parent=self.items.elements,Size=ud2(1,0,0,18),
        BackgroundTransparency=1,BorderSizePixel=0})
    lib:mk("TextLabel",{Parent=items.root,Size=ud2(1,-88,1,0),BackgroundTransparency=1,
        FontFace=fonts.body,Text=cfg.name,TextColor3=T.txt0,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0})

    items.kbtn=lib:mk("TextButton",{Parent=items.root,Size=ud2(0,0,1,-2),Position=ud2(1,-78,0,1),
        AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=T.btn,BorderSizePixel=0,
        Text="",AutoButtonColor=false,ZIndex=3})
    lib:mk("UICorner",{Parent=items.kbtn,CornerRadius=ud(0,5)})
    lib:mk("UIStroke",{Parent=items.kbtn,Color=T.bord2,Transparency=.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    items.klbl=lib:mk("TextLabel",{Parent=items.kbtn,Size=ud2(1,0,1,0),BackgroundTransparency=1,
        FontFace=fonts.sm,Text="NONE",TextColor3=T.txt2,TextSize=11,BorderSizePixel=0,ZIndex=4,AutomaticSize=Enum.AutomaticSize.X})
    lib:mk("UIPadding",{Parent=items.klbl,PaddingLeft=ud(0,6),PaddingRight=ud(0,6)})

    items.mpop=lib:mk("Frame",{Parent=lib.overlay,Size=ud2(0,78,0,0),BackgroundColor3=T.glass,
        BackgroundTransparency=.06,BorderSizePixel=0,ZIndex=30,ClipsDescendants=true})
    lib:mk("UICorner",{Parent=items.mpop,CornerRadius=ud(0,6)})
    lib:mk("UIStroke",{Parent=items.mpop,Color=T.bord2,Transparency=.35,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    lib:mk("UIPadding",{Parent=items.mpop,PaddingTop=ud(0,4),PaddingBottom=ud(0,4),PaddingLeft=ud(0,4),PaddingRight=ud(0,4)})
    lib:mk("UIListLayout",{Parent=items.mpop,Padding=ud(0,3),SortOrder=Enum.SortOrder.LayoutOrder})

    local my=0
    for _,m in{"Toggle","Hold","Always"} do
        local mb=lib:mk("TextButton",{Parent=items.mpop,Size=ud2(1,-2,0,20),
            BackgroundColor3=T.btn,BackgroundTransparency=0,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=31})
        lib:mk("UICorner",{Parent=mb,CornerRadius=ud(0,4)})
        local ml=lib:mk("TextLabel",{Parent=mb,Size=ud2(1,-10,1,0),Position=ud2(0,5,0,0),
            BackgroundTransparency=1,FontFace=fonts.sm,Text=m,TextColor3=T.txt1,TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,ZIndex=32})
        cfg.mode_btns[m]=ml
        mb.MouseButton1Click:Connect(function() cfg.set_mode(m); cfg.set_visible(false); cfg.open=false end)
        mb.MouseEnter:Connect(function() lib:tw(mb,{BackgroundColor3=T.btnH,BackgroundTransparency=.5},A.quad,A.fast) end)
        mb.MouseLeave:Connect(function() lib:tw(mb,{BackgroundColor3=T.btn,BackgroundTransparency=0},A.quad,A.fast) end)
        my+=23
    end

    function cfg.set_visible(b)
        local ap,as=items.kbtn.AbsolutePosition,items.kbtn.AbsoluteSize
        items.mpop.Position=ud2o(ap.X,ap.Y+as.Y+3)
        lib:tw(items.mpop,{Size=ud2(0,78,0,b and my or 0)},A.back,A.normal)
        lib:close_el(cfg)
    end

    function cfg.set_mode(m)
        cfg.mode=m
        for k,lbl in cfg.mode_btns do lib:tw(lbl,{TextColor3=k==m and T.accent or T.txt1},A.quad,A.fast) end
        if m=="Always" then cfg.set(true) elseif m=="Hold" then cfg.set(false) end
        flags[cfg.flag].mode=m
    end

    function cfg.set(inp)
        if type(inp)=="boolean" then
            cfg.active=cfg.mode=="Always" and true or inp
        elseif type(inp)=="table" then
            if inp.key then inp.key=type(inp.key)=="string" and inp.key~="NONE" and lib:str_enum(inp.key) or inp.key end
            cfg.key=inp.key or cfg.key; cfg.mode=inp.mode or cfg.mode
            cfg.active=inp.active or cfg.active; cfg.set_mode(cfg.mode)
        elseif tostring(inp):find("Enum") then
            cfg.key=inp.Name=="Escape" and nil or inp
        end
        local k=cfg.key
        local txt=k and(KEYMAP[k] or tostring(k):gsub("Enum%.KeyCode%.",""):gsub("Enum%.UserInputType%.",""))or"NONE"
        items.klbl.Text=txt
        lib:tw(items.klbl,{TextColor3=k and T.txt0 or T.txt2},A.quad,A.fast)
        flags[cfg.flag]={key=cfg.key,mode=cfg.mode,active=cfg.active}
        cfg.callback(cfg.active)
    end

    items.kbtn.MouseButton1Click:Connect(function()
        if cfg.binding then return end
        items.klbl.Text="..."; lib:tw(items.klbl,{TextColor3=T.accent},A.quad,A.fast)
        cfg.binding=lib:conn(uis.InputBegan,function(i,gev)
            if gev then return end
            cfg.set(i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType)
            cfg.binding:Disconnect(); cfg.binding=nil
        end)
    end)
    items.kbtn.MouseButton2Click:Connect(function() cfg.open=not cfg.open; cfg.set_visible(cfg.open) end)

    lib:conn(uis.InputBegan,function(i,gev)
        if gev then return end
        local k=i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType
        if k==cfg.key then
            if cfg.mode=="Toggle" then cfg.active=not cfg.active; cfg.set(cfg.active)
            elseif cfg.mode=="Hold" then cfg.set(true) end
        end
    end)
    lib:conn(uis.InputEnded,function(i,gev)
        if gev then return end
        local k=i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType
        if k==cfg.key and cfg.mode=="Hold" then cfg.set(false) end
    end)

    cfg.set({key=cfg.key,mode=cfg.mode,active=cfg.active}); cfg_flags[cfg.flag]=cfg.set
    return setmetatable(cfg,lib)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  SEPARATOR  (sidebar label)
-- ═════════════════════════════════════════════════════════════════════════════
function lib:separator(p)
    lib:mk("TextLabel",{
        Parent=self.items.btn_holder,Size=ud2(1,0,0,14),
        BackgroundTransparency=1,FontFace=fonts.sm,
        Text=(p.name or"General"):upper(),TextColor3=T.txt2,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,
    })
end

-- ═════════════════════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ═════════════════════════════════════════════════════════════════════════════
local function reflow()
    local off=14
    for _,f in lib.notif_queue do
        lib:tw(f,{Position=ud2(1,-224,0,off)},A.quad,A.spring)
        off+=f.AbsoluteSize.Y+7
    end
end

function lib:notify(p)
    if not lib.items then return end
    local cfg={title=p.title or "Sentence",body=p.body or "",lifetime=p.lifetime or 4}

    local n=lib:mk("Frame",{Parent=lib.items,Size=ud2(0,218,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        Position=ud2(1,40,0,14),BackgroundColor3=T.notif,BackgroundTransparency=.06,
        BorderSizePixel=0,ZIndex=100,ClipsDescendants=true})
    lib:mk("UICorner",{Parent=n,CornerRadius=ud(0,8)})
    lib:mk("UIStroke",{Parent=n,Color=T.bord2,Transparency=.4,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    local edge=lib:mk("Frame",{Parent=n,Size=ud2(0,3,1,0),BackgroundColor3=T.accent,BorderSizePixel=0,ZIndex=101})
    lib:mk("UICorner",{Parent=edge,CornerRadius=ud(0,8)})
    lib:mk("TextLabel",{Parent=n,Size=ud2(1,-18,0,0),Position=ud2(0,13,0,8),
        AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,FontFace=fonts.lbl,
        Text=cfg.title,TextColor3=T.txt0,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
        BorderSizePixel=0,ZIndex=101})
    if cfg.body~="" then
        lib:mk("TextLabel",{Parent=n,Size=ud2(1,-18,0,0),Position=ud2(0,13,0,24),
            AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,FontFace=fonts.sm,
            Text=cfg.body,TextColor3=T.txt1,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true,BorderSizePixel=0,ZIndex=101})
    end
    local pt=lib:mk("Frame",{Parent=n,Size=ud2(1,0,0,2),Position=ud2(0,0,1,-2),
        BackgroundColor3=T.border,BorderSizePixel=0,ZIndex=102})
    local pf=lib:mk("Frame",{Parent=pt,Size=ud2(1,0,1,0),BackgroundColor3=T.accent,BorderSizePixel=0,ZIndex=103})
    lib:mk("UIGradient",{Parent=pf,Color=cseq{ckey(0,T.acc_hi),ckey(1,T.acc_lo)}})
    lib:mk("UIPadding",{Parent=n,PaddingBottom=ud(0,13)})

    insert(lib.notif_queue,n); reflow()
    lib:tw(n,{Position=ud2(1,-224,0,14)},A.back,A.spring)
    lib:tw(pf,{Size=ud2(0,0,1,0)},A.lin,cfg.lifetime)
    task.spawn(function()
        task.wait(cfg.lifetime)
        local i=find(lib.notif_queue,n); if i then remove(lib.notif_queue,i) end
        lib:tw(n,{Position=ud2(1,40,0,n.Position.Y.Offset)},A.out,A.normal)
        task.wait(A.normal+.05); n:Destroy(); reflow()
    end)
end

-- ═════════════════════════════════════════════════════════════════════════════
--  CONFIG SYSTEM
-- ═════════════════════════════════════════════════════════════════════════════
function lib:init_config(win)
    win:separator({name="Settings"})
    local ct=win:tab({name="Config",icon="rbxassetid://139628202576511"})
    local col=ct:column({})
    local sec=col:section({name="Configs",size=.55,icon="rbxassetid://139628202576511"})
    local dd=sec:dropdown({name="File",items={"none"},flag="config_name_list",callback=function()end})
    lib:update_config_list(dd)

    local sec2=col:section({name="Actions",size=.45,icon="rbxassetid://129380150574313"})
    sec2:textbox({name="File name",placeholder="my_config",flag="config_name_input"})
    sec2:button({name="Save",callback=function()
        local n=flags["config_name_input"]~="" and flags["config_name_input"] or "config"
        writefile(lib.directory.."/configs/"..n..".cfg",lib:get_config())
        lib:update_config_list(dd); lib:notify({title="Saved",body=n})
    end})
    sec2:button({name="Load",callback=function()
        local s=flags["config_name_list"]
        if not s or s=="" then return end
        lib:load_config(readfile(lib.directory.."/configs/"..s..".cfg"))
        lib:notify({title="Loaded",body=s})
    end})
    sec2:button({name="Delete",callback=function()
        local s=flags["config_name_list"]
        if not s or s=="" then return end
        delfile(lib.directory.."/configs/"..s..".cfg")
        lib:update_config_list(dd); lib:notify({title="Deleted",body=s})
    end})

    local col2=ct:column({})
    local sec3=col2:section({name="Appearance",size=.5,icon="rbxassetid://129380150574313"})
    sec3:colorpicker({name="Accent",color=T.accent,callback=function(c) T.accent=c end})
    sec3:keybind({name="Menu Keybind",key=Enum.KeyCode.RightShift,default=true,
        callback=function(a) win.toggle_menu(a) end})
end

function lib:update_config_list(dd)
    if not dd then return end
    local list={}
    for _,f in listfiles(lib.directory.."/configs") do
        insert(list,f:gsub(lib.directory.."/configs\\",""):gsub(lib.directory.."\\configs\\",""):gsub("%.cfg$",""))
    end
    dd.refresh_options(#list>0 and list or{"No configs"})
end

return lib
