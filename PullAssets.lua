local Datamodel = remodel.readPlaceFile("build.rbxlx")

function splitstring(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

local function GetInstanceFromDatamodel(Datamodel, StringPath)
	local CurrentObjectReference = Datamodel

	for _, ObjectName in pairs(splitstring(StringPath, ".")) do
		if CurrentObjectReference:FindFirstChild(ObjectName) ~= nil then
			CurrentObjectReference = CurrentObjectReference[ObjectName]
		else
			error(ObjectName .. " was not found.")
			return nil
		end
	end

	return CurrentObjectReference
end

local function SaveAssetToFilesystem(Asset, Path)
	if Asset.Name == "Workspace" then
		remodel.writeModelFile(Datamodel["Workspace"], "assets/Workspace.rbxmx")
	else
		for _, Instance in pairs(Asset:GetChildren()) do
			Instance.Name = Instance.Name:gsub("/", ".") -- Due to how some meshes are named, this will prevent the script from erroring.
			if Instance.ClassName ~= "Folder" then
				remodel.writeModelFile(Instance, Path .. "/" .. Instance.Name .. ".rbxmx")
			else
				remodel.createDirAll(Path .. "/" .. Instance.Name)
				SaveAssetToFilesystem(Instance, Path .. "/" .. Instance.Name)
			end
		end
	end
end

local AssetsToSave = {
	{
		PullFrom = GetInstanceFromDatamodel(Datamodel, "Workspace"),
		Saveto = "./Assets/Workspace",
	},
	{
		PullFrom = GetInstanceFromDatamodel(Datamodel, "ReplicatedStorage.Assets"),
		Saveto = "./Assets/ReplicatedStorage",
	},
	{
		PullFrom = GetInstanceFromDatamodel(Datamodel, "Teams"),
		Saveto = "./Assets/Teams",
	},
}

for _, v in pairs(AssetsToSave) do
	SaveAssetToFilesystem(v.PullFrom, v.Saveto)
end
