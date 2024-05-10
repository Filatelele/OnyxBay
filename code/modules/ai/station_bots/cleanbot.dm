/datum/ai_behavior/station_bot/cleanbot
	sidestep_prob = 50
	distance_to_maintain = 0

/datum/ai_behavior/station_bot/cleanbot/New()
	. = ..()
	add_think_ctx("remove_ignored_mess", CALLBACK(src, nameof(.proc/remove_ignored_mess)), 0)

/datum/ai_behavior/station_bot/cleanbot/do_idle_action()
	var/mob/living/bot/cleanbot/botparent = mob_parent
	if(!istype(botparent))
		return

	if(!botparent.screwloose && !botparent.oddbutton && prob(5))
		botparent.visible_message("\The [botparent] makes an excited beeping booping sound!")

	if(botparent.screwloose && prob(5))
		var/turf/simulated/turfloc = botparent.loc
		if(istype(turfloc))
			turfloc.wet_floor()

	if(botparent.oddbutton && prob(5))
		botparent.visible_message("Something flies out of \the [botparent]. He seems to be acting oddly.")
		new /obj/effect/decal/cleanable/blood/gibs(botparent.loc)
		set_next_think_ctx("remove_ignored_mess", world.time + 1 MINUTE)

/datum/ai_behavior/station_bot/cleanbot/proc/remove_ignored_mess()
	pass()

///Returns the nearest target that has the right target flag
/datum/ai_behavior/station_bot/cleanbot/get_nearest_target(atom/source, distance, target_flags, attacker_faction)
	if(!source)
		return

	var/mob/living/bot/cleanbot/botparent = mob_parent
	if(!istype(botparent))
		return

	for(var/obj/effect/decal/cleanable/D in view(world.view, botparent))
		if(!LAZYISIN(botparent.target_types, D.type))
			continue

		return D
