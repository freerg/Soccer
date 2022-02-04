local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local ArenaService = Knit.CreateService({
	Name = "ArenaService",
	Client = {},
})

ArenaService.BlueScore = 0
ArenaService.RedScore = 0

function ArenaService:StartGame()
	self.BlueScore = 0
	self.RedScore = 0
end

function ArenaService:KnitInit() end

function ArenaService:KnitStart() end

return ArenaService
