local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local THROW_FORCE_MIN = 20
local THROW_FORCE_MAX = 100
local THROW_FORCE_TIME = 1

local function Lerp(min, max, alpha)
	return (min + ((max - min) * alpha))
end

local ClientBall = Component.new({ Tag = "Ball" })

function ClientBall:Construct()
	self._trove = Trove.new()
	self._playerTrove = Trove.new()
	self._trove:Add(self._playerTrove)
end

function ClientBall:_setupForLocalPlayer()
	local startClick = 0
	local throwForceHandle = nil

	local ballGui = Knit.Player.PlayerGui.BallGui
	local throwForceFrame = ballGui.ThrowForceFrame
	ballGui.Enabled = true

	local function ShowThrowForce()
		throwForceFrame.Bar.Size = UDim2.fromScale(0, 1)
		throwForceFrame.Visible = true
		throwForceHandle = RunService.RenderStepped:Connect(function()
			local clickDuration = (time() - startClick)
			local throwForceAlpha = math.min(THROW_FORCE_TIME, clickDuration) / THROW_FORCE_TIME
			throwForceFrame.Bar.Size = UDim2.fromScale(throwForceAlpha, 1)
		end)
	end

	local function HideThrowForce()
		throwForceFrame.Visible = false
		if throwForceHandle then
			throwForceHandle:Disconnect()
			throwForceHandle = nil
		end
	end

	local function Throw(clickDuration)
		if Knit.Player.Character and Knit.Player.Character.PrimaryPart then
			local alignPos = self.Instance:FindFirstChild("AlignPosition")
			if alignPos then
				alignPos.Parent = nil
			end
			local alignOrientation = self.Instance:FindFirstChild("AlignOrientation")
			if alignOrientation then
				alignOrientation.Parent = nil
			end
			local direction = Knit.Player.Character.PrimaryPart.CFrame.LookVector
			local throwForceAlpha = math.min(THROW_FORCE_TIME, clickDuration) / THROW_FORCE_TIME
			local throwForceMult = Lerp(THROW_FORCE_MIN, THROW_FORCE_MAX, throwForceAlpha)
			local throwForce = self.Instance.AssemblyMass * throwForceMult
			local impulse = direction * throwForce
			impulse += Vector3.new(0, throwForce / 2, 0)
			self.Instance:ApplyImpulse(impulse)
		end
		self.Instance.Throw:FireServer()
	end

	self._playerTrove:Add(UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Throw()
			startClick = time()
			ShowThrowForce()
		end
	end))

	self._playerTrove:Add(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local clickDuration = (time() - startClick)
			HideThrowForce()
			Throw(clickDuration)
		end
	end))

	self._playerTrove:Add(function()
		ballGui.Enabled = false
		HideThrowForce()
	end)
end

function ClientBall:_cleanupForLocalPlayer()
	self._playerTrove:Clean()
end

function ClientBall:Start()
	local function PlayerIdChanged()
		local playerId = self.Instance:GetAttribute("PlayerId")
		if playerId == Knit.Player.UserId then
			self:_setupForLocalPlayer()
		else
			self:_cleanupForLocalPlayer()
		end
	end

	PlayerIdChanged()

	self._trove:Add(self.Instance:GetAttributeChangedSignal("PlayerId"):Connect(PlayerIdChanged))
end

function ClientBall:Destroy()
	self._trove:Destroy()
end

return ClientBall
