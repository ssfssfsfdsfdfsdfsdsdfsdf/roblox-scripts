local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Brainrot Tycoon Hub",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "by Assistant",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Positions
local BASE_POS = Vector3.new(-104.81, 19.08, -133.91)
local SECRET_POS = Vector3.new(-108.72, 27.55, 813.63)
local OG_POS = Vector3.new(-108.72, 27.55, 813.63)

-- Data Lists
local AxesList = {
    "Wood", "Iron", "Gold", "Diamond", "Bamboo", 
    "Neon", "Lava", "Lightning", "Galaxy", "Rainbow", "YingYang"
}

-- Updated: Only OG and God / Godly rarities
local AllowedRarities = { "og", "god", "godly" }

-- Toggles
local Toggles = {
    AutoUpgrade = false,
    AutoCollectCash = false,
    AutoPlace = false,
    AutoUpgradeBrainrots = false,
    AutoFarmBrainrot = false,
    AutoBuyDamage = false,
    AutoBuyCarry = false,
    AutoBuyCapacity = false,
    AutoBuyAxes = false
}

-- Utility Functions
local function teleportTo(position)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

local function triggerPrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0.5)
        prompt:InputHoldEnd()
    end
end

local function isAllowedRarity(object)
    local combinedText = object.Name .. " " .. (object.Parent and object.Parent.Name or "")
    for _, child in ipairs(object:GetDescendants()) do
        if child:IsA("TextLabel") then
            combinedText = combinedText .. " " .. child.Text
        end
    end
    combinedText = combinedText:lower()
    
    for _, rarity in ipairs(AllowedRarities) do
        if string.find(combinedText, rarity) then
            return true
        end
    end
    return false
end

-- UI Tabs
local MainTab = Window:CreateTab("Auto Farm", 4483362458)
local BaseTab = Window:CreateTab("Base Manager", 4483362458)
local ShopTab = Window:CreateTab("Upgrades & Shop", 4483362458)
local TeleportTab = Window:CreateTab("Teleports", 4483362458)

-- ==================== AUTO FARM TAB ====================
MainTab:CreateToggle({
    Name = "Auto Farm Brainrots (OG & Godly Only)",
    CurrentValue = false,
    Flag = "AutoFarmBrainrot",
    Callback = function(Value)
        Toggles.AutoFarmBrainrot = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoFarmBrainrot do
                    teleportTo(SECRET_POS)
                    task.wait(1)

                    local targetPrompt = nil
                    for _, desc in ipairs(Workspace:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and desc.Enabled then
                            if desc.Parent and isAllowedRarity(desc.Parent) then
                                targetPrompt = desc
                                break
                            end
                        end
                    end

                    if targetPrompt and targetPrompt.Parent then
                        local itemPos = targetPrompt.Parent:GetPivot().Position
                        teleportTo(itemPos + Vector3.new(0, 3, 0))
                        task.wait(0.3)
                        
                        triggerPrompt(targetPrompt)
                        task.wait(0.8)

                        teleportTo(BASE_POS)
                        task.wait(1.5)
                    else
                        task.wait(2)
                    end
                end
            end)
        end
    end,
})

-- ==================== BASE MANAGER TAB ====================
BaseTab:CreateToggle({
    Name = "Auto Upgrade Base",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(Value)
        Toggles.AutoUpgrade = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoUpgrade do
                    local remote = Remotes:FindFirstChild("BaseUpgradeEvent")
                    if remote then remote:FireServer() end
                    task.wait(1)
                end
            end)
        end
    end,
})

BaseTab:CreateToggle({
    Name = "Auto Collect Cash (Slots 1-50)",
    CurrentValue = false,
    Flag = "AutoCollectCash",
    Callback = function(Value)
        Toggles.AutoCollectCash = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoCollectCash do
                    local remote = Remotes:FindFirstChild("CollectCashEvent")
                    if remote then
                        for slot = 1, 50 do
                            if not Toggles.AutoCollectCash then break end
                            remote:FireServer(slot)
                            task.wait(0.02)
                        end
                    end
                    task.wait(1.5)
                end
            end)
        end
    end,
})

BaseTab:CreateToggle({
    Name = "Auto Place Inventory Brainrots (1-50)",
    CurrentValue = false,
    Flag = "AutoPlace",
    Callback = function(Value)
        Toggles.AutoPlace = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoPlace do
                    local remote = Remotes:FindFirstChild("PlaceBrainrotEvent")
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    
                    if remote and backpack then
                        for _, item in ipairs(backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                for slot = 1, 50 do
                                    if not Toggles.AutoPlace then break end
                                    remote:FireServer(tostring(slot), item.Name)
                                    task.wait(0.03)
                                end
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end,
})

BaseTab:CreateToggle({
    Name = "Auto Upgrade All Brainrots (1-50)",
    CurrentValue = false,
    Flag = "AutoUpgradeBrainrots",
    Callback = function(Value)
        Toggles.AutoUpgradeBrainrots = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoUpgradeBrainrots do
                    local remote = Remotes:FindFirstChild("UpgradeBrainrotEvent")
                    if remote then
                        for slot = 1, 50 do
                            if not Toggles.AutoUpgradeBrainrots then break end
                            remote:FireServer(slot)
                            task.wait(0.03)
                        end
                    end
                    task.wait(1.5)
                end
            end)
        end
    end,
})

-- ==================== UPGRADES & SHOP TAB ====================
ShopTab:CreateSection("Stat Upgrades")

ShopTab:CreateToggle({
    Name = "Auto Buy Damage (+10)",
    CurrentValue = false,
    Flag = "AutoBuyDamage",
    Callback = function(Value)
        Toggles.AutoBuyDamage = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoBuyDamage do
                    local remote = Remotes:FindFirstChild("BuyUpgradeEvent")
                    if remote then remote:FireServer("Damage", 10) end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

ShopTab:CreateToggle({
    Name = "Auto Buy Carry (+1)",
    CurrentValue = false,
    Flag = "AutoBuyCarry",
    Callback = function(Value)
        Toggles.AutoBuyCarry = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoBuyCarry do
                    local remote = Remotes:FindFirstChild("BuyUpgradeEvent")
                    if remote then remote:FireServer("Carry", 1) end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

ShopTab:CreateToggle({
    Name = "Auto Buy Capacity (+10)",
    CurrentValue = false,
    Flag = "AutoBuyCapacity",
    Callback = function(Value)
        Toggles.AutoBuyCapacity = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoBuyCapacity do
                    local remote = Remotes:FindFirstChild("BuyUpgradeEvent")
                    if remote then remote:FireServer("Capacity", 10) end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

ShopTab:CreateSection("Axes & Shovels")

ShopTab:CreateToggle({
    Name = "Auto Buy All Axes (Progressive)",
    CurrentValue = false,
    Flag = "AutoBuyAxes",
    Callback = function(Value)
        Toggles.AutoBuyAxes = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoBuyAxes do
                    local remote = Remotes:FindFirstChild("BuyShovelEvent")
                    if remote then
                        for _, axeName in ipairs(AxesList) do
                            if not Toggles.AutoBuyAxes then break end
                            remote:FireServer(axeName)
                            task.wait(0.2)
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end,
})

ShopTab:CreateDropdown({
    Name = "Buy Specific Axe",
    Options = AxesList,
    CurrentOption = {"Wood"},
    MultipleOptions = false,
    Flag = "SelectAxe",
    Callback = function(Option)
        local selectedAxe = type(Option) == "table" and Option[1] or Option
        local remote = Remotes:FindFirstChild("BuyShovelEvent")
        if remote then
            remote:FireServer(selectedAxe)
        end
    end,
})

-- ==================== TELEPORT TAB ====================
TeleportTab:CreateButton({
    Name = "Teleport to Base",
    Callback = function() teleportTo(BASE_POS) end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Secret Area",
    Callback = function() teleportTo(SECRET_POS) end,
})

TeleportTab:CreateButton({
    Name = "Teleport to OG Area",
    Callback = function() teleportTo(OG_POS) end,
})
