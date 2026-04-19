-- POWERS MENU
-- Invisible | Speed | Fly | NoClip | Anti-Fling

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- =====================
-- STATE
-- =====================
local powers = {
    invisible = false,
    speed     = false,
    fly       = false,
    noclip    = false,
    antifling = false,
}

local FLY_SPEED     = 60
local WALK_SPEED    = 100
local DEFAULT_SPEED = 16

local flyBodyVelocity  = nil
local flyBodyGyro      = nil
local flyConnection    = nil
local noclipConnection = nil
local speedConnection  = nil
local antiflingConn    = nil

-- =====================
-- HELPERS
-- =====================
local function getHRP()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHuman()
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- =====================
-- INVISIBLE
-- =====================
local function applyInvisible(on)
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.LocalTransparencyModifier = on and 1 or 0
        end
    end
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                handle.LocalTransparencyModifier = on and 1 or 0
            end
        end
    end
end

-- =====================
-- SPEED
-- FIX: loop every Heartbeat because games reset WalkSpeed each frame
-- =====================
local function stopSpeed()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    local hum = getHuman()
    if hum then
        pcall(function() hum.WalkSpeed = DEFAULT_SPEED end)
    end
end

local function startSpeed()
    stopSpeed()
    speedConnection = RunService.Heartbeat:Connect(function()
        local hum = getHuman()
        if not hum then return end
        pcall(function()
            if hum.WalkSpeed ~= WALK_SPEED then
                hum.WalkSpeed = WALK_SPEED
            end
        end)
    end)
end

local function applySpeed(on)
    if on then startSpeed() else stopSpeed() end
end

-- =====================
-- FLY
-- =====================
local function stopFly()
    if flyConnection   then flyConnection:Disconnect()                    flyConnection   = nil end
    if flyBodyVelocity then pcall(function() flyBodyVelocity:Destroy() end) flyBodyVelocity = nil end
    if flyBodyGyro     then pcall(function() flyBodyGyro:Destroy() end)     flyBodyGyro     = nil end
    local hum = getHuman()
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.AutoRotate    = true
        end)
    end
end

local function startFly()
    local hrp = getHRP()
    local hum = getHuman()
    if not hrp or not hum then return end

    pcall(function()
        hum.PlatformStand = true
        hum.AutoRotate    = false
    end)

    flyBodyVelocity          = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVelocity.P        = 1e4
    flyBodyVelocity.Parent   = hrp

    flyBodyGyro           = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.P         = 1e4
    flyBodyGyro.D         = 500
    flyBodyGyro.Parent    = hrp

    flyConnection = RunService.Heartbeat:Connect(function()
        local hrpNow = getHRP()
        if not hrpNow or not powers.fly then stopFly() return end
        pcall(function()
            local cf  = camera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) or
               UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                dir = dir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                dir = dir - Vector3.new(0, 1, 0)
            end
            flyBodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * FLY_SPEED or Vector3.zero
            flyBodyGyro.CFrame       = CFrame.new(Vector3.zero, cf.LookVector)
        end)
    end)
end

local function applyFly(on)
    if on then startFly() else stopFly() end
end

-- =====================
-- NOCLIP
-- =====================
local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local char = player.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p.CanCollide = true end)
            end
        end
    end
end

local function startNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p.CanCollide = false end)
            end
        end
    end)
end

local function applyNoclip(on)
    if on then startNoclip() else stopNoclip() end
end

-- =====================
-- ANTI-FLING
-- Zeros velocity if it spikes above a threshold (fling detection)
-- =====================
local function stopAntiFling()
    if antiflingConn then
        antiflingConn:Disconnect()
        antiflingConn = nil
    end
end

local function startAntiFling()
    stopAntiFling()
    antiflingConn = RunService.Stepped:Connect(function()
        local hrp = getHRP()
        if not hrp then return end
        pcall(function()
            if hrp.AssemblyLinearVelocity.Magnitude > 100 then
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end)
end

local function applyAntiFling(on)
    if on then startAntiFling() else stopAntiFling() end
end

-- =====================
-- RE-APPLY ON RESPAWN
-- =====================
player.CharacterAdded:Connect(function(char)
    pcall(function()
        char:WaitForChild("Humanoid", 10)
        task.wait(0.5)
        if powers.invisible then applyInvisible(true) end
        if powers.speed     then applySpeed(true)     end
        if powers.fly       then applyFly(true)        end
        if powers.noclip    then applyNoclip(true)     end
        if powers.antifling then applyAntiFling(true)  end
    end)
end)

-- =====================
-- GUI SETUP
-- =====================
local existing = player.PlayerGui:FindFirstChild("PowersMenu")
if existing then existing:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name           = "PowersMenu"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = player.PlayerGui

local openBtn = Instance.new("TextButton")
openBtn.Size             = UDim2.new(0, 110, 0, 34)
openBtn.Position         = UDim2.new(0, 10, 0.5, -17)
openBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
openBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
openBtn.Text             = "⚡ POWERS"
openBtn.Font             = Enum.Font.GothamBold
openBtn.TextSize         = 13
openBtn.BorderSizePixel  = 0
openBtn.ZIndex           = 10
openBtn.Parent           = sg
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)

local WIN_W, WIN_H = 260, 420
local win = Instance.new("Frame")
win.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
win.Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
win.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
win.BorderSizePixel  = 0
win.Visible          = false
win.ZIndex           = 5
win.Parent           = sg
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)

local shadow = Instance.new("Frame")
shadow.Size                  = UDim2.new(1, 16, 1, 16)
shadow.Position              = UDim2.new(0, -8, 0, -8)
shadow.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel       = 0
shadow.ZIndex                = 4
shadow.Parent                = win
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 14)

local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
titleBar.BorderSizePixel  = 0
titleBar.ZIndex           = 6
titleBar.Parent           = win
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size                = UDim2.new(1, -44, 1, 0)
titleLbl.Position            = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text                = "⚡ Powers Menu"
titleLbl.TextColor3          = Color3.fromRGB(255, 255, 255)
titleLbl.Font                = Enum.Font.GothamBold
titleLbl.TextSize            = 14
titleLbl.TextXAlignment      = Enum.TextXAlignment.Left
titleLbl.ZIndex              = 7
titleLbl.Parent              = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 28, 0, 28)
closeBtn.Position         = UDim2.new(1, -34, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 13
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 8
closeBtn.Parent           = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame")
scroll.Size                = UDim2.new(1, -16, 1, -52)
scroll.Position            = UDim2.new(0, 8, 0, 48)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel     = 0
scroll.ScrollBarThickness  = 3
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize          = UDim2.new(0, 0, 0, 0)
scroll.ZIndex              = 6
scroll.Parent              = win

local ll = Instance.new("UIListLayout")
ll.Padding   = UDim.new(0, 8)
ll.SortOrder = Enum.SortOrder.LayoutOrder
ll.Parent    = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop    = UDim.new(0, 4)
pad.PaddingBottom = UDim.new(0, 8)
pad.Parent        = scroll

-- =====================
-- UI BUILDERS
-- =====================
local function addSection(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size                = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text                = text
    lbl.TextColor3          = Color3.fromRGB(100, 130, 220)
    lbl.Font                = Enum.Font.GothamBold
    lbl.TextSize            = 10
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 7
    lbl.Parent              = parent
end

local function makeToggleRow(parent, icon, label, description, color, onToggle)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 72)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    row.BorderSizePixel  = 0
    row.ZIndex           = 7
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local accent = Instance.new("Frame")
    accent.Size             = UDim2.new(0, 4, 1, -16)
    accent.Position         = UDim2.new(0, 0, 0, 8)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel  = 0
    accent.ZIndex           = 8
    accent.Parent           = row
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 4)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size             = UDim2.new(0, 36, 0, 36)
    iconLbl.Position         = UDim2.new(0, 12, 0.5, -18)
    iconLbl.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    iconLbl.Text             = icon
    iconLbl.Font             = Enum.Font.GothamBold
    iconLbl.TextSize         = 20
    iconLbl.BorderSizePixel  = 0
    iconLbl.ZIndex           = 8
    iconLbl.Parent           = row
    Instance.new("UICorner", iconLbl).CornerRadius = UDim.new(0, 8)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                = UDim2.new(0, 120, 0, 20)
    nameLbl.Position            = UDim2.new(0, 56, 0, 12)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text                = label
    nameLbl.TextColor3          = Color3.fromRGB(230, 230, 240)
    nameLbl.Font                = Enum.Font.GothamBold
    nameLbl.TextSize            = 13
    nameLbl.TextXAlignment      = Enum.TextXAlignment.Left
    nameLbl.ZIndex              = 8
    nameLbl.Parent              = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Size                = UDim2.new(0, 120, 0, 16)
    descLbl.Position            = UDim2.new(0, 56, 0, 34)
    descLbl.BackgroundTransparency = 1
    descLbl.Text                = description
    descLbl.TextColor3          = Color3.fromRGB(130, 130, 155)
    descLbl.Font                = Enum.Font.Gotham
    descLbl.TextSize            = 10
    descLbl.TextXAlignment      = Enum.TextXAlignment.Left
    descLbl.ZIndex              = 8
    descLbl.Parent              = row

    local state = false
    local toggleBtnInner = Instance.new("TextButton")
    toggleBtnInner.Size             = UDim2.new(0, 56, 0, 28)
    toggleBtnInner.Position         = UDim2.new(1, -64, 0.5, -14)
    toggleBtnInner.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    toggleBtnInner.Text             = "OFF"
    toggleBtnInner.TextColor3       = Color3.fromRGB(180, 180, 180)
    toggleBtnInner.Font             = Enum.Font.GothamBold
    toggleBtnInner.TextSize         = 12
    toggleBtnInner.BorderSizePixel  = 0
    toggleBtnInner.ZIndex           = 9
    toggleBtnInner.Parent           = row
    Instance.new("UICorner", toggleBtnInner).CornerRadius = UDim.new(0, 8)

    toggleBtnInner.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggleBtnInner.Text             = "ON"
            toggleBtnInner.BackgroundColor3 = color
            toggleBtnInner.TextColor3       = Color3.fromRGB(255, 255, 255)
            row.BackgroundColor3            = Color3.fromRGB(28, 30, 50)
        else
            toggleBtnInner.Text             = "OFF"
            toggleBtnInner.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            toggleBtnInner.TextColor3       = Color3.fromRGB(180, 180, 180)
            row.BackgroundColor3            = Color3.fromRGB(22, 22, 38)
        end
        pcall(onToggle, state)
    end)
end

local function makeSlider(parent, labelText, defaultVal, minVal, maxVal, step, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 60)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    row.BorderSizePixel  = 0
    row.ZIndex           = 7
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Size                = UDim2.new(0.5, 0, 0, 20)
    lbl.Position            = UDim2.new(0, 12, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text                = labelText
    lbl.TextColor3          = Color3.fromRGB(200, 200, 220)
    lbl.Font                = Enum.Font.GothamBold
    lbl.TextSize            = 12
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 8
    lbl.Parent              = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size                = UDim2.new(0.4, 0, 0, 20)
    valLbl.Position            = UDim2.new(0.6, 0, 0, 8)
    valLbl.BackgroundTransparency = 1
    valLbl.Text                = tostring(defaultVal)
    valLbl.TextColor3          = Color3.fromRGB(100, 200, 255)
    valLbl.Font                = Enum.Font.GothamBold
    valLbl.TextSize            = 12
    valLbl.TextXAlignment      = Enum.TextXAlignment.Right
    valLbl.ZIndex              = 8
    valLbl.Parent              = row

    local current = defaultVal
    local function update(v)
        current = math.clamp(v, minVal, maxVal)
        valLbl.Text = tostring(current)
        pcall(onChange, current)
    end

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size             = UDim2.new(0, 32, 0, 24)
    minusBtn.Position         = UDim2.new(0, 12, 1, -32)
    minusBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    minusBtn.Text             = "−"
    minusBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    minusBtn.Font             = Enum.Font.GothamBold
    minusBtn.TextSize         = 14
    minusBtn.BorderSizePixel  = 0
    minusBtn.ZIndex           = 8
    minusBtn.Parent           = row
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size             = UDim2.new(0, 32, 0, 24)
    plusBtn.Position         = UDim2.new(0, 52, 1, -32)
    plusBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
    plusBtn.Text             = "+"
    plusBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    plusBtn.Font             = Enum.Font.GothamBold
    plusBtn.TextSize         = 14
    plusBtn.BorderSizePixel  = 0
    plusBtn.ZIndex           = 8
    plusBtn.Parent           = row
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size             = UDim2.new(0, 60, 0, 24)
    resetBtn.Position         = UDim2.new(1, -72, 1, -32)
    resetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    resetBtn.Text             = "Reset"
    resetBtn.TextColor3       = Color3.fromRGB(200, 200, 200)
    resetBtn.Font             = Enum.Font.GothamBold
    resetBtn.TextSize         = 11
    resetBtn.BorderSizePixel  = 0
    resetBtn.ZIndex           = 8
    resetBtn.Parent           = row
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)

    minusBtn.MouseButton1Click:Connect(function() update(current - step) end)
    plusBtn.MouseButton1Click:Connect(function()  update(current + step) end)
    resetBtn.MouseButton1Click:Connect(function() update(defaultVal)     end)
end

-- =====================
-- BUILD ROWS
-- =====================
addSection(scroll, "  POWERS")

makeToggleRow(scroll, "👻", "Invisible", "Hide your character",
    Color3.fromRGB(160, 80, 255),
    function(on)
        powers.invisible = on
        applyInvisible(on)
    end
)

makeToggleRow(scroll, "💨", "Speed", "Boost walk speed",
    Color3.fromRGB(255, 160, 40),
    function(on)
        powers.speed = on
        applySpeed(on)
    end
)

makeSlider(scroll, "Walk Speed", WALK_SPEED, 1, 500, 10, function(v)
    WALK_SPEED = v
    if powers.speed then
        local hum = getHuman()
        if hum then pcall(function() hum.WalkSpeed = WALK_SPEED end) end
    end
end)

makeToggleRow(scroll, "🚀", "Fly", "W/A/S/D + E up, Q down",
    Color3.fromRGB(80, 180, 255),
    function(on)
        powers.fly = on
        applyFly(on)
    end
)

makeSlider(scroll, "Fly Speed", FLY_SPEED, 10, 500, 10, function(v)
    FLY_SPEED = v
end)

makeToggleRow(scroll, "🔮", "NoClip", "Walk through walls",
    Color3.fromRGB(60, 220, 140),
    function(on)
        powers.noclip = on
        applyNoclip(on)
    end
)

makeToggleRow(scroll, "🛡️", "Anti-Fling", "Can't be launched away",
    Color3.fromRGB(220, 80, 80),
    function(on)
        powers.antifling = on
        applyAntiFling(on)
    end
)

addSection(scroll, "  KEYBINDS (Fly Mode)")
local hintLbl = Instance.new("TextLabel")
hintLbl.Size                = UDim2.new(1, 0, 0, 50)
hintLbl.BackgroundColor3    = Color3.fromRGB(18, 18, 32)
hintLbl.TextColor3          = Color3.fromRGB(130, 130, 160)
hintLbl.Text                = "W/A/S/D — Direction\nSpace / E — Up   |   Q — Down"
hintLbl.Font                = Enum.Font.Code
hintLbl.TextSize            = 11
hintLbl.TextWrapped         = true
hintLbl.BorderSizePixel     = 0
hintLbl.ZIndex              = 7
hintLbl.Parent              = scroll
Instance.new("UICorner", hintLbl).CornerRadius = UDim.new(0, 8)

-- =====================
-- DRAG
-- =====================
local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = win.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- =====================
-- OPEN / CLOSE
-- =====================
openBtn.MouseButton1Click:Connect(function()
    win.Visible = not win.Visible
    if win.Visible then
        win.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
    end
end)
closeBtn.MouseButton1Click:Connect(function()
    win.Visible = false
end)
