
/datum/map/devarim
	name = "Devarim"
	full_name = "NCS Devarim"
	path = "example"
	station_short = "Ex"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "Nanotrasen"
	company_short = "NT"
	system_name   = "Nyx"

	overmap_type = /obj/structure/overmap/example_ship

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/example
	)

	map_levels = list(
		new /datum/space_level/devarim,
	)

	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
	)

	allowed_spawns = list("Arrivals Shuttle")
	can_be_voted = FALSE

	welcome_sound = 'sound/signals/start2.ogg'

/client/proc/move_devarim_to_empty()
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/signals/start2.ogg', 75)

	SSannounce.play_station_announce(/datum/announce/comm_program, "Brace for FTL jump.", "Helm", msg_sanitized = TRUE)

	var/datum/map_template/devarim_empty/empty = new /datum/map_template/devarim_empty()
	var/turf/center = locate(1, 1, 1)
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/effects/ship/FTL_long_thirring.ogg', 75)

	sleep(30 SECONDS)
	empty.load(center, clear_contents = TRUE)

/client/proc/move_devarim_to_bog()
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/signals/start2.ogg', 75)

	SSannounce.play_station_announce(/datum/announce/comm_program, "Initiating landing sequence.", "Helm", msg_sanitized = TRUE)

	var/datum/map_template/devarim_empty/empty = new /datum/map_template/devarim_empty()
	var/turf/center = locate(1, 1, 1)
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/effects/ship/FTL_long_thirring.ogg', 75)

	sleep(30 SECONDS)
	empty.load(center, clear_contents = TRUE)
	var/list/spawned = block(
		locate(0 + world.view, 0 + world.view, center.z),
		locate(127 - world.view, 127 - world.view, center.z)
	)
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/effects/ship/radio_100m.wav', 75)

	var/datum/map_generator/mapgen = new /datum/map_generator/planet_generator/swamp()
	mapgen.generate_turfs(spawned)
	mapgen.populate_turfs(spawned)

	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/effects/ship/radio_landing_touch_01.wav', 75)

	for(var/mob/M in GLOB.player_list)
		if(istype(M, /mob/living/carbon))
			if(M.buckled)
				to_chat(M, "<span class='warning'>Sudden acceleration presses you into your chair!</span>")
				shake_camera(M, 3, 1)
			else
				to_chat(M, "<span class='warning'>The floor lurches beneath you!</span>")
				shake_camera(M, 10, 1)
				M.visible_message("<span class='warning'>[M.name] is tossed around by the sudden acceleration!</span>")
				M.throw_at_random(FALSE, 4, 1)

	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/effects/ship/radio_landing_end_03.wav', 75)

/client/proc/move_devarim_from_bog()
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/signals/start2.ogg', 75)

	SSannounce.play_station_announce(/datum/announce/comm_program, "All hands, prepare for takeoff.", "Helm", msg_sanitized = TRUE)

	var/datum/map_template/devarim_empty/empty = new /datum/map_template/devarim_empty()
	var/turf/center = locate(1, 1, 1)
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/effects/ship/env_ship_up.wav', 75)

	for(var/mob/M in GLOB.player_list)
		if(istype(M, /mob/living/carbon))
			if(M.buckled)
				to_chat(M, "<span class='warning'>Sudden acceleration presses you into your chair!</span>")
				shake_camera(M, 3, 1)
			else
				to_chat(M, "<span class='warning'>The floor lurches beneath you!</span>")
				shake_camera(M, 10, 1)
				M.visible_message("<span class='warning'>[M.name] is tossed around by the sudden acceleration!</span>")
				M.throw_at_random(FALSE, 4, 1)

	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/effects/ship/engine_ignit.wav', 75)
	sleep(5 SECONDS)
	empty.load(center, clear_contents = TRUE)
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M.loc, 'sound/effects/ship/env_ship_down.wav', 75)

/datum/map_template/devarim_empty
	mappaths = list('maps/devarim/devarim-empty.dmm')
