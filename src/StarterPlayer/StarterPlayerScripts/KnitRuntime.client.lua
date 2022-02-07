local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Loader = require(ReplicatedStorage.Packages.Loader)

function Knit.OnComponentsLoaded()
	print("OnComponentsLoaded")
	return Promise.new(function(resolve)
		if Knit.ComponentsLoaded then
			print("Components already loaded")
			resolve()
		end

		local heartbeat
		heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
			if Knit.ComponentsLoaded then
				print("Components loaded")
				heartbeat:Disconnect()
				resolve()
			end
		end)
	end)
end

-- Knit.AddControllers(script.Parent.Controllers)

Knit.Start()
	:andThen(function()
		print(script.Parent:GetDescendants())
		Loader.LoadChildren(script.Parent.Components)
		Knit.ComponentsLoaded = true
		print("Knit Started")
	end)
	:catch(warn)
