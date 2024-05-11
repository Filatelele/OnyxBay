//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/ai_behavior/station_bot
	sidestep_prob = 25
	identifier = IDENTIFIER_SBOT
	///List of abilities to consider doing every Process()
	var/list/ability_list = list()
	var/patrolling = TRUE

/datum/ai_behavior/station_bot/New(loc, parent_to_assign, escorted_atom, can_heal = TRUE)
	..()
	mob_parent.a_intent = I_HURT //Killing time

/datum/ai_behavior/station_bot/start_ai()
	register_signal(mob_parent, COMSIG_OBSTRUCTED_MOVE, nameof(.proc/deal_with_obstacle))
	return ..()

///Refresh abilities-to-consider list
/datum/ai_behavior/station_bot/proc/refresh_abilities()
	SIGNAL_HANDLER
	ability_list = list()

/datum/ai_behavior/station_bot/think()
	return ..()

/datum/ai_behavior/station_bot/finished_node_move()
	if(current_node == goal_node)
		clean_goal_node()
	return ..()

/datum/ai_behavior/station_bot/look_for_new_state()
	switch(current_action)
		if(ESCORTING_ATOM)
			if(get_dist(escorted_atom, mob_parent) > ESCORTING_MAX_DISTANCE)
				look_for_next_node()
				return

			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)
				return

			change_action(MOVING_TO_ATOM, next_target)
		if(MOVING_TO_NODE, FOLLOWING_PATH)
			var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)
				if(!goal_node) // We are randomly moving
					var/atom/xeno_to_follow = get_nearest_target(mob_parent, ESCORTING_MAX_DISTANCE, TARGET_FRIENDLY_XENO, mob_parent.faction)
					if(xeno_to_follow)
						set_escorted_atom(null, xeno_to_follow, TRUE)
						return

				return

			change_action(MOVING_TO_ATOM, next_target)
		if(MOVING_TO_ATOM)
			if(!weak_escort && escorted_atom && get_dist(escorted_atom, mob_parent) > target_distance)
				change_action(ESCORTING_ATOM, escorted_atom)
				return

			var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target) // No target - abort.
				cleanup_current_action()
				late_initialize()
				return

			if(next_target == atom_to_walk_to) // No better target, no need to change action.
				return

			change_action(null, next_target) // A better target is found.
		if(MOVING_TO_SAFETY)
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target) //We are safe, try to find some weeds
				target_distance = initial(target_distance)
				cleanup_current_action()
				late_initialize()
				//register_signal(mob_parent, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(check_for_critical_health))
				return

			if(next_target == atom_to_walk_to)
				return

			change_action(null, next_target, INFINITY)
		if(IDLE)
			do_idle_action()
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)
				change_action(MOVING_TO_ATOM, next_target)

/datum/ai_behavior/station_bot/look_for_next_node(ignore_current_node = TRUE, should_reset_goal_nodes = FALSE)
	if(patrolling && !goal_node)
		var/list/possible_nodes = list()
		for(var/obj/effect/ai_node/supporting/S in GLOB.all_nodes)
			if(S.z != mob_parent.z)
				continue

			possible_nodes |= S

		var/obj/effect/ai_node/supporting/new_goal = safepick(possible_nodes)
		if(new_goal)
			set_goal_node(null, IDENTIFIER_SBOT, new_goal)
			return ..(TRUE, FALSE)

	else return ..()

/datum/ai_behavior/station_bot/deal_with_obstacle(datum/source, direction)
	var/turf/obstacle_turf = get_step(mob_parent, direction)

	for(var/thing in obstacle_turf.contents)
		if(istype(thing, /obj/structure/window_frame))
			mob_parent.forceMove(thing)
			return COMSIG_OBSTACLE_DEALT_WITH

		if(istype(thing, /obj/structure/closet))
			var/obj/structure/closet/closet = thing
			if(closet.open(mob_parent))
				return COMSIG_OBSTACLE_DEALT_WITH
			return

		if(istype(thing, /obj/structure))
			var/obj/structure/obstacle = thing
			qdel(thing)
				//INVOKE_ASYNC(src, nameof(.proc/attack_target), null, obstacle)
			return COMSIG_OBSTACLE_DEALT_WITH

		else if(istype(thing, /obj/machinery/door))
			var/obj/machinery/door/airlock/lock = thing
			if(!lock.density) //Airlock is already open no need to force it open again
				continue

			if(lock.operating) //Airlock already doing something
				continue

			if(lock?.welded || lock?.locked) //It's welded or locked, can't force that open
				qdel(lock)
				//INVOKE_ASYNC(src, nameof(.proc/attack_target), null, thing) //ai is cheating
				continue

			return COMSIG_OBSTACLE_DEALT_WITH

	if(ISDIAGONALDIR(direction) && ((deal_with_obstacle(null, turn(direction, -45)) & COMSIG_OBSTACLE_DEALT_WITH) || (deal_with_obstacle(null, turn(direction, 45)) & COMSIG_OBSTACLE_DEALT_WITH)))
		return COMSIG_OBSTACLE_DEALT_WITH

	//Ok we found nothing, yet we are still blocked. Check for blockers on our current turf
	obstacle_turf = get_turf(mob_parent)
	for(var/obj/structure/obstacle in obstacle_turf.contents)
		if(obstacle.dir & direction)
			INVOKE_ASYNC(src, nameof(.proc/attack_target), null, obstacle)
			return COMSIG_OBSTACLE_DEALT_WITH

/datum/ai_behavior/station_bot/cleanup_current_action(next_action)
	. = ..()

/datum/ai_behavior/station_bot/cleanup_signals()
	. = ..()
	unregister_signal(mob_parent, COMSIG_OBSTRUCTED_MOVE)
	//UnregisterSignal(mob_parent, list(ACTION_GIVEN, ACTION_REMOVED))
	//UnregisterSignal(mob_parent, COMSIG_XENOMORPH_TAKING_DAMAGE)

///Signal handler to try to attack our target
/datum/ai_behavior/station_bot/proc/attack_target(datum/soure, atom/attacked)
	//SIGNAL_HANDLER
	if(world.time < mob_parent.next_move)
		return

	if(!attacked)
		attacked = get_atom_on_turf(atom_to_walk_to)
	if(get_dist(attacked, mob_parent) > 1)
		return

	mob_parent.face_atom(attacked)
	mob_parent.UnarmedAttack(attacked, TRUE)

/datum/ai_behavior/station_bot/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			register_signal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, nameof(.proc/attack_target))
			if(ishuman(atom_to_walk_to))
				register_signal(atom_to_walk_to, SIGNAL_MOB_DEATH, nameof(.proc/look_for_new_state))
				return

	return ..()

/datum/ai_behavior/station_bot/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			unregister_signal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			if(ishuman(atom_to_walk_to))
				unregister_signal(atom_to_walk_to, SIGNAL_MOB_DEATH)
				return

	return ..()

/// Called while being IDLE.
/datum/ai_behavior/station_bot/proc/do_idle_action()
	pass()
