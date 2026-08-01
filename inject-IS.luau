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
    local service = game:GetService(name)
    if type(cloneref) == "function" then
        local ok, reference = pcall(cloneref, service)
        if ok and reference then return reference end
    end
    return service
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
Services.Lighting = getService("Lighting")

local LocalPlayer = Services.Players.LocalPlayer

-- Helper for table operations not in all Lua versions
local function tableIndexOf(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then return i end
    end
    return nil
end

local function tableFind(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

local function tableRemoveValue(tbl, value)
    local idx = tableIndexOf(tbl, value)
    if idx then
        table.remove(tbl, idx)
        return true
    end
    return false
end

-- Use local functions instead of modifying global table
-- to avoid conflicts with protected environments

-- ============================================
-- COLOR PALETTE (Modern Dark Theme)
-- ============================================
local Colors = {
    Background = Color3.fromRGB(18, 18, 28),
    BackgroundLight = Color3.fromRGB(28, 28, 40),
    BackgroundLighter = Color3.fromRGB(38, 38, 55),
    BackgroundHover = Color3.fromRGB(50, 50, 70),
    Border = Color3.fromRGB(45, 45, 60),
    BorderLight = Color3.fromRGB(80, 80, 100),
    Accent = Color3.fromRGB(88, 196, 255),  -- Nice blue accent
    AccentLight = Color3.fromRGB(120, 220, 255),
    AccentDark = Color3.fromRGB(50, 150, 220),
    AccentGlow = Color3.fromRGB(88, 196, 255),
    Purple = Color3.fromRGB(170, 0, 255),
    PurpleLight = Color3.fromRGB(210, 100, 255),
    Success = Color3.fromRGB(85, 255, 85),  -- Green
    Warning = Color3.fromRGB(255, 200, 50),  -- Gold
    Danger = Color3.fromRGB(255, 80, 80),   -- Red
    DangerLight = Color3.fromRGB(255, 120, 120),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 195),
    TextMuted = Color3.fromRGB(100, 100, 120),
    GradientStart = Color3.fromRGB(88, 196, 255),
    GradientMid = Color3.fromRGB(150, 100, 255),
    GradientEnd = Color3.fromRGB(200, 150, 255),
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
        snaplineEnabled = false,
        snaplineMode = "Bottom",
        teamCheck = false,
        whitelist = {},  -- List of player names to ignore (treat as teammates)
        boxColor = Color3.fromRGB(88, 196, 255),
        outlineColor = Color3.fromRGB(0, 0, 0),
        nameColor = Color3.fromRGB(255, 255, 255),
        skeletonColor = Color3.fromRGB(255, 255, 255),
        snaplineColor = Color3.fromRGB(88, 196, 255),
        distanceColor = Color3.fromRGB(200, 200, 200),
        healthBarColor = Color3.fromRGB(85, 255, 85),
    },
    aimbot = {
        enabled = false,
        teamCheck = false,
        whitelist = {},  -- List of player names to ignore
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
        nightmode = false,
        nightmodeBrightness = 1,
        nightmodePersist = true,
        aspectRatioEnabled = false,
        aspectRatioWidth = 16,
        aspectRatioHeight = 9,
    },
}

local function colorToTable(c)
    return {r = math.floor(c.R * 255 + 0.5), g = math.floor(c.G * 255 + 0.5), b = math.floor(c.B * 255 + 0.5)}
end

local function tableToColor(t)
    return Color3.fromRGB(t.r or 255, t.g or 255, t.b or 255)
end

local function saveConfig()
    ConfigData.aimbot.whitelist = ConfigData.esp.whitelist
    local dataToSave = {}
    
    -- Serialize each category
    for category, settings in pairs(ConfigData) do
        dataToSave[category] = {}
        for key, value in pairs(settings) do
            if typeof(value) == "Color3" then
                dataToSave[category][key] = colorToTable(value)
            elseif type(value) == "table" then
                -- Copy table values (for whitelist arrays)
                dataToSave[category][key] = {}
                for _, v in ipairs(value) do
                    table.insert(dataToSave[category][key], v)
                end
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
                    elseif type(value) == "table" and ConfigData[category][key] and type(ConfigData[category][key]) == "table" then
                        -- Keep the table reference used by whitelist UI and runtime checks.
                        table.clear(ConfigData[category][key])
                        for _, item in ipairs(value) do
                            table.insert(ConfigData[category][key], item)
                        end
                    else
                        ConfigData[category][key] = value
                    end
                end
            end
        end
    end

    -- ESP and Aimbot intentionally share one protected-player list.
    ConfigData.aimbot.whitelist = ConfigData.esp.whitelist
    
    print("✅ [Config] Loaded from " .. CONFIG_FILE)
    return true
end

local function resetConfig()
    -- Store current whitelist before reset
    local currentEspWhitelist = ConfigData.esp.whitelist
    
    ConfigData.esp = {
        enabled = false, boxEnabled = false, boxType = "Standard", outlineEnabled = true,
        skeletonEnabled = false, healthBarEnabled = false, distanceEnabled = false,
        nameEnabled = false, snaplineEnabled = false,
        snaplineMode = "Bottom", teamCheck = false, whitelist = currentEspWhitelist,
        boxColor = Color3.fromRGB(88, 196, 255), outlineColor = Color3.fromRGB(0, 0, 0),
        nameColor = Color3.fromRGB(255, 255, 255), skeletonColor = Color3.fromRGB(255, 255, 255),
        snaplineColor = Color3.fromRGB(88, 196, 255), distanceColor = Color3.fromRGB(200, 200, 200),
        healthBarColor = Color3.fromRGB(85, 255, 85),
    }
    ConfigData.aimbot = {
        enabled = false, teamCheck = false, whitelist = currentEspWhitelist, fov = 120, smoothness = 5, bodyAim = "Head",
        wallCheck = true, prediction = 0, stickyTarget = false, lookAtView = false,
        activationKey = "MouseButton2", showFov = true, fovColor = Color3.fromRGB(88, 196, 255),
        triggerbotEnabled = false, triggerbotDelay = 50, triggerbotFov = 30,
    }
    ConfigData.misc = {
        nightmode = false,
        nightmodeBrightness = 1,
        nightmodePersist = true,
        aspectRatioEnabled = false,
        aspectRatioWidth = 16,
        aspectRatioHeight = 9,
    }
    print("🔄 [Config] Reset to defaults (whitelist preserved)")
end

-- Cache friendship lookups so ESP never invokes a yielding API every frame.
local friendCache = {}

local function isFriend(player)
    if not player or player == LocalPlayer then return false end
    return friendCache[player.UserId] == true
end

local function cacheFriendship(player)
    if not player or player == LocalPlayer then return end
    local ok, result = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    friendCache[player.UserId] = ok and result == true
end

local function isWhitelisted(player)
    if not player or player == LocalPlayer then return true end
    return isFriend(player)
        or tableFind(ConfigData.esp.whitelist, player.Name)
        or tableFind(ConfigData.aimbot.whitelist, player.Name)
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
    -- Main frame with modern dark styling
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 650, 0, 480)
    self.mainFrame.Position = UDim2.new(0.5, -325, 0.5, -240)
    self.mainFrame.BackgroundColor3 = Colors.Background
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Visible = false
    self.mainFrame.BackgroundTransparency = 0.3
    self.mainFrame.Parent = self.screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.mainFrame

    -- Modern gradient background
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 30)),
    })
    bgGradient.Rotation = 135
    bgGradient.Parent = self.mainFrame

    -- Border with accent color
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 100)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = self.mainFrame

    -- Subtle inner glow/border
    local innerGlow = Instance.new("UIGradient")
    innerGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(Colors.Accent.R*255, Colors.Accent.G*255, Colors.Accent.B*255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 90)),
    })
    innerGlow.Rotation = 0
    
    local stroke2 = Instance.new("UIStroke")
    stroke2.Color = Colors.Accent
    stroke2.Thickness = 1
    stroke2.Transparency = 0.7
    stroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke2.Parent = self.mainFrame

    -- Outer shadow
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
    shadow.Size = UDim2.new(1, 50, 1, 50)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.75
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = self.mainFrame

    -- Dark shadow layer (used in open/close animations)
    local shadowDark = Instance.new("ImageLabel")
    shadowDark.AnchorPoint = Vector2.new(0.5, 0.5)
    shadowDark.BackgroundTransparency = 1
    shadowDark.Position = UDim2.new(0.5, 0, 0.5, 16)
    shadowDark.Size = UDim2.new(1, 80, 1, 80)
    shadowDark.ZIndex = -2
    shadowDark.Image = "rbxassetid://6014261993"
    shadowDark.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadowDark.ImageTransparency = 0.85
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
    local centerPos = UDim2.new(0.5, -360, 0.5, -270)
    local startPos  = UDim2.new(0.5, -360, 0.5, -245)  -- slightly above

    self.mainFrame.Visible = true
    self.mainFrame.BackgroundTransparency = 1
    self.mainFrame.Position = startPos

    local info = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    playTween(self.mainFrame, info, { BackgroundTransparency = 0, Position = centerPos })
    playTween(self.stroke,    info, { Transparency = 0 })
    playTween(self.shadow,    info, { ImageTransparency = 0.88 })
    playTween(self.shadowDark,info, { ImageTransparency = 0.7 })

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

    local endPos = UDim2.new(0.5, -360, 0.5, -310)
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
    -- Modern header with accent bar
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(28, 28, 45)
    header.BorderSizePixel = 0
    header.Parent = self.mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    -- Accent bar on left
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 0.8, 0)
    accentBar.Position = UDim2.new(0, 10, 0.1, 0)
    accentBar.BackgroundColor3 = Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = header

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accentBar

    -- Accent glow
    local accentGlow = Instance.new("UIGradient")
    accentGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(
            math.clamp(math.floor(Colors.Accent.R*255) + 30, 0, 255),
            math.clamp(math.floor(Colors.Accent.G*255) + 30, 0, 255),
            math.clamp(math.floor(Colors.Accent.B*255) + 30, 0, 255)
        )),
        ColorSequenceKeypoint.new(1, Colors.Accent),
    })
    accentGlow.Rotation = 90
    accentGlow.Parent = accentBar

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 150, 1, 0)
    title.Position = UDim2.new(0, 24, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "FCheat"
    title.TextColor3 = Colors.Text
    title.Font = MinecraftFonts.Title
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Version tag
    local version = Instance.new("Frame")
    version.Size = UDim2.new(0, 38, 0, 16)
    version.Position = UDim2.new(0, 150, 0.5, -8)
    version.BackgroundColor3 = Colors.Accent
    version.BackgroundTransparency = 0.85
    version.BorderSizePixel = 0
    version.Parent = header

    local versionCorner = Instance.new("UICorner")
    versionCorner.CornerRadius = UDim.new(0, 4)
    versionCorner.Parent = version

    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, 0, 1, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v2.0"
    versionLabel.TextColor3 = Colors.Text
    versionLabel.Font = MinecraftFonts.Pixel
    versionLabel.TextSize = 10
    versionLabel.Parent = version

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 32, 0, 32)
    minBtn.Position = UDim2.new(1, -80, 0.5, -16)
    minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    minBtn.BackgroundTransparency = 0.3
    minBtn.BorderSizePixel = 0
    minBtn.Text = "−"
    minBtn.TextColor3 = Colors.TextSecondary
    minBtn.Font = MinecraftFonts.Header
    minBtn.TextSize = 18
    minBtn.AutoButtonColor = false
    minBtn.Parent = header

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minBtn

    self:_connect(minBtn.MouseEnter, function()
        playTween(minBtn, TweenInfo_Fast, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Colors.Warning,
            TextColor3 = Colors.Text
        })
    end)
    self:_connect(minBtn.MouseLeave, function()
        playTween(minBtn, TweenInfo_Fast, {
            BackgroundTransparency = 0.3,
            BackgroundColor3 = Color3.fromRGB(50, 50, 65),
            TextColor3 = Colors.TextSecondary
        })
    end)
    self:_connect(minBtn.MouseButton1Click, function()
        self:SetVisible(false)
    end)

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.TextSecondary
    closeBtn.Font = MinecraftFonts.Header
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    self:_connect(closeBtn.MouseEnter, function()
        playTween(closeBtn, TweenInfo_Fast, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Colors.Danger,
            TextColor3 = Colors.Text
        })
    end)
    self:_connect(closeBtn.MouseLeave, function()
        playTween(closeBtn, TweenInfo_Fast, {
            BackgroundTransparency = 0.3,
            BackgroundColor3 = Color3.fromRGB(50, 50, 65),
            TextColor3 = Colors.TextSecondary
        })
    end)
    self:_connect(closeBtn.MouseButton1Click, function()
        self:SetVisible(false)
    end)
end

function UI:_createTabBar()
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -32, 0, 40)
    tabBar.Position = UDim2.new(0, 16, 0, 62)
    tabBar.BackgroundColor3 = Colors.BackgroundLighter
    tabBar.BorderSizePixel = 0
    tabBar.Parent = self.mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = tabBar

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = tabBar

    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Size = UDim2.new(1, -10, 1, 0)
    self.tabContainer.Position = UDim2.new(0, 5, 0, 0)
    self.tabContainer.BackgroundTransparency = 1
    self.tabContainer.Parent = tabBar

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 4)
    layout.Parent = self.tabContainer
end

function UI:_createContentArea()
    self.contentArea = Instance.new("Frame")
    self.contentArea.Name = "ContentArea"
    self.contentArea.Size = UDim2.new(1, -32, 1, -112)
    self.contentArea.Position = UDim2.new(0, 16, 0, 108)
    self.contentArea.BackgroundTransparency = 1
    self.contentArea.Parent = self.mainFrame
end

-- Tab icons map (improved Minecraft style symbols)
local TAB_ICONS = {
    VISUALS = "👁️",
    AIMBOT  = "🎯",
    MISC    = "⚙️",
    CONFIG  = "💾",
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
    -- Removed applyMinecraftStyle to preserve TextMuted color

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
    -- Removed applyMinecraftStyle to preserve TextMuted color

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

function UI:AddSection(parent, title, accentColor)
    local section = Instance.new("Frame")
    section.Name = "Section_" .. title
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    section.BorderColor3 = accentColor or Colors.Accent
    section.BorderSizePixel = 1
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = parent

    -- Minecraft left accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 2, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = accentColor or Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = section

    -- Section title (Minecraft style)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -4, 0, 24)
    titleLabel.Position = UDim2.new(0, 6, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title:upper()
    titleLabel.TextColor3 = Colors.Text
    titleLabel.Font = MinecraftFonts.Header
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    -- Don't applyMinecraftStyle here as it overrides colors to black

    -- Separator line under title
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -8, 0, 1)
    sep.Position = UDim2.new(0, 4, 0, 24)
    sep.BackgroundColor3 = accentColor or Colors.Accent
    sep.BackgroundTransparency = 0.6
    sep.BorderSizePixel = 0
    sep.Parent = section

    -- Items container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -6, 0, 0)
    container.Position = UDim2.new(0, 3, 0, 28)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = section

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 4)
    padding.Parent = container

    return container
end

-- ============================================
-- UI ELEMENTS
-- ============================================
function UI:CreateToggle(parent, text, default, callback, keybindConfig)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, 0, 0, 32)
    toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    toggle.BackgroundTransparency = 0.3
    toggle.BorderSizePixel = 0
    toggle.Parent = parent

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggle

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Text
    label.Font = MinecraftFonts.Minecraft
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 44, 0, 22)
    switch.Position = UDim2.new(1, -110, 0.5, -11)
    switch.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    switch.BorderSizePixel = 0
    switch.Parent = toggle

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    knob.BorderSizePixel = 0
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- Glow effect for enabled state
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 8, 1, 8)
    glow.Position = UDim2.new(-4, -4, -4, -4)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4912607387"
    glow.ImageColor3 = Color3.fromRGB(100, 180, 255)
    glow.ImageTransparency = 0.85
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(20, 20, 220, 220)
    glow.Visible = false
    glow.Parent = switch

    local state = default or false

    local function update(v, silent)
        state = v
        local enabledColor = Color3.fromRGB(88, 196, 255)  -- Nice blue
        local disabledColor = Color3.fromRGB(60, 60, 75)
        local knobColorOn = Color3.fromRGB(255, 255, 255)
        local knobColorOff = Color3.fromRGB(180, 180, 180)
        
        playTween(switch, TweenInfo_Fast, {
            BackgroundColor3 = v and enabledColor or disabledColor
        })
        playTween(knob, TweenInfo_Fast, {
            Position = v and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
            BackgroundColor3 = v and knobColorOn or knobColorOff
        })
        playTween(label, TweenInfo_Fast, {
            TextColor3 = v and Colors.Text or Colors.TextSecondary
        })
        
        -- Show/hide glow
        glow.Visible = v
        glow.ImageColor3 = enabledColor
        
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
            playTween(toggle, TweenInfo_Fast, {
                BackgroundTransparency = 0.15,
                BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            })
        else
            playTween(toggle, TweenInfo_Fast, {
                BackgroundTransparency = 0.2,
                BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            })
        end
    end)
    
    self:_connect(btn.MouseLeave, function()
        if not state then
            playTween(toggle, TweenInfo_Fast, {
                BackgroundTransparency = 0.3,
                BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            })
        else
            playTween(toggle, TweenInfo_Fast, {
                BackgroundTransparency = 0.25,
                BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            })
        end
    end)

    self:_connect(btn.MouseButton1Click, function()
        update(not state, false)
    end)

    return {
        Set = function(_, v) update(v, true) end,
        Get = function() return state end
    }
end

-- KEYBIND PICKER
-- ============================================
function UI:CreateKeybindPicker(parent, text, defaultKey, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Text
    label.Font = MinecraftFonts.Minecraft
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0, 80, 0, 24)
    keybindBtn.Position = UDim2.new(0.5, 30, 0.5, -12)
    keybindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    keybindBtn.BorderSizePixel = 0
    keybindBtn.Text = defaultKey or "None"
    keybindBtn.TextColor3 = Colors.Text
    keybindBtn.Font = MinecraftFonts.Header
    keybindBtn.TextSize = 12
    keybindBtn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = keybindBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Colors.Border
    btnStroke.Thickness = 1
    btnStroke.Parent = keybindBtn
    
    -- Always on toggle
    local alwaysOnToggle = Instance.new("Frame")
    alwaysOnToggle.Size = UDim2.new(0, 60, 0, 24)
    alwaysOnToggle.Position = UDim2.new(1, -70, 0.5, -12)
    alwaysOnToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    alwaysOnToggle.BorderSizePixel = 0
    alwaysOnToggle.Parent = container
    
    local alwaysOnCorner = Instance.new("UICorner")
    alwaysOnCorner.CornerRadius = UDim.new(0, 6)
    alwaysOnCorner.Parent = alwaysOnToggle
    
    local alwaysOnLabel = Instance.new("TextLabel")
    alwaysOnLabel.Size = UDim2.new(1, 0, 1, 0)
    alwaysOnLabel.BackgroundTransparency = 1
    alwaysOnLabel.Text = "Always"
    alwaysOnLabel.TextColor3 = Colors.TextSecondary
    alwaysOnLabel.Font = MinecraftFonts.Minecraft
    alwaysOnLabel.TextSize = 10
    alwaysOnLabel.Parent = alwaysOnToggle
    
    local alwaysOnKnob = Instance.new("Frame")
    alwaysOnKnob.Size = UDim2.new(0, 18, 0, 18)
    alwaysOnKnob.Position = UDim2.new(0, 2, 0.5, -9)
    alwaysOnKnob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    alwaysOnKnob.BorderSizePixel = 0
    alwaysOnKnob.Parent = alwaysOnToggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = alwaysOnKnob
    
    local alwaysOnState = false
    local currentKey = defaultKey or "None"
    local isListening = false
    
    local function updateAlwaysOn(v)
        alwaysOnState = v
        local enabledColor = Color3.fromRGB(88, 196, 255)
        local disabledColor = Color3.fromRGB(60, 60, 75)
        
        playTween(alwaysOnToggle, TweenInfo_Fast, {
            BackgroundColor3 = v and enabledColor or disabledColor
        })
        playTween(alwaysOnKnob, TweenInfo_Fast, {
            Position = v and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
            BackgroundColor3 = v and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 180)
        })
        alwaysOnLabel.TextColor3 = v and Colors.Text or Colors.TextSecondary
        
        if callback and callback.onAlwaysOnChange then
            callback.onAlwaysOnChange(v)
        end
    end
    
    self:_connect(alwaysOnToggle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateAlwaysOn(not alwaysOnState)
        end
    end)
    
    local function startKeyListen()
        isListening = true
        keybindBtn.Text = "Press key..."
        keybindBtn.BackgroundColor3 = Color3.fromRGB(88, 196, 255)
        
        local connection
        connection = Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            local key = input.KeyCode == Enum.KeyCode.Unknown and input.UserInputType or input.KeyCode
            local keyName = input.KeyCode.Name
            
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyName = "Mouse1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keyName = "Mouse2"
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                keyName = "Mouse3"
            end
            
            if keyName and keyName ~= "Unknown" then
                currentKey = keyName
                keybindBtn.Text = keyName
                keybindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                isListening = false
                
                if callback and callback.onKeyChange then
                    callback.onKeyChange(keyName)
                end
                
                connection:Disconnect()
            end
        end)
        
        task.delay(5, function()
            if isListening then
                isListening = false
                keybindBtn.Text = currentKey
                keybindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                connection:Disconnect()
            end
        end)
    end
    
    self:_connect(keybindBtn.MouseButton1Click, function()
        if not isListening then
            startKeyListen()
        end
    end)
    
    return {
        SetKey = function(_, key)
            currentKey = key or "None"
            keybindBtn.Text = currentKey
        end,
        GetKey = function() return currentKey end,
        SetAlwaysOn = function(_, v) updateAlwaysOn(v) end,
        IsAlwaysOn = function() return alwaysOnState end
    }
end

function UI:CreateSlider(parent, text, min, max, default, callback, suffix)
    suffix = suffix or ""
    local current = default

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 48)
    slider.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    slider.BackgroundTransparency = 0.4
    slider.BorderSizePixel = 0
    slider.Parent = parent

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = slider

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Text
    label.Font = MinecraftFonts.Minecraft
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.35, -12, 0, 20)
    valueLabel.Position = UDim2.new(0.65, 0, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default) .. suffix
    valueLabel.TextColor3 = Colors.Accent
    valueLabel.Font = MinecraftFonts.Header
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = slider

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -20, 0, 6)
    trackBg.Position = UDim2.new(0, 10, 0, 36)
    trackBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
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

    -- Glow on fill
    local fillGlow = Instance.new("UIGradient")
    fillGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(
            math.clamp(math.floor(Colors.Accent.R*255) + 30, 0, 255),
            math.clamp(math.floor(Colors.Accent.G*255) + 30, 0, 255),
            math.clamp(math.floor(Colors.Accent.B*255) + 30, 0, 255)
        )),
        ColorSequenceKeypoint.new(1, Colors.Accent),
    })
    fillGlow.Rotation = 0
    fillGlow.Parent = fill

    -- Drag handle
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 0.5, 0)
    handle.BackgroundColor3 = Colors.Text
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = trackBg

    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle

    -- Handle shadow glow
    local handleGlow = Instance.new("ImageLabel")
    handleGlow.Size = UDim2.new(1, 8, 1, 8)
    handleGlow.Position = UDim2.new(-4, -4, -4, -4)
    handleGlow.BackgroundTransparency = 1
    handleGlow.Image = "rbxassetid://4912607387"
    handleGlow.ImageColor3 = Colors.Accent
    handleGlow.ImageTransparency = 0.7
    handleGlow.ScaleType = Enum.ScaleType.Slice
    handleGlow.SliceCenter = Rect.new(20, 20, 220, 220)
    handleGlow.Parent = handle

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 1, 4)
    btn.Position = UDim2.new(0, 2, 0, -2)
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
        playTween(handle, TweenInfo_Fast, {Size = UDim2.new(0, 18, 0, 18)})
        playTween(handleGlow, TweenInfo_Fast, {ImageTransparency = 0.5})
        playTween(fill, TweenInfo_Fast, {BackgroundColor3 = Colors.AccentLight})
    end)
    
    self:_connect(btn.MouseLeave, function()
        if not dragging then
            playTween(handle, TweenInfo_Fast, {Size = UDim2.new(0, 16, 0, 16)})
            playTween(handleGlow, TweenInfo_Fast, {ImageTransparency = 0.7})
        end
        playTween(fill, TweenInfo_Fast, {BackgroundColor3 = Colors.Accent})
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
            playTween(handle, TweenInfo_Fast, {Size = UDim2.new(0, 16, 0, 16)})
            playTween(handleGlow, TweenInfo_Fast, {ImageTransparency = 0.7})
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
    -- Don't applyMinecraftStyle - keeps text readable

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
    -- Don't applyMinecraftStyle - keeps text readable

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
    -- Removed applyMinecraftStyle to preserve Accent color

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
        optBtn.TextColor3 = Colors.Text
        optBtn.Font = MinecraftFonts.Minecraft
        optBtn.TextSize = 12
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.AutoButtonColor = false
        optBtn.ZIndex = 201
        optBtn.Parent = list
        -- Don't applyMinecraftStyle - keeps text readable

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

-- ============================================
-- SIMPLE COLOR PICKER
-- ============================================
function UI:CreateColorPicker(parent, text, default, category, key, callback)
    local picker = Instance.new("Frame")
    picker.Size = UDim2.new(1, 0, 0, 28)
    picker.BackgroundTransparency = 1
    picker.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextSecondary
    label.Font = MinecraftFonts.Minecraft
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = picker
    
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0, 60, 1, -4)
    colorFrame.Position = UDim2.new(1, -66, 0, 2)
    colorFrame.BackgroundColor3 = default
    colorFrame.BorderSizePixel = 0
    colorFrame.Parent = picker
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 4)
    colorCorner.Parent = colorFrame
    
    local colorStroke = Instance.new("UIStroke")
    colorStroke.Color = Colors.Border
    colorStroke.Thickness = 1
    colorStroke.Parent = colorFrame
    
    -- RGB display
    local rgbLabel = Instance.new("TextLabel")
    rgbLabel.Size = UDim2.new(0, 50, 1, -4)
    rgbLabel.Position = UDim2.new(1, -116, 0, 2)
    rgbLabel.BackgroundTransparency = 1
    rgbLabel.Text = string.format("R%d G%d B%d", math.floor(default.R*255), math.floor(default.G*255), math.floor(default.B*255))
    rgbLabel.TextColor3 = Colors.TextMuted
    rgbLabel.Font = Enum.Font.SourceSans
    rgbLabel.TextSize = 10
    rgbLabel.TextXAlignment = Enum.TextXAlignment.Right
    rgbLabel.Parent = picker
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = picker
    
    local function updateColorDisplay(c)
        colorFrame.BackgroundColor3 = c
        rgbLabel.Text = string.format("R%d G%d B%d", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
        if category and key then
            ConfigData[category][key] = c
        end
        if callback then callback(c) end
    end
    
    local connections = {}
    local function addConnection(conn)
        table.insert(connections, conn)
    end
    
    local isOpen = false
    local pickerFrame = nil
    local hSlider, sSlider, vSlider = nil, nil, nil
    
    local function createGradientColors(count)
        local colors = {}
        for i = 1, count do
            local hue = (i - 1) / count
            table.insert(colors, Color3.fromHSV(hue, 1, 1))
        end
        return colors
    end
    
    local function openPicker()
        if isOpen then return end
        isOpen = true
        
        pickerFrame = Instance.new("Frame")
        pickerFrame.Size = UDim2.new(0, 180, 0, 130)
        pickerFrame.BackgroundColor3 = Colors.BackgroundLight
        pickerFrame.BorderColor3 = Colors.Border
        pickerFrame.BorderSizePixel = 1
        pickerFrame.Position = UDim2.new(0, picker.AbsolutePosition.X, 0, picker.AbsolutePosition.Y + 28)
        pickerFrame.ZIndex = 100
        pickerFrame.Parent = self.screenGui
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 6)
        frameCorner.Parent = pickerFrame
        
        -- Preview
        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(1, -12, 0, 25)
        preview.Position = UDim2.new(0, 6, 0, 6)
        preview.BackgroundColor3 = colorFrame.BackgroundColor3
        preview.BorderSizePixel = 0
        preview.Parent = pickerFrame
        
        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 4)
        previewCorner.Parent = preview
        
        -- Hue slider with gradient
        local hueContainer = Instance.new("Frame")
        hueContainer.Size = UDim2.new(1, -12, 0, 20)
        hueContainer.Position = UDim2.new(0, 6, 0, 36)
        hueContainer.BackgroundTransparency = 1
        hueContainer.Parent = pickerFrame
        
        local hueBg = Instance.new("Frame")
        hueBg.Size = UDim2.new(1, 0, 0, 14)
        hueBg.Position = UDim2.new(0, 0, 0, 3)
        hueBg.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        hueBg.BorderSizePixel = 0
        hueBg.Parent = hueContainer
        
        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(1, 0)
        hueCorner.Parent = hueBg
        
        -- Create hue gradient using UIConstraint or multiple frames (simplified)
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        })
        hueGradient.Rotation = 0
        hueGradient.Parent = hueBg
        
        local hueHandle = Instance.new("Frame")
        hueHandle.Size = UDim2.new(0, 4, 0, 18)
        hueHandle.AnchorPoint = Vector2.new(0.5, 0)
        hueHandle.Position = UDim2.new(0.5, 0, 0, -2)
        hueHandle.BackgroundColor3 = Colors.Text
        hueHandle.BorderSizePixel = 0
        hueHandle.Parent = hueContainer
        
        local handleCorner = Instance.new("UICorner")
        handleCorner.CornerRadius = UDim.new(1, 0)
        handleCorner.Parent = hueHandle
        
        -- Saturation/Value grid (simplified as SV slider)
        local svContainer = Instance.new("Frame")
        svContainer.Size = UDim2.new(1, -12, 0, 45)
        svContainer.Position = UDim2.new(0, 6, 0, 62)
        svContainer.BackgroundTransparency = 1
        svContainer.Parent = pickerFrame
        
        local svBg = Instance.new("Frame")
        svBg.Size = UDim2.new(1, 0, 0, 35)
        svBg.Position = UDim2.new(0, 0, 0, 5)
        svBg.BackgroundColor3 = Color3.fromHSV(0.5, 1, 1)
        svBg.BorderSizePixel = 0
        svBg.Parent = svContainer
        
        local svCorner = Instance.new("UICorner")
        svCorner.CornerRadius = UDim.new(0, 4)
        svCorner.Parent = svBg
        
        -- SV gradient overlay (white to transparent)
        local svGradient1 = Instance.new("UIGradient")
        svGradient1.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        })
        svGradient1.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        svGradient1.Rotation = 90
        svGradient1.Parent = svBg
        
        -- SV gradient overlay (black to transparent)
        local svGradient2 = Instance.new("UIGradient")
        svGradient2.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        })
        svGradient2.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        })
        svGradient2.Rotation = 0
        svGradient2.Parent = svBg
        
        local svHandle = Instance.new("Frame")
        svHandle.Size = UDim2.new(0, 10, 0, 10)
        svHandle.AnchorPoint = Vector2.new(0.5, 0.5)
        svHandle.Position = UDim2.new(0.5, 0, 0.5, 0)
        svHandle.BackgroundColor3 = Colors.Text
        svHandle.BorderSizePixel = 0
        svHandle.Parent = svBg
        
        local svHandleCorner = Instance.new("UICorner")
        svHandleCorner.CornerRadius = UDim.new(1, 0)
        svHandleCorner.Parent = svHandle
        
        local function updateColorFromSliders()
            local hue = hueHandle.Position.X.Scale
            local sat = svHandle.Position.X.Scale
            local val = 1 - svHandle.Position.Y.Scale
            local newColor = Color3.fromHSV(hue, sat, val)
            updateColorDisplay(newColor)
            preview.BackgroundColor3 = newColor
        end
        
        local hueDragging = false
        local svDragging = false
        
        local hueBtn = Instance.new("TextButton")
        hueBtn.Size = UDim2.new(1, 0, 1, 0)
        hueBtn.Position = UDim2.new(0, 0, 0, -2)
        hueBtn.BackgroundTransparency = 1
        hueBtn.Text = ""
        hueBtn.Parent = hueContainer
        
        addConnection(hueBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDragging = true
            end
        end))
        
        addConnection(hueBtn.InputChanged:Connect(function(input)
            if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = (input.Position.X - hueBg.AbsolutePosition.X) / hueBg.AbsoluteSize.X
                relX = math.clamp(relX, 0, 1)
                hueHandle.Position = UDim2.new(relX, 0, 0, -2)
                updateColorFromSliders()
            end
        end))
        
        addConnection(Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDragging = false
                svDragging = false
            end
        end))
        
        local svBtn = Instance.new("TextButton")
        svBtn.Size = UDim2.new(1, 0, 1, -10)
        svBtn.Position = UDim2.new(0, 0, 0, 5)
        svBtn.BackgroundTransparency = 1
        svBtn.Text = ""
        svBtn.Parent = svContainer
        
        addConnection(svBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                svDragging = true
                local relX = (input.Position.X - svBg.AbsolutePosition.X) / svBg.AbsoluteSize.X
                local relY = (input.Position.Y - svBg.AbsolutePosition.Y) / svBg.AbsoluteSize.Y
                svHandle.Position = UDim2.new(math.clamp(relX, 0, 1), 0, math.clamp(relY, 0, 1), 0)
                updateColorFromSliders()
            end
        end))
        
        addConnection(svBtn.InputChanged:Connect(function(input)
            if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = (input.Position.X - svBg.AbsolutePosition.X) / svBg.AbsoluteSize.X
                local relY = (input.Position.Y - svBg.AbsolutePosition.Y) / svBg.AbsoluteSize.Y
                svHandle.Position = UDim2.new(math.clamp(relX, 0, 1), 0, math.clamp(relY, 0, 1), 0)
                updateColorFromSliders()
            end
        end))
        
        -- Close button
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(1, -12, 0, 20)
        closeBtn.Position = UDim2.new(0, 6, 0, 106)
        closeBtn.BackgroundColor3 = Colors.BackgroundLighter
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "Close"
        closeBtn.TextColor3 = Colors.TextSecondary
        closeBtn.Font = MinecraftFonts.Minecraft
        closeBtn.TextSize = 11
        closeBtn.Parent = pickerFrame
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 4)
        closeCorner.Parent = closeBtn
        
        addConnection(closeBtn.MouseEnter:Connect(function()
            closeBtn.BackgroundColor3 = Colors.AccentDark
        end))
        
        addConnection(closeBtn.MouseLeave:Connect(function()
            closeBtn.BackgroundColor3 = Colors.BackgroundLighter
        end))
        
        addConnection(closeBtn.MouseButton1Click:Connect(function()
            isOpen = false
            for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
            connections = {}
            if pickerFrame then
                pickerFrame:Destroy()
                pickerFrame = nil
            end
        end))
        
        -- Close when clicking outside
        local outsideConn
        outsideConn = Services.UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = Services.UserInputService:GetMouseLocation()
                if pickerFrame then
                    local lp = pickerFrame.AbsolutePosition
                    local ls = pickerFrame.AbsoluteSize
                    local inPicker = mousePos.X >= lp.X and mousePos.X <= lp.X + ls.X
                               and mousePos.Y >= lp.Y and mousePos.Y <= lp.Y + ls.Y
                    if not inPicker then
                        isOpen = false
                        outsideConn:Disconnect()
                        for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
                        connections = {}
                        pickerFrame:Destroy()
                        pickerFrame = nil
                    end
                end
            end
        end)
    end
    
    addConnection(btn.MouseButton1Click:Connect(openPicker))
    
    return {
        Set = function(_, c)
            updateColorDisplay(c)
        end,
        Get = function()
            return colorFrame.BackgroundColor3
        end
    }
end

function UI:CreateWhitelistList(parent, whitelist, callback)
    local listHeight = 220
    local fetchedFriendNames = {}
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, listHeight)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    container.BorderSizePixel = 0
    container.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, 16)
    label.Position = UDim2.new(0, 6, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = "Protected Players"
    label.TextColor3 = Colors.TextSecondary
    label.Font = MinecraftFonts.Header
    label.TextSize = 10
    label.Parent = container
    
    -- Add every Roblox friend to the protected list in one click.
    local filterBtn = Instance.new("TextButton")
    filterBtn.Size = UDim2.new(1, -12, 0, 20)
    filterBtn.Position = UDim2.new(0, 6, 0, 20)
    filterBtn.BackgroundColor3 = Colors.BackgroundHover
    filterBtn.BorderSizePixel = 0
    filterBtn.Text = "Sync Online Friends"
    filterBtn.TextColor3 = Colors.TextSecondary
    filterBtn.Font = MinecraftFonts.Body
    filterBtn.TextSize = 11
    filterBtn.AutoButtonColor = false
    filterBtn.Parent = container
    
    local filterCorner = Instance.new("UICorner")
    filterCorner.CornerRadius = UDim.new(0, 4)
    filterCorner.Parent = filterBtn

    local list = Instance.new("ScrollingFrame")
    list.Name = "WhitelistList"
    list.Size = UDim2.new(1, -8, 0, 112)
    list.Position = UDim2.new(0, 4, 0, 44)
    list.BackgroundTransparency = 1
    list.ScrollBarThickness = 3
    list.ScrollBarImageColor3 = Colors.Accent
    list.ScrollBarImageTransparency = 0.5
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = list

    local framePadding = Instance.new("UIPadding")
    framePadding.PaddingTop = UDim.new(0, 4)
    framePadding.PaddingBottom = UDim.new(0, 4)
    framePadding.PaddingLeft = UDim.new(0, 6)
    framePadding.PaddingRight = UDim.new(0, 6)
    framePadding.Parent = list

    -- AutoComplete dropdown for suggestions
    local autoCompleteDropdown = Instance.new("Frame")
    autoCompleteDropdown.Size = UDim2.new(0, 0, 0, 0)
    autoCompleteDropdown.BackgroundColor3 = Colors.BackgroundLight
    autoCompleteDropdown.BorderSizePixel = 0
    autoCompleteDropdown.Visible = false
    autoCompleteDropdown.ZIndex = 100
    autoCompleteDropdown.Parent = self.screenGui

    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 4)
    autoCorner.Parent = autoCompleteDropdown

    local autoStroke = Instance.new("UIStroke")
    autoStroke.Color = Colors.Accent
    autoStroke.Thickness = 1
    autoStroke.Transparency = 0.6
    autoStroke.Parent = autoCompleteDropdown

    local autoCompleteLayout = Instance.new("UIListLayout")
    autoCompleteLayout.SortOrder = Enum.SortOrder.LayoutOrder
    autoCompleteLayout.Padding = UDim.new(0, 2)
    autoCompleteLayout.Parent = autoCompleteDropdown

    local autoCompletePadding = Instance.new("UIPadding")
    autoCompletePadding.PaddingTop = UDim.new(0, 4)
    autoCompletePadding.PaddingBottom = UDim.new(0, 4)
    autoCompletePadding.PaddingLeft = UDim.new(0, 6)
    autoCompletePadding.PaddingRight = UDim.new(0, 6)
    autoCompletePadding.Parent = autoCompleteDropdown

    -- Manual input field for adding players by name
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, 0, 0, 28)
    inputContainer.Position = UDim2.new(0, 0, 0, 166)
    inputContainer.BackgroundColor3 = Colors.BackgroundLighter
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = container

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = inputContainer

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Colors.Border
    inputStroke.Thickness = 1
    inputStroke.Parent = inputContainer

    local inputField = Instance.new("TextBox")
    inputField.Size = UDim2.new(1, -50, 1, 0)
    inputField.Position = UDim2.new(0, 6, 0, 0)
    inputField.BackgroundColor3 = Colors.BackgroundLight
    inputField.BorderSizePixel = 0
    inputField.Text = "Enter player name..."
    inputField.TextColor3 = Colors.TextMuted
    inputField.Font = MinecraftFonts.Body
    inputField.TextSize = 11
    inputField.Parent = inputContainer
    inputField.ClearTextOnFocus = false

    local addBtn = Instance.new("TextButton")
    addBtn.Size = UDim2.new(0, 40, 1, 0)
    addBtn.Position = UDim2.new(1, -42, 0, 0)
    addBtn.BackgroundColor3 = Colors.Accent
    addBtn.BorderSizePixel = 0
    addBtn.Text = "Add"
    addBtn.TextColor3 = Colors.Text
    addBtn.Font = MinecraftFonts.Header
    addBtn.TextSize = 11
    addBtn.AutoButtonColor = false
    addBtn.Parent = inputContainer

    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 3)
    addCorner.Parent = addBtn

    -- Notification label for Add/Remove events
    local notifyLabel = Instance.new("TextLabel")
    notifyLabel.Size = UDim2.new(1, -12, 0, 20)
    notifyLabel.Position = UDim2.new(0, 6, 0, listHeight - 54)
    notifyLabel.BackgroundTransparency = 1
    notifyLabel.TextColor3 = Colors.Text
    notifyLabel.Font = MinecraftFonts.Body
    notifyLabel.TextSize = 11
    notifyLabel.TextXAlignment = Enum.TextXAlignment.Center
    notifyLabel.Parent = container

    local function showNotification(text, duration)
        notifyLabel.Text = text
        task.delay(duration or 2, function()
            notifyLabel.Text = ""
        end)
    end

    local renderList

    local function addPlayerByName(playerName)
        local trimmedName = playerName:Trim()
        
        -- Validate name is not empty
        if trimmedName == "" then
            showNotification("Please enter a player name", 2)
            return
        end
        
        -- Check if already in whitelist
        if tableFind(whitelist, trimmedName) then
            showNotification(trimmedName .. " is already in whitelist", 2)
            return
        end
        
        -- Validate name exists on server
        local players = Services.Players:GetPlayers()
        local found = false
        for _, player in ipairs(players) do
            if player.Name == trimmedName then
                found = true
                break
            end
        end
        
        if not found then
            showNotification("Player '" .. trimmedName .. "' not found on server", 2)
            return
        end
        
        -- Add to whitelist
        table.insert(whitelist, trimmedName)
        callback(whitelist)
        saveConfig()
        showNotification(trimmedName .. " added to whitelist")
        inputField.Text = "Enter player name..."
        renderList()
    end

    -- Connect input events
    self:_connect(inputField.FocusLost, function(enterPressed)
        if enterPressed then
            addPlayerByName(inputField.Text)
        end
    end)

    self:_connect(addBtn.MouseButton1Click, function()
        addPlayerByName(inputField.Text)
    end)
    
    -- Input field hover effects
    self:_connect(inputField.MouseEnter, function()
        playTween(inputContainer, TweenInfo_Fast, {BackgroundTransparency = 0.2, BackgroundColor3 = Colors.BackgroundHover})
    end)
    self:_connect(inputField.MouseLeave, function()
        playTween(inputContainer, TweenInfo_Fast, {BackgroundTransparency = 0.98, BackgroundColor3 = Colors.BackgroundLighter})
    end)
    
    self:_connect(addBtn.MouseEnter, function()
        playTween(addBtn, TweenInfo_Fast, {BackgroundColor3 = Colors.AccentLight})
    end)
    self:_connect(addBtn.MouseLeave, function()
        playTween(addBtn, TweenInfo_Fast, {BackgroundColor3 = Colors.Accent})
    end)
    
    local refreshButton = Instance.new("TextButton")
    refreshButton.Size = UDim2.new(1, 0, 0, 24)
    refreshButton.Position = UDim2.new(0, 0, 0, 196)
    refreshButton.BackgroundColor3 = Colors.BackgroundHover
    refreshButton.BorderSizePixel = 0
    refreshButton.Text = "Refresh"
    refreshButton.TextColor3 = Colors.Text
    refreshButton.Font = MinecraftFonts.Body
    refreshButton.TextSize = 11
    refreshButton.Parent = container

    local refreshCorner = Instance.new("UICorner")
    refreshCorner.CornerRadius = UDim.new(0, 4)
    refreshCorner.Parent = refreshButton
    
    self:_connect(filterBtn.MouseButton1Click, function()
        filterBtn.Text = "Loading Friends..."
        filterBtn.Active = false

        task.spawn(function()
            local syncedNames = {}
            local syncedSet = {}
            local checked = 0

            for _, player in ipairs(Services.Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    cacheFriendship(player)
                    checked = checked + 1
                    if isFriend(player) then
                        syncedSet[player.Name:lower()] = true
                        table.insert(syncedNames, player.Name)
                    end
                end
            end

            for _, name in ipairs(syncedNames) do
                if not tableFind(whitelist, name) then
                    table.insert(whitelist, name)
                end
            end
            fetchedFriendNames = syncedSet
            ConfigData.aimbot.whitelist = whitelist
            callback(whitelist)
            saveConfig()
            renderList()
            showNotification(string.format("Found %d online friends", #syncedNames), 2)

            filterBtn.Text = "Sync Online Friends"
            filterBtn.Active = true
        end)
    end)
    
    -- Notification label for Add/Remove events
    local notifyLabel = Instance.new("TextLabel")
    notifyLabel.Size = UDim2.new(1, -12, 0, 20)
    notifyLabel.Position = UDim2.new(0, 6, 0, listHeight - 54)
    notifyLabel.BackgroundTransparency = 1
    notifyLabel.TextColor3 = Colors.Text
    notifyLabel.Font = MinecraftFonts.Body
    notifyLabel.TextSize = 11
    notifyLabel.TextXAlignment = Enum.TextXAlignment.Center
    notifyLabel.Parent = container

    local function showNotification(text, duration)
        notifyLabel.Text = text
        task.delay(duration or 2, function()
            notifyLabel.Text = ""
        end)
    end

    renderList = function()
        -- Keep the layout and padding; destroying them makes every row overlap.
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end

        for _, name in ipairs(whitelist) do
            local onlinePlayer = Services.Players:FindFirstChild(name)
            if not onlinePlayer then continue end

            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, 0, 0, 28)
            item.BackgroundColor3 = Colors.BackgroundLighter
            item.BorderSizePixel = 0
            item.Parent = list

            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 4)
            itemCorner.Parent = item

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -40, 1, 0)
            nameLabel.Position = UDim2.new(0, 8, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = (isFriend(onlinePlayer) and "[FRIEND] " or "[MANUAL] ") .. name
            nameLabel.TextColor3 = Colors.Text
            nameLabel.Font = MinecraftFonts.Body
            nameLabel.TextSize = 11
            nameLabel.Parent = item

            local removeBtn = Instance.new("TextButton")
            removeBtn.Size = UDim2.new(0, 30, 0, 18)
            removeBtn.Position = UDim2.new(1, -32, 0.5, -9)
            removeBtn.BackgroundColor3 = Colors.Danger
            removeBtn.BorderSizePixel = 0
            removeBtn.Text = "×"
            removeBtn.TextColor3 = Colors.Text
            removeBtn.Font = MinecraftFonts.Header
            removeBtn.TextSize = 14
            removeBtn.AutoButtonColor = false
            removeBtn.Parent = item

            local removeCorner = Instance.new("UICorner")
            removeCorner.CornerRadius = UDim.new(0, 3)
            removeCorner.Parent = removeBtn

            local function removePlayer()
                local idx = tableIndexOf(whitelist, name)
                if idx then
                    table.remove(whitelist, idx)
                    callback(whitelist)
                    saveConfig()
                    showNotification("Removed " .. name .. " from whitelist")
                    renderList()
                end
            end

            self:_connect(removeBtn.MouseButton1Click, removePlayer)
            self:_connect(removeBtn.MouseEnter, function()
                playTween(removeBtn, TweenInfo_Fast, {BackgroundColor3 = Colors.DangerLight})
            end)
            self:_connect(removeBtn.MouseLeave, function()
                playTween(removeBtn, TweenInfo_Fast, {BackgroundColor3 = Colors.Danger})
            end)

            -- Hover effect for item
            self:_connect(item.MouseEnter, function()
                playTween(item, TweenInfo_Fast, {BackgroundTransparency = 0.2, BackgroundColor3 = Colors.BackgroundHover})
            end)
            self:_connect(item.MouseLeave, function()
                playTween(item, TweenInfo_Fast, {BackgroundTransparency = 0.98, BackgroundColor3 = Colors.BackgroundLighter})
            end)
        end

        -- Auto-scroll to bottom if list is not empty
        if #list:GetChildren() > 0 then
            task.spawn(function()
                task.wait()
                list.CanvasPosition = Vector2.new(0, list.CanvasPosition.Y + 50)
            end)
        end
    end

    self:_connect(refreshButton.MouseButton1Click, function()
        renderList()
        showNotification("List refreshed")
    end)

    -- AutoComplete logic
    local function showAutoComplete()
        local text = inputField.Text:Trim()
        if text == "" or text == "Enter player name..." then
            autoCompleteDropdown.Visible = false
            return
        end
        
        autoCompleteDropdown:ClearAllChildren()
        
        local players = Services.Players:GetPlayers()
        local matches = 0
        
        for _, player in ipairs(players) do
            if player.Name:lower():sub(1, #text) == text:lower():sub(1, #text) then
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 24)
                item.BackgroundColor3 = Colors.BackgroundLighter
                item.BorderSizePixel = 0
                item.Text = player.Name
                item.TextColor3 = Colors.Text
                item.Font = MinecraftFonts.Body
                item.TextSize = 11
                item.AutoButtonColor = false
                item.Parent = autoCompleteDropdown
                
                local itemCorner = Instance.new("UICorner")
                itemCorner.CornerRadius = UDim.new(0, 3)
                itemCorner.Parent = item
                
                local playerName = player.Name
                self:_connect(item.MouseButton1Click, function()
                    inputField.Text = playerName
                    autoCompleteDropdown.Visible = false
                end)
                
                self:_connect(item.MouseEnter, function()
                    playTween(item, TweenInfo_Fast, {BackgroundTransparency = 0, BackgroundColor3 = Colors.AccentDark})
                end)
                
                self:_connect(item.MouseLeave, function()
                    playTween(item, TweenInfo_Fast, {BackgroundTransparency = 0.98, BackgroundColor3 = Colors.BackgroundLighter})
                end)
                
                matches = matches + 1
                if matches >= 5 then break end
            end
        end
        
        if matches > 0 then
            local absPos = inputContainer.AbsolutePosition
            local absSize = inputContainer.AbsoluteSize
            autoCompleteDropdown.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y)
            autoCompleteDropdown.Size = UDim2.new(0, absSize.X, 0, matches * 24 + 8)
            autoCompleteDropdown.BackgroundTransparency = 0.3
            autoCompleteDropdown.Visible = true
        else
            autoCompleteDropdown.Visible = false
        end
    end
    
    self:_connect(inputField.FocusLost, function(enterPressed)
        if enterPressed then
            addPlayerByName(inputField.Text)
        end
    end)
    
    self:_connect(inputField.MouseLeave, function()
        task.delay(0.1, function()
            autoCompleteDropdown.Visible = false
        end)
    end)
    
    self:_connect(inputField:GetPropertyChangedSignal("Text"), function()
        if inputField.Text ~= "" and inputField.Text ~= "Enter player name..." then
            showAutoComplete()
        end
    end)
    
    local function closeAutoComplete()
        autoCompleteDropdown.Visible = false
    end
    
    self:_connect(Services.UserInputService.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = Services.UserInputService:GetMouseLocation()
            local ap = autoCompleteDropdown.AbsolutePosition
            local as = autoCompleteDropdown.AbsoluteSize
            local inAuto = mousePos.X >= ap.X and mousePos.X <= ap.X + as.X
                       and mousePos.Y >= ap.Y and mousePos.Y <= ap.Y + as.Y
            if not inAuto and autoCompleteDropdown.Visible then
                closeAutoComplete()
            end
        end
    end)

    renderList()
    return {
        Instance = container,
        Refresh = renderList,
    }
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
    -- Removed applyMinecraftStyle to preserve TextSecondary color

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
            self.drawings.boxOutline.Color = settings.outlineColor or Color3.new(0, 0, 0)
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
        -- Use custom health bar color or gradient based on health
        if settings.healthBarColor then
            self.drawings.healthFill.Color = settings.healthBarColor
        else
            self.drawings.healthFill.Color = Color3.fromRGB(255 - hf * 255, hf * 255, 0)
        end
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
end

function ESPObject:destroy()
    for _, drawing in pairs(self.drawings) do pcall(function() drawing:Remove() end) end
    for _, line in ipairs(self.skeletonLines) do pcall(function() line:Remove() end) end
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
    if isWhitelisted(player) then return true end
    
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
                                if isWhitelisted(self.currentTarget) then
                                    return nil
                                end
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
        if isWhitelisted(player) then continue end
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
    if not cam then
        self.fovCircle.Visible = false
        self.currentTarget = nil
        return
    end
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
        if type(mousemoverel) ~= "function" then return end
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
        if isWhitelisted(player) then continue end
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
                    if type(mouse1press) ~= "function" or type(mouse1release) ~= "function" then return end
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
    self.nightModeEnabled = false
    self.nightModeBrightness = 1
    self.originalLighting = nil
    self.aspectRatioEnabled = false
    self.aspectCamera = nil
    self.originalAspectFov = nil
    self.lastAspectCamera = nil
    self.lastAspectViewport = nil
    self.lastAspectWidth = nil
    self.lastAspectHeight = nil
    self.lastAspectFov = nil
    return self
end

function MiscSystem:destroy()
    self:setNightMode(false)
    self:setAspectRatio(false)
end

function MiscSystem:setNightMode(enabled, brightness)
    enabled = enabled == true
    brightness = math.clamp(tonumber(brightness) or 1, 0, 5)
    if enabled == self.nightModeEnabled and (not enabled or brightness == self.nightModeBrightness) then
        if enabled then self:applyNightMode() end
        return
    end

    local lighting = Services.Lighting
    if enabled then
        if not self.originalLighting then
            self.originalLighting = {
                Ambient = lighting.Ambient,
                OutdoorAmbient = lighting.OutdoorAmbient,
                Brightness = lighting.Brightness,
                ClockTime = lighting.ClockTime,
                FogColor = lighting.FogColor,
                FogEnd = lighting.FogEnd,
            }
        end

        self.nightModeEnabled = true
        self.nightModeBrightness = brightness
        self:applyNightMode()
    elseif self.originalLighting then
        for property, value in pairs(self.originalLighting) do
            pcall(function()
                lighting[property] = value
            end)
        end
        self.originalLighting = nil
    end

    self.nightModeEnabled = enabled
    self.nightModeBrightness = brightness
end

function MiscSystem:applyNightMode()
    if not self.nightModeEnabled then return end

    local lighting = Services.Lighting
    pcall(function() lighting.Ambient = Color3.fromRGB(25, 25, 45) end)
    pcall(function() lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 25) end)
    pcall(function() lighting.Brightness = self.nightModeBrightness end)
    pcall(function() lighting.ClockTime = 0 end)
    pcall(function() lighting.FogColor = Color3.fromRGB(15, 15, 35) end)
    pcall(function() lighting.FogEnd = 1000 end)
end

function MiscSystem:setAspectRatio(enabled, width, height)
    self.aspectRatioEnabled = enabled == true
    self.aspectRatioWidth = math.max(1, tonumber(width) or 16)
    self.aspectRatioHeight = math.max(1, tonumber(height) or 9)
    self:applyAspectRatio(true)
end

function MiscSystem:applyAspectRatio(force)
    local ok, camera = pcall(function()
        return Services.Workspace.CurrentCamera
    end)
    if not ok or not camera then return end

    local viewportOk, viewport = pcall(function() return camera.ViewportSize end)
    if not viewportOk or not viewport then return end
    local viewportKey = tostring(viewport.X) .. ":" .. tostring(viewport.Y)
    local currentFovOk, currentFov = pcall(function() return camera.FieldOfView end)
    if not currentFovOk then return end
    if not force and camera == self.lastAspectCamera and viewportKey == self.lastAspectViewport
        and self.aspectRatioWidth == self.lastAspectWidth and self.aspectRatioHeight == self.lastAspectHeight
        and math.abs(currentFov - (self.lastAspectFov or currentFov)) < 0.01 then
        return
    end

    if not self.aspectRatioEnabled then
        local originalFov = self.originalAspectFov
        if self.aspectCamera and self.originalAspectFov then
            pcall(function() self.aspectCamera.FieldOfView = self.originalAspectFov end)
        end
        self.aspectCamera = nil
        self.originalAspectFov = nil
        self.lastAspectCamera = camera
        self.lastAspectViewport = viewportKey
        self.lastAspectWidth = self.aspectRatioWidth
        self.lastAspectHeight = self.aspectRatioHeight
        self.lastAspectFov = originalFov
        return
    end

    local currentAspect = viewport.Y > 0 and viewport.X / viewport.Y or (16 / 9)
    local targetAspect = self.aspectRatioWidth / self.aspectRatioHeight
    if self.aspectCamera ~= camera then
        self.aspectCamera = camera
        self.originalAspectFov = currentFov
    end

    local baseFov = self.originalAspectFov or currentFov
    local adjustedFov = math.deg(2 * math.atan(math.tan(math.rad(baseFov) / 2) * targetAspect / currentAspect))
    pcall(function() camera.FieldOfView = math.clamp(adjustedFov, 1, 120) end)
    self.lastAspectCamera = camera
    self.lastAspectViewport = viewportKey
    self.lastAspectWidth = self.aspectRatioWidth
    self.lastAspectHeight = self.aspectRatioHeight
    self.lastAspectFov = adjustedFov
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
    local espGeneral = self.ui:AddSection(visualsContent, "ESP General", Colors.Accent)
    local miscGeneral = self.ui:AddSection(miscContent, "Display", Colors.Accent)
    self.nightModeToggle = self.ui:CreateToggle(miscGeneral, "Nightmode", ConfigData.misc.nightmode, function(v)
        ConfigData.misc.nightmode = v
        self.misc:setNightMode(v, ConfigData.misc.nightmodeBrightness)
    end)
    self.ui.sliderNightModeBrightness = self.ui:CreateSlider(miscGeneral, "Nightmode Brightness", 0, 500, ConfigData.misc.nightmodeBrightness * 100, function(v)
        ConfigData.misc.nightmodeBrightness = v / 100
        self.misc:setNightMode(ConfigData.misc.nightmode, ConfigData.misc.nightmodeBrightness)
    end, "%")
    self.nightModePersistToggle = self.ui:CreateToggle(miscGeneral, "Keep Nightmode on Round Start", ConfigData.misc.nightmodePersist, function(v)
        ConfigData.misc.nightmodePersist = v
    end)
    self.aspectRatioToggle = self.ui:CreateToggle(miscGeneral, "Aspect Ratio Stretch", ConfigData.misc.aspectRatioEnabled, function(v)
        ConfigData.misc.aspectRatioEnabled = v
        self.misc:setAspectRatio(v, ConfigData.misc.aspectRatioWidth, ConfigData.misc.aspectRatioHeight)
    end)
    self.ui.sliderAspectRatioWidth = self.ui:CreateSlider(miscGeneral, "Aspect Width", 1, 40, ConfigData.misc.aspectRatioWidth, function(v)
        ConfigData.misc.aspectRatioWidth = v
        self.misc:setAspectRatio(ConfigData.misc.aspectRatioEnabled, v, ConfigData.misc.aspectRatioHeight)
    end)
    self.ui.sliderAspectRatioHeight = self.ui:CreateSlider(miscGeneral, "Aspect Height", 1, 40, ConfigData.misc.aspectRatioHeight, function(v)
        ConfigData.misc.aspectRatioHeight = v
        self.misc:setAspectRatio(ConfigData.misc.aspectRatioEnabled, ConfigData.misc.aspectRatioWidth, v)
    end)
    self.ui:CreateButton(miscGeneral, "Reset Aspect Ratio to 16:9", function()
        ConfigData.misc.aspectRatioWidth = 16
        ConfigData.misc.aspectRatioHeight = 9
        if self.ui.sliderAspectRatioWidth then self.ui.sliderAspectRatioWidth:Set(16) end
        if self.ui.sliderAspectRatioHeight then self.ui.sliderAspectRatioHeight:Set(9) end
        self.misc:setAspectRatio(ConfigData.misc.aspectRatioEnabled, 16, 9)
    end)
    self.espToggle = self.ui:CreateToggle(espGeneral, "Enable ESP", ConfigData.esp.enabled, function(v) ConfigData.esp.enabled = v end)
    self.ui.boxToggle = self.ui:CreateToggle(espGeneral, "Box ESP", ConfigData.esp.boxEnabled, function(v) ConfigData.esp.boxEnabled = v end)
    self.ui.dropdownBoxType = self.ui:CreateDropdown(espGeneral, "Box Type", {"Standard", "Corner", "Rounded", "Dashed"}, ConfigData.esp.boxType, function(v) ConfigData.esp.boxType = v end)
    self.ui.outlineToggle = self.ui:CreateToggle(espGeneral, "Box Outline", ConfigData.esp.outlineEnabled, function(v) ConfigData.esp.outlineEnabled = v end)
    self.ui.nameToggle = self.ui:CreateToggle(espGeneral, "Name ESP", ConfigData.esp.nameEnabled, function(v) ConfigData.esp.nameEnabled = v end)
    self.ui.distanceToggle = self.ui:CreateToggle(espGeneral, "Distance ESP", ConfigData.esp.distanceEnabled, function(v) ConfigData.esp.distanceEnabled = v end)
    self.ui.healthBarToggle = self.ui:CreateToggle(espGeneral, "Health Bar", ConfigData.esp.healthBarEnabled, function(v) ConfigData.esp.healthBarEnabled = v end)
    self.ui:CreateToggle(espGeneral, "Team Check", ConfigData.esp.teamCheck, function(v) ConfigData.esp.teamCheck = v end)
    
    -- Whitelist section
    local espWhitelist = self.ui:AddSection(visualsContent, "Whitelist", Colors.Accent)
    self.ui.whitelistScroll = self.ui:CreateWhitelistList(espWhitelist, ConfigData.esp.whitelist, function(list)
        ConfigData.esp.whitelist = list
        ConfigData.aimbot.whitelist = list
    end)
    
    local espVisual = self.ui:AddSection(visualsContent, "Visual Effects", Colors.Accent)
    self.ui.skeletonToggle = self.ui:CreateToggle(espVisual, "Skeleton", ConfigData.esp.skeletonEnabled, function(v) ConfigData.esp.skeletonEnabled = v end)
    self.ui.colorSkeletonColor = self.ui:CreateColorPicker(espVisual, "Skeleton Color", ConfigData.esp.skeletonColor, "esp", "skeletonColor", function(c) ConfigData.esp.skeletonColor = c end)
    self.ui.snaplineToggle = self.ui:CreateToggle(espVisual, "Snaplines", ConfigData.esp.snaplineEnabled, function(v) ConfigData.esp.snaplineEnabled = v end)
    self.ui.dropdownSnaplineMode = self.ui:CreateDropdown(espVisual, "Snapline Origin", {"Bottom", "Center", "Top"}, ConfigData.esp.snaplineMode, function(v) ConfigData.esp.snaplineMode = v end)
    
    -- ESP Colors section
    local espColors = self.ui:AddSection(visualsContent, "Colors", Colors.Accent)
    self.ui.colorBoxColor = self.ui:CreateColorPicker(espColors, "Box Color", ConfigData.esp.boxColor, "esp", "boxColor", function(c) ConfigData.esp.boxColor = c end)
    self.ui.colorOutlineColor = self.ui:CreateColorPicker(espColors, "Outline Color", ConfigData.esp.outlineColor, "esp", "outlineColor", function(c) ConfigData.esp.outlineColor = c end)
    self.ui.colorNameColor = self.ui:CreateColorPicker(espColors, "Name Color", ConfigData.esp.nameColor, "esp", "nameColor", function(c) ConfigData.esp.nameColor = c end)
    self.ui.colorSnaplineColor = self.ui:CreateColorPicker(espColors, "Snapline Color", ConfigData.esp.snaplineColor, "esp", "snaplineColor", function(c) ConfigData.esp.snaplineColor = c end)
    self.ui.colorDistanceColor = self.ui:CreateColorPicker(espColors, "Distance Color", ConfigData.esp.distanceColor, "esp", "distanceColor", function(c) ConfigData.esp.distanceColor = c end)
    self.ui.colorHealthBarColor = self.ui:CreateColorPicker(espColors, "Health Bar Color", ConfigData.esp.healthBarColor, "esp", "healthBarColor", function(c) ConfigData.esp.healthBarColor = c end)
    
    -- AIMBOT TAB
    local aimGeneral = self.ui:AddSection(aimbotContent, "Aimbot Settings", Colors.Accent)
    self.aimbotToggle = self.ui:CreateToggle(aimGeneral, "Enable Aimbot", ConfigData.aimbot.enabled, function(v) ConfigData.aimbot.enabled = v end)
    self.ui.sliderFOV = self.ui:CreateSlider(aimGeneral, "FOV", 10, 500, ConfigData.aimbot.fov, function(v) ConfigData.aimbot.fov = v end, "px")
    self.ui.showFovToggle = self.ui:CreateToggle(aimGeneral, "Show FOV Circle", ConfigData.aimbot.showFov, function(v) ConfigData.aimbot.showFov = v end)
    self.ui.colorFovColor = self.ui:CreateColorPicker(aimGeneral, "FOV Color", ConfigData.aimbot.fovColor, "aimbot", "fovColor", function(c) ConfigData.aimbot.fovColor = c end)
    self.ui.sliderSmoothness = self.ui:CreateSlider(aimGeneral, "Smoothness", 1, 50, ConfigData.aimbot.smoothness, function(v) ConfigData.aimbot.smoothness = v end)
    self.ui.dropdownActivationKey = self.ui:CreateDropdown(aimGeneral, "Activation Key", {"MouseButton1", "MouseButton2", "MouseButton3", "Q", "E", "X", "C", "F"}, ConfigData.aimbot.activationKey, function(v) ConfigData.aimbot.activationKey = v end)
    
    local aimOptions = self.ui:AddSection(aimbotContent, "Options", Colors.Accent)
    self.ui.dropdownBodyAim = self.ui:CreateDropdown(aimOptions, "Hitboxes", {"Head", "Neck", "UpperTorso", "LowerTorso", "Torso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg", "HumanoidRootPart", "Nearest"}, ConfigData.aimbot.bodyAim, function(v) ConfigData.aimbot.bodyAim = v end)
    self.ui:CreateToggle(aimOptions, "Wall Check", ConfigData.aimbot.wallCheck, function(v) ConfigData.aimbot.wallCheck = v end)
    self.ui:CreateToggle(aimOptions, "Team Check", ConfigData.aimbot.teamCheck, function(v) ConfigData.aimbot.teamCheck = v end)
    self.ui:CreateToggle(aimOptions, "Sticky Target", ConfigData.aimbot.stickyTarget, function(v) ConfigData.aimbot.stickyTarget = v end)
    self.ui.sliderPrediction = self.ui:CreateSlider(aimOptions, "Prediction", 0, 200, ConfigData.aimbot.prediction * 1000, function(v) ConfigData.aimbot.prediction = v / 1000 end, "ms")
    
    local aimTrigger = self.ui:AddSection(aimbotContent, "Triggerbot", Colors.Accent)
    self.ui.triggerbotToggle = self.ui:CreateToggle(aimTrigger, "Enable Triggerbot", ConfigData.aimbot.triggerbotEnabled, function(v) ConfigData.aimbot.triggerbotEnabled = v end)
    self.ui.sliderTriggerbotDelay = self.ui:CreateSlider(aimTrigger, "Delay", 0, 500, ConfigData.aimbot.triggerbotDelay, function(v) ConfigData.aimbot.triggerbotDelay = v end, "ms")
    self.ui.sliderTriggerbotFOV = self.ui:CreateSlider(aimTrigger, "FOV", 5, 200, ConfigData.aimbot.triggerbotFov, function(v) ConfigData.aimbot.triggerbotFov = v end, "px")
    
    -- CONFIG TAB
    local configActions = self.ui:AddSection(configContent, "Actions", Colors.Accent)
    self.ui:CreateButton(configActions, "Save Config", function()
        saveConfig()
        self:notify("Config Saved", "Configuration saved successfully!")
    end, "success")
    self.ui:CreateButton(configActions, "Load Config", function()
        loadConfig()
        self:_applyConfig()
        self:notify("Config Loaded", "Configuration loaded successfully!")
    end)
    self.ui:CreateButton(configActions, "Reset to Defaults", function()
        resetConfig()
        self:_applyConfig()
        self:notify("Config Reset", "Configuration reset to defaults!")
    end, "danger")
    
    local configInfo = self.ui:AddSection(configContent, "Information", Colors.Accent)
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
    if self.nightModeToggle then self.nightModeToggle:Set(ConfigData.misc.nightmode) end
    if self.ui.sliderNightModeBrightness then self.ui.sliderNightModeBrightness:Set(ConfigData.misc.nightmodeBrightness * 100) end
    if self.nightModePersistToggle then self.nightModePersistToggle:Set(ConfigData.misc.nightmodePersist) end
    if self.aspectRatioToggle then self.aspectRatioToggle:Set(ConfigData.misc.aspectRatioEnabled) end
    if self.ui.sliderAspectRatioWidth then self.ui.sliderAspectRatioWidth:Set(ConfigData.misc.aspectRatioWidth) end
    if self.ui.sliderAspectRatioHeight then self.ui.sliderAspectRatioHeight:Set(ConfigData.misc.aspectRatioHeight) end
    self.misc:setNightMode(ConfigData.misc.nightmode, ConfigData.misc.nightmodeBrightness)
    self.misc:setAspectRatio(ConfigData.misc.aspectRatioEnabled, ConfigData.misc.aspectRatioWidth, ConfigData.misc.aspectRatioHeight)
    if self.ui.whitelistScroll and self.ui.whitelistScroll.Refresh then
        self.ui.whitelistScroll.Refresh()
    end
    if self.ui.boxToggle then self.ui.boxToggle:Set(ConfigData.esp.boxEnabled) end
    if self.ui.outlineToggle then self.ui.outlineToggle:Set(ConfigData.esp.outlineEnabled) end
    if self.ui.nameToggle then self.ui.nameToggle:Set(ConfigData.esp.nameEnabled) end
    if self.ui.distanceToggle then self.ui.distanceToggle:Set(ConfigData.esp.distanceEnabled) end
    if self.ui.healthBarToggle then self.ui.healthBarToggle:Set(ConfigData.esp.healthBarEnabled) end
    if self.ui.skeletonToggle then self.ui.skeletonToggle:Set(ConfigData.esp.skeletonEnabled) end
    if self.ui.snaplineToggle then self.ui.snaplineToggle:Set(ConfigData.esp.snaplineEnabled) end
    if self.ui.showFovToggle then self.ui.showFovToggle:Set(ConfigData.aimbot.showFov) end
    if self.ui.triggerbotToggle then self.ui.triggerbotToggle:Set(ConfigData.aimbot.triggerbotEnabled) end
    
    -- Apply sliders
    if self.ui.sliderFOV then self.ui.sliderFOV:Set(ConfigData.aimbot.fov) end
    if self.ui.sliderSmoothness then self.ui.sliderSmoothness:Set(ConfigData.aimbot.smoothness) end
    if self.ui.sliderTriggerbotDelay then self.ui.sliderTriggerbotDelay:Set(ConfigData.aimbot.triggerbotDelay) end
    if self.ui.sliderTriggerbotFOV then self.ui.sliderTriggerbotFOV:Set(ConfigData.aimbot.triggerbotFov) end
    if self.ui.sliderPrediction then self.ui.sliderPrediction:Set(ConfigData.aimbot.prediction * 1000) end
    
    -- Apply dropdowns
    if self.ui.dropdownBoxType then self.ui.dropdownBoxType:Set(ConfigData.esp.boxType) end
    if self.ui.dropdownSnaplineMode then self.ui.dropdownSnaplineMode:Set(ConfigData.esp.snaplineMode) end
    if self.ui.dropdownActivationKey then self.ui.dropdownActivationKey:Set(ConfigData.aimbot.activationKey) end
    if self.ui.dropdownBodyAim then self.ui.dropdownBodyAim:Set(ConfigData.aimbot.bodyAim) end
    
    -- Apply colors
    if self.ui.colorBoxColor then self.ui.colorBoxColor:Set(ConfigData.esp.boxColor) end
    if self.ui.colorOutlineColor then self.ui.colorOutlineColor:Set(ConfigData.esp.outlineColor) end
    if self.ui.colorNameColor then self.ui.colorNameColor:Set(ConfigData.esp.nameColor) end
    if self.ui.colorSnaplineColor then self.ui.colorSnaplineColor:Set(ConfigData.esp.snaplineColor) end
    if self.ui.colorDistanceColor then self.ui.colorDistanceColor:Set(ConfigData.esp.distanceColor) end
    if self.ui.colorHealthBarColor then self.ui.colorHealthBarColor:Set(ConfigData.esp.healthBarColor) end
    if self.ui.colorSkeletonColor then self.ui.colorSkeletonColor:Set(ConfigData.esp.skeletonColor) end
    if self.ui.colorFovColor then self.ui.colorFovColor:Set(ConfigData.aimbot.fovColor) end
    
    print("Config applied to UI")
    print("ConfigData saved settings:", ConfigData.esp.enabled, ConfigData.esp.boxEnabled, ConfigData.aimbot.enabled)
end

function App:_bindConfigToUI()
    -- Bind UI elements to ConfigData for real-time sync
    -- ESP
    table.insert(self.uiElements, {type="toggle", ref=self.espToggle, category="esp", key="enabled"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.boxToggle, category="esp", key="boxEnabled"})
    table.insert(self.uiElements, {type="dropdown", ref=self.ui.dropdownBoxType, category="esp", key="boxType"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.outlineToggle, category="esp", key="outlineEnabled"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorBoxColor, category="esp", key="boxColor"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorOutlineColor, category="esp", key="outlineColor"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.nameToggle, category="esp", key="nameEnabled"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorNameColor, category="esp", key="nameColor"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.distanceToggle, category="esp", key="distanceEnabled"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorDistanceColor, category="esp", key="distanceColor"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.healthBarToggle, category="esp", key="healthBarEnabled"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorHealthBarColor, category="esp", key="healthBarColor"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.skeletonToggle, category="esp", key="skeletonEnabled"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorSkeletonColor, category="esp", key="skeletonColor"})

    table.insert(self.uiElements, {type="toggle", ref=self.ui.snaplineToggle, category="esp", key="snaplineEnabled"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorSnaplineColor, category="esp", key="snaplineColor"})
    table.insert(self.uiElements, {type="dropdown", ref=self.ui.dropdownSnaplineMode, category="esp", key="snaplineMode"})
    
    -- Aimbot
    table.insert(self.uiElements, {type="toggle", ref=self.aimbotToggle, category="aimbot", key="enabled"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderFOV, category="aimbot", key="fov"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.showFovToggle, category="aimbot", key="showFov"})
    table.insert(self.uiElements, {type="color", ref=self.ui.colorFovColor, category="aimbot", key="fovColor"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderSmoothness, category="aimbot", key="smoothness"})
    table.insert(self.uiElements, {type="dropdown", ref=self.ui.dropdownActivationKey, category="aimbot", key="activationKey"})
    table.insert(self.uiElements, {type="dropdown", ref=self.ui.dropdownBodyAim, category="aimbot", key="bodyAim"})
    table.insert(self.uiElements, {type="toggle", ref=self.ui.triggerbotToggle, category="aimbot", key="triggerbotEnabled"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderTriggerbotDelay, category="aimbot", key="triggerbotDelay"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderTriggerbotFOV, category="aimbot", key="triggerbotFov"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderPrediction, category="aimbot", key="prediction"})
    
    -- Misc
    table.insert(self.uiElements, {type="toggle", ref=self.nightModeToggle, category="misc", key="nightmode"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderNightModeBrightness, category="misc", key="nightmodeBrightness"})
    table.insert(self.uiElements, {type="toggle", ref=self.nightModePersistToggle, category="misc", key="nightmodePersist"})
    table.insert(self.uiElements, {type="toggle", ref=self.aspectRatioToggle, category="misc", key="aspectRatioEnabled"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderAspectRatioWidth, category="misc", key="aspectRatioWidth"})
    table.insert(self.uiElements, {type="slider", ref=self.ui.sliderAspectRatioHeight, category="misc", key="aspectRatioHeight"})
end

function App:notify(title, message)
    -- Simple notification
    print(string.format("[%s] %s", title, message))
end

function App:_setupESP()
    local function onPlayerAdded(player)
        if player == LocalPlayer then return end
        self.espObjects[player] = ESPObject.new(player)
        task.spawn(function()
            cacheFriendship(player)
            if isFriend(player) and not tableFind(ConfigData.esp.whitelist, player.Name) then
                table.insert(ConfigData.esp.whitelist, player.Name)
                ConfigData.aimbot.whitelist = ConfigData.esp.whitelist
                saveConfig()
            end
            if self.ui.whitelistScroll and self.ui.whitelistScroll.Refresh then
                self.ui.whitelistScroll.Refresh()
            end
        end)
    end
    
    local function onPlayerRemoving(player)
        friendCache[player.UserId] = nil
        if self.espObjects[player] then
            self.espObjects[player]:destroy()
            self.espObjects[player] = nil
        end
        if self.ui.whitelistScroll and self.ui.whitelistScroll.Refresh then
            self.ui.whitelistScroll.Refresh()
        end
    end
    
    for _, player in ipairs(Services.Players:GetPlayers()) do
        onPlayerAdded(player)
        if player ~= LocalPlayer then
            task.spawn(function() cacheFriendship(player) end)
        end
    end
    
    self.ui:_connect(Services.Players.PlayerAdded, onPlayerAdded)
    self.ui:_connect(Services.Players.PlayerRemoving, onPlayerRemoving)
    
    self.ui:_connect(Services.RunService.RenderStepped, function()
        if not ConfigData.esp.enabled then
            for _, obj in pairs(self.espObjects) do obj:hide() end
            return
        end
        
        local cam = Services.Workspace.CurrentCamera
        if not cam then
            for _, obj in pairs(self.espObjects) do obj:hide() end
            return
        end
        local localChar = LocalPlayer.Character
        
        for player, obj in pairs(self.espObjects) do
            local isTeammate = ConfigData.esp.teamCheck and player.Team == LocalPlayer.Team
            if not isTeammate and not isWhitelisted(player) then
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
    local lightingCheckElapsed = 0

    -- Round scripts can reset Lighting, but checking four times per second avoids per-frame property contention.
    self.ui:_connect(Services.RunService.RenderStepped, function(delta)
        lightingCheckElapsed = lightingCheckElapsed + delta
        if lightingCheckElapsed >= 0.25 then
            lightingCheckElapsed = 0
            if ConfigData.misc.nightmode and ConfigData.misc.nightmodePersist then
                self.misc:setNightMode(true, ConfigData.misc.nightmodeBrightness)
            end
        end

        self.misc.aspectRatioEnabled = ConfigData.misc.aspectRatioEnabled == true
        self.misc.aspectRatioWidth = math.max(1, tonumber(ConfigData.misc.aspectRatioWidth) or 16)
        self.misc.aspectRatioHeight = math.max(1, tonumber(ConfigData.misc.aspectRatioHeight) or 9)
        self.misc:applyAspectRatio(false)
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
