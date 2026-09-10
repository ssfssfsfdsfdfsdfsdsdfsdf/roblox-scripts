local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Function to create ESP elements for a player
local function createESP(player)
	if player == LocalPlayer then return end

	local function onCharacterAdded(character)
		-- Wait for essential character parts
		local head = character:WaitForChild("Head", 10)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not head or not humanoid then return end

		-- 1. Full-Body Highlight (See whole player through walls)
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESPHighlight"
		highlight.FillColor = Color3.fromRGB(255, 50, 50)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = character
		highlight.Parent = character

		-- 2. BillboardGui above the head (Name + Health Bar)
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESPBillboard"
		billboard.Size = UDim2.new(0, 150, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = head
		billboard.Parent = character

		-- Player Name Label
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = player.DisplayName
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.Parent = billboard

		-- Health Bar Background
		local healthBg = Instance.new("Frame")
		healthBg.Size = UDim2.new(1, 0, 0.3, 0)
		healthBg.Position = UDim2.new(0, 0, 0.5, 0)
		healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		healthBg.BorderSizePixel = 0
		healthBg.Parent = billboard

		-- Health Bar Fill
		local healthFill = Instance.new("Frame")
		healthFill.Size = UDim2.new(1, 0, 1, 0)
		healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		healthFill.BorderSizePixel = 0
		healthFill.Parent = healthBg

		-- 3. Update Health dynamically
		local function updateHealth()
			local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)

			-- Change color dynamically based on health
			if healthPercent > 0.6 then
				healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
			elseif healthPercent > 0.3 then
				healthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
			else
				healthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
			end
		end

		humanoid.HealthChanged:Connect(updateHealth)
		updateHealth()
	end

	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
end

-- Apply to current and future players
for _, player in ipairs(Players:GetPlayers()) do
	createESP(player)
end

Players.PlayerAdded:Connect(createESP)
