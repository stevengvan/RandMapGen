local StartOp = game.ServerStorage:WaitForChild("RoomStart")
local RoomDone = game.ServerStorage:WaitForChild("RoomDone")
local lists = require(script.Parent.Parent.ServerStorage.ModuleScript)


StartOp.Event:Connect(function()
	local rand = Random.new(tick())
	local totalRooms = 45


	--error flag for exceeded room limit--
	if totalRooms > math.pow((lists.mapX - 1), 2) then
		print("Input of total rooms to add exceed allowable space - User input: ", totalRooms, " | Max placement: ", math.pow((lists.mapX - 1), 2))
		return nil
	end


	--create room placement layout for the map--
	lists.spots = table.create(lists.mapX)
	lists.doors = table.create(lists.mapX)
	for i = 1, lists.mapX, 1 do
		lists.spots[i] = table.create(lists.mapZ)
		lists.doors[i] = table.create(lists.mapZ)
		for j = 1, lists.mapZ, 1 do
			lists.spots[i][j] = 0
			lists.doors[i][j] = {0, 0, 0, 0}
		end
	end



	--start filling map with room structures--
	local repetitions = 0
	while repetitions < totalRooms do
		local spotX = 0
		local spotZ = 0
		local opendoors = 0
		local openspots = 0
		local layout = {0, 0, 0, 0}


		--selecting an empty spot to occupy--
		repeat
			spotX = rand:NextInteger(2, lists.mapX - 1)
			spotZ = rand:NextInteger(2, lists.mapZ - 1)
			local attributes = lists.countDoors(spotX, spotZ)
			opendoors = attributes[1]
			openspots = attributes[2]
			lists.copyLayout(attributes[3], layout)
		until(lists.spots[spotX][spotZ] == 0 and (opendoors > 0 or openspots > 0))
		lists.spots[spotX][spotZ] = 1


		--designates a random room structure that fits the spot
		local selectroom
		local tofill = layout[1] + layout[2] + layout[3] + layout[4]
		local angle = 1
		if opendoors > 0 then
			selectroom = rand:NextInteger(opendoors, (opendoors + openspots))
		elseif openspots > 0 then
			selectroom = rand:NextInteger(1, openspots)
			angle = rand:NextInteger(1, 4)
		end

		--create duplicate room structure to place--
		local room
		if selectroom == 2 then
			local attributes = lists.room2Select(layout)
			room = attributes[1]
			room.Parent = lists.model
			lists.copyLayout(attributes[2], lists.doors[spotX][spotZ])
		else
			room = lists.roomList[selectroom][1]:Clone()
			room.Parent = lists.model
			lists.copyLayout(lists.roomList[selectroom][2], lists.doors[spotX][spotZ])
		end


		--connecting room to all surrounding doorways--
		local check = false
		if opendoors > 0 or openspots < 4 then
			local attributes = lists.autoFit(lists.doors[spotX][spotZ], layout)
			angle = attributes[1]
			check = attributes[2]
		else
			local rotation = 1
			while rotation < angle do
				lists.copyLayout(lists.rotateStruct(lists.doors[spotX][spotZ]), lists.doors[spotX][spotZ])
				rotation = rotation + 1
			end
		end


		--moving room structure to the selected spot--
		local x = 50 + (100 * (spotX - 6))
		local z = 50 + (100 * (spotZ - 6))
		local position = CFrame.new(x, 0.5, z)
		local orientation = CFrame.Angles(0, math.rad(lists.selectOrientation(angle)), 0)
		room:SetPrimaryPartCFrame(position * orientation)
		if check == true then
			error("Error at ", spotX, spotZ, " Room: ", selectroom, " lists.doors needed: ", opendoors,
				" Orientation: ", lists.selectOrientation(angle), layout, lists.doors[spotX][spotZ])
		end

		--# of rooms placed so far--
		repetitions = repetitions + 1
	end


	--error flag if a room was not placed--
	if repetitions ~= totalRooms then
		lists.roomDone = false
		error("Failed: ", repetitions, "/", totalRooms)
	else
		print("Made it to ", repetitions, "/", totalRooms)
		lists.roomDone = true
		wait(1)
		RoomDone:Fire()
	end
end)
