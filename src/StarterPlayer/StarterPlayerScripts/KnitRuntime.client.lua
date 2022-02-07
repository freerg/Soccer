local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Loader = require(ReplicatedStorage.Packages.Loader)

function Knit.OnComponentsLoaded()
	return Promise.new(function(resolve)
		if Knit.ComponentsLoaded then
			resolve()
		end

		local heartbeat
		heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
			if Knit.ComponentsLoaded then
				heartbeat:Disconnect()
				resolve()
			end
		end)
	end)
end

Knit.AddControllers(ReplicatedStorage.Controllers)

Knit.Start()
	:andThen(function()
		Loader.LoadChildren(ReplicatedStorage.Components)
		Knit.ComponentsLoaded = true
	end)
	:catch(warn)
