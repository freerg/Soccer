local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Arena = require(ServerScriptService.Components.Arena) -- import the Arena component to be able to use :FromInstance()

local ArenaService = Knit.CreateService({
	Name = "ArenaService",
	Client = {},
})

function ArenaService:GetArena()
	local arenaInstance = Arena:FromInstance(workspace.Arena) -- use the FromInstance method to get the arenaInstance, since there is no longer a Component.FromTag method as seen here https://youtu.be/P8mtVyBXkXs?t=2692
	return arenaInstance
end

function ArenaService:_startGame()
	local arena = self:GetArena()
	arena:ResetBlueScore()
	arena:ResetRedScore()
end

function ArenaService:KnitInit() end

function ArenaService:KnitStart()
	Knit.OnComponentsLoaded():andThen(function()
		self:_startGame()
	end)
end

return ArenaService
