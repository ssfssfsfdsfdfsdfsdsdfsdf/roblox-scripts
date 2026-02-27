-- ===============================
--   Universal Cheat GUI Script
--   Draggable | Toggle Cheats
-- ===============================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ===============================
--        CHEAT VARIABLES
-- ===============================
local speedValue = 100
local flySpeed = 60
local flying = false
local godModeOn = false
local speedOn = false
local bodyVelocity, bodyGyro

-- ===============================
--        CREATE GUI
-- ===============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Try to parent to CoreGui to survive games
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true  -- Makes it draggable!
MainFrame.Parent = ScreenGui

-- Rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Stroke/outline
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(100, 80, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(100, 80, 255)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Title Text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ Cheat Menu"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ===============================
--      BUTTON CREATOR FUNCTION
-- ===============================
local buttonYPos = 50 -- starting Y position for buttons

local function createButton(labelText, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, buttonYPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 80)
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    buttonYPos = buttonYPos + 55 -- move next button down
    return btn
end

-- Status label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 1, -28)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ready!"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

local function setStatus(msg)
    StatusLabel.Text = "▶ " .. msg
end

-- Create all buttons
local GodBtn   = createButton("🛡️ God Mode: OFF", Color3.fromRGB(60, 60, 80))
local SpeedBtn = createButton("⚡ Speed: OFF",     Color3.fromRGB(60, 60, 80))
local FlyBtn   = createButton("🚀 Fly: OFF",       Color3.fromRGB(60, 60, 80))

-- ===============================
--        CHEAT FUNCTIONS
-- ===============================

-- GOD MODE
local function toggleGodMode()
    godModeOn = not godModeOn
    if godModeOn then
        GodBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
        GodBtn.Text = "🛡️ God Mode: ON"
        setStatus("God Mode ON!")
        RunService.Heartbeat:Connect(function()
            if not godModeOn then return end
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.MaxHealth = math.huge
                        hum.Health = math.huge
                    end
                end
            end)
        end)
    else
        GodBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        GodBtn.Text = "🛡️ God Mode: OFF"
        setStatus("God Mode OFF")
    end
end

-- SPEED
local function toggleSpeed()
    speedOn = not speedOn
    if speedOn then
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
        SpeedBtn.Text = "⚡ Speed: ON"
        setStatus("Speed ON!")
        RunService.Heartbeat:Connect(function()
            if not speedOn then return end
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then hum.WalkSpeed = speedValue end
                end
            end)
        end)
    else
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        SpeedBtn.Text = "⚡ Speed: OFF"
        setStatus("Speed OFF")
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
    end
end

-- FLY
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.D = 100
    bodyGyro.Parent = root

    hum.PlatformStand = true
    flying = true

    RunService.Heartbeat:Connect(function()
        if not flying then return end
        pcall(function()
            local cam = workspace.CurrentCamera
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

            bodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
            bodyGyro.CFrame = cam.CFrame
        end)
    end)
end

local function stopFly()
    flying = false
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end)
end

local function toggleFly()
    flying = not flying
    if flying then
        FlyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
        FlyBtn.Text = "🚀 Fly: ON"
        setStatus("Flying! WASD to move")
        startFly()
    else
        FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        FlyBtn.Text = "🚀 Fly: OFF"
        setStatus("Fly OFF")
        stopFly()
    end
end

-- ===============================
--        BUTTON CLICKS
-- ===============================
GodBtn.MouseButton1Click:Connect(toggleGodMode)
SpeedBtn.MouseButton1Click:Connect(toggleSpeed)
FlyBtn.MouseButton1Click:Connect(toggleFly)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ===============================
--        HOVER EFFECTS
-- ===============================
local function addHover(btn, activeColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = activeColor or Color3.fromRGB(80, 80, 110)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        -- only revert if not active (ON)
        if not btn.Text:find("ON") then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            }):Play()
        end
    end)
end

addHover(GodBtn)
addHover(SpeedBtn)
addHover(FlyBtn)

print("✅ Cheat GUI Loaded! Check your screen.")
