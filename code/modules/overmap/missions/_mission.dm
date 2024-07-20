/datum/mission
	var/name = "Mission"
	var/desc = "Do something for me."
	/// Reward on completion
	var/reward = 1000
	/// The amount of time in which this mission should be completed
	var/duration = 30 MINUTES
	/// The relative probability of this mission being selected. 0-weight missions are never selected.
	var/weight = 0


	/// Should mission value scale proportionally to the deviation from the mission's base duration?
	var/dur_value_scaling = TRUE
	/// The maximum deviation of the mission's true value from the base value, as a proportion.
	var/val_mod_range = 0.1
	/// The maximum deviation of the mission's true duration from the base value, as a proportion.
	var/dur_mod_range = 0.1

	/// The ship that accepted this mission. Passed in accept().
	var/obj/structure/overmap/servant

	var/accepted = FALSE
	var/failed = FALSE
	var/ends_at

	/// Assoc list of atoms "bound" to this mission; each atom is associated with a 2-element list. The first
	/// entry in that list is a bool that determines if the mission should fail when the atom qdeletes; the second
	/// is a callback to be invoked upon the atom's qdeletion.
	var/list/atom/movable/bound_atoms

/datum/mission/New()
	var/old_dur = duration
	var/val_mod = reward * val_mod_range
	var/dur_mod = duration * dur_mod_range

	duration = round(rand(duration - dur_mod, duration + dur_mod), 30 SECONDS)
	reward = round(rand(reward - val_mod, reward + val_mod) * (dur_value_scaling ? old_dur / duration : 1), 50)

	return ..()

/datum/mission/Destroy()
	if(servant)
		unregister_signal(servant, SIGNAL_QDELETING)
		LAZYREMOVE(servant.missions, src)
		servant = null

	return ..()

/datum/mission/proc/accept(obj/structure/overmap/acceptor)
	accepted = TRUE
	servant = acceptor
	set_next_think(world.time + duration)
	ends_at = world.time + duration

/datum/mission/proc/turn_in()
	var/datum/transaction/T = new("[servant.name]", "Incentive payment #[generateRandomString()]", reward, "Sectoral Corporative Command")
	servant.ship_account.do_transaction(T)
	qdel_self()

/datum/mission/proc/give_up()
	qdel_self()

/datum/mission/proc/can_complete()
	return !failed

/datum/mission/proc/get_tgui_info()
	var/time_remaining = (ends_at - world.time) / 10

	var/act_str = "Give up"
	if(!accepted)
		act_str = "Accept"
	else if(can_complete())
		act_str = "Turn in"

	return list(
		"ref" = any2ref(src),
		"name" = name,
		"desc" = desc,
		"reward" = reward,
		"duration" = duration,
		"remaining" = time_remaining,
		"timeStr" = time2text(time_remaining, "mm:ss"),
		"progressStr" = get_progress_string(),
		"actStr" = act_str
	)

/datum/mission/proc/get_progress_string()
	return "null"

/proc/get_weighted_mission_type()
	var/static/list/weighted_missions
	if(!weighted_missions)
		weighted_missions = list()
		var/list/mission_types = subtypesof(/datum/mission)
		for(var/datum/mission/mis_type as anything in mission_types)
			if(initial(mis_type.weight) > 0)
				weighted_missions[mis_type] = initial(mis_type.weight)

	return util_pick_weight(weighted_missions)
