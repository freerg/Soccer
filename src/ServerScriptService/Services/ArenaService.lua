local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ArenaService = Knit.CreateService({
	Name = "ArenaService",
	Client = {},
})

function ArenaService:GetArena()
	return workspace.Arena
end

function ArenaService:KnitInit() end

function ArenaService:KnitStart() end

return ArenaService
