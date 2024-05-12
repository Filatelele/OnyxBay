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
	var/turf/center = get_safe_random_station_turf()
	var/datum/map_template/malfbot_droppod/dlevel = new /datum/map_template/malfbot_droppod()
	dlevel.load(center, TRUE, TRUE)
	var/amt = pick(group_size_min, group_size_max)
	for(var/i = 1 to amt)
		new /mob/living/carbon/human/malf_robot(center)
	new /obj/machinery/borgizer(center)

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

/datum/map_template/malfbot_droppod
	mappaths = list("maps/malfbot_droppod.dmm")

/obj/machinery/door/airlock/vault/malfbot_lock/Initialize()
	. = ..()
	set_next_think(world.time + 2 SECONDS)

/obj/machinery/door/airlock/vault/malfbot_lock/think()
	for(var/dir in GLOB.cardinal)
		var/turf/neighbour = get_step(src.loc, dir)
		if(neighbour.c_airblock(loc) & AIR_BLOCKED)
			continue

		for(var/obj/O in src.loc)
			if(istype(O, /obj/machinery/door))
				continue

			. |= O.c_airblock(neighbour)
		if(. & AIR_BLOCKED)
			continue

	open(TRUE)
	lock(TRUE)
