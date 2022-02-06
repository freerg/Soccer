local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Component = require(ReplicatedStorage.Packages.Component)

local Arena = Component.new({ Tag = "Arena" })

function Arena:Construct()
	self._trove = Trove.new()
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

function Arena:Destroy()
	self._trove:Destroy()
end

return Arena
