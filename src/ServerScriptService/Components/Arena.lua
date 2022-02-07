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

function Arena:GetScore(teamName)
	return self.Instance:GetAttribute(teamName .. "Score")
end

function Arena:ResetScore(teamName)
	return self.Instance:SetAttribute(teamName .. "Score", 0)
end

function Arena:IncrementScore(teamName)
	return self.Instance:SetAttribute(teamName .. "Score", self:GetScore(teamName) + 1)
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
				"cancel" -- cancel method of Promise is passed since trove doesn't have 'GivePromise' method as seen here https://youtu.be/P8mtVyBXkXs?t=3085
			)
		end
	end))
end

function Arena:Start()
	self._trove:Clean() -- Clean the trove before using it in the respawn, since we can't give it to the signal to autoclean it up inside .new() as seen here https://youtu.be/P8mtVyBXkXs?t=3035
	self._respawn:Connect(function()
		self:_spawnBall()
	end)
	self._respawn:Fire()
end

function Arena:Destroy()
	self._trove:Destroy()
end

return Arena
