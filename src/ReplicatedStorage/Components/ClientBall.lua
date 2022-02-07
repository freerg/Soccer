local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ClientBall = Component.new({ Tag = "Ball" })

function ClientBall:Construct()
	self._trove = Trove.new()
	self._playerTrove = Trove.new()
	self._trove:Add(self._playerTrove)
end

function ClientBall:_setupForLocalPlayer()
	self._playerTrove:Add(UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Instance.Throw:FireServer()
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
