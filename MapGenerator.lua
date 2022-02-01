local lists = require(script.Parent.Parent.ServerStorage.ModuleScript)
local RoomStart = game.ServerStorage:WaitForChild("RoomStart")
local RoomDone = game.ServerStorage:WaitForChild("RoomDone")
local HallStart = game.ServerStorage:WaitForChild("HallStart")

--(map's dimensions must be divisible by 100)--
--(square/rectangular shaped baseplates only)--
local gridBase = lists.model.Baseplate


--represent map baseplate as a grid--
lists.mapX = (gridBase.Size.X / 100)
lists.mapZ = (gridBase.Size.Z / 100)


--create the map--
wait(1)
RoomStart:Fire()
RoomDone.Event:Connect(function()
	HallStart:Fire()
end)
