--[[
    OPTICALZ MD
    Custom Glass UI V3 • Midnight + Cyan
    Smooth Aimbot + Sticky Lock + Prediction
    Silent Aim (soft) + Triggerbot
    Full ESP: Box / Corner / Tracer / Name / Dist / Health / Skeleton / Chams
    Bullet Tracers • Hit Markers • Kill Flash
    Knife Aura • Hitbox Expand • No Recoil / No Spread
    Speed / Inf Jump / Noclip / Soft Fly
    Fullbright / No Fog / FPS Boost
    Config Save • UI Color Customize
    Works any UNC executor (Xeno / Wave / Solara / Delta / JJSploit / etc.)
]]

-- ======================== OPTICALZ CUSTOM UI ENGINE ========================
-- Local ScreenGui implementation; no Rayfield download required.
local Rayfield = {Flags = {}}
local UI = {accent = Color3.fromRGB(0, 215, 245), connections = {}, themeName = "DarkBlue"}
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 9)}, obj)
    return obj
end
local function stroke(obj, color, thickness)
    make("UIStroke", {Color = color or Color3.fromRGB(45, 56, 72), Thickness = thickness or 1, Transparency = 0.3}, obj)
end
local C = {
    bg = Color3.fromRGB(11, 15, 23), panel = Color3.fromRGB(17, 23, 34),
    card = Color3.fromRGB(24, 32, 46), muted = Color3.fromRGB(139, 154, 175),
    white = Color3.fromRGB(236, 244, 255), border = Color3.fromRGB(47, 60, 77)
}
-- Theme palettes update the existing UI immediately, without rebuilding controls.
local palettes = {
    DarkBlue={accent={0,215,245},bg={11,15,23},panel={17,23,34},card={24,32,46},border={47,60,77}},
    Default={accent={115,185,255},bg={17,19,27},panel={25,28,40},card={34,39,54},border={69,77,98}},
    AmberGlow={accent={255,180,70},bg={22,17,16},panel={31,24,22},card={44,33,29},border={83,61,48}},
    Amethyst={accent={192,132,252},bg={19,15,29},panel={28,22,42},card={39,31,58},border={77,60,104}},
    Bloom={accent={255,126,178},bg={26,17,27},panel={36,24,39},card={50,34,53},border={92,64,94}},
    Green={accent={91,226,166},bg={12,22,20},panel={18,32,29},card={27,45,40},border={54,82,73}},
    Light={accent={22,125,175},bg={219,229,239},panel={235,242,249},card={248,251,255},border={165,187,207},white={24,38,54},muted={80,102,121}},
    Ocean={accent={66,188,232},bg={11,24,34},panel={17,35,47},card={24,48,63},border={49,90,110}},
    Serenity={accent={135,176,249},bg={18,22,35},panel={27,33,49},card={38,46,65},border={71,86,113}},
}
local function rgb(a) return Color3.fromRGB(a[1],a[2],a[3]) end
local function applyTheme(name)
    local palette=palettes[name]
    if not palette then return end
    local old={bg=C.bg,panel=C.panel,card=C.card,border=C.border,white=C.white,muted=C.muted,accent=UI.accent}
    local new={}
    for k,v in pairs(old) do new[k]=palette[k] and rgb(palette[k]) or (k=="white" and Color3.fromRGB(236,244,255) or k=="muted" and Color3.fromRGB(139,154,175) or v) end
    if UI.root then
        for _,obj in ipairs(UI.root:GetDescendants()) do
            for _,property in ipairs({"BackgroundColor3","TextColor3","ImageColor3","ScrollBarImageColor3","Color"}) do
                local ok,value=pcall(function() return obj[property] end)
                if ok and typeof(value)=="Color3" then
                    for k,oldColor in pairs(old) do
                        if value==oldColor then
                            pcall(function() obj[property]=new[k] end)
                            break
                        end
                    end
                end
            end
        end
    end
    for k,v in pairs(new) do if k=="accent" then UI.accent=v else C[k]=v end end
    UI.themeName=name
end
local function label(parent, text, size, color, props)
    local p = {BackgroundTransparency=1, Text=tostring(text), TextColor3=color or C.white,
        Font=Enum.Font.Gotham, TextSize=size or 13, TextXAlignment=Enum.TextXAlignment.Left}
    for k,v in pairs(props or {}) do p[k]=v end
    return make("TextLabel",p,parent)
end
local function button(parent, text, props)
    local p = {Text=text or "", AutoButtonColor=false, Font=Enum.Font.GothamMedium,
        TextSize=12, TextColor3=C.white, BackgroundColor3=C.card, BackgroundTransparency=0.32, BorderSizePixel=0}
    for k,v in pairs(props or {}) do p[k]=v end
    local b=make("TextButton",p,parent)
    round(b,8)
    return b
end
local function notify(title, content)
    print("[OPTICALZ MD] "..tostring(title)..": "..tostring(content))
    if UI.toast and UI.toast.Parent then
        UI.toast.Text=tostring(title).."  -  "..tostring(content)
        UI.toast.Visible=true
        task.delay(3.5,function() if UI.toast and UI.toast.Parent then UI.toast.Visible=false end end)
    end
end
function Rayfield:Notify(opts) notify(opts.Title or "Notice",opts.Content or "") end
function Rayfield:Destroy()
    if UI.root then UI.root:Destroy() UI.root=nil end
    for _, conn in ipairs(UI.connections) do pcall(function() conn:Disconnect() end) end
    table.clear(UI.connections)
end
function Rayfield:CreateWindow(opts)
    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local old=pg:FindFirstChild("OpticalzModern")
    if old then old:Destroy() end
    local root=make("ScreenGui",{Name="OpticalzModern",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
    UI.root=root
    local shadow=round(make("Frame",{Name="Shadow",Size=UDim2.fromOffset(722,492),Position=UDim2.new(0.5,-361,0.5,-246),BackgroundColor3=Color3.fromRGB(3,7,13),BackgroundTransparency=0.78,BorderSizePixel=0},root),16)
    local shell=round(make("Frame",{Name="Window",Size=UDim2.fromOffset(710,480),Position=UDim2.new(0.5,-355,0.5,-240),BackgroundColor3=C.bg,BackgroundTransparency=0.34,BorderSizePixel=0,ClipsDescendants=true},root),14)
    stroke(shell,C.border,1)
    UI.shell=shell; UI.shadow=shadow
    make("UIGradient",{Rotation=110,Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(198,218,235))
    })},shell)
    local side=make("Frame",{Size=UDim2.new(0,177,1,0),BackgroundColor3=C.panel,BackgroundTransparency=0.43,BorderSizePixel=0},shell)
    make("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=C.border,BackgroundTransparency=0.55,BorderSizePixel=0},side)
    label(side,"OPTICALZ MD",18,C.white,{Position=UDim2.fromOffset(17,24),Size=UDim2.fromOffset(156,24),Font=Enum.Font.GothamBold})
    label(side,"MURDER DUELS  /  V3",9,UI.accent,{Position=UDim2.fromOffset(20,51),Size=UDim2.fromOffset(150,17),Font=Enum.Font.GothamBold})
    label(side,"WORKSPACE",9,C.muted,{Position=UDim2.fromOffset(20,92),Size=UDim2.fromOffset(135,17),Font=Enum.Font.GothamBold})
    local nav=make("ScrollingFrame",{Position=UDim2.fromOffset(10,116),Size=UDim2.new(1,-20,1,-132),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},side)
    make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},nav)
    local top=make("Frame",{Position=UDim2.fromOffset(177,0),Size=UDim2.new(1,-177,0,79),BackgroundTransparency=1},shell)
    local title=label(top,"Dashboard",20,C.white,{Position=UDim2.fromOffset(23,18),Size=UDim2.new(1,-130,0,28),Font=Enum.Font.GothamBold})
    local subtitle=label(top,"Fine-tune your experience",11,C.muted,{Position=UDim2.fromOffset(24,49),Size=UDim2.new(1,-150,0,17)})
    local minimize=button(top,"−",{Position=UDim2.new(1,-73,0,20),Size=UDim2.fromOffset(26,26),TextSize=19,BackgroundColor3=C.card})
    local close=button(top,"×",{Position=UDim2.new(1,-39,0,20),Size=UDim2.fromOffset(26,26),TextSize=18,BackgroundColor3=C.card})
    close.MouseButton1Click:Connect(function() shell.Visible=false shadow.Visible=false end)
    local minimized=false
    minimize.MouseButton1Click:Connect(function()
        minimized=not minimized
        -- Compact floating titlebar, rather than a clipped full-size sidebar.
        side.Visible=not minimized
        shell.Size=minimized and UDim2.fromOffset(282,52) or UDim2.fromOffset(710,480)
        shell.BackgroundTransparency=minimized and 0.22 or 0.34
        shadow.Visible=not minimized
        top.Position=minimized and UDim2.fromOffset(0,0) or UDim2.fromOffset(177,0)
        top.Size=minimized and UDim2.new(1,0,1,0) or UDim2.new(1,-177,0,79)
        title.Text=minimized and "OPTICALZ MD" or (UI.activeTitle or "Dashboard")
        title.Position=minimized and UDim2.fromOffset(15,12) or UDim2.fromOffset(23,18)
        title.Size=minimized and UDim2.new(1,-100,0,28) or UDim2.new(1,-130,0,28)
        title.TextSize=minimized and 15 or 20
        subtitle.Visible=not minimized
        minimize.Position=UDim2.new(1,-73,0,minimized and 13 or 20)
        close.Position=UDim2.new(1,-39,0,minimized and 13 or 20)
        minimize.Text=minimized and "+" or "−"
    end)
    local content=make("Frame",{Position=UDim2.fromOffset(192,82),Size=UDim2.new(1,-210,1,-98),BackgroundTransparency=1},shell)
    UI.toast=round(label(root,"",11,C.white,{Visible=false,TextXAlignment=Enum.TextXAlignment.Center,BackgroundTransparency=0.3,BackgroundColor3=C.card,Position=UDim2.new(0.5,-220,1,-76),Size=UDim2.fromOffset(440,35),ZIndex=10}),9)
    local dragging, dragStart, initial
    local input=game:GetService("UserInputService")
    top.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dragStart=i.Position initial=shell.Position end
    end)
    table.insert(UI.connections,input.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dragStart
            local pos=UDim2.new(initial.X.Scale,initial.X.Offset+d.X,initial.Y.Scale,initial.Y.Offset+d.Y)
            shell.Position=pos
            shadow.Position=UDim2.new(pos.X.Scale,pos.X.Offset-6,pos.Y.Scale,pos.Y.Offset-6)
        end
    end))
    table.insert(UI.connections,input.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end))
    table.insert(UI.connections,input.InputBegan:Connect(function(i,gameProcessed)
        if not gameProcessed and i.KeyCode==Enum.KeyCode.RightShift and shell.Parent then
            shell.Visible=not shell.Visible; shadow.Visible=shell.Visible and not minimized
        end
    end))
    local win={tabs={},selected=nil}
    function win:CreateTab(name)
        local navbtn=button(nav,"   "..name,{Size=UDim2.new(1,0,0,35),TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,TextColor3=C.muted,TextSize=12})
        local page=make("ScrollingFrame",{Name=name,Visible=false,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=UI.accent,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0)},content)
        make("UIListLayout",{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder},page)
        make("UIPadding",{PaddingTop=UDim.new(0,3),PaddingBottom=UDim.new(0,10),PaddingRight=UDim.new(0,9)},page)
        local tab={page=page}
        function win:Select(t)
            for _,entry in ipairs(self.tabs) do
                local active=entry==t
                entry.page.Visible=active
                entry.navbtn.BackgroundTransparency=active and 0 or 1
                entry.navbtn.BackgroundColor3=active and Color3.fromRGB(25,48,62) or C.panel
                entry.navbtn.TextColor3=active and UI.accent or C.muted
            end
            UI.activeTitle=t.name
            if not minimized then title.Text=t.name end
            self.selected=t
        end
        tab.name=name;tab.navbtn=navbtn
        table.insert(self.tabs,tab)
        navbtn.MouseButton1Click:Connect(function() win:Select(tab) end)
        if #self.tabs==1 then self:Select(tab) end
        local function card(height)
            local f=round(make("Frame",{Size=UDim2.new(1,-4,0,height or 51),BackgroundColor3=C.card,BackgroundTransparency=0.40,BorderSizePixel=0},page),9)
            stroke(f,C.border,0.7)
            return f
        end
        function tab:CreateSection(name)
            local f=make("Frame",{Size=UDim2.new(1,-4,0,32),BackgroundTransparency=1},page)
            label(f,string.upper(name),10,UI.accent,{Position=UDim2.fromOffset(2,10),Size=UDim2.new(1,-5,0,18),Font=Enum.Font.GothamBold})
        end
        function tab:CreateParagraph(o)
            local f=card(65)
            label(f,o.Title or "",13,C.white,{Position=UDim2.fromOffset(14,9),Size=UDim2.new(1,-28,0,19),Font=Enum.Font.GothamBold})
            label(f,o.Content or "",11,C.muted,{Position=UDim2.fromOffset(14,30),Size=UDim2.new(1,-28,0,30),TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
        end
        function tab:CreateToggle(o)
            local f=card(49)
            label(f,o.Name,12,C.white,{Position=UDim2.fromOffset(14,13),Size=UDim2.new(1,-94,0,22)})
            local track=round(make("Frame",{Size=UDim2.fromOffset(42,23),Position=UDim2.new(1,-57,0,13),BackgroundColor3=C.border},f),12)
            local knob=round(make("Frame",{Size=UDim2.fromOffset(17,17),Position=UDim2.fromOffset(3,3),BackgroundColor3=C.white},track),10)
            local hit=button(f,"",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
            local state=false
            local function set(v)
                state=not not v
                track.BackgroundColor3=state and UI.accent or C.border
                knob.Position=state and UDim2.fromOffset(22,3) or UDim2.fromOffset(3,3)
                if o.Callback then o.Callback(state) end
            end
            hit.MouseButton1Click:Connect(function() set(not state) end)
            set(o.CurrentValue)
            local ctl={Set=function(_,v) set(v) end}
            if o.Flag then Rayfield.Flags[o.Flag]=ctl end
            return ctl
        end
        function tab:CreateButton(o)
            local f=card(47)
            local b=button(f,o.Name,{Position=UDim2.fromOffset(7,6),Size=UDim2.new(1,-14,1,-12),BackgroundColor3=Color3.fromRGB(32,53,68),BackgroundTransparency=0.42,TextColor3=UI.accent})
            b.MouseButton1Click:Connect(function() if o.Callback then o.Callback() end end)
            return b
        end
        function tab:CreateSlider(o)
            local f=card(69)
            label(f,o.Name,12,C.white,{Position=UDim2.fromOffset(14,8),Size=UDim2.new(1,-98,0,20)})
            local value=label(f,"",12,UI.accent,{Position=UDim2.new(1,-90,0,8),Size=UDim2.fromOffset(76,20),TextXAlignment=Enum.TextXAlignment.Right,Font=Enum.Font.GothamBold})
            local rail=round(make("Frame",{Position=UDim2.new(0,14,0,45),Size=UDim2.new(1,-28,0,6),BackgroundColor3=C.border},f),3)
            local fill=round(make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=UI.accent},rail),3)
            local hit=button(f,"",{Position=UDim2.new(0,9,0,32),Size=UDim2.new(1,-18,0,30),BackgroundTransparency=1})
            local lo,hi=o.Range[1],o.Range[2]
            local step=o.Increment or 1
            local function set(v)
                v=math.clamp(tonumber(v) or lo,lo,hi)
                v=math.floor((v-lo)/step+0.5)*step+lo
                v=math.clamp(v,lo,hi)
                v=tonumber(string.format("%.4f",v))
                value.Text=tostring(v)
                fill.Size=UDim2.fromScale((v-lo)/(hi-lo),1)
                if o.Callback then o.Callback(v) end
            end
            local sliding=false
            local function update(x)
                set(lo+math.clamp((x-rail.AbsolutePosition.X)/math.max(rail.AbsoluteSize.X,1),0,1)*(hi-lo))
            end
            hit.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true update(i.Position.X) end
            end)
            table.insert(UI.connections,input.InputChanged:Connect(function(i)
                if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end
            end))
            table.insert(UI.connections,input.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
            end))
            set(o.CurrentValue)
            local ctl={Set=function(_,v) set(v) end}
            if o.Flag then Rayfield.Flags[o.Flag]=ctl end
            return ctl
        end
        function tab:CreateDropdown(o)
            local f=card(55)
            label(f,o.Name,12,C.white,{Position=UDim2.fromOffset(14,16),Size=UDim2.new(0.48,0,0,20)})
            local b=button(f,"",{Position=UDim2.new(0.49,0,0,10),Size=UDim2.new(0.49,0,0,34),TextColor3=UI.accent,TextSize=11})
            local options=o.Options or {}
            local selected
            local ctl={}
            local function set(v)
                selected=type(v)=="table" and v[1] or v
                b.Text=tostring(selected or "Select").."  v"
                if o.Callback then o.Callback({selected}) end
            end
            local expanded=false
            local extra={}
            local function clear()
                for _,obj in ipairs(extra) do obj:Destroy() end
                table.clear(extra)
                f.Size=UDim2.new(1,-4,0,55)
                expanded=false
            end
            local function toggle()
                if expanded then clear() return end
                expanded=true
                local count=math.min(#options,18)
                f.Size=UDim2.new(1,-4,0,55+count*29)
                for i=1,count do
                    local v=options[i]
                    local opt=button(f,tostring(v),{Position=UDim2.fromOffset(14,52+(i-1)*29),Size=UDim2.new(1,-28,0,26),TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.white,TextSize=11})
                    table.insert(extra,opt)
                    opt.MouseButton1Click:Connect(function() set(v) clear() end)
                end
            end
            b.MouseButton1Click:Connect(toggle)
            function ctl:Set(v) set(v) end
            function ctl:Refresh(values)
                clear()
                options=values or {}
            end
            set(o.CurrentOption)
            if o.Flag then Rayfield.Flags[o.Flag]=ctl end
            return ctl
        end
        function tab:CreateInput(o)
            local f=card(68)
            label(f,o.Name,11,C.muted,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,-28,0,18)})
            local field=round(make("TextBox",{Position=UDim2.fromOffset(12,28),Size=UDim2.new(1,-24,0,30),BackgroundColor3=C.panel,TextColor3=C.white,PlaceholderColor3=C.muted,PlaceholderText=o.PlaceholderText or "",Text="",TextSize=12,Font=Enum.Font.Gotham,ClearTextOnFocus=false,BorderSizePixel=0},f),7)
            field.FocusLost:Connect(function() if o.Callback then o.Callback(field.Text) end end)
            return {Set=function(_,v) field.Text=tostring(v) end}
        end
        function tab:CreateColorPicker(o)
            local f=card(51)
            label(f,o.Name,12,C.white,{Position=UDim2.fromOffset(14,13),Size=UDim2.new(1,-100,0,22)})
            local swatch=button(f,"",{Position=UDim2.new(1,-53,0,11),Size=UDim2.fromOffset(34,25),BackgroundTransparency=0,BackgroundColor3=o.Color or UI.accent})
            local wheelSize=156
            local wheel=make("Frame",{Position=UDim2.new(0.5,-wheelSize/2,0,54),Size=UDim2.fromOffset(wheelSize,wheelSize),BackgroundTransparency=1,Visible=false},f)
            -- 72 hue slices form a clickable wheel; no RGB fields or brightness slider.
            for i=0,71 do
                local angle=i*5
                local radians=math.rad(angle-90)
                local x=wheelSize/2+math.cos(radians)*57
                local y=wheelSize/2+math.sin(radians)*57
                local segment=make("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(14,17),Rotation=angle,BackgroundColor3=Color3.fromHSV(i/72,1,1),BorderSizePixel=0},wheel)
                round(segment,5)
            end
            local center=round(make("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(67,67),BackgroundColor3=C.panel,BackgroundTransparency=0.06,BorderSizePixel=0},wheel),34)
            local preview=round(make("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(39,39),BackgroundColor3=o.Color or UI.accent,BorderSizePixel=0},center),20)
            local hit=button(wheel,"",{Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,TextTransparency=1,ZIndex=5})
            local expanded=false
            local function set(c)
                if typeof(c)~="Color3" then return end
                swatch.BackgroundColor3=c
                preview.BackgroundColor3=c
                if o.Callback then o.Callback(c) end
            end
            local function choose(pos)
                local centerPos=wheel.AbsolutePosition+wheel.AbsoluteSize/2
                local delta=pos-centerPos
                local radius=delta.Magnitude
                if radius<35 or radius>85 then return end
                local hue=(math.atan2(delta.Y,delta.X)+math.pi/2)/(2*math.pi)
                set(Color3.fromHSV(hue%1,1,1))
            end
            local selecting=false
            hit.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    selecting=true
                    choose(Vector2.new(i.Position.X,i.Position.Y))
                end
            end)
            hit.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then selecting=false end
            end)
            table.insert(UI.connections,input.InputChanged:Connect(function(i)
                if expanded and selecting and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    choose(Vector2.new(i.Position.X,i.Position.Y))
                end
            end))
            swatch.MouseButton1Click:Connect(function()
                expanded=not expanded
                wheel.Visible=expanded
                f.Size=UDim2.new(1,-4,0,expanded and 222 or 51)
            end)
            set(o.Color)
            local ctl={Set=function(_,v) set(v) end}
            if o.Flag then Rayfield.Flags[o.Flag]=ctl end
            return ctl
        end
        return tab
    end
    return win
end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

-- ======================== SETTINGS ========================
local S = {
    -- Aimbot
    Aimbot          = false,
    SilentAim       = false,
    AlwaysOn        = false,
    AimKey          = Enum.UserInputType.MouseButton2,
    FOV             = 145,
    Smoothness      = 0.10,
    AimPart         = "Head",
    TeamCheck       = true,
    WallCheck       = true,
    Prediction      = true,
    PredMult        = 0.09,
    Sticky          = true,
    ShowFOV         = true,
    FOVColor        = Color3.fromRGB(0, 220, 255),
    AimMethod       = "Camera",

    -- Triggerbot
    Triggerbot      = false,
    TriggerDelay    = 0.03,
    TriggerFOV      = 32,
    TriggerChance   = 100,

    -- Combat
    KnifeAura       = false,
    KnifeRange      = 14,
    KnifeDelay      = 0.11,
    HitboxExpand    = false,
    HitboxSize      = 5.5,
    NoRecoil        = true,
    NoSpread        = true,
    RapidFire       = false,

    -- ESP
    ESP             = true,
    Box             = true,
    BoxStyle        = "Full",
    Tracer          = true,
    TracerOrigin    = "Bottom",
    Name            = true,
    Distance        = true,
    HealthBar       = true,
    HealthText      = true,
    Skeleton        = true,
    Chams           = false,
    ESPTeamCheck    = true,
    MaxDist         = 2500,
    BoxColor        = Color3.fromRGB(0, 220, 255),
    BoxFill         = false,
    TracerColor     = Color3.fromRGB(0, 200, 255),
    NameColor       = Color3.fromRGB(255, 255, 255),
    SkelColor       = Color3.fromRGB(0, 230, 255),
    ChamsColor      = Color3.fromRGB(0, 180, 255),
    VisibleColor    = Color3.fromRGB(80, 255, 140),
    HiddenColor     = Color3.fromRGB(255, 70, 90),

    -- Bullet tracers
    BulletTracer    = true,
    BulletColor     = Color3.fromRGB(0, 255, 220),
    BulletThick     = 2,
    BulletLife      = 1.2,
    BulletMaxDist   = 1500,

    -- Feedback
    HitMarker       = true,
    KillFlash       = true,

    -- Movement
    Speed           = false,
    WalkSpeed       = 28,
    InfJump         = false,
    Noclip          = false,
    Fly             = false,
    FlySpeed        = 48,

    -- World
    FullBright      = false,
    NoFog           = false,
    FPSBoost        = false,

    -- System
    AutoReattach    = true,
}

-- ======================== STATE ========================
local HoldingAim     = false
local HoldingFire    = false
local currentTarget  = nil
local lastTrigger    = 0
local lastKnife      = 0
local espCache       = {}
local bulletLines    = {}
local lastShotTime   = 0
local chamsCache     = {}
local originalSizes  = {}
local flyBV, flyBG

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible      = false
FOVCircle.Thickness    = 1.4
FOVCircle.Filled       = false
FOVCircle.NumSides     = 72
FOVCircle.Transparency = 0.85
FOVCircle.Color        = S.FOVColor
FOVCircle.Radius       = S.FOV

-- Hit marker
local HitX1 = Drawing.new("Line")
local HitX2 = Drawing.new("Line")
for _, h in ipairs({HitX1, HitX2}) do
    h.Thickness = 2.2
    h.Color = Color3.fromRGB(255, 255, 255)
    h.Visible = false
    h.Transparency = 1
end

-- ======================== HELPERS ========================
local function getChar()
    return LocalPlayer.Character
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function isAlive(plr)
    local c = plr.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function isEnemy(plr)
    if plr == LocalPlayer then return false end
    if not isAlive(plr) then return false end
    if S.TeamCheck or S.ESPTeamCheck then
        if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then
            return false
        end
    end
    return true
end

local function hasLineOfSight(fromPos, toPart)
    if not S.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, toPart.Parent}
    params.IgnoreWater = true
    local result = Workspace:Raycast(fromPos, (toPart.Position - fromPos), params)
    return result == nil or result.Instance:IsDescendantOf(toPart.Parent)
end

local function getPredictedPos(part)
    if not S.Prediction or not part then return part.Position end
    local vel = part.AssemblyLinearVelocity or Vector3.zero
    return part.Position + vel * S.PredMult
end

local function getClosestTarget(maxFOV)
    local closest, closestDist = nil, maxFOV or S.FOV
    local mousePos = UserInputService:GetMouseLocation()

    -- sticky
    if S.Sticky and currentTarget then
        local part = currentTarget
        local char = part and part.Parent
        local plr = char and Players:GetPlayerFromCharacter(char)
        if plr and isEnemy(plr) then
            local pos = getPredictedPos(part)
            local screen, onScreen = Camera:WorldToViewportPoint(pos)
            if onScreen then
                local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                if dist < (maxFOV or S.FOV) * 1.35 and hasLineOfSight(Camera.CFrame.Position, part) then
                    return part
                end
            end
        end
        currentTarget = nil
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local char = plr.Character
            local part = char and (char:FindFirstChild(S.AimPart) or char:FindFirstChild("HumanoidRootPart"))
            if part then
                local pos = getPredictedPos(part)
                local screen, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen then
                    local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                    if dist < closestDist and hasLineOfSight(Camera.CFrame.Position, part) then
                        closestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    currentTarget = closest
    return closest
end

local function getClosestInRange(range)
    local closest, closestDist = nil, range
    local hrp = getHRP()
    if not hrp then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local char = plr.Character
            local targetHRP = char and char:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local dist = (targetHRP.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = char
                end
            end
        end
    end
    return closest
end

local function worldToScreen(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), on, v.Z
end

-- ======================== APPEARANCE ========================
-- Separate from gameplay presets so changing themes never resets a config.
local appearancePath = "EliteMurderDuels/ui_theme.txt"
local availableThemes = {
    "DarkBlue", "Default", "AmberGlow", "Amethyst",
    "Bloom", "Green", "Light", "Ocean", "Serenity"
}
local currentTheme = "DarkBlue"

local function themeAllowed(name)
    for _, candidate in ipairs(availableThemes) do
        if candidate == name then return true end
    end
    return false
end

pcall(function()
    if type(isfile) == "function" and isfile(appearancePath)
        and type(readfile) == "function" then
        local stored = readfile(appearancePath)
        if themeAllowed(stored) then currentTheme = stored end
    end
end)

local function saveAppearanceTheme(name)
    if not themeAllowed(name) then return false, "Unknown theme" end
    if type(writefile) ~= "function" then
        return false, "Executor does not support saving files"
    end
    local ok, err = pcall(function()
        if type(makefolder) == "function"
            and type(isfolder) == "function"
            and not isfolder("EliteMurderDuels") then
            makefolder("EliteMurderDuels")
        end
        writefile(appearancePath, name)
    end)
    if ok then currentTheme = name end
    return ok, err
end

-- ======================== UI ========================
applyTheme(currentTheme)
local Window = Rayfield:CreateWindow({
    Name            = "OPTICALZ MD  |  CONTROL CENTER",
    LoadingTitle    = "OPTICALZ MD",
    LoadingSubtitle = "Loading your workspace",
    Theme           = currentTheme,
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "EliteMurderDuels",
        FileName   = "Config"
    },
    Discord  = { Enabled = false },
    KeySystem = false
})

local AimTab      = Window:CreateTab("Aim", 4483362458)
local CombatTab   = Window:CreateTab("Combat", 4483362458)
local ESPTab      = Window:CreateTab("Visuals", 4483362458)
local MoveTab     = Window:CreateTab("Movement", 4483362458)
local WorldTab    = Window:CreateTab("World", 4483362458)
local CustomTab   = Window:CreateTab("Appearance", 4483362458)
local MiscTab     = Window:CreateTab("System", 4483362458)
local InfoTab     = Window:CreateTab("About", 4483362458)
local ConfigTab   = Window:CreateTab("Config", 4483362458)

-- ---------- AIMBOT ----------
AimTab:CreateSection("Targeting")

AimTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = S.Aimbot,
    Flag = "Aimbot",
    Callback = function(v) S.Aimbot = v end
})

AimTab:CreateToggle({
    Name = "Silent Aim (Soft)",
    CurrentValue = S.SilentAim,
    Flag = "SilentAim",
    Callback = function(v) S.SilentAim = v end
})

AimTab:CreateToggle({
    Name = "Always On (no key)",
    CurrentValue = S.AlwaysOn,
    Flag = "AlwaysOn",
    Callback = function(v) S.AlwaysOn = v end
})

AimTab:CreateToggle({
    Name = "Sticky Target",
    CurrentValue = S.Sticky,
    Flag = "Sticky",
    Callback = function(v) S.Sticky = v end
})

AimTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = S.TeamCheck,
    Flag = "TeamCheck",
    Callback = function(v) S.TeamCheck = v end
})

AimTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = S.WallCheck,
    Flag = "WallCheck",
    Callback = function(v) S.WallCheck = v end
})

AimTab:CreateToggle({
    Name = "Prediction",
    CurrentValue = S.Prediction,
    Flag = "Prediction",
    Callback = function(v) S.Prediction = v end
})

AimTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = S.ShowFOV,
    Flag = "ShowFOV",
    Callback = function(v)
        S.ShowFOV = v
        FOVCircle.Visible = v and (S.Aimbot or S.SilentAim)
    end
})

AimTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    CurrentOption = {S.AimPart},
    Flag = "AimPart",
    Callback = function(opt)
        S.AimPart = type(opt) == "table" and opt[1] or opt
    end
})

AimTab:CreateDropdown({
    Name = "Aim Method",
    Options = {"Camera", "Mouse"},
    CurrentOption = {S.AimMethod},
    Flag = "AimMethod",
    Callback = function(opt)
        S.AimMethod = type(opt) == "table" and opt[1] or opt
    end
})

AimTab:CreateSlider({
    Name = "FOV Radius",
    Range = {40, 400},
    Increment = 5,
    CurrentValue = S.FOV,
    Flag = "FOV",
    Callback = function(v)
        S.FOV = v
        FOVCircle.Radius = v
    end
})

AimTab:CreateSlider({
    Name = "Smoothness (lower = smoother)",
    Range = {0.02, 0.35},
    Increment = 0.01,
    CurrentValue = S.Smoothness,
    Flag = "Smoothness",
    Callback = function(v) S.Smoothness = v end
})

AimTab:CreateSlider({
    Name = "Prediction Multiplier",
    Range = {0.02, 0.25},
    Increment = 0.01,
    CurrentValue = S.PredMult,
    Flag = "PredMult",
    Callback = function(v) S.PredMult = v end
})

AimTab:CreateSection("Triggerbot")

AimTab:CreateToggle({
    Name = "Triggerbot",
    CurrentValue = S.Triggerbot,
    Flag = "Triggerbot",
    Callback = function(v) S.Triggerbot = v end
})

AimTab:CreateSlider({
    Name = "Trigger Delay (s)",
    Range = {0, 0.15},
    Increment = 0.005,
    CurrentValue = S.TriggerDelay,
    Flag = "TriggerDelay",
    Callback = function(v) S.TriggerDelay = v end
})

AimTab:CreateSlider({
    Name = "Trigger FOV",
    Range = {10, 80},
    Increment = 1,
    CurrentValue = S.TriggerFOV,
    Flag = "TriggerFOV",
    Callback = function(v) S.TriggerFOV = v end
})

AimTab:CreateSlider({
    Name = "Trigger Chance %",
    Range = {10, 100},
    Increment = 5,
    CurrentValue = S.TriggerChance,
    Flag = "TriggerChance",
    Callback = function(v) S.TriggerChance = v end
})

-- ---------- COMBAT ----------
CombatTab:CreateSection("Melee")

CombatTab:CreateToggle({
    Name = "Knife Aura",
    CurrentValue = S.KnifeAura,
    Flag = "KnifeAura",
    Callback = function(v) S.KnifeAura = v end
})

CombatTab:CreateSlider({
    Name = "Aura Range",
    Range = {6, 25},
    Increment = 0.5,
    CurrentValue = S.KnifeRange,
    Flag = "KnifeRange",
    Callback = function(v) S.KnifeRange = v end
})

CombatTab:CreateSlider({
    Name = "Aura Delay",
    Range = {0.05, 0.3},
    Increment = 0.01,
    CurrentValue = S.KnifeDelay,
    Flag = "KnifeDelay",
    Callback = function(v) S.KnifeDelay = v end
})

CombatTab:CreateSection("Hitbox & Weapon")

CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = S.HitboxExpand,
    Flag = "HitboxExpand",
    Callback = function(v) S.HitboxExpand = v end
})

CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 12},
    Increment = 0.5,
    CurrentValue = S.HitboxSize,
    Flag = "HitboxSize",
    Callback = function(v) S.HitboxSize = v end
})

CombatTab:CreateToggle({
    Name = "No Recoil",
    CurrentValue = S.NoRecoil,
    Flag = "NoRecoil",
    Callback = function(v) S.NoRecoil = v end
})

CombatTab:CreateToggle({
    Name = "No Spread",
    CurrentValue = S.NoSpread,
    Flag = "NoSpread",
    Callback = function(v) S.NoSpread = v end
})

CombatTab:CreateToggle({
    Name = "Rapid Fire Assist",
    CurrentValue = S.RapidFire,
    Flag = "RapidFire",
    Callback = function(v) S.RapidFire = v end
})

-- ---------- ESP ----------
ESPTab:CreateSection("Overview")

ESPTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = S.ESP,
    Flag = "ESP",
    Callback = function(v) S.ESP = v end
})

ESPTab:CreateToggle({
    Name = "Team Check (ESP)",
    CurrentValue = S.ESPTeamCheck,
    Flag = "ESPTeamCheck",
    Callback = function(v) S.ESPTeamCheck = v end
})

ESPTab:CreateSection("Elements")

ESPTab:CreateToggle({
    Name = "Box",
    CurrentValue = S.Box,
    Flag = "Box",
    Callback = function(v) S.Box = v end
})

ESPTab:CreateDropdown({
    Name = "Box Style",
    Options = {"Full", "Corner"},
    CurrentOption = {S.BoxStyle},
    Flag = "BoxStyle",
    Callback = function(opt)
        S.BoxStyle = type(opt) == "table" and opt[1] or opt
    end
})



ESPTab:CreateToggle({
    Name = "Name",
    CurrentValue = S.Name,
    Flag = "Name",
    Callback = function(v) S.Name = v end
})

ESPTab:CreateToggle({
    Name = "Distance",
    CurrentValue = S.Distance,
    Flag = "Distance",
    Callback = function(v) S.Distance = v end
})

ESPTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = S.HealthBar,
    Flag = "HealthBar",
    Callback = function(v) S.HealthBar = v end
})

ESPTab:CreateToggle({
    Name = "Health Text",
    CurrentValue = S.HealthText,
    Flag = "HealthText",
    Callback = function(v) S.HealthText = v end
})

ESPTab:CreateToggle({
    Name = "Skeleton",
    CurrentValue = S.Skeleton,
    Flag = "Skeleton",
    Callback = function(v) S.Skeleton = v end
})

ESPTab:CreateToggle({
    Name = "Chams",
    CurrentValue = S.Chams,
    Flag = "Chams",
    Callback = function(v) S.Chams = v end
})

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {200, 5000},
    Increment = 50,
    CurrentValue = S.MaxDist,
    Flag = "MaxDist",
    Callback = function(v) S.MaxDist = v end
})

ESPTab:CreateSection("Colors")




-- ---------- MOVEMENT ----------
MoveTab:CreateSection("Speed & Jump")

MoveTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = S.Speed,
    Flag = "Speed",
    Callback = function(v) S.Speed = v end
})

MoveTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 80},
    Increment = 1,
    CurrentValue = S.WalkSpeed,
    Flag = "WalkSpeed",
    Callback = function(v) S.WalkSpeed = v end
})

MoveTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = S.InfJump,
    Flag = "InfJump",
    Callback = function(v) S.InfJump = v end
})

MoveTab:CreateSection("Fly / Noclip")

MoveTab:CreateToggle({
    Name = "Fly",
    CurrentValue = S.Fly,
    Flag = "Fly",
    Callback = function(v)
        S.Fly = v
        if not v then
            if flyBV then flyBV:Destroy() flyBV = nil end
            if flyBG then flyBG:Destroy() flyBG = nil end
        end
    end
})

MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 120},
    Increment = 2,
    CurrentValue = S.FlySpeed,
    Flag = "FlySpeed",
    Callback = function(v) S.FlySpeed = v end
})

MoveTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = S.Noclip,
    Flag = "Noclip",
    Callback = function(v) S.Noclip = v end
})

-- ---------- WORLD ----------
WorldTab:CreateSection("Visuals")

WorldTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = S.FullBright,
    Flag = "FullBright",
    Callback = function(v)
        S.FullBright = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})

WorldTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = S.NoFog,
    Flag = "NoFog",
    Callback = function(v)
        S.NoFog = v
        if v then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end
    end
})

WorldTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = S.FPSBoost,
    Flag = "FPSBoost",
    Callback = function(v)
        S.FPSBoost = v
        if v then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                    obj.Enabled = false
                end
            end
        end
    end
})

WorldTab:CreateSection("Bullet Tracers")



WorldTab:CreateSection("Hit Feedback")

WorldTab:CreateToggle({
    Name = "Hit Marker",
    CurrentValue = S.HitMarker,
    Flag = "HitMarker",
    Callback = function(v) S.HitMarker = v end
})

WorldTab:CreateToggle({
    Name = "Kill Flash",
    CurrentValue = S.KillFlash,
    Flag = "KillFlash",
    Callback = function(v) S.KillFlash = v end
})

-- ---------- MISC ----------
MiscTab:CreateSection("Utilities")


MiscTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        for _, cache in pairs(espCache) do
            for _, d in pairs(cache) do
                if typeof(d) == "Instance" and d.Destroy then
                    pcall(function() d:Destroy() end)
                elseif type(d) == "table" then
                    for _, line in pairs(d) do
                        if line and line.Remove then pcall(function() line:Remove() end) end
                    end
                elseif d and d.Remove then
                    pcall(function() d:Remove() end)
                end
            end
        end
        FOVCircle:Remove()
        HitX1:Remove()
        HitX2:Remove()
        Rayfield:Destroy()
    end
})

-- ---------- UI APPEARANCE ----------
CustomTab:CreateSection("Theme & layout")
CustomTab:CreateParagraph({
    Title = "Personalize your workspace",
    Content = "Choose a theme to preview it instantly. Your saved presets and gameplay settings stay separate."
})
CustomTab:CreateDropdown({
    Name = "Interface theme",
    Options = availableThemes,
    CurrentOption = {currentTheme},
    MultipleOptions = false,
    Flag = "OpticalzInterfaceTheme",
    Callback = function(option)
        local name = type(option) == "table" and option[1] or option
        if not themeAllowed(name) then return end
        applyTheme(name)
        local ok, err = saveAppearanceTheme(name)
        if ok then
            Rayfield:Notify({
                Title = "OPTICALZ MD",
                Content = "Theme applied: " .. name,
                Duration = 5
            })
        else
            Rayfield:Notify({
                Title = "OPTICALZ MD",
                Content = "Theme could not be saved: " .. tostring(err),
                Duration = 5
            })
        end
    end
})
CustomTab:CreateButton({
    Name = "Reset interface theme",
    Callback = function()
        applyTheme("DarkBlue")
        local ok = saveAppearanceTheme("DarkBlue")
        Rayfield:Notify({
            Title = "OPTICALZ MD",
            Content = ok and "Default theme applied."
                or "Unable to save theme on this executor.",
            Duration = 4
        })
    end
})

-- ---------- CUSTOMIZE UI COLORS ----------
CustomTab:CreateSection("ESP Colors")

CustomTab:CreateColorPicker({
    Name = "Box Color",
    Color = S.BoxColor,
    Flag = "C_BoxColor",
    Callback = function(c) S.BoxColor = c end
})

CustomTab:CreateColorPicker({
    Name = "Tracer Color",
    Color = S.TracerColor,
    Flag = "C_TracerColor",
    Callback = function(c) S.TracerColor = c end
})

CustomTab:CreateColorPicker({
    Name = "Name Color",
    Color = S.NameColor,
    Flag = "C_NameColor",
    Callback = function(c) S.NameColor = c end
})

CustomTab:CreateColorPicker({
    Name = "Skeleton Color",
    Color = S.SkelColor,
    Flag = "C_SkelColor",
    Callback = function(c) S.SkelColor = c end
})

CustomTab:CreateColorPicker({
    Name = "Chams Color",
    Color = S.ChamsColor,
    Flag = "C_ChamsColor",
    Callback = function(c) S.ChamsColor = c end
})

-- Aim / Feedback color editors intentionally removed





CustomTab:CreateSection("FOV CIRCLE COLOR")

CustomTab:CreateButton({
    Name = "Cyan",
    Callback = function()
        S.FOVColor = Color3.fromRGB(0, 220, 255)
        FOVCircle.Color = S.FOVColor
        Rayfield:Notify({Title = "OPTICALZ MD", Content = "Cyan FOV color applied", Duration = 2})
    end
})

CustomTab:CreateButton({
    Name = "Red",
    Callback = function()
        S.FOVColor = Color3.fromRGB(255, 55, 70)
        FOVCircle.Color = S.FOVColor
        Rayfield:Notify({Title = "OPTICALZ MD", Content = "Red FOV color applied", Duration = 2})
    end
})

CustomTab:CreateButton({
    Name = "Purple",
    Callback = function()
        S.FOVColor = Color3.fromRGB(180, 80, 255)
        FOVCircle.Color = S.FOVColor
        Rayfield:Notify({Title = "OPTICALZ MD", Content = "Purple FOV color applied", Duration = 2})
    end
})

CustomTab:CreateButton({
    Name = "Green",
    Callback = function()
        S.FOVColor = Color3.fromRGB(50, 255, 120)
        FOVCircle.Color = S.FOVColor
        Rayfield:Notify({Title = "OPTICALZ MD", Content = "Green FOV color applied", Duration = 2})
    end
})

-- ---------- NAMED CONFIGS ----------
-- Stores only the settings table, not executable code.
local configFolder = "EliteMurderDuels/NamedConfigs"
local configName = "default"
local configDropdown
local selectedConfig = "default"
local autoloadPath = "EliteMurderDuels/autoload.txt"
local autoloadName = nil

local function configNotify(message)
    Rayfield:Notify({Title = "Configs", Content = message, Duration = 3})
end

local function configSupported()
    return type(writefile) == "function" and type(readfile) == "function"
        and type(isfile) == "function" and type(makefolder) == "function"
        and type(isfolder) == "function"
end

local function ensureConfigFolder()
    if not configSupported() then return false end
    if not isfolder("EliteMurderDuels") then makefolder("EliteMurderDuels") end
    if not isfolder(configFolder) then makefolder(configFolder) end
    return true
end

local function cleanConfigName(name)
    name = tostring(name or ""):match("^%s*(.-)%s*$")
    if #name == 0 or #name > 48 or name:find("[^%w%s_%-]") then
        return nil
    end
    return name
end

local function configPath(name)
    return configFolder .. "/" .. name .. ".json"
end

local function packSetting(value)
    if typeof(value) == "Color3" then
        return {__kind = "Color3", r = value.R, g = value.G, b = value.B}
    elseif typeof(value) == "EnumItem" then
        return {__kind = "EnumItem", enum = tostring(value.EnumType), name = value.Name}
    elseif type(value) == "boolean" or type(value) == "number" or type(value) == "string" then
        return value
    end
    return nil
end

local function unpackSetting(value)
    if type(value) == "table" and value.__kind == "Color3" then
        return Color3.new(value.r, value.g, value.b)
    elseif type(value) == "table" and value.__kind == "EnumItem" then
        local enumName = tostring(value.enum):match("^Enum%.(.+)$")
        if enumName and Enum[enumName] then return Enum[enumName][value.name] end
        return nil
    end
    return value
end

local function getConfigNames()
    local names = {}
    if ensureConfigFolder() and type(listfiles) == "function" then
        local ok, files = pcall(listfiles, configFolder)
        if ok and type(files) == "table" then
            for _, path in ipairs(files) do
                local name = tostring(path):gsub("\\", "/"):match("/([^/]+)%.json$")
                if name then table.insert(names, name) end
            end
        end
    end
    table.sort(names)
    return names
end

local function refreshConfigs()
    local names = getConfigNames()
    if #names == 0 then names = {"(no saved configs)"} end
    if configDropdown then
        pcall(function() configDropdown:Refresh(names, true) end)
    end
end

ConfigTab:CreateSection("Named presets")
ConfigTab:CreateParagraph({
    Title = "Settings only",
    Content = "Save multiple named presets and load them later. Saves toggles, sliders, dropdowns, colors and other settings."
})

ConfigTab:CreateInput({
    Name = "Config name",
    PlaceholderText = "e.g. legit, rage, esp only",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        configName = tostring(text or "")
    end
})

configDropdown = ConfigTab:CreateDropdown({
    Name = "Saved configs",
    Options = (function()
        local names = getConfigNames()
        return #names > 0 and names or {"(no saved configs)"}
    end)(),
    CurrentOption = {"(no saved configs)"},
    MultipleOptions = false,
    Callback = function(value)
        local name = type(value) == "table" and value[1] or value
        if name and name ~= "(no saved configs)" then
            selectedConfig = name
            configName = name
        end
    end
})

ConfigTab:CreateButton({
    Name = "Save config",
    Callback = function()
        local name = cleanConfigName(configName)
        if not name then configNotify("Use 1-48 letters, numbers, spaces, _ or -") return end
        local ok, err = pcall(function()
            assert(ensureConfigFolder(), "Executor file functions unavailable")
            local values = {}
            for key, value in pairs(S) do
                values[key] = packSetting(value)
            end
            writefile(configPath(name), HttpService:JSONEncode({version = 1, settings = values}))
        end)
        if ok then
            selectedConfig = name
            refreshConfigs()
            configNotify("Saved: " .. name)
        else configNotify("Save failed: " .. tostring(err)) end
    end
})

local function loadNamedConfig(name)
    assert(ensureConfigFolder(), "Executor file functions unavailable")
    assert(isfile(configPath(name)), "Config not found")
    local data = HttpService:JSONDecode(readfile(configPath(name)))
    assert(type(data) == "table" and type(data.settings) == "table", "Invalid config")
            for key, saved in pairs(data.settings) do
                if S[key] ~= nil then
                    local value = unpackSetting(saved)
                    if value ~= nil and typeof(value) == typeof(S[key]) then
                        S[key] = value
                        local flags = {key}
                        if key == "BoxColor" or key == "TracerColor" or key == "NameColor" then
                            table.insert(flags, "C_" .. key)
                        elseif key == "SkelColor" or key == "ChamsColor" or key == "FOVColor"
                            or key == "BulletColor" or key == "VisibleColor" or key == "HiddenColor" then
                            table.insert(flags, "C_" .. key)
                        end
                        for _, flag in ipairs(flags) do
                            pcall(function()
                                if Rayfield.Flags and Rayfield.Flags[flag] then
                                    Rayfield.Flags[flag]:Set((key == "AimPart" or key == "AimMethod" or key == "BoxStyle" or key == "TracerOrigin") and {value} or value)
                                end
                            end)
                        end
                    end
                end
            end
            FOVCircle.Radius = S.FOV
            FOVCircle.Color = S.FOVColor
end

ConfigTab:CreateButton({
    Name = "Load config",
    Callback = function()
        local name = cleanConfigName(configName) or cleanConfigName(selectedConfig)
        if not name then configNotify("Enter or select a config") return end
        local ok, err = pcall(loadNamedConfig, name)
        if ok then configNotify("Loaded: " .. name)
        else configNotify("Load failed: " .. tostring(err)) end
    end
})

ConfigTab:CreateSection("Auto-load")
ConfigTab:CreateParagraph({
    Title = "Startup preset",
    Content = "Select a saved preset, then click Set autoload. It will load automatically whenever this script starts."
})

ConfigTab:CreateButton({
    Name = "Set autoload to selected config",
    Callback = function()
        local name = cleanConfigName(configName) or cleanConfigName(selectedConfig)
        if not name then configNotify("Select a saved config first") return end
        local ok, err = pcall(function()
            assert(ensureConfigFolder(), "Executor file functions unavailable")
            assert(isfile(configPath(name)), "Save the config first")
            writefile(autoloadPath, name)
            autoloadName = name
        end)
        if ok then configNotify("Autoload set: " .. name)
        else configNotify("Autoload failed: " .. tostring(err)) end
    end
})

ConfigTab:CreateButton({
    Name = "Disable autoload",
    Callback = function()
        local ok, err = pcall(function()
            assert(ensureConfigFolder(), "Executor file functions unavailable")
            if isfile(autoloadPath) then
                assert(type(delfile) == "function", "Executor delete function unavailable")
                delfile(autoloadPath)
            end
            autoloadName = nil
        end)
        if ok then configNotify("Autoload disabled")
        else configNotify("Could not disable autoload: " .. tostring(err)) end
    end
})

-- Apply the chosen preset after all controls are created, so their UI values update too.
task.defer(function()
    local ok, err = pcall(function()
        if not ensureConfigFolder() or not isfile(autoloadPath) then return end
        local name = cleanConfigName(readfile(autoloadPath))
        if not name then error("Invalid autoload preset name") end
        loadNamedConfig(name)
        autoloadName = name
        selectedConfig = name
        configName = name
        configNotify("Autoloaded: " .. name)
    end)
    if not ok then configNotify("Autoload failed: " .. tostring(err)) end
end)

ConfigTab:CreateButton({
    Name = "Delete config",
    Callback = function()
        local name = cleanConfigName(configName) or cleanConfigName(selectedConfig)
        if not name then configNotify("Enter or select a config") return end
        local ok, err = pcall(function()
            assert(type(delfile) == "function", "Executor delete function unavailable")
            assert(ensureConfigFolder() and isfile(configPath(name)), "Config not found")
            delfile(configPath(name))
        end)
        if ok then
            refreshConfigs()
            configNotify("Deleted: " .. name)
        else configNotify("Delete failed: " .. tostring(err)) end
    end
})

ConfigTab:CreateButton({
    Name = "Refresh saved configs",
    Callback = function()
        refreshConfigs()
        configNotify("Config list refreshed")
    end
})

-- ---------- INFO ----------
InfoTab:CreateSection("About OPTICALZ MD")

InfoTab:CreateParagraph({
    Title = "Build",
    Content = "OPTICALZ MD | Control Center\nCustomizable themes • Named presets • Autoload"
})

InfoTab:CreateParagraph({
    Title = "Discord",
    Content = "https://discord.gg/JyHTa3M7h"
})

InfoTab:CreateParagraph({
    Title = "Credits",
    Content = "OPTICALZ MD"
})

-- ======================== ESP DRAW ========================
local function clearESP(plr)
    local cache = espCache[plr]
    if not cache then return end
    for k, v in pairs(cache) do
        if k == "skel" and type(v) == "table" then
            for _, line in pairs(v) do
                if line and line.Remove then pcall(function() line:Remove() end) end
            end
        elseif v and v.Remove then
            pcall(function() v:Remove() end)
        end
    end
    espCache[plr] = nil
end

local function ensureESP(plr)
    if espCache[plr] then return espCache[plr] end
    local cache = {
        box = Drawing.new("Square"),
        boxOutline = Drawing.new("Square"),
        tracer = Drawing.new("Line"),
        name = Drawing.new("Text"),
        dist = Drawing.new("Text"),
        healthBar = Drawing.new("Square"),
        healthBg = Drawing.new("Square"),
        healthTxt = Drawing.new("Text"),
        skel = {},
    }
    for i = 1, 14 do
        cache.skel[i] = Drawing.new("Line")
        cache.skel[i].Thickness = 1.4
        cache.skel[i].Color = S.SkelColor
        cache.skel[i].Visible = false
        cache.skel[i].Transparency = 0.9
    end

    cache.box.Filled = false
    cache.box.Thickness = 1.5
    cache.box.Color = S.BoxColor
    cache.box.Visible = false
    cache.boxOutline.Filled = false
    cache.boxOutline.Thickness = 3
    cache.boxOutline.Color = Color3.new(0,0,0)
    cache.boxOutline.Visible = false
    cache.tracer.Thickness = 1.3
    cache.tracer.Color = S.TracerColor
    cache.tracer.Visible = false
    cache.name.Size = 14
    cache.name.Center = true
    cache.name.Outline = true
    cache.name.Color = S.NameColor
    cache.name.Visible = false
    cache.dist.Size = 12
    cache.dist.Center = true
    cache.dist.Outline = true
    cache.dist.Color = Color3.fromRGB(200, 220, 255)
    cache.dist.Visible = false
    cache.healthBg.Filled = true
    cache.healthBg.Color = Color3.fromRGB(20,20,20)
    cache.healthBg.Visible = false
    cache.healthBar.Filled = true
    cache.healthBar.Visible = false
    cache.healthTxt.Size = 11
    cache.healthTxt.Center = true
    cache.healthTxt.Outline = true
    cache.healthTxt.Color = Color3.fromRGB(255,255,255)
    cache.healthTxt.Visible = false

    espCache[plr] = cache
    return cache
end

local function updateESP()
    if not S.ESP then
        for plr in pairs(espCache) do clearESP(plr) end
        return
    end

    local myHRP = getHRP()
    local viewport = Camera.ViewportSize
    local bottomCenter = Vector2.new(viewport.X / 2, viewport.Y)
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if not isEnemy(plr) then
            clearESP(plr)
            continue
        end

        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")
        if not (hrp and hum and head) then
            clearESP(plr)
            continue
        end

        local dist3d = myHRP and (hrp.Position - myHRP.Position).Magnitude or 9999
        if dist3d > S.MaxDist then
            clearESP(plr)
            continue
        end

        local cache = ensureESP(plr)
        local pos, onScreen, depth = worldToScreen(hrp.Position)
        local headPos = worldToScreen(head.Position + Vector3.new(0, 0.4, 0))
        local footPos = worldToScreen(hrp.Position - Vector3.new(0, 3, 0))

        if not onScreen or depth < 0 then
            for k, v in pairs(cache) do
                if k == "skel" then
                    for _, line in pairs(v) do line.Visible = false end
                elseif v and v.Visible ~= nil then
                    v.Visible = false
                end
            end
            continue
        end

        local height = math.abs(headPos.Y - footPos.Y)
        local width = height * 0.55
        local boxPos = Vector2.new(pos.X - width / 2, headPos.Y)
        local boxSize = Vector2.new(width, height)

        -- Box
        if S.Box then
            cache.box.Position = boxPos
            cache.box.Size = boxSize
            cache.box.Color = S.BoxColor
            cache.box.Visible = true
            cache.boxOutline.Position = boxPos
            cache.boxOutline.Size = boxSize
            cache.boxOutline.Visible = true
        else
            cache.box.Visible = false
            cache.boxOutline.Visible = false
        end

        -- Tracer
        if S.Tracer then
            local origin = bottomCenter
            if S.TracerOrigin == "Center" then origin = center
            elseif S.TracerOrigin == "Mouse" then origin = mousePos end
            cache.tracer.From = origin
            cache.tracer.To = Vector2.new(pos.X, footPos.Y)
            cache.tracer.Color = S.TracerColor
            cache.tracer.Visible = true
        else
            cache.tracer.Visible = false
        end

        -- Name
        if S.Name then
            cache.name.Text = plr.DisplayName or plr.Name
            cache.name.Position = Vector2.new(pos.X, headPos.Y - 16)
            cache.name.Color = S.NameColor
            cache.name.Visible = true
        else
            cache.name.Visible = false
        end

        -- Distance
        if S.Distance then
            cache.dist.Text = string.format("[%d studs]", math.floor(dist3d))
            cache.dist.Position = Vector2.new(pos.X, footPos.Y + 4)
            cache.dist.Visible = true
        else
            cache.dist.Visible = false
        end

        -- Health
        if S.HealthBar or S.HealthText then
            local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            local barH = height * hp
            local barX = boxPos.X - 5
            if S.HealthBar then
                cache.healthBg.Position = Vector2.new(barX, boxPos.Y)
                cache.healthBg.Size = Vector2.new(3, height)
                cache.healthBg.Visible = true
                cache.healthBar.Position = Vector2.new(barX, boxPos.Y + height - barH)
                cache.healthBar.Size = Vector2.new(3, barH)
                cache.healthBar.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 40)
                cache.healthBar.Visible = true
            else
                cache.healthBg.Visible = false
                cache.healthBar.Visible = false
            end
            if S.HealthText then
                cache.healthTxt.Text = tostring(math.floor(hum.Health))
                cache.healthTxt.Position = Vector2.new(barX - 10, boxPos.Y + height / 2)
                cache.healthTxt.Visible = true
            else
                cache.healthTxt.Visible = false
            end
        else
            cache.healthBg.Visible = false
            cache.healthBar.Visible = false
            cache.healthTxt.Visible = false
        end

        -- Skeleton
        if S.Skeleton then
            local bones = {
                {"Head", "UpperTorso"},
                {"UpperTorso", "LowerTorso"},
                {"UpperTorso", "LeftUpperArm"},
                {"LeftUpperArm", "LeftLowerArm"},
                {"LeftLowerArm", "LeftHand"},
                {"UpperTorso", "RightUpperArm"},
                {"RightUpperArm", "RightLowerArm"},
                {"RightLowerArm", "RightHand"},
                {"LowerTorso", "LeftUpperLeg"},
                {"LeftUpperLeg", "LeftLowerLeg"},
                {"LeftLowerLeg", "LeftFoot"},
                {"LowerTorso", "RightUpperLeg"},
                {"RightUpperLeg", "RightLowerLeg"},
                {"RightLowerLeg", "RightFoot"},
            }
            for i, pair in ipairs(bones) do
                local a = char:FindFirstChild(pair[1])
                local b = char:FindFirstChild(pair[2])
                local line = cache.skel[i]
                if a and b and line then
                    local pa, oa = worldToScreen(a.Position)
                    local pb, ob = worldToScreen(b.Position)
                    if oa and ob then
                        line.From = pa
                        line.To = pb
                        line.Color = S.SkelColor
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                elseif line then
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(cache.skel) do line.Visible = false end
        end
    end
end

-- Chams
local function updateChams()
    for plr, hl in pairs(chamsCache) do
        if not S.Chams or not isEnemy(plr) then
            if hl and hl.Parent then hl:Destroy() end
            chamsCache[plr] = nil
        end
    end
    if not S.Chams then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            if not chamsCache[plr] or not chamsCache[plr].Parent then
                local hl = Instance.new("Highlight")
                hl.FillColor = S.ChamsColor
                hl.OutlineColor = Color3.new(1,1,1)
                hl.FillTransparency = 0.55
                hl.OutlineTransparency = 0.2
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = plr.Character
                chamsCache[plr] = hl
            end
        end
    end
end

-- ======================== AIMBOT LOOP ========================
local function aimAt(part)
    if not part then return end
    local pos = getPredictedPos(part)
    if S.AimMethod == "Camera" or S.SilentAim then
        local cf = CFrame.new(Camera.CFrame.Position, pos)
        Camera.CFrame = Camera.CFrame:Lerp(cf, S.Smoothness)
    else
        local screen = Camera:WorldToViewportPoint(pos)
        local mousePos = UserInputService:GetMouseLocation()
        local delta = Vector2.new(screen.X - mousePos.X, screen.Y - mousePos.Y) * S.Smoothness
        mousemoverel(delta.X, delta.Y)
    end
end

-- ======================== COMBAT LOOPS ========================
local function knifeAuraTick()
    if not S.KnifeAura then return end
    local now = tick()
    if now - lastKnife < S.KnifeDelay then return end
    local targetChar = getClosestInRange(S.KnifeRange)
    if not targetChar then return end
    local tool = getChar() and getChar():FindFirstChildOfClass("Tool")
    if tool then
        pcall(function()
            tool:Activate()
        end)
        lastKnife = now
    end
end

local function hitboxTick()
    if not S.HitboxExpand then
        for plr, sizes in pairs(originalSizes) do
            local char = plr.Character
            if char then
                for partName, size in pairs(sizes) do
                    local p = char:FindFirstChild(partName)
                    if p and p:IsA("BasePart") then
                        p.Size = size
                    end
                end
            end
        end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local char = plr.Character
            if not originalSizes[plr] then originalSizes[plr] = {} end
            for _, name in ipairs({"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}) do
                local p = char:FindFirstChild(name)
                if p and p:IsA("BasePart") then
                    if not originalSizes[plr][name] then
                        originalSizes[plr][name] = p.Size
                    end
                    p.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
                    p.Transparency = 0.7
                    p.CanCollide = false
                end
            end
        end
    end
end

-- ======================== MOVEMENT ========================
local function movementTick()
    local char = getChar()
    local hum = getHum()
    local hrp = getHRP()
    if not (char and hum and hrp) then return end

    if S.Speed then
        hum.WalkSpeed = S.WalkSpeed
    end

    if S.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if S.Fly then
        if not flyBV or not flyBV.Parent then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = hrp
        end
        if not flyBG or not flyBG.Parent then
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.P = 9e4
            flyBG.Parent = hrp
        end
        flyBG.CFrame = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * S.FlySpeed or Vector3.zero
    end
end

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if S.InfJump then
        local hum = getHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ======================== INPUT ========================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == S.AimKey or input.UserInputType == Enum.UserInputType.MouseButton2 then
        HoldingAim = true
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        HoldingFire = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == S.AimKey or input.UserInputType == Enum.UserInputType.MouseButton2 then
        HoldingAim = false
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        HoldingFire = false
    end
end)

-- ======================== MAIN RENDER LOOP ========================
RunService.RenderStepped:Connect(function()
    -- FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = S.FOV
    FOVCircle.Color = S.FOVColor
    FOVCircle.Visible = S.ShowFOV and (S.Aimbot or S.SilentAim)

    -- Aimbot
    if S.Aimbot or S.SilentAim then
        local shouldAim = S.AlwaysOn or HoldingAim or (S.SilentAim and HoldingFire)
        if shouldAim then
            local target = getClosestTarget(S.FOV)
            if target then
                aimAt(target)
            end
        end
    end

    -- Triggerbot
    if S.Triggerbot and HoldingFire == false then
        local target = getClosestTarget(S.TriggerFOV)
        if target and tick() - lastTrigger > S.TriggerDelay then
            if math.random(1, 100) <= S.TriggerChance then
                pcall(function()
                    mouse1click()
                end)
                lastTrigger = tick()
            end
        end
    end

    updateESP()
    updateChams()
    knifeAuraTick()
    hitboxTick()
    movementTick()
end)

-- ======================== REATTACH ========================
Players.PlayerRemoving:Connect(function(plr)
    clearESP(plr)
    if chamsCache[plr] then
        pcall(function() chamsCache[plr]:Destroy() end)
        chamsCache[plr] = nil
    end
    originalSizes[plr] = nil
end)

LocalPlayer.CharacterAdded:Connect(function()
    if S.AutoReattach then
        task.wait(1)
        -- re-bind nothing special needed; loops already live
    end
end)

-- ======================== NOTIFY ========================
Rayfield:Notify({
    Title = "OPTICALZ MD",
    Content = "Modern UI loaded. Right Shift to toggle.",
    Duration = 5,
    Image = 4483362458
})

print("[OPTICALZ MD] ready")

