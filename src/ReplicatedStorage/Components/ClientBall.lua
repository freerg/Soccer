local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
			local throwForce = Lerp(THROW_FORCE_MIN, THROW_FORCE_MAX, throwForceAlpha)
			self.Instance:ApplyImpulse(direction * self.Instance.AssemblyMass * throwForce)
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
		end
	end))

	self._playerTrove:Add(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local clickDuration = (time() - startClick)
			Throw(clickDuration)
		end
	end))
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
