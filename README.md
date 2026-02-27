-- Simple version, more compatible
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "CheatGUI"

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
    gui.Parent = lp.PlayerGui
end

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 280)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(90, 60, 200)
title.Text = "⚡ Cheat Menu"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Button maker
local function makeBtn(text, ypos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 170, 0, 45)
    b.Position = UDim2.new(0, 15, 0, ypos)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local godBtn   = makeBtn("🛡️ God Mode: OFF", 45)
local spdBtn   = makeBtn("⚡ Speed: OFF",    100)
local flyBtn   = makeBtn("🚀 Fly: OFF",      155)
local closeBtn = makeBtn("❌ Close",          215)

closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)

-- State
local godOn, spdOn, flyOn = false, false, false
local bv, bg

-- GOD MODE
godBtn.MouseButton1Click:Connect(function()
    godOn = not godOn
    godBtn.BackgroundColor3 = godOn and Color3.fromRGB(40,160,70) or Color3.fromRGB(50,50,70)
    godBtn.Text = godOn and "🛡️ God Mode: ON" or "🛡️ God Mode: OFF"
end)

RunService.Heartbeat:Connect(function()
    if not godOn then return end
    pcall(function()
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
        end
    end)
end)

-- SPEED
spdBtn.MouseButton1Click:Connect(function()
    spdOn = not spdOn
    spdBtn.BackgroundColor3 = spdOn and Color3.fromRGB(40,160,70) or Color3.fromRGB(50,50,70)
    spdBtn.Text = spdOn and "⚡ Speed: ON" or "⚡ Speed: OFF"
end)

RunService.Heartbeat:Connect(function()
    if not spdOn then return end
    pcall(function()
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 100 end
        end
    end)
end)

-- FLY
flyBtn.MouseButton1Click:Connect(function()
    flyOn = not flyOn
    flyBtn.BackgroundColor3 = flyOn and Color3.fromRGB(40,160,70) or Color3.fromRGB(50,50,70)
    flyBtn.Text = flyOn and "🚀 Fly: ON" or "🚀 Fly: OFF"

    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if flyOn then
        hum.PlatformStand = true
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9,1e9,1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = root
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
        bg.D = 100
        bg.Parent = root
    else
        hum.PlatformStand = false
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end)

RunService.Heartbeat:Connect(function()
    if not flyOn or not bv or not bg then return end
    pcall(function()
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * 60 or Vector3.zero
        bg.CFrame = cam.CFrame
    end)
end)

-- CLOSE
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("✅ GUI Loaded!")
