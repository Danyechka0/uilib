--[[
    skeet.cc Style Menu | Potassium Executor
    Toggle: Insert
    Style: Black & White, Snow particles
]]

-------------------------------------------------
--  SERVICES
-------------------------------------------------
local Players        = game:GetService("Players")
local UIS            = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local Player         = Players.LocalPlayer

-------------------------------------------------
--  PALETTE  (skeet-чёрно-белая)
-------------------------------------------------
local C = {
    bg          = Color3.fromRGB(16, 16, 16),
    header      = Color3.fromRGB(22, 22, 22),
    border      = Color3.fromRGB(50, 50, 50),
    accent      = Color3.fromRGB(255, 255, 255),
    tabActive   = Color3.fromRGB(32, 32, 32),
    tabInactive = Color3.fromRGB(22, 22, 22),
    section     = Color3.fromRGB(20, 20, 20),
    sectionHead = Color3.fromRGB(26, 26, 26),
    toggleOn    = Color3.fromRGB(255, 255, 255),
    toggleOff   = Color3.fromRGB(55, 55, 55),
    text        = Color3.fromRGB(210, 210, 210),
    textDim     = Color3.fromRGB(110, 110, 110),
    snow        = Color3.fromRGB(255, 255, 255),
}

-------------------------------------------------
--  HELPERS
-------------------------------------------------
local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, ch in ipairs(children or {}) do ch.Parent = inst end
    return inst
end

local function addStroke(parent, color, thickness)
    return create("UIStroke", {
        Parent = parent,
        Color = color or C.border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function addCorner(parent, radius)
    return create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 4),
    })
end

-------------------------------------------------
--  SCREEN GUI
-------------------------------------------------
local gui = create("ScreenGui", {
    Name = "SkeetMenu",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
})
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = Player:WaitForChild("PlayerGui") end

-------------------------------------------------
--  ❄  SNOW LAYER  (полноэкранный, за менюхой)
-------------------------------------------------
local snowFrame = create("Frame", {
    Name = "Snow",
    Parent = gui,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 0,
    ClipsDescendants = true,
})

local snowParticles = {}
local MAX_SNOW = 80

local function spawnSnowflake()
    local size = math.random(2, 5)
    local x = math.random(0, 1000) / 1000
    local speed = math.random(40, 120)
    local drift = math.random(-20, 20)
    local opacity = math.random(15, 60) / 100

    local flake = create("Frame", {
        Parent = snowFrame,
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(x, 0, 0, -size),
        BackgroundColor3 = C.snow,
        BackgroundTransparency = 1 - opacity,
        BorderSizePixel = 0,
        ZIndex = 0,
    })
    addCorner(flake, size)

    table.insert(snowParticles, {
        obj = flake,
        x = x,
        y = -size,
        speed = speed,
        drift = drift,
        size = size,
    })
end

RunService.RenderStepped:Connect(function(dt)
    -- spawn
    if #snowParticles < MAX_SNOW and math.random() < 0.4 then
        spawnSnowflake()
    end

    local viewY = snowFrame.AbsoluteSize.Y
    local viewX = snowFrame.AbsoluteSize.X

    for i = #snowParticles, 1, -1 do
        local p = snowParticles[i]
        p.y = p.y + p.speed * dt
        p.x = p.x + (p.drift / viewX) * dt

        p.obj.Position = UDim2.new(p.x, 0, 0, p.y)

        if p.y > viewY + 10 then
            p.obj:Destroy()
            table.remove(snowParticles, i)
        end
    end
end)

-------------------------------------------------
--  MAIN FRAME  (draggable)
-------------------------------------------------
local MENU_W, MENU_H = 580, 420

local mainFrame = create("Frame", {
    Name = "Main",
    Parent = gui,
    Size = UDim2.new(0, MENU_W, 0, MENU_H),
    Position = UDim2.new(0.5, -MENU_W/2, 0.5, -MENU_H/2),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ZIndex = 5,
    ClipsDescendants = true,
})
addCorner(mainFrame, 4)
addStroke(mainFrame, C.border, 1)

-- inner accent line (top, 2px white — skeet-стиль)
create("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
    ZIndex = 10,
})

-------------------------------------------------
--  DRAG
-------------------------------------------------
do
    local dragging, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-------------------------------------------------
--  HEADER / TITLE
-------------------------------------------------
local header = create("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 2),
    BackgroundColor3 = C.header,
    BorderSizePixel = 0,
    ZIndex = 6,
})

create("TextLabel", {
    Parent = header,
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "skeet",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = C.accent,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7,
})

create("TextLabel", {
    Parent = header,
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 50, 0, 0),
    BackgroundTransparency = 1,
    Text = ".cc",
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = C.textDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7,
})

-------------------------------------------------
--  TABS BAR
-------------------------------------------------
local tabBar = create("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, -16, 0, 28),
    Position = UDim2.new(0, 8, 0, 36),
    BackgroundColor3 = C.header,
    BorderSizePixel = 0,
    ZIndex = 6,
})
addCorner(tabBar, 3)
addStroke(tabBar, C.border, 1)

local tabNames = {"rage", "legit", "visuals", "misc", "skins"}
local tabs = {}
local tabContents = {}
local activeTab = nil

local tabLayout = create("UIListLayout", {
    Parent = tabBar,
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 0),
})

-------------------------------------------------
--  CONTENT AREA
-------------------------------------------------
local contentArea = create("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, -16, 1, -74),
    Position = UDim2.new(0, 8, 0, 68),
    BackgroundTransparency = 1,
    ZIndex = 6,
    ClipsDescendants = true,
})

-------------------------------------------------
--  SECTION BUILDER
-------------------------------------------------
local function createSection(parent, title, posX, posY, sizeX, sizeY)
    local sec = create("Frame", {
        Parent = parent,
        Size = UDim2.new(sizeX, -4, sizeY, 0),
        Position = UDim2.new(posX, posX > 0 and 2 or 0, posY, 0),
        BackgroundColor3 = C.section,
        BorderSizePixel = 0,
        ZIndex = 7,
    })
    addCorner(sec, 3)
    addStroke(sec, C.border, 1)

    local secHeader = create("Frame", {
        Parent = sec,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = C.sectionHead,
        BorderSizePixel = 0,
        ZIndex = 8,
    })
    addCorner(secHeader, 3)

    -- чтобы нижние углы не скруглялись визуально
    create("Frame", {
        Parent = secHeader,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = C.sectionHead,
        BorderSizePixel = 0,
        ZIndex = 8,
    })

    create("TextLabel", {
        Parent = secHeader,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
    })

    local content = create("ScrollingFrame", {
        Parent = sec,
        Size = UDim2.new(1, -8, 1, -30),
        Position = UDim2.new(0, 4, 0, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.textDim,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 8,
    })

    create("UIListLayout", {
        Parent = content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })

    create("UIPadding", {
        Parent = content,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    })

    return content
end

-------------------------------------------------
--  TOGGLE ELEMENT
-------------------------------------------------
local function createToggle(parent, text, default, callback)
    callback = callback or function() end
    local state = default or false

    local holder = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 9,
    })

    create("TextLabel", {
        Parent = holder,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10,
    })

    local box = create("Frame", {
        Parent = holder,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -14, 0.5, -6),
        BackgroundColor3 = state and C.toggleOn or C.toggleOff,
        BorderSizePixel = 0,
        ZIndex = 10,
    })
    addCorner(box, 2)
    addStroke(box, C.border, 1)

    -- checkmark
    local check = create("TextLabel", {
        Parent = box,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = state and "✓" or "",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = C.bg,
        ZIndex = 11,
    })

    local btn = create("TextButton", {
        Parent = holder,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 12,
    })

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(box, TweenInfo.new(0.15), {
            BackgroundColor3 = state and C.toggleOn or C.toggleOff
        }):Play()
        check.Text = state and "✓" or ""
        callback(state)
    end)

    return {holder = holder, getState = function() return state end}
end

-------------------------------------------------
--  SLIDER ELEMENT
-------------------------------------------------
local function createSlider(parent, text, min, max, default, callback)
    callback = callback or function() end
    local value = default or min

    local holder = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = 9,
    })

    local label = create("TextLabel", {
        Parent = holder,
        Size = UDim2.new(1, -40, 0, 14),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10,
    })

    local valLabel = create("TextLabel", {
        Parent = holder,
        Size = UDim2.new(0, 36, 0, 14),
        Position = UDim2.new(1, -36, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(value),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.textDim,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 10,
    })

    local track = create("Frame", {
        Parent = holder,
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = C.toggleOff,
        BorderSizePixel = 0,
        ZIndex = 10,
    })
    addCorner(track, 2)

    local fill = create("Frame", {
        Parent = track,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        ZIndex = 11,
    })
    addCorner(fill, 2)

    local btn = create("TextButton", {
        Parent = track,
        Size = UDim2.new(1, 0, 1, 10),
        Position = UDim2.new(0, 0, 0, -5),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 12,
    })

    local sliding = false
    btn.MouseButton1Down:Connect(function() sliding = true end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(value)
            callback(value)
        end
    end)
end

-------------------------------------------------
--  DROPDOWN (combo box)
-------------------------------------------------
local function createDropdown(parent, text, options, default, callback)
    callback = callback or function() end
    local selected = default or options[1]
    local open = false

    local holder = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        ZIndex = 9,
        ClipsDescendants = false,
    })

    create("TextLabel", {
        Parent = holder,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10,
    })

    local box = create("Frame", {
        Parent = holder,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = C.sectionHead,
        BorderSizePixel = 0,
        ZIndex = 10,
    })
    addCorner(box, 2)
    addStroke(box, C.border, 1)

    local selLabel = create("TextLabel", {
        Parent = box,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = selected,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.textDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
    })

    local arrow = create("TextLabel", {
        Parent = box,
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.Gotham,
        TextSize = 8,
        TextColor3 = C.textDim,
        ZIndex = 11,
    })

    local dropList = create("Frame", {
        Parent = box,
        Size = UDim2.new(1, 0, 0, #options * 20),
        Position = UDim2.new(0, 0, 1, 2),
        BackgroundColor3 = C.sectionHead,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
    })
    addCorner(dropList, 2)
    addStroke(dropList, C.border, 1)

    local dlLayout = create("UIListLayout", {
        Parent = dropList,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    for i, opt in ipairs(options) do
        local optBtn = create("TextButton", {
            Parent = dropList,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = C.sectionHead,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 51,
        })
        if i == 1 then addCorner(optBtn, 2) end
        if i == #options then addCorner(optBtn, 2) end

        create("TextLabel", {
            Parent = optBtn,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Text = opt,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = C.text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52,
        })

        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundColor3 = C.tabActive
        end)
        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundColor3 = C.sectionHead
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            selLabel.Text = opt
            dropList.Visible = false
            open = false
            callback(opt)
        end)
    end

    local toggleBtn = create("TextButton", {
        Parent = box,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 12,
    })

    toggleBtn.MouseButton1Click:Connect(function()
        open = not open
        dropList.Visible = open
    end)
end

-------------------------------------------------
--  SEPARATOR
-------------------------------------------------
local function createSeparator(parent)
    create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = C.border,
        BorderSizePixel = 0,
        ZIndex = 9,
    })
end

-------------------------------------------------
--  BUILD TABS + CONTENT
-------------------------------------------------
for i, name in ipairs(tabNames) do
    -- tab button
    local tabBtn = create("TextButton", {
        Parent = tabBar,
        Size = UDim2.new(1 / #tabNames, 0, 1, 0),
        BackgroundColor3 = (i == 1) and C.tabActive or C.tabInactive,
        BorderSizePixel = 0,
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = (i == 1) and C.accent or C.textDim,
        ZIndex = 7,
        LayoutOrder = i,
    })

    -- tab content page
    local page = create("Frame", {
        Parent = contentArea,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = (i == 1),
        ZIndex = 6,
    })

    tabs[name] = tabBtn
    tabContents[name] = page

    tabBtn.MouseButton1Click:Connect(function()
        for n, btn in pairs(tabs) do
            btn.BackgroundColor3 = C.tabInactive
            btn.TextColor3 = C.textDim
            tabContents[n].Visible = false
        end
        tabBtn.BackgroundColor3 = C.tabActive
        tabBtn.TextColor3 = C.accent
        page.Visible = true
        activeTab = name
    end)
end

activeTab = "rage"

-------------------------------------------------
--  FILL: rage tab
-------------------------------------------------
do
    local page = tabContents["rage"]

    local leftSec  = createSection(page, "aimbot", 0, 0, 0.5, 1)
    local rightSec = createSection(page, "anti-aim", 0.5, 0, 0.5, 1)

    createToggle(leftSec, "enabled", false)
    createToggle(leftSec, "silent aim", false)
    createToggle(leftSec, "auto fire", false)
    createDropdown(leftSec, "hitbox", {"head","chest","pelvis","auto"}, "head")
    createSlider(leftSec, "fov", 0, 180, 30)
    createSlider(leftSec, "hitchance", 0, 100, 70)
    createSeparator(leftSec)
    createToggle(leftSec, "auto wall", false)
    createSlider(leftSec, "min damage", 0, 100, 20)

    createToggle(rightSec, "enabled", false)
    createDropdown(rightSec, "pitch", {"none","down","up","zero"}, "down")
    createDropdown(rightSec, "yaw base", {"local view","at targets","freestanding"}, "at targets")
    createSlider(rightSec, "yaw offset", -180, 180, 0)
    createSeparator(rightSec)
    createToggle(rightSec, "fakelag", false)
    createSlider(rightSec, "limit", 1, 14, 6)
end

-------------------------------------------------
--  FILL: legit tab
-------------------------------------------------
do
    local page = tabContents["legit"]

    local leftSec  = createSection(page, "aimbot", 0, 0, 0.5, 1)
    local rightSec = createSection(page, "triggerbot", 0.5, 0, 0.5, 1)

    createToggle(leftSec, "enabled", false)
    createSlider(leftSec, "fov", 0, 30, 5)
    createSlider(leftSec, "smooth", 1, 20, 8)
    createDropdown(leftSec, "bone", {"head","neck","chest"}, "head")
    createToggle(leftSec, "aim lock", false)

    createToggle(rightSec, "enabled", false)
    createSlider(rightSec, "delay (ms)", 0, 200, 30)
    createToggle(rightSec, "head only", false)
end

-------------------------------------------------
--  FILL: visuals tab
-------------------------------------------------
do
    local page = tabContents["visuals"]

    local leftSec  = createSection(page, "players", 0, 0, 0.5, 1)
    local rightSec = createSection(page, "world", 0.5, 0, 0.5, 1)

    createToggle(leftSec, "box esp", false)
    createToggle(leftSec, "name esp", false)
    createToggle(leftSec, "health bar", false)
    createToggle(leftSec, "chams", false)
    createToggle(leftSec, "tracers", false)
    createToggle(leftSec, "skeleton", false)

    createToggle(rightSec, "fullbright", false)
    createToggle(rightSec, "no fog", false)
    createToggle(rightSec, "no particles", false)
    createSlider(rightSec, "ambient", 0, 255, 128)
    createToggle(rightSec, "crosshair", false)
end

-------------------------------------------------
--  FILL: misc tab
-------------------------------------------------
do
    local page = tabContents["misc"]

    local leftSec  = createSection(page, "movement", 0, 0, 0.5, 1)
    local rightSec = createSection(page, "other", 0.5, 0, 0.5, 1)

    createToggle(leftSec, "bunny hop", false)
    createToggle(leftSec, "auto strafe", false)
    createSlider(leftSec, "speed", 16, 100, 16)
    createToggle(leftSec, "infinite jump", false)
    createToggle(leftSec, "fly", false)
    createSlider(leftSec, "fly speed", 10, 200, 50)

    createToggle(rightSec, "anti afk", false)
    createToggle(rightSec, "no fall damage", false)
    createToggle(rightSec, "server info", false)
    createToggle(rightSec, "fps counter", false)
end

-------------------------------------------------
--  FILL: skins tab
-------------------------------------------------
do
    local page = tabContents["skins"]

    local leftSec  = createSection(page, "weapon skins", 0, 0, 0.5, 1)
    local rightSec = createSection(page, "profile", 0.5, 0, 0.5, 1)

    createDropdown(leftSec, "weapon", {"all","rifle","pistol","knife"}, "all")
    createDropdown(leftSec, "skin", {"default","galaxy","fade","neon"}, "default")
    createToggle(leftSec, "force apply", false)

    createToggle(rightSec, "custom name", false)
    createToggle(rightSec, "stat track", false)
end

-------------------------------------------------
--  WATERMARK  (top-right)
-------------------------------------------------
local watermark = create("Frame", {
    Parent = gui,
    Size = UDim2.new(0, 220, 0, 22),
    Position = UDim2.new(1, -230, 0, 10),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ZIndex = 50,
})
addCorner(watermark, 3)
addStroke(watermark, C.border, 1)

create("Frame", {
    Parent = watermark,
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = C.accent,
    BorderSizePixel = 0,
    ZIndex = 51,
})

local wmText = create("TextLabel", {
    Parent = watermark,
    Size = UDim2.new(1, -10, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1,
    Text = "skeet.cc | delay: 0ms | 60 fps",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = C.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 52,
})

-- update watermark fps
task.spawn(function()
    while task.wait(0.5) do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = math.floor(Player:GetNetworkPing() * 1000)
        wmText.Text = string.format("skeet.cc | delay: %dms | %d fps", ping, fps)
    end
end)

-------------------------------------------------
--  INSERT TOGGLE
-------------------------------------------------
local menuOpen = true

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen

        if menuOpen then
            mainFrame.Visible = true
            TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, MENU_W, 0, MENU_H),
                BackgroundTransparency = 0,
            }):Play()
        else
            local tw = TweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, MENU_W, 0, 0),
                BackgroundTransparency = 0.5,
            })
            tw:Play()
            tw.Completed:Connect(function()
                if not menuOpen then
                    mainFrame.Visible = false
                    mainFrame.Size = UDim2.new(0, MENU_W, 0, MENU_H)
                    mainFrame.BackgroundTransparency = 0
                end
            end)
        end
    end
end)

-------------------------------------------------
--  NOTIFICATION (показ при загрузке)
-------------------------------------------------
do
    local notif = create("Frame", {
        Parent = gui,
        Size = UDim2.new(0, 280, 0, 30),
        Position = UDim2.new(0.5, -140, 1, 0),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
        ZIndex = 60,
    })
    addCorner(notif, 3)
    addStroke(notif, C.border, 1)

    create("Frame", {
        Parent = notif,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        ZIndex = 61,
    })

    create("TextLabel", {
        Parent = notif,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "skeet.cc loaded — press [INSERT] to toggle",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 62,
    })

    -- slide up
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -140, 1, -45)
    }):Play()

    task.delay(3, function()
        local tw = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -140, 1, 10)
        })
        tw:Play()
        tw.Completed:Connect(function() notif:Destroy() end)
    end)
end

print("[skeet.cc] menu loaded ❄")
