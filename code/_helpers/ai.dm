///Returns a list of mobs/living via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_living_near(atom/movable/source, distance)
	. = list()
	for(var/mob/living/nearby_living as anything in GLOB.living_mob_list_)
		if(source.z != nearby_living.z)
			continue
		if(get_dist(source, nearby_living) > distance)
			continue
		. += nearby_living

///Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(atom/movable/source, distance)
	. = list()
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	for(var/mob/living/carbon/human/nearby_human as anything in GLOB.human_mob_list)
		if(isnull(nearby_human))
			continue

		if(nearby_human.z != source.z)
			continue

		if(get_dist(source_turf, nearby_human) > distance)
			continue

		. += nearby_human

///Returns a list of mechs via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_mechs_near(atom/movable/source, distance)
	. = list()
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	for(var/obj/mecha/nearby_mech as anything in mechas_list)
		if(isnull(nearby_mech))
			continue

		if(source_turf.z != nearby_mech.z)
			continue

		if(get_dist(source_turf, nearby_mech) > distance)
			continue

		. += nearby_mech

///Returns the nearest target that has the right target flag
/proc/get_nearest_target(atom/source, distance, target_flags, attacker_faction)
	if(!source)
		return
	var/atom/nearest_target
	var/shorter_distance = distance + 1
	if(target_flags & TARGET_HUMAN)
		for(var/mob/living/nearby_human as anything in cheap_get_humans_near(source, distance))
			if(nearby_human.is_ic_dead() || nearby_human.faction == attacker_faction)
				continue

			if(get_dist(source, nearby_human) < shorter_distance)
				nearest_target = nearby_human
				shorter_distance = get_dist(source, nearby_human) //better to recalculate than to save the var

	if(target_flags & TARGET_HUMAN_TURRETS)
		for(var/atom/nearby_turret as anything in GLOB.all_turrets)
			if(source.z != nearby_turret.z)
				continue

			if(!(get_dist(source, nearby_turret) < shorter_distance))
				continue

			nearest_target = nearby_turret

	return nearest_target

/**
 * This proc attempts to get an instance of an atom type within distance, with center as the center.
 * Arguments
 * * center - The center of the search
 * * type - The type of atom we're looking for
 * * distance - The distance we should search
 * * list_to_search - The list to look through for the type
 */
/proc/cheap_get_atom(atom/center, type, distance, list/list_to_search)
	var/turf/turf_center = get_turf(center)
	if(!turf_center)
		return
	for(var/atom/near as anything in list_to_search)
		if(!istype(near, type))
			continue
		if(get_dist(turf_center, near) > distance)
			continue
		return near
