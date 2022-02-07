local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local BALL_TAG = "Ball"

local Goal = Component.new({ Tag = "Goal" })

function Goal:Construct()
	self._trove = Trove.new()
	local teamName = self.Instance.Parent.Name
	local team = game:GetService("Teams")[teamName]
	local teamColor = team.TeamColor.Color
	print("Team", teamName, "has color", team.TeamColor)
	self:_setColors(teamColor)
	self:_observeScore(teamName)
	self:_setupScoring(teamName)
end

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
	local function ScoreChanged(score)
		self.Instance.TopBar.BillboardGui.Score.Text = tostring(score)
	end
	self._trove:Add(arena:ObserveScore(teamName, ScoreChanged))
end

function Goal:_setupScoring(teamName)
	self.Instance.Hitbox.Touched:Connect(function(part)
		if CollectionService:HasTag(part, BALL_TAG) then
			part:Destroy()
			local arena = Knit.GetService("ArenaService"):GetArena()
			arena:IncrementScore(teamName)
		end
	end)
end

function Goal:Destroy() end

return Goal
