local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Component = require(ReplicatedStorage.Packages.Component)

local Goal = Component.new({ Tag = "Goal" })

function Goal:_setColors(color)
	for _, v in ipairs(self.Instance:GetDescendants()) do
		if v:IsA("BasePart") and v:GetAttribute("TeamColor") then
			print("Setting color to", color)
			v.Color = color
		end
	end
	self.Instance.TopBar.BillboardGui.Score.TextColor3 = color
end

function Goal:_observeScore(teamName)
	local arena = Knit.GetService("ArenaService"):GetArena()
	local scoreAttrName = teamName .. "Score"
	local function ScoreChanged()
		local score = arena:GetAttribute(scoreAttrName)
		self.Instance.TopBar.BillboardGui.Score.Text = tostring(score)
	end
	ScoreChanged()
	arena:GetAttributeChangedSignal(scoreAttrName):Connect(ScoreChanged)
end

function Goal:Construct()
	local teamName = self.Instance.Parent.Name
	local team = game:GetService("Teams")[teamName]
	local teamColor = team.TeamColor.Color
	print("Team", teamName, "has color", team.TeamColor)
	self:_setColors(teamColor)
	self:_observeScore(teamName)

	self._trove = Trove.new()
end

function Goal:Stop()
	self._trove:Destroy()
end

return Goal
