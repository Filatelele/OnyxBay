/client/proc/initiate_docking(obj/docker, obj/to_dock, list/moved_atoms)
	var/list/exceptions_list = list()
	var/turf/center = locate(world.maxx / 2, world.maxy / 2, 2)
	var/list/old_turfs = RANGE_TURFS(world.maxx / 2, center)
	center = locate(world.maxx / 2, world.maxy / 2, 1)
	var/list/new_turfs = RANGE_TURFS(world.maxx / 2, center)
	for(var/i = 1, i <= old_turfs.len, i++)
		try
			var/turf/oldT = old_turfs[i]
			var/turf/newT = new_turfs[i]
			for(var/k in oldT)
				try
					var/atom/movable/moving_atom = k
					if(moving_atom.loc != oldT) //fix for multi-tile objects
						continue
					if(moving_atom.onShuttleMove(newT, oldT))	//atoms
						moved_atoms[moving_atom] = oldT
				catch(var/exception/e1)
					exceptions_list += e1
		catch(var/exception/e1)
			exceptions_list += e1

	// C-like for loop; see top of file for explanation
	for(var/i = 1, i <= old_turfs.len, i++)
		try
			var/turf/oldT = old_turfs[i]
			var/turf/newT = new_turfs[i]
			var/area/ship/A = oldT.loc
			newT.onShuttleMove(oldT)
		catch(var/exception/e2)
			exceptions_list += e2

	for(var/i = 1, i <= old_turfs.len, i++)
		try
			var/turf/oldT = old_turfs[i]
			var/turf/newT = new_turfs[i]
			var/area/ship/shuttle_area = oldT.loc //The area on the shuttle, typecasted for the checks further down
			var/area/ship/target_area = newT.loc //The area we're landing on
			var/area/ship/new_area //The area that we leave behind

			shuttle_area.onShuttleMove(oldT, newT, new_area)										//areas
		catch(var/exception/e3)
			exceptions_list += e3

// Called on atoms to move the atom to the new location
/atom/movable/proc/onShuttleMove(turf/newT, turf/oldT)
	SHOULD_CALL_PARENT(TRUE)
	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return

	if(loc != oldT) // This is for multi tile objects
		return

	loc = newT

	return TRUE

// Called on the old turf to move the turf data
/turf/proc/onShuttleMove(turf/newT)
	if(newT == src) // In case of in place shuttle rotation shenanigans.
		return

	ChangeTurf(newT.type)
	set_dir(newT)
	icon_state = newT.icon_state
	newT.icon = icon
	CopyOverlays(newT)
	underlays = newT.underlays

	return TRUE

// Called on areas to move their turf between areas
/area/proc/onShuttleMove(turf/oldT, turf/newT, area/underlying_old_area)
	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return TRUE

	contents -= oldT
	underlying_old_area.contents += oldT
	//The old turf has now been given back to the area that turf originaly belonged to

	var/area/old_dest_area = newT.loc

	old_dest_area.contents -= newT
	contents += newT
	//newT.change_area(old_dest_area, src)
	return TRUE
