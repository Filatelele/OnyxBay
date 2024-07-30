/datum/stat_mod
	var/time = 0
	var/value = 0
	var/id

/datum/stat_mod/New(_delay, _affect, _id)
	if(_delay == INFINITY)
		time = -1
	else
		time = world.time + _delay
	value = _affect
	id = _id
