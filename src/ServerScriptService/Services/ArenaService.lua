local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TaskQueue = require(ReplicatedStorage.Packages.TaskQueue)
local Arena = require(ServerScriptService.Components.Arena) -- import the Arena component to be able to use :FromInstance()

local ArenaService = Knit.CreateService({
	Name = "ArenaService",
	Client = {},
})

ArenaService.RunSpeed = 18
ArenaService.BallRunSpeed = 14

function ArenaService:GetArena()
	local arenaInstance = Arena:FromInstance(workspace.Arena) -- use the FromInstance method to get the arenaInstance, since there is no longer a Component.FromTag method as seen here https://youtu.be/P8mtVyBXkXs?t=2692
	return arenaInstance
end

function ArenaService:_startGame()
	local arena = self:GetArena()
	arena:ResetScore("Blue")
	arena:ResetScore("Red")
end

function ArenaService:KnitInit()
	local function PlayerAdded(player)
		local function CharacterAdded(character)
			local humanoid = character:WaitForChild("Humanoid", 30)
			if not humanoid then
				return
			end
			humanoid.WalkSpeed = self.RunSpeed
		end
		CharacterAdded(player.Character or player.CharacterAdded:Wait())
		player.CharacterAdded:Connect(CharacterAdded)
	end
	local taskQueue = TaskQueue.new(PlayerAdded)
	Players.PlayerAdded:Connect(PlayerAdded)
	for _, player in ipairs(Players:GetPlayers()) do
		taskQueue:Add(player)
	end
end

function ArenaService:KnitStart()
	Knit.OnComponentsLoaded():andThen(function()
		self:_startGame()
	end)
end

return ArenaService
