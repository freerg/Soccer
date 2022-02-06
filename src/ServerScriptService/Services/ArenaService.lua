local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Arena = require(ServerScriptService.Components.Arena)

local ArenaService = Knit.CreateService({
	Name = "ArenaService",
	Client = {},
})

function ArenaService:GetArena()
	local arenaInstance = Arena:FromInstance(workspace.Arena)
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
