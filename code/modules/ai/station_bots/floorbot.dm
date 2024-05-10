/datum/ai_behavior/station_bot/floorbot
	sidestep_prob = 50
	distance_to_maintain = 0

///Returns the nearest target that has the right target flag
/datum/ai_behavior/station_bot/floorbot/get_nearest_target(atom/source, distance, target_flags, attacker_faction)
	if(!source)
		return

	var/mob/living/bot/floorbot/floorbot = mob_parent
	if(!istype(floorbot))
		return

	for(var/turf/simulated/floor/T in view(world.view, floorbot))
		if(confirm_target(T))
			return T

	if(floorbot.amount < floorbot.maxAmount && (floorbot.eattiles || floorbot.maketiles))
		for(var/obj/item/stack/S in view(world.view, floorbot))
			if(confirm_target(S))
				return S

/datum/ai_behavior/station_bot/floorbot/proc/confirm_target(atom/target)
	var/mob/living/bot/floorbot/floorbot = mob_parent
	if(!istype(floorbot))
		return FALSE

	if(istype(target, /obj/item/stack/tile/floor))
		return (floorbot.amount < floorbot.maxAmount && floorbot.eattiles)

	if(istype(target, /obj/item/stack/material/steel))
		return (floorbot.amount < floorbot.maxAmount && floorbot.maketiles)

	var/turf/simulated/floor/T = target
	if(istype(T))
		if(floorbot.emagged)
			return TRUE
		else
			return (floorbot.amount && (T.broken || T.burnt || (floorbot.improvefloors && !T.flooring)))

	return FALSE
