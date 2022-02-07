local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Component = require(ReplicatedStorage.Packages.Component)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)

local BALL_PREFAB = game:GetService("ServerStorage").Assets.Ball
local RESPAWN_BALL_TIME = 1
local Arena = Component.new({ Tag = "Arena" })

function Arena:Construct()
	self._trove = Trove.new()
	self._respawn = Signal.new()
end

function Arena:ObserveScore(teamName, handler)
	local attrName = teamName .. "Score"
	handler(self.Instance:GetAttribute(attrName))
	local connection = self.Instance:GetAttributeChangedSignal(attrName):Connect(function()
		handler(self.Instance:GetAttribute(attrName))
	end)
	self._trove:Add(connection)
	return connection
end

function Arena:GetBlueScore()
	return self.Instance:GetAttribute("BlueScore")
end

function Arena:ResetBlueScore()
	return self.Instance:SetAttribute("BlueScore", 0)
end

function Arena:IncrementBlueScore()
	return self.Instance:SetAttribute("Score", self:GetBlueScore() + 1)
end

function Arena:GetRedScore()
	return self.Instance:GetAttribute("RedScore")
end

function Arena:ResetRedScore()
	return self.Instance:SetAttribute("RedScore", 0)
end

function Arena:IncrementRedScore()
	return self.Instance:SetAttribute("RedScore", self:GetRedScore() + 1)
end

function Arena:_spawnBall()
	local ball = BALL_PREFAB:Clone()
	ball.CFrame = self.Instance.Base.BallSpawn.WorldCFrame
	ball.Parent = self.Instance
	self._trove:Add(ball)
	self._trove:Add(ball:GetPropertyChangedSignal("Parent"):Connect(function()
		if not ball.Parent then
			self._trove:Add(
				Promise.delay(RESPAWN_BALL_TIME):andThen(function()
					self._respawn:Fire()
				end),
				"cancel" -- cancel method of Promise is passed since trove doesn't have 'GivePromise' method
			)
		end
	end))
end

function Arena:Start()
	self._trove:Clean() -- Clean the trove before using it in the respawn, since we can't give it to the signal to autoclean it up inside .new()
	self._respawn:Connect(function()
		self:_spawnBall()
	end)
	self._respawn:Fire()
end

function Arena:Destroy()
	self._trove:Destroy()
end

return Arena
