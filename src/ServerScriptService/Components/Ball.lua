local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Option = require(ReplicatedStorage.Packages.Option)

local Players = game:GetService("Players")

local Ball = Component.new({ Tag = "Ball" })

function Ball:Construct()
	self._trove = Trove.new()
end

function Ball:_listenForTouches()
	local playerTrove = Trove.new()

	local function GetPlayerFromPart(part)
		return Option.Wrap(Players:GetPlayerFromCharacter(part.Parent))
	end

	local function GetHumanoid(player)
		if player.Character then
			local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
			return Option.Wrap(humanoid)
		end
		return Option.None
	end

	local function DetachFromPlayer()
		playerTrove:Clean()
	end

	local function CreateHold(player)
		local att = Instance.new("Attachment")
		att.Position = Vector3.new(0, 0.5, -2)
		att.Parent = player.Character.UpperTorso

		local alignPos = Instance.new("AlignPosition")
		alignPos.RigidityEnabled = true
		alignPos.Attachment0 = self.Instance.Attachment
		alignPos.Attachment1 = att
		alignPos.Parent = self.Instance

		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.RigidityEnabled = true
		alignOrientation.Attachment0 = self.Instance.Attachment
		alignOrientation.Attachment1 = att
		alignPos.Parent = self.Instance

		playerTrove:Add(att)
		playerTrove:Add(alignPos)
		playerTrove:Add(alignOrientation)
	end

	local function AttachToPlayer(player, humanoid)
		self.Instance:SetAttribute("PlayerId", player.UserId)
		playerTrove:Add(function()
			self.Instance:SetAttribute("PlayerId", 0)
		end)
		playerTrove:Add(humanoid.Died:Connect(DetachFromPlayer))
		playerTrove:Add(Players.PlayerRemoving:Connect(function(plr)
			if plr == player then
				DetachFromPlayer()
			end
		end))
		CreateHold(player)
	end

	self._trove:Add(self.Instance.Touched:Connect(function(part)
		print("Touched", part, self.Instance:GetAttribute("PlayerId"))
		if self.Instance:GetAttribute("PlayerId") ~= 0 then
			return
		end
		GetPlayerFromPart(part):Match({
			Some = function(player)
				GetHumanoid(player):Match({
					Some = function(humanoid)
						if humanoid.Health > 0 then
							AttachToPlayer(player, humanoid)
						end
					end,
					None = function() end,
				})
			end,
			None = function() end,
		})
	end))
end

function Ball:Start()
	self:_listenForTouches()
end

function Ball:Destroy()
	self._trove:Destroy()
end

return Ball
