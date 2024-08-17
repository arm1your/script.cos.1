_G.On = true

local ignored
local ignoredEvents = {
	"MeteorSelfDamage",
	"MeteorFlySelfDamage",
	"LavaSelfDamage",
	"OxygenRemote",
	"TornadoSelfDamage",
	"WillToLiveSelfDamage",
	"DrownRemote",
	"BreathToggle"
}

ignored = hookmetamethod(game, "__namecall", function(...)
	local Self = ...
	if table.find(ignoredEvents, tostring(Self)) then
		return nil
	end
	return ignored(...)
end)

local getDietType = function()
	for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.HUDGui.BottomFrame.Other.DietType.HoverUpLabel:GetChildren()) do
		if v:IsA("ImageLabel") and v.Visible then
			return v.Name
		end
	end
end

local dietTypes = {
	["Herbivore"] = {"Grass"},
	["Omnivore"] = {""},
	["Carnivore"] = {"Ribs"},
	["Photocarni"] = {},
	["Photovore"] = {},
}

local findMeat = function()
	local diet = getDietType()
	local foodList = dietTypes[diet]

	local distance = math.huge
	local target

	for _, v in pairs(workspace.Interactions.Food:GetChildren()) do
		if v:GetAttribute("Value") > 0 then
			for _, foodName in pairs(foodList) do
				if v.Name == foodName then
					local magnitude = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:GetPivot().Position).magnitude
					if magnitude < distance then
						target = v
						distance = magnitude
					end
				end
			end
		end
	end
	return target
end

local NoclipNotDup = tostring(math.random(10000000,99999999))

task.spawn(function()
	game:GetService("RunService").Stepped:Connect(function()
		xpcall(function()
			local HumanoidRootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart then
				if not AntiClip and _G.On then
					if not HumanoidRootPart:FindFirstChild("NoClip"..NoclipNotDup) then
						local bv = Instance.new("BodyVelocity")
						bv.Parent = HumanoidRootPart
						bv.Name = "NoClip"..NoclipNotDup
						bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						bv.Velocity = Vector3.new(0, 0, 0)
					end
				else
					if HumanoidRootPart:FindFirstChild("NoClip"..NoclipNotDup) then
						HumanoidRootPart:FindFirstChild("NoClip"..NoclipNotDup):Destroy()
					end
				end
			end
		end, function() end)
	end)
end)

task.spawn(function()
	while task.wait() do
		xpcall(function()
			local hungerValue = game:GetService("Players").LocalPlayer.PlayerGui.HUDGui.BottomFrame.Other.Hunger.HoverLabel.Text:gsub("%%", "")
			if tonumber(hungerValue) < 30 and not debounceToken and _G.On then
				debounceHunger = true
				repeat task.wait()
					local target = findMeat()
					game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = target:GetPivot()
					game:GetService("ReplicatedStorage").Remotes.Food:FireServer(target)
					hungerValue = game:GetService("Players").LocalPlayer.PlayerGui.HUDGui.BottomFrame.Other.Hunger.HoverLabel.Text:gsub("%%", "")
				until tonumber(hungerValue) > 90 or debounceToken or not _G.On
				debounceHunger = false
			elseif tonumber(hungerValue) > 90 then
				debounceHunger = false
			end
		end, print)
	end
end)

task.spawn(function()
	while task.wait() do
		xpcall(function()
			local waterValue = game:GetService("Players").LocalPlayer.PlayerGui.HUDGui.BottomFrame.Other.Thirst.HoverLabel.Text:gsub("%%", "")
			if tonumber(waterValue) < 30 and not debounceToken and _G.On then
				debounceWater = true
				repeat task.wait()
					game:GetService("ReplicatedStorage").Remotes.DrinkRemote:FireServer(workspace:WaitForChild("Interactions"):FindFirstChild("Lakes"):FindFirstChild("Lake"))
				until tonumber(waterValue) > 90 or debounceToken or not _G.On
			elseif tonumber(waterValue) > 90 then
				debounceWater = false
			end
		end, print)
	end
end)

task.spawn(function()
	while task.wait() do
		xpcall(function()
			for _, v in pairs(workspace.Interactions.SpawnedTokens:GetChildren()) do
				if v:IsA("BasePart") and v:FindFirstChild("Attachment") and not debounceWater and not debounceHunger and _G.On then
					debounceToken = true
					repeat task.wait()
						if game:GetService("Players").LocalPlayer:DistanceFromCharacter(v.CFrame.p) < 10 then
							game:service('VirtualInputManager'):SendKeyEvent(true, "E", false, game)
							task.wait(0.05)
							game:service('VirtualInputManager'):SendKeyEvent(false, "E", false, game)
						else
							game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
						end
					until not v.Parent or not v or not _G.On
					debounceToken = false
				else
					debounceToken = false
				end
			end
		end, print)
	end
end)

local createSafeZone = function()
	local part = Instance.new("Part", workspace)
	part.Size = Vector3.new(1000, 5, 1000)
	part.CFrame = CFrame.new(50, 5000, 50)
	part.Anchored = true
	part.Transparency = 1
	part:SetAttribute("SafeZone", true)
end

local getSafeZone = function()
	for _, v in pairs(workspace:GetChildren()) do
		if v:GetAttribute("SafeZone") and v:IsA("Part") then
			return v
		end
	end
end

createSafeZone()

task.spawn(function()
	while task.wait() do
		xpcall(function()
			if getSafeZone() and not debounceHunger and not debounceToken and _G.On then
				repeat task.wait()
					game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = getSafeZone().CFrame * CFrame.new(0, 10, 0)
				until debounceHunger or debounceToken or not _G.On
			end
		end, print)
	end
end)
