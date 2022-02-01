local module = {
	model = game.Workspace,
	roomList = {},
	spots = {},
	doors = {},
	hallList = {},
	halls = {},
	hallOpen = {},
	mapX = 0,
	mapZ = 0
}


--layout for all structures--
module.roomList[1] = {module.model.room_U, {1, 0, 0, 0}}
module.roomList[2] = {{module.model.room_II, module.model.room_L}, {{1, 0, 1, 0}, {1, 1, 0, 0}}}
module.roomList[3] = {module.model.room_T, {0, 1, 1, 1}}
module.roomList[4] = {module.model.room_cross, {1, 1, 1, 1}}
module.hallList[1] = {module.model.hall_U, {1, 0, 0, 0}}
module.hallList[2] = {{module.model.hall_II, module.model.hall_L}, {{1, 0, 1, 0}, {1, 1, 0, 0}}}
module.hallList[3] = {module.model.hall_II, {0, 1, 1, 1}}
module.hallList[4] = {module.model.hall_II, {1, 1, 1, 1}}


function module.copyLayout(source, dest)
	for i = 1, 4, 1 do
		dest[i] = source[i]
	end
end


function module.transferMap(listSpots, listDoors, listHalls, X, Z)
	module.spots = {unpack(listSpots)}
	module.doors = {unpack(listDoors)}
	module.halls = {unpack(listHalls)}
	module.mapX = X
	module.mapZ = Z
end


--count surrounding doors--
function module.countDoors(spotx, spotz)
	local opendoors = 0
	local openspot = 0
	local doorways = {0, 0, 0, 0}


	--check north side--
	if module.spots[spotx][spotz - 1] == 0 then
		openspot = openspot + 1
		doorways[1] = 2
	elseif module.doors[spotx][spotz - 1][3] == 1 then
		opendoors = opendoors + 1
		doorways[1] = 1
	end


	--check east side--
	if module.spots[spotx + 1][spotz] == 0 then
		openspot = openspot + 1
		doorways[2] = 2
	elseif module.doors[spotx + 1][spotz][4] == 1 then
		opendoors = opendoors + 1
		doorways[2] = 1
	end


	--check south side--
	if module.spots[spotx][spotz + 1] == 0 then
		openspot = openspot + 1
		doorways[3] = 2
	elseif module.doors[spotx][spotz + 1][1] == 1 then
		opendoors = opendoors + 1
		doorways[3] = 1
	end


	--check west side--
	if module.spots[spotx - 1][spotz] == 0 then
		openspot = openspot + 1
		doorways[4] = 2
	elseif module.doors[spotx - 1][spotz][2] == 1 then
		opendoors = opendoors + 1
		doorways[4] = 1
	end


	return {opendoors, openspot, doorways}
end


--makes sure structure is properly aligned with surrounding entryways--
function module.checkConnectionDoor(fix, Doors)
	for i = 1, 4, 1 do
		if Doors[i] + fix[i] == 1 then
			return false
		end
	end
	return true
end


--realigns structure to fit with all surrounding entryways-
function module.autoFit(fix, Doors)
	local rotation = 1
	local failed = false


	while module.checkConnectionDoor(fix, Doors) == false and rotation <= 4 do
		rotation = rotation + 1
		module.copyLayout(module.rotateStruct(fix), fix)
	end
	if rotation > 4 then
		failed = true
	end


	return {rotation, failed}
end


--rotate any structure 90 degrees eastward--
function module.rotateStruct(layout)
	local attempt = {unpack(layout)}
	local copy = {unpack(layout)}


	for i = 1, 4, 1 do
		if attempt[i] >= 1 then
			copy[i] = copy[i] - 1
			if i == 4 then
				copy[1] = copy[1] + 1
			else
				copy[i + 1] = copy[i + 1] + 1
			end
		end
	end
	attempt = {unpack(copy)}


	return attempt
end


--determines the best 2 door structure for the spot--
function module.room2Select(doorways)
	local room = module.model
	local layout = {0, 0, 0, 0}
	local count = 0
	for i = 1, 4, 1 do
		if doorways[i] == 1 then
			count = count + 1
		end
	end


	if count == 2 then
		if (doorways[1] == 1 and doorways[1] == doorways[3])  or (doorways[2] == 1 and doorways[2] == doorways[4]) then
			room = module.roomList[2][1][1]:Clone()
			module.copyLayout(module.roomList[2][2][1], layout)
		else
			room = module.roomList[2][1][2]:Clone()
			module.copyLayout(module.roomList[2][2][2], layout)
		end
	elseif count == 1 then
		if doorways[1] + doorways[3] == 3 or doorways[2] + doorways[4] == 3 then
			room = module.roomList[2][1][1]:Clone()
			module.copyLayout(module.roomList[2][2][1], layout)
		else
			room = module.roomList[2][1][2]:Clone()
			module.copyLayout(module.roomList[2][2][2], layout)
		end
	else
		if doorways[1] + doorways[3] == 4 or doorways[2] + doorways[4] == 4 then
			room = module.roomList[2][1][1]:Clone()
			module.copyLayout(module.roomList[2][2][1], layout)
		else
			room = module.roomList[2][1][2]:Clone()
			module.copyLayout(module.roomList[2][2][2], layout)
		end
	end


	room.Parent = module.model
	return {room, layout}
end


function module.selectOrientation(selection)
	if selection == 1 then return 0
	elseif selection == 2 then return -90
	elseif selection == 3 then return 180
	elseif selection == 4 then return 90
	else return -1
	end
end


--check surrounding spaces to connect structure to--
function module.countSpots(i, j)
	local spaces = 0


	--check north side--
	if j > 1 then
		if module.spots[i][j - 1] == 0 or module.doors[i][j - 1][3] == 1 then
			spaces = spaces + 1
		end
	end


	--check east side--
	if i < module.mapX then
		if module.spots[i + 1][j] == 0 or module.doors[i + 1][j][4] == 1 then
			spaces = spaces + 1
		end
	end


	--check south side--
	if j < module.mapZ then
		if module.spots[i][j + 1] == 0 or module.doors[i][j + 1][1] == 0 then
			spaces = spaces + 1
		end
	end


	--check west side--
	if i > 1 then
		if module.spots[i - 1][j] == 0 or module.doors[i - 1][j][2] == 1 then
			spaces = spaces + 1
		end
	end	


	return spaces
end


return module
