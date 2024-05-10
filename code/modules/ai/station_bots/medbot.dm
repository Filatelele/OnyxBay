/datum/ai_behavior/station_bot/medbot
	sidestep_prob = 50
	distance_to_maintain = 1

///Returns the nearest target that has the right target flag
/datum/ai_behavior/station_bot/medbot/get_nearest_target(atom/source, distance, target_flags, attacker_faction)
	if(!source)
		return

	var/atom/nearest_target
	var/shorter_distance = distance + 1
	var/mob/living/bot/medbot/medbot = mob_parent
	if(!istype(medbot))
		return

	for(var/mob/living/carbon/human/nearby_human in view(world.view, medbot)) // Time to find a patient!
		if(!confirm_target(nearby_human))
			continue

		if(get_dist(source, nearby_human) < shorter_distance)
			nearest_target = nearby_human
			shorter_distance = get_dist(source, nearby_human)


	THROTTLE(last_speak, 30 SECONDS)
	if(last_speak)
		var/message = pick(list(
			"Hey, [nearest_target.name]! Hold on, I'm coming." = 'sound/voice/medbot/coming.ogg',
			"Wait [nearest_target.name]! I want to help!" = 'sound/voice/medbot/help.ogg',
			"[nearest_target.name], you appear to be injured!" = 'sound/voice/medbot/injured.ogg',
		))
		medbot.say(message)
		playsound(src, message[message], 75, FALSE)
		medbot.visible_emote("points at [nearest_target].")

	return nearest_target

/datum/ai_behavior/station_bot/medbot/proc/confirm_target(mob/living/carbon/human/H)
	var/mob/living/bot/medbot/medbot = mob_parent
	if(!istype(medbot))
		return

	if(H.is_ic_dead())
		return FALSE

	if(medbot.emagged)
		return TRUE

	if(medbot.reagent_glass && medbot.use_beaker && (
		((medbot.should_treat_brute && (H.getBruteLoss() >= medbot.heal_threshold)) || \
		(medbot.should_treat_fire && (H.getFireLoss() >= medbot.heal_threshold)) || \
		(medbot.should_treat_tox && (H.getToxLoss() >=medbot.heal_threshold)) || \
		(medbot.should_treat_oxy && (H.getOxyLoss() >= (medbot.heal_threshold + 15)))))
	)
		for(var/datum/reagent/R in medbot.reagent_glass.reagents.reagent_list)
			if(!H.reagents.has_reagent(R))
				return TRUE

			continue

	if(medbot.should_treat_brute && (H.getBruteLoss() >= medbot.heal_threshold) && (!H.reagents.has_reagent(medbot.treatment_brute)))
		return TRUE //If they're already medicated don't bother!

	if(medbot.should_treat_oxy && (H.getOxyLoss() >= (15 + medbot.heal_threshold)) && (!H.reagents.has_reagent(medbot.treatment_oxy)))
		return TRUE

	if(medbot.should_treat_fire && (H.getFireLoss() >= medbot.heal_threshold) && (!H.reagents.has_reagent(medbot.treatment_fire)))
		return TRUE

	if(medbot.should_treat_tox && (H.getToxLoss() >= medbot.heal_threshold) && (!H.reagents.has_reagent(medbot.treatment_tox)))
		return TRUE
