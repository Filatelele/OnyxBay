/datum/ai_behavior/station_bot/farmbot
	sidestep_prob = 50
	distance_to_maintain = 1

///Returns the nearest target that has the right target flag
/datum/ai_behavior/station_bot/farmbot/get_nearest_target(atom/source, distance, target_flags, attacker_faction)
	if(!source)
		return

	var/mob/living/bot/farmbot/farmbot = mob_parent
	if(!istype(farmbot))
		return

	if(farmbot.emagged)
		for(var/mob/living/carbon/human/H in view(world.view, farmbot))
			return H

	else
		var/atom/target = null
		for(var/obj/machinery/portable_atmospherics/hydroponics/tray in view(world.view, farmbot))
			if(confirm_target(tray))
				target = tray
				break

		if(target)
			return target

		if(farmbot.refills_water && farmbot.tank?.reagents?.total_volume < farmbot.tank?.reagents.maximum_volume)
			for(var/obj/structure/sink/sink in view(world.view, farmbot))
				target = sink
				break

		return target

/datum/ai_behavior/station_bot/farmbot/proc/confirm_target(atom/target)
	var/mob/living/bot/farmbot/farmbot = mob_parent
	if(!istype(farmbot))
		return FALSE

	if(istype(target, /obj/structure/sink))
		if(farmbot.tank?.reagents?.total_volume >= farmbot.tank?.reagents?.total_volume)
			return FALSE

		return TRUE

	var/obj/machinery/portable_atmospherics/hydroponics/tray = target
	if(!istype(tray))
		return FALSE

	if(tray.closed_system || !tray.seed)
		return FALSE

	if(tray.dead && farmbot.removes_dead || tray.harvest && farmbot.collects_produce)
		return TRUE

	else if(farmbot.refills_water && tray.waterlevel < 40 && !tray.reagents.has_reagent(/datum/reagent/water))
		return TRUE

	else if(farmbot.uproots_weeds && tray.weedlevel > 3)
		return TRUE

	else if(farmbot.replaces_nutriment && tray.nutrilevel < 1 && tray.reagents.total_volume < 1)
		return TRUE

	return FALSE
