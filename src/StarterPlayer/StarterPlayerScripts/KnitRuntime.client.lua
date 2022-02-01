local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllers(ReplicatedStorage.Controllers)

Knit.Start()
	:andThen(function()
		print("Knit client is loaded")
	end)
	:catch(warn)
