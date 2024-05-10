/datum/ai_behavior/station_bot/secbot
	sidestep_prob = 50
	distance_to_maintain = 0

///Returns the nearest target that has the right target flag
/datum/ai_behavior/station_bot/secbot/get_nearest_target(atom/source, distance, target_flags, attacker_faction)
	if(!source)
		return

	var/atom/nearest_target
	var/shorter_distance = distance + 1
	for(var/mob/living/nearby_human as anything in cheap_get_humans_near(source, distance))
		if(nearby_human.is_ic_dead() || nearby_human.faction == attacker_faction)
			continue

		if(get_dist(source, nearby_human) < shorter_distance)
			nearest_target = nearby_human
			shorter_distance = get_dist(source, nearby_human)
