local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Config Options
local TOGGLE_KEY = Enum.KeyCode.E      -- Key to toggle targeting on/off
local SMOOTHNESS = 0.08                -- Lower = softer, smooth tracking (0.05 - 0.15 is natural/undetected)

local isTargeting = false
local currentTargetHead = nil

-- Find the globally closest player's head without range/angle limits
local function getClosestHead()
	local closestHead = nil
	local shortestDistance = math.huge
	local cameraPos = Camera.CFrame.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local character = player.Character
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local head = character:FindFirstChild("Head")

			if humanoid and humanoid.Health > 0 and head then
				local dist = (head.Position - cameraPos).Magnitude
				if dist < shortestDistance then
					shortestDistance = dist
					closestHead = head
				end
			end
		end
	end

	return closestHead
end

-- Toggle key handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == TOGGLE_KEY then
		isTargeting = not isTargeting
		if not isTargeting then
			currentTargetHead = nil
		end
	end
end)

-- Main tracking loop
RunService.RenderStepped:Connect(function()
	if not isTargeting then return end

	-- Check target validity (Alive and still in workspace)
	if currentTargetHead then
		local character = currentTargetHead.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		
		-- If killed or destroyed, drop target smoothly without immediately snapping to another player
		if not humanoid or humanoid.Health <= 0 or not currentTargetHead:IsDescendantOf(workspace) then
			currentTargetHead = nil
		end
	end

	-- Acquire new target if none currently active
	if not currentTargetHead then
		currentTargetHead = getClosestHead()
	end

	-- Apply smooth tracking
	if currentTargetHead then
		local currentCF = Camera.CFrame
		local targetDirection = (currentTargetHead.Position - currentCF.Position).Unit
		local targetCF = CFrame.lookAt(currentCF.Position, currentCF.Position + targetDirection)

		-- Smooth Lerp prevents aggressive locking visual glitches
		Camera.CFrame = currentCF:Lerp(targetCF, SMOOTHNESS)
	end
end)
