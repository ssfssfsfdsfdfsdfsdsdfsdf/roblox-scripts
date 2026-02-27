-- Universal Cheat Script
-- Works on most Roblox games
-- Load with: loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Wait for character
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ===============================
--         GOD MODE / INF HEALTH
-- ===============================
local function enableGodMode()
    local char = getChar()
    local humanoid = char:WaitForChild("Humanoid")
    
    -- Set max health and keep it full
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
    
    -- Keep health topped up every frame
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if h then
                h.MaxHealth = math.huge
                h.Health = math.huge
            end
        end)
    end)
    
    print("[Script] God Mode ON")
end

-- ===============================
--         SPEED BOOST
-- ===============================
local speedValue = 100 -- change this number for faster/slower

local function enableSpeed()
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = speedValue
                end
            end
        end)
    end)
    print("[Script] Speed ON - Speed: " .. speedValue)
end

-- ===============================
--         FLY SCRIPT
-- ===============================
local flying = false
local flySpeed = 50 -- change for faster/slower flying
local bodyVelocity, bodyGyro

local function enableFly()
    local char = getChar()
    local rootPart = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.Parent = rootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.D = 100
    bodyGyro.Parent = rootPart

    humanoid.PlatformStand = true
    flying = true

    RunService.Heartbeat:Connect(function()
        if not flying then return end
        pcall(function()
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.zero

            -- WASD movement in fly mode
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
            -- Up and down
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            if moveDir.Magnitude > 0 then
                bodyVelocity.Velocity = moveDir.Unit * flySpeed
            else
                bodyVelocity.Velocity = Vector3.zero
            end

            bodyGyro.CFrame = cam.CFrame
        end)
    end)

    print("[Script] Fly ON - Press F to toggle fly")
end

local function disableFly()
    flying = false
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    print("[Script] Fly OFF")
end

-- ===============================
--         KEYBINDS
-- ===============================
-- F = Toggle Fly
-- G = Toggle Speed (on/off)

local speedOn = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle Fly with F key
    if input.KeyCode == Enum.KeyCode.F then
        if flying then
            disableFly()
        else
            enableFly()
        end
    end
    
    -- Toggle Speed with G key
    if input.KeyCode == Enum.KeyCode.G then
        speedOn = not speedOn
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = speedOn and speedValue or 16
                print("[Script] Speed: " .. (speedOn and "ON" or "OFF"))
            end
        end
    end
end)

-- ===============================
--         START
-- ===============================
enableGodMode()
enableSpeed()

print("===============================")
print("  Cheat Script Loaded!")
print("  F = Toggle Fly")
print("  G = Toggle Speed")
print("  God Mode: Always ON")
print("===============================")
