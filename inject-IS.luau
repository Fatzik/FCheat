--[[
    Blatant.cat v2.0
    Modern UI + Fixed Config + Optimized
    
    Features:
    - Fixed config system (saves all settings properly)
    - Modern, sleek UI with animations
    - Optimized ESP rendering
    - Improved aimbot with better prediction
    
    Hotkeys:
    - F2: Toggle Menu
    - F3: Save Config
    - F4: Load Config
]]

-- ============================================
-- SERVICES
-- ============================================
local Services = {}
local function getService(name)
    return cloneref(game:GetService(name))
end

Services.CoreGui = getService("CoreGui")
Services.UserInputService = getService("UserInputService")
Services.TextService = getService("TextService")
Services.Players = getService("Players")
Services.RunService = getService("RunService")
Services.Workspace = getService("Workspace")
Services.MarketplaceService = getService("MarketplaceService")
Services.HttpService = getService("HttpService")
Services.TweenService = getService("TweenService")

local LocalPlayer = Services.Players.LocalPlayer

-- ============================================
-- COLOR PALETTE (MINECRAFT STYLE)
-- ============================================
local Colors = {
    Background = Color3.fromRGB(15, 15, 25),
    BackgroundLight = Color3.fromRGB(25, 25, 35),
    BackgroundLighter = Color3.fromRGB(35, 35, 45),
    BackgroundHover = Color3.fromRGB(45, 45, 65),
    Border = Color3.fromRGB(0, 0, 0),  -- Minecraft black borders
    BorderLight = Color3.fromRGB(85, 85, 85),  -- Minecraft gray
    Accent = Color3.fromRGB(255, 255, 85),  -- Minecraft yellow
    AccentLight = Color3.fromRGB(255, 255, 170),
    AccentDark = Color3.fromRGB(170, 170, 0),
    AccentGlow = Color3.fromRGB(255, 220, 50),
    Purple = Color3.fromRGB(170, 0, 255),
    PurpleLight = Color3.fromRGB(210, 100, 255),
    Success = Color3.fromRGB(85, 255, 85),  -- Minecraft green
    Warning = Color3.fromRGB(255, 170, 0),  -- Minecraft gold/orange
    Danger = Color3.fromRGB(255, 85, 85),  -- Minecraft red
    DangerLight = Color3.fromRGB(255, 120, 120),
    Text = Color3.fromRGB(255, 255, 255),  -- Minecraft white
    TextSecondary = Color3.fromRGB(170, 170, 170),  -- Minecraft gray
    TextMuted = Color3.fromRGB(85, 85, 85),
    GradientStart = Color3.fromRGB(255, 255, 85),  -- Yellow
    GradientMid = Color3.fromRGB(85, 255, 85),  -- Green
    GradientEnd = Color3.fromRGB(85, 170, 255),  -- Blue
}

-- ============================================
-- MINECRAFT FONT SYSTEM
-- Blocky, pixelated Minecraft-style fonts
-- ============================================
local MinecraftFonts = {
    -- Minecraft-style font mappings
    Title = Enum.Font.GothamBlack,      -- Blocky for titles
    Header = Enum.Font.GothamBold,      -- Bold headers
    Body = Enum.Font.Gotham,            -- Regular text
    Code = Enum.Font.SourceSansBold,    -- Pixelated for code
    Pixel = Enum.Font.Arcade,           -- Very pixelated
    Minecraft = Enum.Font.SourceSansBold, -- Main Minecraft-like
}

-- Helper function to apply Minecraft style to text elements
local function applyMinecraftStyle(textElement, style, size)
    style = style or "Minecraft"
    
    -- Set font based on style
    textElement.Font = MinecraftFonts[style] or MinecraftFonts.Minecraft
    
    -- Adjust size for better Minecraft look
    if not size then
        if style == "Title" then
            textElement.TextSize = 20
        elseif style == "Header" then
            textElement.TextSize = 16
        elseif style == "Code" or style == "Pixel" then
            textElement.TextSize = 14
        else
            textElement.TextSize = 14
        end
    end
    
    -- Add text stroke for blocky Minecraft effect
    if not textElement:FindFirstChild("MinecraftStroke") then
        local stroke = Instance.new("UIStroke")
        stroke.Name = "MinecraftStroke"
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Thickness = style == "Title" and 2 or 1
        stroke.Transparency = 0.5
        stroke.Parent = textElement
    end
    
    -- Minecraft text coloring
    if style == "Title" then
        textElement.TextColor3 = Colors.Text
    elseif style == "Header" then
        textElement.TextColor3 = Colors.Accent
    elseif style == "Code" then
        textElement.TextColor3 = Colors.Success
    else
        textElement.TextColor3 = Colors.Text
    end
    
    return textElement
end

-- ============================================
-- ANIMATION SYSTEM (OPTIMIZED)
-- Reuses TweenInfo objects to avoid GC pressure
-- ============================================
local TweenInfo_Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfo_Medium = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfo_Slow = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfo_Elastic = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local TweenInfo_Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

-- Cache for active tweens to cancel before starting new ones
local activeTweens = {}

local function playTween(object, tweenInfo, properties)
    -- Cancel existing tween for this object
    local existing = activeTweens[object]
    if existing then
        existing:Cancel()
    end
    
    local tween = Services.TweenService:Create(object, tweenInfo, properties)
    activeTweens[object] = tween
    tween:Play()
    
    -- Clean up reference when done
    tween.Completed:Connect(function()
        activeTweens[object] = nil
    end)
    
    return tween
end

-- ============================================
-- CONFIG SYSTEM (COMPLETELY REWRITTEN)
-- ============================================
local CONFIG_FILE = "BlatantConfig_v2.json"

local ConfigData = {
    esp = {
        enabled = false,
        boxEnabled = false,
        boxType = "Standard",
        outlineEnabled = true,
        skeletonEnabled = false,
        healthBarEnabled = false,
        distanceEnabled = false,
        nameEnabled = false,
        highlightEnabled = false,
        snaplineEnabled = false,
        snaplineMode = "Bottom",
        teamCheck = false,
        boxColor = Color3.fromRGB(88, 196, 255),
        nameColor = Color3.fromRGB(255, 255, 255),
        skeletonColor = Color3.fromRGB(255, 255, 255),
        snaplineColor = Color3.fromRGB(88, 196, 255),
        distanceColor = Color3.fromRGB(200, 200, 200),
        highlightFillColor = Color3.fromRGB(88, 196, 255),
        highlightOutlineColor = Color3.fromRGB(255, 255, 255),
        highlightFillTransparency = 0.75,
        highlightOutlineTransparency = 0,
    },
    aimbot = {
        enabled = false,
        teamCheck = false,
        fov = 120,
        smoothness = 5,
        bodyAim = "Head",
        wallCheck = true,
        prediction = 0,
        stickyTarget = false,
        lookAtView = false,
        activationKey = "MouseButton2",
        showFov = true,
        fovColor = Color3.fromRGB(88, 196, 255),
        triggerbotEnabled = false,
        triggerbotDelay = 50,
        triggerbotFov = 30,
    },
    misc = {
        walkSpeed = 16,
        loopWalkSpeed = false,
        infiniteJump = false,
        hitboxEnabled = false,
        hitboxSize = 15,
        hitboxTransparency = 0.9,
        hitboxVisible = false,
        hitboxPart = "HumanoidRootPart",
        hitboxTeamCheck = false,
        flyEnabled = false,
        flySpeed = 50,
        noclipEnabled = false,
    },
}

local function colorToTable(c)
    return {r = math.floor(c.R * 255 + 0.5), g = math.floor(c.G * 255 + 0.5), b = math.floor(c.B * 255 + 0.5)}
end

local function tableToColor(t)
    return Color3.fromRGB(t.r or 255, t.g or 255, t.b or 255)
end

local function saveConfig()
    local dataToSave = {}
    
    -- Serialize each category
    for category, settings in pairs(ConfigData) do
        dataToSave[category] = {}
        for key, value in pairs(settings) do
            if typeof(value) == "Color3" then
                dataToSave[category][key] = colorToTable(value)
            else
                dataToSave[category][key] = value
            end
        end
    end
    
    local json = Services.HttpService:JSONEncode(dataToSave)
    local success = pcall(function()
        writefile(CONFIG_FILE, json)
    end)
    
    if success then
        print("✅ [Config] Saved to " .. CONFIG_FILE)
    else
        warn("❌ [Config] Failed to save")
    end
    
    return success
end

local function loadConfig()
    if not isfile or not isfile(CONFIG_FILE) then
        print("ℹ️ [Config] No config file found")
        return false
    end
    
    local success, data = pcall(function()
        local content = readfile(CONFIG_FILE)
        return Services.HttpService:JSONDecode(content)
    end)
    
    if not success or not data then
        warn("❌ [Config] Failed to load")
        return false
    end
    
    -- Merge loaded data
    for category, settings in pairs(data) do
        if ConfigData[category] then
            for key, value in pairs(settings) do
                if ConfigData[category][key] ~= nil then
                    if type(value) == "table" and value.r and value.g and value.b then
                        ConfigData[category][key] = tableToColor(value)
                    else
                        ConfigData[category][key] = value
                    end
                end
            end
        end
    end
    
    print("✅ [Config] Loaded from " .. CONFIG_FILE)
    return true
end

local function resetConfig()
    ConfigData.esp = {
        enabled = false, boxEnabled = false, boxType = "Standard", outlineEnabled = true,
        skeletonEnabled = false, healthBarEnabled = false, distanceEnabled = false,
        nameEnabled = false, highlightEnabled = false, snaplineEnabled = false,
        snaplineMode = "Bottom", teamCheck = false,
        boxColor = Color3.fromRGB(88, 196, 255), nameColor = Color3.fromRGB(255, 255, 255),
        skeletonColor = Color3.fromRGB(255, 255, 255), snaplineColor = Color3.fromRGB(88, 196, 255),
        distanceColor = Color3.fromRGB(200, 200, 200), highlightFillColor = Color3.fromRGB(88, 196, 255),
        highlightOutlineColor = Color3.fromRGB(255, 255, 255), highlightFillTransparency = 0.75,
        highlightOutlineTransparency = 0,
    }
    ConfigData.aimbot = {
        enabled = false, teamCheck = false, fov = 120, smoothness = 5, bodyAim = "Head",
        wallCheck = true, prediction = 0, stickyTarget = false, lookAtView = false,
        activationKey = "MouseButton2", showFov = true, fovColor = Color3.fromRGB(88, 196, 255),
        triggerbotEnabled = false, triggerbotDelay = 50, triggerbotFov = 30,
    }
    ConfigData.misc = {
        walkSpeed = 16, loopWalkSpeed = false, infiniteJump = false, hitboxEnabled = false,
        hitboxSize = 15, hitboxTransparency = 0.9, hitboxVisible = false,
        hitboxPart = "HumanoidRootPart", hitboxTeamCheck = false, flyEnabled = false,
        flySpeed = 50, noclipEnabled = false,
    }
    print("🔄 [Config] Reset to defaults")
end

-- ============================================
-- UI SYSTEM (MODERN DESIGN)
-- ============================================
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    self.connections = {}
    self.visible = false  -- Menu starts hidden, will be shown on F2
    self.tabs = {}
    self.activeTab = nil
    self.openDropdowns = {}   -- legacy, kept for compat
    self.dropdownClosers = {} -- list of {isOpen, forceClose} per dropdown
    
    self:_createScreenGui()
    self:_createMainFrame()
    self:_createHeader()
    self:_createTabBar()
    self:_createContentArea()
    self:_setupToggle()
    
    return self
end

function UI:_setupToggle()
    -- Hotkey toggling is handled in App:_setupHotkeys
end

function UI:_connect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(self.connections, conn)
    return conn
end

function UI:_createScreenGui()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "BlatantUI_v2"
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = Services.CoreGui
end

function UI:_createMainFrame()
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 660, 0, 510)
    self.mainFrame.Position = UDim2.new(0.5, -330, 0.5, -255)
    self.mainFrame.BackgroundColor3 = Colors.Background
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Visible = false
    self.mainFrame.BackgroundTransparency = 1
    self.mainFrame.Parent = self.screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.mainFrame

    -- Subtle gradient overlay on the background
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 14, 24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 18)),
    })
    bgGradient.Rotation = 135
    bgGradient.Parent = self.mainFrame

    -- Border glow stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0
    stroke.Parent = self.mainFrame

    -- Outer glow (shadow)
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    shadow.Size = UDim2.new(1, 50, 1, 50)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Colors.Accent
    shadow.ImageTransparency = 0.92
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = self.mainFrame

    -- Dark outer shadow
    local shadowDark = Instance.new("ImageLabel")
    shadowDark.AnchorPoint = Vector2.new(0.5, 0.5)
    shadowDark.BackgroundTransparency = 1
    shadowDark.Position = UDim2.new(0.5, 0, 0.5, 10)
    shadowDark.Size = UDim2.new(1, 70, 1, 70)
    shadowDark.ZIndex = -2
    shadowDark.Image = "rbxassetid://6014261993"
    shadowDark.ImageColor3 = Color3.new(0, 0, 0)
    shadowDark.ImageTransparency = 0.65
    shadowDark.ScaleType = Enum.ScaleType.Slice
    shadowDark.SliceCenter = Rect.new(49, 49, 450, 450)
    shadowDark.Parent = self.mainFrame

    self.stroke = stroke
    self.shadow = shadow
    self.shadowDark = shadowDark

    self:_setupDrag()
end

function UI:AnimateOpen()
    if not self.mainFrame then return end

    -- Store the real center position
    local centerPos = UDim2.new(0.5, -330, 0.5, -255)
    local startPos  = UDim2.new(0.5, -330, 0.5, -230)  -- slightly above

    self.mainFrame.Visible = true
    self.mainFrame.BackgroundTransparency = 1
    self.mainFrame.Position = startPos

    local info = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    playTween(self.mainFrame, info, { BackgroundTransparency = 0, Position = centerPos })
    playTween(self.stroke,    info, { Transparency = 0 })
    playTween(self.shadow,    info, { ImageTransparency = 0.92 })
    playTween(self.shadowDark,info, { ImageTransparency = 0.65 })

    -- Animate children group (header, tabbar, content) by fading in via CanvasGroupTransparency trick
    -- We fade all top-level children of mainFrame except shadow
    for _, child in ipairs(self.mainFrame:GetChildren()) do
        if child:IsA("GuiObject") and child ~= self.shadow and child ~= self.shadowDark then
            if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                child.BackgroundTransparency = 1
                playTween(child, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = child.BackgroundTransparency == 1 and 0 or child.BackgroundTransparency })
            end
            -- Fade text in children
            for _, desc in ipairs(child:GetDescendants()) do
                if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                    local origTrans = desc:GetAttribute("OrigTextTrans") or 0
                    desc.TextTransparency = 1
                    playTween(desc, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = origTrans })
                elseif desc:IsA("ImageLabel") and desc ~= self.shadow and desc ~= self.shadowDark then
                    local orig = desc:GetAttribute("OrigImageTrans") or 0
                    desc.ImageTransparency = 1
                    playTween(desc, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = orig })
                end
            end
        end
    end
end

function UI:AnimateClose(callback)
    if not self.mainFrame then
        if callback then callback() end
        return
    end

    local endPos = UDim2.new(0.5, -330, 0.5, -280)
    local info   = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    playTween(self.mainFrame,  info, { BackgroundTransparency = 1, Position = endPos })
    playTween(self.stroke,     info, { Transparency = 1 })
    playTween(self.shadow,     info, { ImageTransparency = 1 })
    playTween(self.shadowDark, info, { ImageTransparency = 1 })

    for _, child in ipairs(self.mainFrame:GetChildren()) do
        if child:IsA("GuiObject") and child ~= self.shadow and child ~= self.shadowDark then
            for _, desc in ipairs(child:GetDescendants()) do
                if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                    playTween(desc, info, { TextTransparency = 1 })
                elseif desc:IsA("ImageLabel") and desc ~= self.shadow and desc ~= self.shadowDark then
                    playTween(desc, info, { ImageTransparency = 1 })
                end
            end
        end
    end

    task.wait(0.22)
    if callback then callback() end
end

function UI:_setupDrag()
    local dragging, dragStart, startPos = false, nil, nil
    
    self:_connect(self.mainFrame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
        end
    end)
    
    self:_connect(Services.UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    self:_connect(Services.UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function UI:_createHeader()
    -- Header background with gradient
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 54)
    header.BackgroundColor3 = Colors.BackgroundLight
    header.BorderSizePixel = 0
    header.Parent = self.mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    -- Gradient overlay on header
    local headerGrad = Instance.new("UIGradient")
    headerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 20, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 22)),
    })
    headerGrad.Rotation = 90
    headerGrad.Parent = header

    -- Fix bottom corners
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0, 16)
    fix.Position = UDim2.new(0, 0, 1, -16)
    fix.BackgroundColor3 = Colors.BackgroundLight
    fix.BorderSizePixel = 0
    fix.Parent = header
    local fixGrad = Instance.new("UIGradient")
    fixGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 22)),
    })
    fixGrad.Rotation = 90
    fixGrad.Parent = fix

    -- Animated gradient bottom line
    local gradientLine = Instance.new("Frame")
    gradientLine.Size = UDim2.new(1, 0, 0, 2)
    gradientLine.Position = UDim2.new(0, 0, 1, -2)
    gradientLine.BackgroundColor3 = Color3.new(1, 1, 1)
    gradientLine.BorderSizePixel = 0
    gradientLine.Parent = header

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Colors.GradientStart),
        ColorSequenceKeypoint.new(0.5,  Colors.GradientMid),
        ColorSequenceKeypoint.new(1,    Colors.GradientEnd),
    })
    grad.Parent = gradientLine

    -- Animated gradient rotation
    task.spawn(function()
        local rotation = 0
        while self.mainFrame and self.mainFrame.Parent do
            rotation = (rotation + 0.4) % 360
            grad.Rotation = rotation
            task.wait(0.03)
        end
    end)

    -- Logo dot (glowing circle)
    local logoDot = Instance.new("Frame")
    logoDot.Size = UDim2.new(0, 10, 0, 10)
    logoDot.Position = UDim2.new(0, 16, 0.5, -5)
    logoDot.BackgroundColor3 = Colors.Accent
    logoDot.BorderSizePixel = 0
    logoDot.Parent = header
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = logoDot

    -- Pulsing glow behind dot
    local dotGlow = Instance.new("ImageLabel")
    dotGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    dotGlow.BackgroundTransparency = 1
    dotGlow.Position = UDim2.new(0, 21, 0.5, 0)
    dotGlow.Size = UDim2.new(0, 28, 0, 28)
    dotGlow.ZIndex = 0
    dotGlow.Image = "rbxassetid://6014261993"
    dotGlow.ImageColor3 = Colors.Accent
    dotGlow.ImageTransparency = 0.7
    dotGlow.ScaleType = Enum.ScaleType.Slice
    dotGlow.SliceCenter = Rect.new(49, 49, 450, 450)
    dotGlow.Parent = header

    -- Pulse animation on dot
    task.spawn(function()
        local growing = true
        while self.mainFrame and self.mainFrame.Parent do
            local target = growing and 0.5 or 0.75
            playTween(dotGlow, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = target})
            growing = not growing
            task.wait(0.9)
        end
    end)

    -- Title (Minecraft style)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 130, 1, 0)
    title.Position = UDim2.new(0, 32, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "BLATANT.CAT"
    title.TextColor3 = Colors.Accent
    title.Font = MinecraftFonts.Title
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    applyMinecraftStyle(title, "Title")

    -- Gradient on title text
    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Text),
        ColorSequenceKeypoint.new(1, Colors.TextSecondary),
    })
    titleGrad.Rotation = 0
    titleGrad.Parent = title

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0, 40, 0, 18)
    version.Position = UDim2.new(0, 130, 0.5, -9)
    version.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    version.BackgroundTransparency = 0.2
    version.BorderColor3 = Colors.Accent
    version.BorderSizePixel = 2
    version.Text = "v2.0"
    version.TextColor3 = Colors.Accent
    version.Font = MinecraftFonts.Pixel
    version.TextSize = 10
    version.Parent = header
    applyMinecraftStyle(version, "Code")

    -- Minimize button (Minecraft style)
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -70, 0.5, -14)
    minBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    minBtn.BorderColor3 = Colors.Warning
    minBtn.BorderSizePixel = 2
    minBtn.Text = "-"
    minBtn.TextColor3 = Colors.Warning
    minBtn.Font = MinecraftFonts.Title
    minBtn.TextSize = 20
    minBtn.Parent = header
    applyMinecraftStyle(minBtn, "Header")
    self:_connect(minBtn.MouseEnter, function()
        playTween(minBtn, TweenInfo_Fast, {BackgroundColor3 = Colors.Warning, TextColor3 = Colors.Text, BorderColor3 = Colors.Text})
    end)
    self:_connect(minBtn.MouseLeave, function()
        playTween(minBtn, TweenInfo_Fast, {BackgroundColor3 = Color3.fromRGB(0,0,0), TextColor3 = Colors.Warning, BorderColor3 = Colors.Warning})
    end)
    self:_connect(minBtn.MouseButton1Click, function()
        self:SetVisible(false)
    end)

    -- Close button (Minecraft style)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    closeBtn.BorderColor3 = Colors.Danger
    closeBtn.BorderSizePixel = 2
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Colors.Danger
    closeBtn.Font = MinecraftFonts.Title
    closeBtn.TextSize = 18
    closeBtn.Parent = header
    applyMinecraftStyle(closeBtn, "Header")
    self:_connect(closeBtn.MouseEnter, function()
        playTween(closeBtn, TweenInfo_Fast, {BackgroundColor3 = Colors.Danger, TextColor3 = Colors.Text, BorderColor3 = Colors.Text})
    end)
    self:_connect(closeBtn.MouseLeave, function()
        playTween(closeBtn, TweenInfo_Fast, {BackgroundColor3 = Color3.fromRGB(0,0,0), TextColor3 = Colors.Danger, BorderColor3 = Colors.Danger})
    end)
    self:_connect(closeBtn.MouseButton1Click, function()
        self:SetVisible(false)
    end)
end

function UI:_createTabBar()
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -32, 0, 36)
    tabBar.Position = UDim2.new(0, 16, 0, 58)
    tabBar.BackgroundColor3 = Colors.BackgroundLighter
    tabBar.BorderSizePixel = 0
    tabBar.Parent = self.mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tabBar

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = tabBar

    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Size = UDim2.new(1, -8, 1, 0)
    self.tabContainer.Position = UDim2.new(0, 4, 0, 0)
    self.tabContainer.BackgroundTransparency = 1
    self.tabContainer.Parent = tabBar

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 2)
    layout.Parent = self.tabContainer
end

function UI:_createContentArea()
    self.contentArea = Instance.new("Frame")
    self.contentArea.Name = "ContentArea"
    self.contentArea.Size = UDim2.new(1, -32, 1, -108)
    self.contentArea.Position = UDim2.new(0, 16, 0, 100)
    self.contentArea.BackgroundTransparency = 1
    self.contentArea.Parent = self.mainFrame
end

-- Tab icons map (Minecraft style symbols)
local TAB_ICONS = {
    VISUALS = "[👁]",
    AIMBOT  = "[🎯]",
    MISC    = "[⚙]",
    CONFIG  = "[�]",
}

function UI:AddTab(name)
    local icon = TAB_ICONS[name] or "•"

    -- Outer wrapper (Minecraft square style)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 100, 1, -8)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 1
    btn.BorderColor3 = Colors.TextMuted
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = self.tabContainer

    -- Icon label (Minecraft style)
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 24, 1, 0)
    iconLabel.Position = UDim2.new(0, 6, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = Colors.TextMuted
    iconLabel.Font = MinecraftFonts.Pixel
    iconLabel.TextSize = 12
    iconLabel.TextXAlignment = Enum.TextXAlignment.Left
    iconLabel.Parent = btn
    applyMinecraftStyle(iconLabel, "Pixel")

    -- Text label (Minecraft style)
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -30, 1, 0)
    textLabel.Position = UDim2.new(0, 28, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = Colors.TextMuted
    textLabel.Font = MinecraftFonts.Header
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = btn
    applyMinecraftStyle(textLabel, "Header")

    -- Active indicator bar at bottom
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 0, 0, 2)
    indicator.Position = UDim2.new(0.5, 0, 1, -3)
    indicator.AnchorPoint = Vector2.new(0.5, 0)
    indicator.BackgroundColor3 = Colors.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    -- Gradient on indicator
    local indGrad = Instance.new("UIGradient")
    indGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.GradientStart),
        ColorSequenceKeypoint.new(1, Colors.GradientEnd),
    })
    indGrad.Parent = indicator

    -- Content scrolling frame
    local content = Instance.new("ScrollingFrame")
    content.Name = name .. "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Colors.Accent
    content.ScrollBarImageTransparency = 0.4
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Visible = false
    content.Parent = self.contentArea

    -- Close any open dropdown when the user scrolls this tab's content
    self:_connect(content:GetPropertyChangedSignal("CanvasPosition"), function()
        for _, closer in ipairs(self.dropdownClosers) do
            closer.forceClose()
        end
    end)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = content

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 6)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 2)
    contentPadding.PaddingRight = UDim.new(0, 4)
    contentPadding.Parent = content

    self.tabs[name] = {button = btn, content = content, icon = iconLabel, text = textLabel, indicator = indicator}

    self:_connect(btn.MouseEnter, function()
        if self.activeTab ~= name then
            playTween(btn, TweenInfo_Fast, {BackgroundTransparency = 0.6, BackgroundColor3 = Colors.BackgroundHover})
            playTween(textLabel, TweenInfo_Fast, {TextColor3 = Colors.TextSecondary})
            playTween(iconLabel, TweenInfo_Fast, {TextColor3 = Colors.TextSecondary})
        end
    end)

    self:_connect(btn.MouseLeave, function()
        if self.activeTab ~= name then
            playTween(btn, TweenInfo_Fast, {BackgroundTransparency = 1})
            playTween(textLabel, TweenInfo_Fast, {TextColor3 = Colors.TextMuted})
            playTween(iconLabel, TweenInfo_Fast, {TextColor3 = Colors.TextMuted})
        end
    end)

    self:_connect(btn.MouseButton1Click, function()
        self:SetActiveTab(name)
    end)

    return content
end

function UI:SetActiveTab(name)
    for tabName, tabData in pairs(self.tabs) do
        local isActive = tabName == name
        tabData.content.Visible = isActive

        if isActive then
            -- Active: pill bg, colored text, slide indicator in
            playTween(tabData.button, TweenInfo_Fast, {
                BackgroundTransparency = 0.5,
                BackgroundColor3 = Colors.AccentDark,
            })
            playTween(tabData.text, TweenInfo_Fast, {TextColor3 = Colors.Text})
            playTween(tabData.icon, TweenInfo_Fast, {TextColor3 = Colors.AccentLight})
            playTween(tabData.indicator, TweenInfo_Medium, {Size = UDim2.new(0.7, 0, 0, 2)})
        else
            playTween(tabData.button, TweenInfo_Fast, {
                BackgroundTransparency = 1,
                BackgroundColor3 = Colors.BackgroundLighter,
            })
            playTween(tabData.text, TweenInfo_Fast, {TextColor3 = Colors.TextMuted})
            playTween(tabData.icon, TweenInfo_Fast, {TextColor3 = Colors.TextMuted})
            playTween(tabData.indicator, TweenInfo_Fast, {Size = UDim2.new(0, 0, 0, 2)})
        end
    end
    self.activeTab = name
end

function UI:AddSection(parent, title)
    local section = Instance.new("Frame")
    section.Name = "Section_" .. title
    section.Size = UDim2.new(1, -4, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    section.BorderColor3 = Colors.Accent
    section.BorderSizePixel = 2
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = parent

    -- Minecraft left accent bar (solid yellow, no gradients)
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = section

    -- Section title (Minecraft style)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 28)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "[" .. title:upper() .. "]"
    titleLabel.TextColor3 = Colors.Accent
    titleLabel.Font = MinecraftFonts.Header
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    applyMinecraftStyle(titleLabel, "Header")

    -- Separator line under title
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -16, 0, 1)
    sep.Position = UDim2.new(0, 8, 0, 28)
    sep.BackgroundColor3 = Colors.Accent
    sep.BackgroundTransparency = 0.7
    sep.BorderSizePixel = 0
    sep.Parent = section

    -- Items container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -16, 0, 0)
    container.Position = UDim2.new(0, 8, 0, 32)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = section

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 4)
    padding.Parent = container

    return container
end

-- ============================================
-- UI ELEMENTS
-- ============================================
function UI:CreateToggle(parent, text, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, 0, 0, 28)
    toggle.BackgroundColor3 = Colors.BackgroundLighter
    toggle.BackgroundTransparency = 1
    toggle.BorderSizePixel = 0
    toggle.Parent = parent

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggle

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextSecondary
    label.Font = MinecraftFonts.Minecraft
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    applyMinecraftStyle(label, "Minecraft", 12)

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 36, 0, 18)
    switch.Position = UDim2.new(1, -42, 0.5, -9)
    switch.BackgroundColor3 = Colors.BackgroundLighter
    switch.BorderSizePixel = 0
    switch.Parent = toggle

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local switchStroke = Instance.new("UIStroke")
    switchStroke.Color = Colors.Border
    switchStroke.Thickness = 1
    switchStroke.Parent = switch

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Colors.TextMuted
    knob.BorderSizePixel = 0
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = default or false

    local function update(v, silent)
        state = v
        playTween(switch, TweenInfo_Fast, {
            BackgroundColor3 = v and Colors.Accent or Colors.BackgroundLighter
        })
        playTween(switchStroke, TweenInfo_Fast, {
            Color = v and Colors.AccentDark or Colors.Border
        })
        playTween(knob, TweenInfo_Fast, {
            Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = v and Colors.Text or Colors.TextMuted
        })
        playTween(label, TweenInfo_Fast, {TextColor3 = v and Colors.Text or Colors.TextSecondary})
        if not silent and callback then callback(v) end
    end

    update(default or false, true)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 2
    btn.Parent = toggle

    self:_connect(btn.MouseEnter, function()
        if not state then
            playTween(toggle, TweenInfo_Fast, {BackgroundTransparency = 0.85})
        end
    end)
    self:_connect(btn.MouseLeave, function()
        if not state then
            playTween(toggle, TweenInfo_Fast, {BackgroundTransparency = 1})
        end
    end)

    self:_connect(btn.MouseButton1Click, function()
        update(not state, false)
        if state then
            playTween(toggle, TweenInfo_Fast, {BackgroundTransparency = 1})
        end
    end)

    return {
        Set = function(_, v) update(v, true) end,
        Get = function() return state end
    }
end

function UI:CreateSlider(parent, text, min, max, default, callback, suffix)
    suffix = suffix or ""
    local current = default

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 44)
    slider.BackgroundTransparency = 1
    slider.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 18)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextSecondary
    label.Font = MinecraftFonts.Minecraft
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    applyMinecraftStyle(label, "Minecraft", 12)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, -6, 0, 18)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default) .. suffix
    valueLabel.TextColor3 = Colors.Accent
    valueLabel.Font = MinecraftFonts.Header
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    applyMinecraftStyle(valueLabel, "Header", 12)
    valueLabel.Parent = slider

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -12, 0, 6)
    trackBg.Position = UDim2.new(0, 6, 0, 30)
    trackBg.BackgroundColor3 = Colors.BackgroundLighter
    trackBg.BorderSizePixel = 0
    trackBg.Parent = slider

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = trackBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = trackBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    -- Drag handle dot
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 0.5, 0)
    handle.BackgroundColor3 = Colors.Text
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = trackBg

    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 16)
    btn.Position = UDim2.new(0, 0, 0, -8)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = trackBg

    local dragging = false

    local function setValue(x)
        local rel = math.clamp((x - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        current = math.floor(min + (max - min) * rel + 0.5)
        local frac = (current - min) / (max - min)
        fill.Size = UDim2.new(frac, 0, 1, 0)
        handle.Position = UDim2.new(frac, 0, 0.5, 0)
        valueLabel.Text = tostring(current) .. suffix
        if callback then callback(current) end
    end

    self:_connect(btn.MouseEnter, function()
        playTween(handle, TweenInfo_Fast, {Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Colors.Accent})
        playTween(fill, TweenInfo_Fast, {BackgroundColor3 = Colors.AccentLight})
    end)
    self:_connect(btn.MouseLeave, function()
        if not dragging then
            playTween(handle, TweenInfo_Fast, {Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Colors.Text})
            playTween(fill, TweenInfo_Fast, {BackgroundColor3 = Colors.Accent})
        end
    end)

    self:_connect(btn.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setValue(input.Position.X)
        end
    end)

    self:_connect(Services.UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setValue(input.Position.X)
        end
    end)

    self:_connect(Services.UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            playTween(handle, TweenInfo_Fast, {Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Colors.Text})
            playTween(fill, TweenInfo_Fast, {BackgroundColor3 = Colors.Accent})
        end
    end)

    return {
        Set = function(_, v)
            current = math.clamp(v, min, max)
            local frac = (current - min) / (max - min)
            fill.Size = UDim2.new(frac, 0, 1, 0)
            handle.Position = UDim2.new(frac, 0, 0.5, 0)
            valueLabel.Text = tostring(current) .. suffix
        end,
        Get = function() return current end
    }
end

function UI:CreateDropdown(parent, text, options, default, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, 0, 0, 50)
    dropdown.BackgroundTransparency = 1
    dropdown.ClipsDescendants = false
    dropdown.ZIndex = 10
    dropdown.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextSecondary
    label.Font = MinecraftFonts.Minecraft
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 10
    label.Parent = dropdown
    applyMinecraftStyle(label, "Minecraft", 11)

    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 28)
    box.Position = UDim2.new(0, 0, 0, 18)
    box.BackgroundColor3 = Colors.BackgroundLighter
    box.BorderSizePixel = 0
    box.ClipsDescendants = false
    box.ZIndex = 10
    box.Parent = dropdown

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 5)
    boxCorner.Parent = box

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Parent = box

    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(1, -28, 1, 0)
    selected.Position = UDim2.new(0, 8, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = default
    selected.TextColor3 = Colors.Text
    selected.Font = MinecraftFonts.Minecraft
    selected.TextSize = 12
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.ZIndex = 11
    selected.Parent = box
    applyMinecraftStyle(selected, "Minecraft", 12)

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -22, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = Colors.Accent
    arrow.Font = MinecraftFonts.Header
    arrow.TextSize = 10
    arrow.ZIndex = 11
    arrow.Parent = box
    applyMinecraftStyle(arrow, "Header", 10)

    -- List is parented to ScreenGui to escape clipping
    local listHeight = math.min(#options, 6) * 28 + 8
    local list = Instance.new("Frame")
    list.Size = UDim2.new(0, 0, 0, listHeight)  -- width set on open
    list.BackgroundColor3 = Colors.BackgroundLight
    list.BorderSizePixel = 0
    list.Visible = false
    list.ZIndex = 200
    list.Parent = self.screenGui

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = list

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Colors.Accent
    listStroke.Thickness = 1
    listStroke.Transparency = 0.6
    listStroke.Parent = list

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = list

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 4)
    listPadding.PaddingBottom = UDim.new(0, 4)
    listPadding.PaddingLeft = UDim.new(0, 4)
    listPadding.PaddingRight = UDim.new(0, 4)
    listPadding.Parent = list

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, -8, 0, 26)
        optBtn.BackgroundColor3 = Colors.BackgroundLighter
        optBtn.BackgroundTransparency = 0.98
        optBtn.BorderSizePixel = 0
        optBtn.Text = "> " .. opt
        optBtn.TextColor3 = Colors.TextSecondary
        optBtn.Font = MinecraftFonts.Minecraft
        optBtn.TextSize = 12
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.AutoButtonColor = false
        optBtn.ZIndex = 201
        optBtn.Parent = list
        applyMinecraftStyle(optBtn, "Minecraft", 12)

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn

        self:_connect(optBtn.MouseButton1Click, function()
            selected.Text = opt
            isOpen = false
            list.Visible = false
            arrow.Text = "v"
            playTween(stroke, TweenInfo_Fast, {Color = Colors.Border})
            if callback then callback(opt) end
        end)

        self:_connect(optBtn.MouseEnter, function()
            playTween(optBtn, TweenInfo_Fast, {BackgroundTransparency = 0, BackgroundColor3 = Colors.AccentDark})
            playTween(optBtn, TweenInfo_Fast, {TextColor3 = Colors.Text})
        end)

        self:_connect(optBtn.MouseLeave, function()
            playTween(optBtn, TweenInfo_Fast, {BackgroundTransparency = 1})
            playTween(optBtn, TweenInfo_Fast, {TextColor3 = Colors.TextSecondary})
        end)
    end

    local isOpen = false

    -- Instantly close this dropdown (no animation, used when scrolling)
    local function forceClose()
        if not isOpen then return end
        isOpen = false
        arrow.Text = "v"
        pcall(function() playTween(stroke, TweenInfo_Fast, {Color = Colors.Border}) end)
        list.Visible = false
    end

    local function openList()
        -- Close every other dropdown immediately
        for _, closer in ipairs(self.dropdownClosers) do
            if closer.forceClose ~= forceClose then
                closer.forceClose()
            end
        end

        -- Recompute absolute position every time (user may have scrolled)
        local absPos = box.AbsolutePosition
        local absSize = box.AbsoluteSize
        list.Size = UDim2.new(0, absSize.X, 0, listHeight)
        list.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y)
        list.BackgroundTransparency = 0.3
        list.Visible = true

        playTween(list, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4),
            BackgroundTransparency = 0,
        })
    end

    local function closeList()
        local absPos = box.AbsolutePosition
        local absSize = box.AbsoluteSize
        playTween(list, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y),
            BackgroundTransparency = 1,
        })
        task.delay(0.13, function() list.Visible = false end)
    end

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 12
    toggleBtn.Parent = box

    self:_connect(toggleBtn.MouseEnter, function()
        playTween(box, TweenInfo_Fast, {BackgroundColor3 = Colors.BackgroundHover})
    end)
    self:_connect(toggleBtn.MouseLeave, function()
        playTween(box, TweenInfo_Fast, {BackgroundColor3 = Colors.BackgroundLighter})
    end)

    self:_connect(toggleBtn.MouseButton1Click, function()
        isOpen = not isOpen
        arrow.Text = isOpen and "^" or "v"
        playTween(stroke, TweenInfo_Fast, {Color = isOpen and Colors.Accent or Colors.Border})
        if isOpen then
            openList()
        else
            closeList()
        end
    end)

    -- Close when clicking outside
    self:_connect(Services.UserInputService.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
            local mousePos = Services.UserInputService:GetMouseLocation()
            local lp = list.AbsolutePosition
            local ls = list.AbsoluteSize
            local inList = mousePos.X >= lp.X and mousePos.X <= lp.X + ls.X
                       and mousePos.Y >= lp.Y and mousePos.Y <= lp.Y + ls.Y
            local bp = box.AbsolutePosition
            local bs = box.AbsoluteSize
            local inBox = mousePos.X >= bp.X and mousePos.X <= bp.X + bs.X
                      and mousePos.Y >= bp.Y and mousePos.Y <= bp.Y + bs.Y
            if not inList and not inBox then
                isOpen = false
                arrow.Text = "v"
                playTween(stroke, TweenInfo_Fast, {Color = Colors.Border})
                closeList()
            end
        end
    end)

    table.insert(self.openDropdowns, list)
    table.insert(self.dropdownClosers, {forceClose = forceClose})

    return {Set = function(_, v) selected.Text = v end, Get = function() return selected.Text end}
end

function UI:CreateColorPicker(parent, text, default, callback)
    local picker = Instance.new("Frame")
    picker.Size = UDim2.new(1, 0, 0, 26)
    picker.BackgroundTransparency = 1
    picker.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextSecondary
    label.Font = MinecraftFonts.Minecraft
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = picker
    applyMinecraftStyle(label, "Minecraft", 12)
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 40, 0, 18)
    preview.Position = UDim2.new(1, -40, 0.5, -9)
    preview.BackgroundColor3 = default
    preview.BorderColor3 = Color3.new(0, 0, 0)
    preview.BorderSizePixel = 2
    preview.Parent = picker
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = preview
    
    local h, s, v = Color3.toHSV(default)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = picker
    
    self:_connect(btn.MouseButton1Click, function()
        -- Simple color cycle for now (can be expanded to full picker)
        h = (h + 0.1) % 1
        local c = Color3.fromHSV(h, s, v)
        preview.BackgroundColor3 = c
        if callback then callback(c) end
    end)
    
    return {Set = function(_, c) preview.BackgroundColor3 = c; h, s, v = Color3.toHSV(c) end, Get = function() return preview.BackgroundColor3 end}
end

function UI:CreateButton(parent, text, callback, style)
    style = style or "default"

    local baseColor   = style == "danger"  and Color3.fromRGB(50, 10, 10)
                     or style == "success" and Color3.fromRGB(10, 50, 10)
                     or Color3.fromRGB(20, 20, 20)
    local accentColor = style == "danger"  and Colors.Danger
                     or style == "success" and Colors.Success
                     or Colors.Accent

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = baseColor
    button.BorderColor3 = accentColor
    button.BorderSizePixel = 2
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextSecondary
    label.Font = MinecraftFonts.Header
    label.TextSize = 13
    label.Parent = button
    applyMinecraftStyle(label, "Header", 13)

    self:_connect(button.MouseEnter, function()
        playTween(button, TweenInfo_Fast, {BackgroundColor3 = accentColor, BorderColor3 = Colors.Text})
        playTween(label,  TweenInfo_Fast, {TextColor3 = Colors.Text})
    end)
    self:_connect(button.MouseLeave, function()
        playTween(button, TweenInfo_Fast, {BackgroundColor3 = baseColor, BorderColor3 = accentColor})
        playTween(label,  TweenInfo_Fast, {TextColor3 = Colors.TextSecondary})
    end)
    self:_connect(button.MouseButton1Down, function()
        playTween(button, TweenInfo_Fast, {Size = UDim2.new(1, 0, 0, 27)})
    end)
    self:_connect(button.MouseButton1Up, function()
        playTween(button, TweenInfo_Fast, {Size = UDim2.new(1, 0, 0, 30)})
    end)
    self:_connect(button.MouseButton1Click, callback)

    return button
end

function UI:SetVisible(visible)
    if self.visible == visible then 
        print("[UI] SetVisible skipped - already", visible)
        return end
    self.visible = visible
    
    print("[UI] SetVisible called with:", visible)
    
    if visible then
        self.screenGui.Enabled = true
        self.mainFrame.Visible = true
        print("[UI] ScreenGui enabled, calling AnimateOpen")
        self:AnimateOpen()
    else
        print("[UI] Closing menu")
        self:AnimateClose(function()
            self.screenGui.Enabled = false
            self.mainFrame.Visible = false
        end)
    end
end

function UI:Destroy()
    for _, conn in ipairs(self.connections) do pcall(function() conn:Disconnect() end) end
    pcall(function() self.screenGui:Destroy() end)
end

-- ============================================
-- ESP SYSTEM (OPTIMIZED)
-- ============================================
local ESPObject = {}
ESPObject.__index = ESPObject

local BONE_CONNECTIONS = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

function ESPObject.new(player)
    local self = setmetatable({}, ESPObject)
    self.player = player
    self.drawings = {}
    self.skeletonLines = {}
    self.highlight = nil
    self:_createDrawings()
    return self
end

function ESPObject:_createDrawings()
    -- Box outline
    self.drawings.boxOutline = Drawing.new("Square")
    self.drawings.boxOutline.Visible = false
    self.drawings.boxOutline.Color = Color3.new(0, 0, 0)
    self.drawings.boxOutline.Thickness = 3
    self.drawings.boxOutline.Filled = false
    
    -- Box
    self.drawings.box = Drawing.new("Square")
    self.drawings.box.Visible = false
    self.drawings.box.Thickness = 1
    self.drawings.box.Filled = false
    
    -- Name
    self.drawings.name = Drawing.new("Text")
    self.drawings.name.Visible = false
    self.drawings.name.Size = 13
    self.drawings.name.Center = true
    self.drawings.name.Outline = true
    self.drawings.name.Font = 2
    
    -- Distance
    self.drawings.distance = Drawing.new("Text")
    self.drawings.distance.Visible = false
    self.drawings.distance.Size = 12
    self.drawings.distance.Center = true
    self.drawings.distance.Outline = true
    self.drawings.distance.Font = 2
    
    -- Health bar
    self.drawings.healthBg = Drawing.new("Square")
    self.drawings.healthBg.Visible = false
    self.drawings.healthBg.Filled = true
    self.drawings.healthBg.Thickness = 1
    
    self.drawings.healthFill = Drawing.new("Square")
    self.drawings.healthFill.Visible = false
    self.drawings.healthFill.Filled = true
    self.drawings.healthFill.Thickness = 1
    
    -- Snapline
    self.drawings.snapline = Drawing.new("Line")
    self.drawings.snapline.Visible = false
    self.drawings.snapline.Thickness = 1
    
    -- Skeleton lines
    for _ = 1, #BONE_CONNECTIONS do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        table.insert(self.skeletonLines, line)
    end
end

function ESPObject:update(camera, localChar, settings)
    local char = self.player.Character
    if not char then self:hide() return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    
    if not hum or not root or not head or hum.Health <= 0 then self:hide() return end
    
    local lRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not lRoot then self:hide() return end
    
    local dist = (root.Position - lRoot.Position).Magnitude
    local sp, onScreen = camera:WorldToViewportPoint(root.Position)
    
    if not onScreen then self:hide() return end
    
    -- Calculate box dimensions
    local hsp = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local fsp = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
    
    local boxH = math.abs(hsp.Y - fsp.Y)
    local boxW = boxH * 0.6
    local boxX = sp.X - boxW / 2
    local boxY = hsp.Y
    
    -- Box
    if settings.boxEnabled then
        if settings.outlineEnabled then
            self.drawings.boxOutline.Size = Vector2.new(boxW, boxH)
            self.drawings.boxOutline.Position = Vector2.new(boxX, boxY)
            self.drawings.boxOutline.Visible = true
        end
        self.drawings.box.Size = Vector2.new(boxW, boxH)
        self.drawings.box.Position = Vector2.new(boxX, boxY)
        self.drawings.box.Color = settings.boxColor
        self.drawings.box.Visible = true
    else
        self.drawings.box.Visible = false
        self.drawings.boxOutline.Visible = false
    end
    
    -- Name
    if settings.nameEnabled then
        self.drawings.name.Text = self.player.DisplayName
        self.drawings.name.Position = Vector2.new(sp.X, boxY - 16)
        self.drawings.name.Color = settings.nameColor
        self.drawings.name.Visible = true
    else
        self.drawings.name.Visible = false
    end
    
    -- Distance
    if settings.distanceEnabled then
        self.drawings.distance.Text = string.format("[%dm]", math.floor(dist))
        self.drawings.distance.Position = Vector2.new(sp.X, fsp.Y + 2)
        self.drawings.distance.Color = settings.distanceColor
        self.drawings.distance.Visible = true
    else
        self.drawings.distance.Visible = false
    end
    
    -- Health bar
    if settings.healthBarEnabled then
        local hf = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local barW = 3
        local barX = boxX - barW - 4
        
        self.drawings.healthBg.Size = Vector2.new(barW, boxH)
        self.drawings.healthBg.Position = Vector2.new(barX, boxY)
        self.drawings.healthBg.Color = Color3.fromRGB(30, 30, 30)
        self.drawings.healthBg.Visible = true
        
        local fillH = boxH * hf
        self.drawings.healthFill.Size = Vector2.new(barW, fillH)
        self.drawings.healthFill.Position = Vector2.new(barX, boxY + boxH - fillH)
        self.drawings.healthFill.Color = Color3.fromRGB(255 - hf * 255, hf * 255, 0)
        self.drawings.healthFill.Visible = true
    else
        self.drawings.healthBg.Visible = false
        self.drawings.healthFill.Visible = false
    end
    
    -- Snapline
    if settings.snaplineEnabled then
        local vp = camera.ViewportSize
        local fx, fy = vp.X / 2, vp.Y
        if settings.snaplineMode == "Top" then fy = 0
        elseif settings.snaplineMode == "Center" then fy = vp.Y / 2 end
        
        self.drawings.snapline.From = Vector2.new(fx, fy)
        self.drawings.snapline.To = Vector2.new(sp.X, fsp.Y)
        self.drawings.snapline.Color = settings.snaplineColor
        self.drawings.snapline.Visible = true
    else
        self.drawings.snapline.Visible = false
    end
    
    -- Skeleton
    if settings.skeletonEnabled then
        self:_updateSkeleton(char, camera, settings.skeletonColor)
    else
        for _, line in ipairs(self.skeletonLines) do line.Visible = false end
    end
    
    -- Highlight
    if settings.highlightEnabled then
        if not self.highlight then
            self.highlight = Instance.new("Highlight")
            self.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            self.highlight.Parent = char
        end
        self.highlight.Adornee = char
        self.highlight.FillColor = settings.highlightFillColor
        self.highlight.OutlineColor = settings.highlightOutlineColor
        self.highlight.FillTransparency = settings.highlightFillTransparency
        self.highlight.OutlineTransparency = settings.highlightOutlineTransparency
        self.highlight.Enabled = true
    elseif self.highlight then
        self.highlight.Enabled = false
    end
end

function ESPObject:_updateSkeleton(char, camera, color)
    local r6Map = {
        Head = "Head", UpperTorso = "Torso", LowerTorso = "Torso",
        LeftUpperArm = "Left Arm", LeftLowerArm = "Left Arm", LeftHand = "Left Arm",
        RightUpperArm = "Right Arm", RightLowerArm = "Right Arm", RightHand = "Right Arm",
        LeftUpperLeg = "Left Leg", LeftLowerLeg = "Left Leg", LeftFoot = "Left Leg",
        RightUpperLeg = "Right Leg", RightLowerLeg = "Right Leg", RightFoot = "Right Leg",
    }
    
    local positions = {}
    for _, boneName in ipairs({"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
        local part = char:FindFirstChild(boneName) or char:FindFirstChild(r6Map[boneName] or "")
        if part then
            local sp, onScreen = camera:WorldToViewportPoint(part.Position)
            if onScreen then
                positions[boneName] = Vector2.new(sp.X, sp.Y)
            end
        end
    end
    
    for i, conn in ipairs(BONE_CONNECTIONS) do
        local from, to = positions[conn[1]], positions[conn[2]]
        if from and to then
            self.skeletonLines[i].From = from
            self.skeletonLines[i].To = to
            self.skeletonLines[i].Color = color
            self.skeletonLines[i].Visible = true
        else
            self.skeletonLines[i].Visible = false
        end
    end
end

function ESPObject:hide()
    for _, drawing in pairs(self.drawings) do drawing.Visible = false end
    for _, line in ipairs(self.skeletonLines) do line.Visible = false end
    if self.highlight then self.highlight.Enabled = false end
end

function ESPObject:destroy()
    for _, drawing in pairs(self.drawings) do pcall(function() drawing:Remove() end) end
    for _, line in ipairs(self.skeletonLines) do pcall(function() line:Remove() end) end
    if self.highlight then pcall(function() self.highlight:Destroy() end) end
end

-- ============================================
-- AIMBOT SYSTEM
-- ============================================
local AimbotSystem = {}
AimbotSystem.__index = AimbotSystem

local KEY_MAP = {
    MouseButton1 = Enum.UserInputType.MouseButton1,
    MouseButton2 = Enum.UserInputType.MouseButton2,
    MouseButton3 = Enum.UserInputType.MouseButton3,
    Q = Enum.KeyCode.Q, E = Enum.KeyCode.E, X = Enum.KeyCode.X,
    C = Enum.KeyCode.C, F = Enum.KeyCode.F, R = Enum.KeyCode.R,
    T = Enum.KeyCode.T, V = Enum.KeyCode.V, Z = Enum.KeyCode.Z,
}

local MOUSE_KEYS = {MouseButton1 = true, MouseButton2 = true, MouseButton3 = true}

function AimbotSystem.new()
    local self = setmetatable({}, AimbotSystem)
    self.fovCircle = Drawing.new("Circle")
    self.fovCircle.Visible = false
    self.fovCircle.Thickness = 1
    self.fovCircle.Filled = false
    self.fovCircle.NumSides = 64
    self.fovCircle.Transparency = 0.8
    
    self.isActive = false
    self.currentTarget = nil
    self.triggerbotCooldown = 0
    
    return self
end

function AimbotSystem:isTeammate(player)
    if not player.Team or not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

function AimbotSystem:getAimPart(player, bodyAim)
    if not player.Character then return nil end
    local char = player.Character

    -- "Nearest" mode: pick the part whose screen position is closest to the mouse
    if bodyAim == "Nearest" then
        local cam = Services.Workspace.CurrentCamera
        local mousePos = Services.UserInputService:GetMouseLocation()
        local best, bestDist = nil, math.huge

        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = part
                    end
                end
            end
        end
        return best
    end

    -- R15 → R6 fallback map.
    -- If a named R15 part is missing (R6 rig), use the equivalent R6 part.
    local R6_FALLBACK = {
        UpperTorso       = "Torso",
        LowerTorso       = "Torso",
        Neck             = "Torso",     -- R6 has no Neck part
        LeftUpperArm     = "Left Arm",
        LeftLowerArm     = "Left Arm",
        LeftHand         = "Left Arm",
        RightUpperArm    = "Right Arm",
        RightLowerArm    = "Right Arm",
        RightHand        = "Right Arm",
        LeftUpperLeg     = "Left Leg",
        LeftLowerLeg     = "Left Leg",
        LeftFoot         = "Left Leg",
        RightUpperLeg    = "Right Leg",
        RightLowerLeg    = "Right Leg",
        RightFoot        = "Right Leg",
        -- R6 "Torso" alias keeps the old behaviour
        Torso            = "Torso",
    }

    -- Try the exact name first; if missing, try the R6 fallback
    local part = char:FindFirstChild(bodyAim)
    if not part and R6_FALLBACK[bodyAim] then
        part = char:FindFirstChild(R6_FALLBACK[bodyAim])
    end
    return part
end

function AimbotSystem:isVisible(part)
    local cam = Services.Workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local dir = part.Position - origin
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {}
    if LocalPlayer.Character then table.insert(exclude, LocalPlayer.Character) end
    if part.Parent then table.insert(exclude, part.Parent) end
    params.FilterDescendantsInstances = exclude
    
    return Services.Workspace:Raycast(origin, dir, params) == nil
end

function AimbotSystem:getTarget(settings)
    if settings.stickyTarget and self.currentTarget then
        local char = self.currentTarget.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local aimPart = self:getAimPart(self.currentTarget, settings.bodyAim)
                if aimPart then
                    local cam = Services.Workspace.CurrentCamera
                    local sp, onScreen = cam:WorldToViewportPoint(aimPart.Position)
                    if onScreen then
                        local mousePos = Services.UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                        if dist <= settings.fov then
                            if not settings.wallCheck or self:isVisible(aimPart) then
                                return self.currentTarget
                            end
                        end
                    end
                end
            end
        end
    end
    
    local cam = Services.Workspace.CurrentCamera
    local mousePos = Services.UserInputService:GetMouseLocation()
    local best, bestDist = nil, settings.fov
    
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if settings.teamCheck and self:isTeammate(player) then continue end
        if not player.Character then continue end
        
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local aimPart = self:getAimPart(player, settings.bodyAim)
        if not aimPart then continue end
        
        local sp, onScreen = cam:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
        if dist > bestDist then continue end
        
        if settings.wallCheck and not self:isVisible(aimPart) then continue end
        
        bestDist = dist
        best = player
    end
    
    return best
end

function AimbotSystem:update(settings, delta)
    local cam = Services.Workspace.CurrentCamera
    local mousePos = Services.UserInputService:GetMouseLocation()
    
    -- FOV Circle
    if settings.enabled and settings.showFov then
        self.fovCircle.Position = mousePos
        self.fovCircle.Radius = settings.fov
        self.fovCircle.Color = settings.fovColor
        self.fovCircle.Visible = true
    else
        self.fovCircle.Visible = false
    end
    
    -- Triggerbot
    if settings.enabled and settings.triggerbotEnabled then
        self:processTriggerbot(settings, cam)
    end
    
    -- Aimbot
    if not settings.enabled or not self.isActive then return end
    
    local target = self:getTarget(settings)
    if not target then
        self.currentTarget = nil
        return
    end
    
    self.currentTarget = target
    local aimPart = self:getAimPart(target, settings.bodyAim)
    if not aimPart then return end
    
    local aimPos = aimPart.Position
    if settings.prediction > 0 then
        local vel = aimPart.AssemblyLinearVelocity or Vector3.zero
        aimPos = aimPos + vel * settings.prediction
    end
    
    local smooth = math.max(settings.smoothness, 1)
    local alpha = 1 / smooth
    
    if settings.lookAtView then
        local cf = CFrame.lookAt(cam.CFrame.Position, aimPos)
        cam.CFrame = cam.CFrame:Lerp(cf, alpha)
    else
        local sp = cam:WorldToViewportPoint(aimPos)
        local targetScreen = Vector2.new(sp.X, sp.Y)
        local diff = targetScreen - mousePos
        local moveBy = diff * alpha
        mousemoverel(moveBy.X, moveBy.Y)
    end
end

function AimbotSystem:processTriggerbot(settings, camera)
    local now = tick()
    local delay = settings.triggerbotDelay / 1000
    if now - self.triggerbotCooldown < delay then return end
    
    local centerScreen = camera.ViewportSize / 2
    local tbFov = settings.triggerbotFov
    
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if settings.teamCheck and self:isTeammate(player) then continue end
        if not player.Character then continue end
        
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        for _, partName in ipairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart"}) do
            local part = player.Character:FindFirstChild(partName)
            if not part then continue end
            
            local sp, onScreen = camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            
            local dist = (Vector2.new(sp.X, sp.Y) - centerScreen).Magnitude
            if dist <= tbFov then
                if settings.wallCheck and not self:isVisible(part) then continue end
                
                self.triggerbotCooldown = now
                task.spawn(function()
                    mouse1press()
                    task.wait(0.03 + math.random() * 0.02)
                    mouse1release()
                end)
                return
            end
        end
    end
end

function AimbotSystem:handleInput(input, gpe, settings, isBegin)
    if not settings.enabled then return end
    if isBegin and gpe then return end

    local key = KEY_MAP[settings.activationKey]
    if not key then return end

    local matched = false
    if MOUSE_KEYS[settings.activationKey] then
        matched = input.UserInputType == key
    else
        matched = input.KeyCode == key
    end

    if not matched then return end

    if isBegin then
        self.isActive = true
    else
        self.isActive = false
        if not settings.stickyTarget then
            self.currentTarget = nil
        end
    end
end

function AimbotSystem:destroy()
    pcall(function() self.fovCircle:Remove() end)
end

-- ============================================
-- MISC SYSTEM
-- ============================================
local MiscSystem = {}
MiscSystem.__index = MiscSystem

function MiscSystem.new()
    local self = setmetatable({}, MiscSystem)
    self.flyLoop = nil
    self.noclipLoop = nil
    return self
end

function MiscSystem:toggleFly(enabled, speed)
    if enabled then
        local char = LocalPlayer.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        if not hum or not head then return end
        
        hum.PlatformStand = true
        head.Anchored = true
        
        self.flyLoop = Services.RunService.Heartbeat:Connect(function(dt)
            local c = LocalPlayer.Character
            if not c then return end
            
            local h = c:FindFirstChildOfClass("Humanoid")
            local hd = c:FindFirstChild("Head")
            if not h or not hd then return end
            
            local moveDir = h.MoveDirection * (speed * dt)
            local headCF = hd.CFrame
            local cam = Services.Workspace.CurrentCamera
            local camCF = cam.CFrame
            
            local camOffset = headCF:ToObjectSpace(camCF).Position
            camCF = camCF * CFrame.new(-camOffset.X, -camOffset.Y, -camOffset.Z + 1)
            local camPos = camCF.Position
            local headPos = headCF.Position
            
            local objSpaceVel = CFrame.new(camPos, Vector3.new(headPos.X, camPos.Y, headPos.Z)):VectorToObjectSpace(moveDir)
            hd.CFrame = CFrame.new(headPos) * (camCF - camPos) * CFrame.new(objSpaceVel)
        end)
    else
        if self.flyLoop then
            self.flyLoop:Disconnect()
            self.flyLoop = nil
        end
        
        local char = LocalPlayer.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then head.Anchored = false end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end

function MiscSystem:updateNoclip(enabled)
    if not enabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

function MiscSystem:updateHitbox(settings)
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if settings.teamCheck and player.Team == LocalPlayer.Team then continue end
        if not player.Character then continue end
        
        local part = player.Character:FindFirstChild(settings.part)
        if not part then continue end
        
        if settings.enabled then
            part.Size = Vector3.new(settings.size, settings.size, settings.size)
            part.CanCollide = false
            
            if settings.visible then
                part.Transparency = settings.transparency
                part.Material = Enum.Material.Neon
            else
                part.Transparency = 1
            end
        else
            -- Reset to default
            if settings.part == "HumanoidRootPart" then
                part.Size = Vector3.new(2, 2, 1)
            else
                part.Size = Vector3.new(1.2, 1.2, 1.2)
            end
            part.Transparency = 1
        end
    end
end

function MiscSystem:updateWalkSpeed(speed, loop)
    if not loop then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speed
    end
end

function MiscSystem:destroy()
    if self.flyLoop then
        self.flyLoop:Disconnect()
    end
end

-- ============================================
-- MAIN APPLICATION
-- ============================================
local App = {}
App.__index = App

function App.new()
    local self = setmetatable({}, App)
    
    self.ui = UI.new()
    self.espObjects = {}
    self.aimbot = AimbotSystem.new()
    self.misc = MiscSystem.new()
    self.uiElements = {}  -- Store references to UI elements for config binding
    
    self:_buildUI()
    self:_setupESP()
    self:_setupAimbot()
    self:_setupMisc()
    self:_setupHotkeys()
    
    -- Load config after short delay
    task.spawn(function()
        task.wait(0.5)
        loadConfig()
        self:_bindConfigToUI()  -- Bind UI elements to ConfigData
        self:_applyConfig()     -- Then apply values
    end)
    
    return self
end

function App:_buildUI()
    -- Create tabs
    local visualsContent = self.ui:AddTab("VISUALS")
    local aimbotContent = self.ui:AddTab("AIMBOT")
    local miscContent = self.ui:AddTab("MISC")
    local configContent = self.ui:AddTab("CONFIG")
    
    -- VISUALS TAB
    local espGeneral = self.ui:AddSection(visualsContent, "ESP General")
    self.espToggle = self.ui:CreateToggle(espGeneral, "Enable ESP", ConfigData.esp.enabled, function(v) ConfigData.esp.enabled = v end)
    self.ui.boxToggle = self.ui:CreateToggle(espGeneral, "Box ESP", ConfigData.esp.boxEnabled, function(v) ConfigData.esp.boxEnabled = v end)
    self.ui.dropdownBoxType = self.ui:CreateDropdown(espGeneral, "Box Type", {"Standard", "Corner", "Rounded", "Dashed"}, ConfigData.esp.boxType, function(v) ConfigData.esp.boxType = v end)
    self.ui.outlineToggle = self.ui:CreateToggle(espGeneral, "Box Outline", ConfigData.esp.outlineEnabled, function(v) ConfigData.esp.outlineEnabled = v end)
    self.ui.nameToggle = self.ui:CreateToggle(espGeneral, "Name ESP", ConfigData.esp.nameEnabled, function(v) ConfigData.esp.nameEnabled = v end)
    self.ui.distanceToggle = self.ui:CreateToggle(espGeneral, "Distance ESP", ConfigData.esp.distanceEnabled, function(v) ConfigData.esp.distanceEnabled = v end)
    self.ui.healthBarToggle = self.ui:CreateToggle(espGeneral, "Health Bar", ConfigData.esp.healthBarEnabled, function(v) ConfigData.esp.healthBarEnabled = v end)
    self.ui:CreateToggle(espGeneral, "Team Check", ConfigData.esp.teamCheck, function(v) ConfigData.esp.teamCheck = v end)
    
    local espVisual = self.ui:AddSection(visualsContent, "Visual Effects")
    self.ui.skeletonToggle = self.ui:CreateToggle(espVisual, "Skeleton", ConfigData.esp.skeletonEnabled, function(v) ConfigData.esp.skeletonEnabled = v end)
    self.ui.colorSkeletonColor = self.ui:CreateColorPicker(espVisual, "Skeleton Color", ConfigData.esp.skeletonColor, function(c) ConfigData.esp.skeletonColor = c end)
    self.ui.highlightToggle = self.ui:CreateToggle(espVisual, "Highlight Chams", ConfigData.esp.highlightEnabled, function(v) ConfigData.esp.highlightEnabled = v end)
    self.ui.colorHighlightColor = self.ui:CreateColorPicker(espVisual, "Fill Color", ConfigData.esp.highlightFillColor, function(c) ConfigData.esp.highlightFillColor = c end)
    self.ui.sliderFillTransparency = self.ui:CreateSlider(espVisual, "Fill Transparency", 0, 100, ConfigData.esp.highlightFillTransparency * 100, function(v) ConfigData.esp.highlightFillTransparency = v / 100 end, "%")
    self.ui.snaplineToggle = self.ui:CreateToggle(espVisual, "Snaplines", ConfigData.esp.snaplineEnabled, function(v) ConfigData.esp.snaplineEnabled = v end)
    self.ui.dropdownSnaplineMode = self.ui:CreateDropdown(espVisual, "Snapline Origin", {"Bottom", "Center", "Top"}, ConfigData.esp.snaplineMode, function(v) ConfigData.esp.snaplineMode = v end)
    
    -- AIMBOT TAB
    local aimGeneral = self.ui:AddSection(aimbotContent, "Aimbot Settings")
    self.aimbotToggle = self.ui:CreateToggle(aimGeneral, "Enable Aimbot", ConfigData.aimbot.enabled, function(v) ConfigData.aimbot.enabled = v end)
    self.ui.sliderFOV = self.ui:CreateSlider(aimGeneral, "FOV", 10, 500, ConfigData.aimbot.fov, function(v) ConfigData.aimbot.fov = v end, "px")
    self.ui.showFovToggle = self.ui:CreateToggle(aimGeneral, "Show FOV Circle", ConfigData.aimbot.showFov, function(v) ConfigData.aimbot.showFov = v end)
    self.ui.sliderSmoothness = self.ui:CreateSlider(aimGeneral, "Smoothness", 1, 50, ConfigData.aimbot.smoothness, function(v) ConfigData.aimbot.smoothness = v end)
    self.ui.dropdownActivationKey = self.ui:CreateDropdown(aimGeneral, "Activation Key", {"MouseButton1", "MouseButton2", "MouseButton3", "Q", "E", "X", "C", "F"}, ConfigData.aimbot.activationKey, function(v) ConfigData.aimbot.activationKey = v end)
    
    local aimOptions = self.ui:AddSection(aimbotContent, "Options")
    self.ui.dropdownBodyAim = self.ui:CreateDropdown(aimOptions, "Hitboxes", {"Head", "Neck", "UpperTorso", "LowerTorso", "Torso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg", "HumanoidRootPart", "Nearest"}, ConfigData.aimbot.bodyAim, function(v) ConfigData.aimbot.bodyAim = v end)
    self.ui:CreateToggle(aimOptions, "Wall Check", ConfigData.aimbot.wallCheck, function(v) ConfigData.aimbot.wallCheck = v end)
    self.ui:CreateToggle(aimOptions, "Team Check", ConfigData.aimbot.teamCheck, function(v) ConfigData.aimbot.teamCheck = v end)
    self.ui:CreateToggle(aimOptions, "Sticky Target", ConfigData.aimbot.stickyTarget, function(v) ConfigData.aimbot.stickyTarget = v end)
    self.ui.sliderPrediction = self.ui:CreateSlider(aimOptions, "Prediction", 0, 200, ConfigData.aimbot.prediction * 1000, function(v) ConfigData.aimbot.prediction = v / 1000 end, "ms")
    
    local aimTrigger = self.ui:AddSection(aimbotContent, "Triggerbot")
    self.ui.triggerbotToggle = self.ui:CreateToggle(aimTrigger, "Enable Triggerbot", ConfigData.aimbot.triggerbotEnabled, function(v) ConfigData.aimbot.triggerbotEnabled = v end)
    self.ui.sliderTriggerbotDelay = self.ui:CreateSlider(aimTrigger, "Delay", 0, 500, ConfigData.aimbot.triggerbotDelay, function(v) ConfigData.aimbot.triggerbotDelay = v end, "ms")
    self.ui.sliderTriggerbotFOV = self.ui:CreateSlider(aimTrigger, "FOV", 5, 200, ConfigData.aimbot.triggerbotFov, function(v) ConfigData.aimbot.triggerbotFov = v end, "px")
    
    -- MISC TAB
    local miscMovement = self.ui:AddSection(miscContent, "Movement")
    self.ui.sliderWalkSpeed = self.ui:CreateSlider(miscMovement, "Walk Speed", 16, 500, ConfigData.misc.walkSpeed, function(v)
        ConfigData.misc.walkSpeed = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end)
    self.ui:CreateToggle(miscMovement, "Loop WalkSpeed", ConfigData.misc.loopWalkSpeed, function(v)
        ConfigData.misc.loopWalkSpeed = v
    end)
    self.ui:CreateToggle(miscMovement, "Infinite Jump", ConfigData.misc.infiniteJump, function(v)
        ConfigData.misc.infiniteJump = v
    end)
    self.flyToggle = self.ui:CreateToggle(miscMovement, "Fly", ConfigData.misc.flyEnabled, function(v)
        ConfigData.misc.flyEnabled = v
        self.misc:toggleFly(v, ConfigData.misc.flySpeed)
    end)
    self.ui.sliderFlySpeed = self.ui:CreateSlider(miscMovement, "Fly Speed", 1, 300, ConfigData.misc.flySpeed, function(v)
        ConfigData.misc.flySpeed = v
        -- Update fly speed instantly if flying
        if ConfigData.misc.flyEnabled then
            self.misc:toggleFly(false)
            self.misc:toggleFly(true, v)
        end
    end)
    self.ui:CreateToggle(miscMovement, "Noclip", ConfigData.misc.noclipEnabled, function(v)
        ConfigData.misc.noclipEnabled = v
    end)
    
    local miscHitbox = self.ui:AddSection(miscContent, "Hitbox Expander")
    self.hitboxToggle = self.ui:CreateToggle(miscHitbox, "Enable", ConfigData.misc.hitboxEnabled, function(v) ConfigData.misc.hitboxEnabled = v end)
    self.ui.sliderHitboxSize = self.ui:CreateSlider(miscHitbox, "Size", 1, 50, ConfigData.misc.hitboxSize, function(v) ConfigData.misc.hitboxSize = v end)
    self.ui.sliderHitboxTransparency = self.ui:CreateSlider(miscHitbox, "Transparency", 0, 100, ConfigData.misc.hitboxTransparency * 100, function(v) ConfigData.misc.hitboxTransparency = v / 100 end, "%")
    self.ui:CreateToggle(miscHitbox, "Visible", ConfigData.misc.hitboxVisible, function(v) ConfigData.misc.hitboxVisible = v end)
    self.ui.dropdownHitboxPart = self.ui:CreateDropdown(miscHitbox, "Target Part", {"HumanoidRootPart", "Head"}, ConfigData.misc.hitboxPart, function(v) ConfigData.misc.hitboxPart = v end)
    self.ui:CreateToggle(miscHitbox, "Team Check", ConfigData.misc.hitboxTeamCheck, function(v) ConfigData.misc.hitboxTeamCheck = v end)
    
    -- CONFIG TAB
    local configActions = self.ui:AddSection(configContent, "Actions")
    self.ui:CreateButton(configActions, "💾 Save Config", function()
        saveConfig()
        self:notify("Config Saved", "Configuration saved successfully!")
    end, "success")
    self.ui:CreateButton(configActions, "📂 Load Config", function()
        loadConfig()
        self:_applyConfig()
        self:notify("Config Loaded", "Configuration loaded successfully!")
    end)
    self.ui:CreateButton(configActions, "🔄 Reset to Defaults", function()
        resetConfig()
        self:_applyConfig()
        self:notify("Config Reset", "Configuration reset to defaults!")
    end, "danger")
    
    local configInfo = self.ui:AddSection(configContent, "Information")
    local placeName = "Unknown"
    pcall(function() placeName = Services.MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    
    local execName = "Unknown"
    pcall(function()
        local name, ver = identifyexecutor()
        execName = name .. (ver and (" " .. ver) or "")
    end)
    
    self.ui:CreateButton(configInfo, "Place: " .. placeName, function() end)
    self.ui:CreateButton(configInfo, "Executor: " .. execName, function() end)
    self.ui:CreateButton(configInfo, "User: " .. LocalPlayer.Name, function() end)
    
    -- Set first tab active
    self.ui:SetActiveTab("VISUALS")
end

function App:_applyConfig()
    print("🔄 Applying config to UI...")
    
    -- Apply toggles
    if self.espToggle then self.espToggle:Set(ConfigData.esp.enabled) end
    if self.aimbotToggle then self.aimbotToggle:Set(ConfigData.aimbot.enabled) end
    if self.flyToggle then self.flyToggle:Set(ConfigData.misc.flyEnabled) end
    if self.hitboxToggle then self.hitboxToggle:Set(ConfigData.misc.hitboxEnabled) end
    
    -- Apply sliders
    if self.ui.sliderWalkSpeed then self.ui.sliderWalkSpeed:Set(ConfigData.misc.walkSpeed) end
    if self.ui.sliderFlySpeed then self.ui.sliderFlySpeed:Set(ConfigData.misc.flySpeed) end
    if self.ui.sliderHitboxSize then self.ui.sliderHitboxSize:Set(ConfigData.misc.hitboxSize) end
    if self.ui.sliderHitboxTransparency then self.ui.sliderHitboxTransparency:Set(ConfigData.misc.hitboxTransparency * 100) end
    if self.ui.sliderFOV then self.ui.sliderFOV:Set(ConfigData.aimbot.fov) end
    if self.ui.sliderSmoothness then self.ui.sliderSmoothness:Set(ConfigData.aimbot.smoothness) end
    if self.ui.sliderTriggerbotDelay then self.ui.sliderTriggerbotDelay:Set(ConfigData.aimbot.triggerbotDelay) end
    if self.ui.sliderTriggerbotFOV then self.ui.sliderTriggerbotFOV:Set(ConfigData.aimbot.triggerbotFov) end
    if self.ui.sliderPrediction then self.ui.sliderPrediction:Set(ConfigData.aimbot.prediction * 1000) end
    if self.ui.sliderFillTransparency then self.ui.sliderFillTransparency:Set(ConfigData.esp.highlightFillTransparency * 100) end
    
    -- Apply dropdowns
    if self.ui.dropdownBoxType then self.ui.dropdownBoxType:Set(ConfigData.esp.boxType) end
    if self.ui.dropdownSnaplineMode then self.ui.dropdownSnaplineMode:Set(ConfigData.esp.snaplineMode) end
    if self.ui.dropdownActivationKey then self.ui.dropdownActivationKey:Set(ConfigData.aimbot.activationKey) end
    if self.ui.dropdownBodyAim then self.ui.dropdownBodyAim:Set(ConfigData.aimbot.bodyAim) end
    if self.ui.dropdownHitboxPart then self.ui.dropdownHitboxPart:Set(ConfigData.misc.hitboxPart) end
    
    -- Apply colors (need to update color picker preview)
    -- Note: CreateColorPicker returns an object but doesn't have Set method yet
    
    -- Apply colors
    if self.ui.colorSkeletonColor then self.ui.colorSkeletonColor:Set(ConfigData.esp.skeletonColor) end
    if self.ui.colorHighlightColor then self.ui.colorHighlightColor:Set(ConfigData.esp.highlightFillColor) end
    
    -- Apply fly state
    if ConfigData.misc.flyEnabled then
        self.misc:toggleFly(true, ConfigData.misc.flySpeed)
    else
        self.misc:toggleFly(false)
    end
    
    print("✅ Config applied to UI")
    print("ConfigData saved settings:", ConfigData.esp.enabled, ConfigData.esp.boxEnabled, ConfigData.aimbot.enabled)
end

function App:_bindConfigToUI()
    -- Bind UI elements to ConfigData for real-time sync
    -- ESP
    table.insert(self.uiElements, {type="toggle", ref=self.espToggle, category="esp", key="enabled"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.boxToggle, category="esp", key="boxEnabled"})
    table.insert(self.uiElements, {type="dropdown", ref=self.ui.dropdownBoxType, category="esp", key="boxType"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.outlineToggle, category="esp", key="outlineEnabled"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.nameToggle, category="esp", key="nameEnabled"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.distanceToggle, category="esp", key="distanceEnabled"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.healthBarToggle, category="esp", key="healthBarEnabled"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.skeletonToggle, category="esp", key="skeletonEnabled"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorSkeletonColor, category="esp", key="skeletonColor"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.highlightToggle, category="esp", key="highlightEnabled"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorHighlightColor, category="esp", key="highlightFillColor"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderFillTransparency, category="esp", key="highlightFillTransparency"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.snaplineToggle, category="esp", key="snaplineEnabled"})
    table.insert(self.uiElements, {type="dropdown", ref=self.ui.dropdownSnaplineMode, category="esp", key="snaplineMode"})
    
    -- Aimbot
    table.insert(self.uiElements, {type="toggle", ref=self.aimbotToggle, category="aimbot", key="enabled"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderFOV, category="aimbot", key="fov"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.showFovToggle, category="aimbot", key="showFov"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderSmoothness, category="aimbot", key="smoothness"})
    table.insert(self.uiElements, {type="dropdown", ref=self.ui.dropdownActivationKey, category="aimbot", key="activationKey"})
    table.insert(self.uiElements, {type="dropdown", ref=self.ui.dropdownBodyAim, category="aimbot", key="bodyAim"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.triggerbotToggle, category="aimbot", key="triggerbotEnabled"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderTriggerbotDelay, category="aimbot", key="triggerbotDelay"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderTriggerbotFOV, category="aimbot", key="triggerbotFov"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderPrediction, category="aimbot", key="prediction"})
    
    -- Misc
    table.insert(self.uiElements, {type="toggle", ref=self.flyToggle, category="misc", key="flyEnabled"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderWalkSpeed, category="misc", key="walkSpeed"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderFlySpeed, category="misc", key="flySpeed"})
    table.insert(self.uiElements, {type="toggle", ref=self.hitboxToggle, category="misc", key="hitboxEnabled"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderHitboxSize, category="misc", key="hitboxSize"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderHitboxTransparency, category="misc", key="hitboxTransparency"})
    table.insert(self.uiElements, {type="dropdown", ref=self.ui.dropdownHitboxPart, category="misc", key="hitboxPart"})
end

function App:notify(title, message)
    -- Simple notification
    print(string.format("[%s] %s", title, message))
end

function App:_setupESP()
    local function onPlayerAdded(player)
        if player == LocalPlayer then return end
        self.espObjects[player] = ESPObject.new(player)
    end
    
    local function onPlayerRemoving(player)
        if self.espObjects[player] then
            self.espObjects[player]:destroy()
            self.espObjects[player] = nil
        end
    end
    
    for _, player in ipairs(Services.Players:GetPlayers()) do
        onPlayerAdded(player)
    end
    
    self.ui:_connect(Services.Players.PlayerAdded, onPlayerAdded)
    self.ui:_connect(Services.Players.PlayerRemoving, onPlayerRemoving)
    
    self.ui:_connect(Services.RunService.RenderStepped, function()
        if not ConfigData.esp.enabled then
            for _, obj in pairs(self.espObjects) do obj:hide() end
            return
        end
        
        local cam = Services.Workspace.CurrentCamera
        local localChar = LocalPlayer.Character
        
        for player, obj in pairs(self.espObjects) do
            local isTeammate = ConfigData.esp.teamCheck and player.Team == LocalPlayer.Team
            if not isTeammate then
                obj:update(cam, localChar, ConfigData.esp)
            else
                obj:hide()
            end
        end
    end)
end

function App:_setupAimbot()
    self.ui:_connect(Services.UserInputService.InputBegan, function(input, gpe)
        self.aimbot:handleInput(input, gpe, ConfigData.aimbot, true)
    end)
    
    self.ui:_connect(Services.UserInputService.InputEnded, function(input)
        self.aimbot:handleInput(input, false, ConfigData.aimbot, false)
    end)
    
    self.ui:_connect(Services.RunService.RenderStepped, function(delta)
        self.aimbot:update(ConfigData.aimbot, delta)
    end)
end

function App:_setupMisc()
    -- Infinite Jump
    self.ui:_connect(Services.UserInputService.JumpRequest, function()
        if ConfigData.misc.infiniteJump then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end
    end)
    
    -- Character respawn handling
    self.ui:_connect(LocalPlayer.CharacterAdded, function()
        if ConfigData.misc.flyEnabled then
            task.wait(0.5)
            self.misc:toggleFly(false)
            task.wait(0.1)
            self.misc:toggleFly(true, ConfigData.misc.flySpeed)
        end
    end)
    
    -- Update loops
    self.ui:_connect(Services.RunService.Stepped, function()
        self.misc:updateNoclip(ConfigData.misc.noclipEnabled)
    end)
    
    self.ui:_connect(Services.RunService.Heartbeat, function()
        self.misc:updateWalkSpeed(ConfigData.misc.walkSpeed, ConfigData.misc.loopWalkSpeed)
        self.misc:updateHitbox({
            enabled = ConfigData.misc.hitboxEnabled,
            size = ConfigData.misc.hitboxSize,
            transparency = ConfigData.misc.hitboxTransparency,
            visible = ConfigData.misc.hitboxVisible,
            part = ConfigData.misc.hitboxPart,
            teamCheck = ConfigData.misc.hitboxTeamCheck,
        })
    end)
end

function App:_setupHotkeys()
    self.ui:_connect(Services.UserInputService.InputBegan, function(input, gpe)
        if gpe then return end
        
        if input.KeyCode == Enum.KeyCode.F2 then
            local isVisible = not self.ui.visible
            print("F2 pressed, setting visible to:", isVisible)
            self.ui:SetVisible(isVisible)
        elseif input.KeyCode == Enum.KeyCode.F3 then
            saveConfig()
            self:notify("Config", "Saved!")
        elseif input.KeyCode == Enum.KeyCode.F4 then
            loadConfig()
            self:_applyConfig()
            self:notify("Config", "Loaded!")
        end
    end)
end

function App:destroy()
    self.ui:Destroy()
    self.aimbot:destroy()
    self.misc:destroy()
    
    for _, obj in pairs(self.espObjects) do
        obj:destroy()
    end
end

-- ============================================
-- INITIALIZATION
-- ============================================
if getgenv().BlatantUI_v2 then
    pcall(function() getgenv().BlatantUI_v2:destroy() end)
end

local app = App.new()
getgenv().BlatantUI_v2 = app

print([[
╔════════════════════════════════════════════╗
║           blatant.cat v2.0 loaded!         ║
╠════════════════════════════════════════════╣
║  F2 - Toggle Menu                          ║
║  F3 - Save Config                          ║
║  F4 - Load Config                          ║
╚════════════════════════════════════════════╝
]])
