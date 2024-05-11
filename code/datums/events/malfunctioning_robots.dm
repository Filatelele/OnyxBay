/datum/event/malfunctioning_robots_base
	id = "malfunctioning_robots_base"
	name = "Malfunctioning Robots"
	description = "Droppod with malfunctioning robots will arrive on station."

	mtth = 2 HOURS
	difficulty = 55

	options = newlist(
		/datum/event_option/malfunctioning_robots_option {
			id = "option_mundane";
			name = "Mundane Level";
			description = "1 to 3 robots";
			weight = 75;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION_R;
			event_id = "malfunctioning_robots";
			severity = EVENT_LEVEL_MUNDANE;
		},
		/datum/event_option/malfunctioning_robots_option {
			id = "option_moderate";
			name = "Moderate Level";
			description = "3 to 6 robots";
			weight = 15;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
			event_id = "malfunctioning_robots";
			severity = EVENT_LEVEL_MODERATE;
		},
		/datum/event_option/malfunctioning_robots_option {
			id = "option_major";
			name = "Major Level";
			description = "All organic beings will be assimilated.";
			weight = 10;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
			event_id = "malfunctioning_robots";
			severity = EVENT_LEVEL_MAJOR;
		}
	)
/datum/event/malfunctioning_robots_base/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Security"] * (10 MINUTES))
	. = max(1 HOUR, .)

/datum/event/malfunctioning_robots_base/get_conditions_description()
	. = "<em>Carp Migration</em> should not be <em>running</em>."

/datum/event/malfunctioning_robots_base/check_conditions()
	. = SSevents.evars["malfunctioning_robots_running"] != TRUE

/datum/event_option/malfunctioning_robots_option
	var/severity = EVENT_LEVEL_MUNDANE

/datum/event_option/malfunctioning_robots_option/on_choose()
	SSevents.evars["malfunctioning_robots_severity"] = severity

/datum/event/malfunctioning_robots
	id = "malfunctioning_robots"
	name = "Malfunctioning Robots"

	hide = TRUE
	triggered_only = TRUE

	var/severity = EVENT_LEVEL_MUNDANE
	var/list/spawned_carp = list()

/datum/event/malfunctioning_robots/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce)), 0)

/datum/event/malfunctioning_robots/on_fire()
	SSevents.evars["carp_migration_running"] = TRUE
	severity = SSevents.evars["carp_migration_severity"]

	if(severity == EVENT_LEVEL_MAJOR)
		spawn_malf_robots(6, 12)
	else if(severity == EVENT_LEVEL_MODERATE)
		spawn_malf_robots(3, 6)
	else
		spawn_malf_robots(1, 3)

	announce()

/datum/event/malfunctioning_robots/proc/spawn_malf_robots(num_groups, group_size_min = 1, group_size_max = 3)
	var/turf/target = get_safe_random_station_turf(GLOB.station_areas)
	new /datum/random_map/droppod/malfunctioning_robots(null, target.x, target.y, target.z, do_not_announce = TRUE)

/datum/event/malfunctioning_robots/proc/announce()
	if(severity == EVENT_LEVEL_MAJOR)
		SSannounce.play_station_announce(/datum/announce/malfunctioning_robots_arrival)
	else
		SSannounce.play_station_announce(pick(list(
			/datum/announce/malfunctioning_robots_arrival_icarus,
			/datum/announce/skipjack_arrival,
			/datum/announce/nukeops_arrival,
			/datum/announce/malfunctioning_robots_arrival_icarus,
			/datum/announce/malfunctioning_robots_arrival
		)))

/datum/random_map/droppod/malfunctioning_robots
	descriptor = "drop pod"
	initial_wall_cell = FALSE
	limit_x = 5
	limit_y = 5
	preserve_map = FALSE
	auto_open_doors = TRUE
	spawnchair = FALSE

	wall_type = /turf/simulated/wall/titanium
	floor_type = /turf/simulated/floor/reinforced
	door_type = /obj/structure/droppod_door
	drop_type = /mob/living/carbon/human/malf_robot
	supplied_drop_types = list(

	)

/datum/random_map/droppod/malfunctioning_robots/get_spawned_drop(turf/T)
