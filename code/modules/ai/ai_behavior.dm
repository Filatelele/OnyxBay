/*
 * AI BEHAVIOR

 * The actual thinking brain that determines what it wants the mob to do
 * Registers signals, handles the pathfinding element addition/removal alongside making the mob do actions
 *
 * A brief note regarding the issue of commented SIGNAL_HANDLERS
 * Most procs use to_chat for debugging purposes. As you know, to_chat and some other procs use sleep - yay, BS12 code!
 * Therefore to prevent 30+ warnings from popping up they are commented to serve as a reminder for any future generations of coders.
*/

/datum/ai_behavior
	///What atom is the ai moving to
	var/atom/atom_to_walk_to
	/// How far should we stay away from atom_to_walk_to
	var/distance_to_maintain = 1
	/// Prob chance of sidestepping (left or right) when distance maintained with target
	var/sidestep_prob = 0
	/// Current node to use for calculating action states: this is the mob's node
	var/obj/effect/ai_node/current_node
	/// The node goal of this ai
	var/obj/effect/ai_node/goal_node
	/// A list of nodes the ai should go to in order to go to goal_node
	var/list/obj/effect/ai_node/goal_nodes
	/// A list of turfs the ai should go in order to get to atom_to_walk_to
	var/list/turf/turfs_in_path
	/// What the ai is doing right now
	var/current_action
	/// The standard ation of the AI, aka what it should do at the init or when going back to "normal" behavior
	var/base_action = MOVING_TO_NODE
	/// Parent associated with this AI behavior instance
	var/mob/mob_parent
	/// An identifier associated with this behavior, used for accessing specific values of a node's weights
	var/identifier
	/// How far will we look for targets
	var/target_distance = 8
	/// What we will escort
	var/atom/escorted_atom
	/// When this timer is up, we force a change of node to ensure that the ai will never stay stuck trying to go to a specific node
	var/anti_stuck_timer
	/// Minimum health percentage before the ai tries to run away
	var/minimum_health = 0.4
	/// Are we waiting for advanced pathfinding
	var/registered_for_node_pathfinding = FALSE
	/// Are we already registered for normal pathfinding
	var/registered_for_move = FALSE
	/// Should we lose the escorted atom if we change action
	var/weak_escort = FALSE
	/// Delay before bot tries to switch pathfinding modes between node and tile-based in order to unstuck itself
	var/unstuck_delay = 4 SECONDS

/datum/ai_behavior/New(loc, mob/parent_to_assign, atom/escorted_atom)
	..()
	if(isnull(parent_to_assign))
		util_crash_with("An ai behavior was initialized without a parent to assign it to; destroying mind. Mind type: [type]")
		qdel_self()
		return

	mob_parent = parent_to_assign
	set_escorted_atom(null, escorted_atom)
	//We always use the escorted atom as our reference point for looking for target. So if we don't have any escorted atom, we take ourselve as the reference
	add_think_ctx("scheduled_move", CALLBACK(src, nameof(.proc/scheduled_move)), 0)
	add_think_ctx("ask_for_pathfinding", CALLBACK(src, nameof(.proc/ask_for_pathfinding)), 0)
	add_think_ctx("look_for_next_node", CALLBACK(src, nameof(.proc/look_for_next_node)), 0)
	set_next_think(world.time + 1 SECOND)

/datum/ai_behavior/Destroy(force)
	current_node = null
	escorted_atom = null
	mob_parent = null
	atom_to_walk_to = null
	return ..()

/// Register ai behaviours
/datum/ai_behavior/proc/start_ai()
	if(escorted_atom)
		global_set_escorted_atom(null, escorted_atom)
	else
		register_global_signal(COMSIG_GLOB_AI_MINION_RALLY, nameof(.proc/global_set_escorted_atom))
	register_global_signal(COMSIG_GLOB_AI_GOAL_SET, nameof(.proc/set_goal_node))
	set_goal_node(null, null, GLOB.goal_nodes[identifier])
	register_signal(goal_node, SIGNAL_QDELETING, nameof(.proc/clean_goal_node))
	late_initialize()

/// Set behaviour to base behavior
/datum/ai_behavior/proc/late_initialize()
	switch(base_action)
		if(MOVING_TO_NODE)
			look_for_next_node()
		if(ESCORTING_ATOM)
			change_action(ESCORTING_ATOM, escorted_atom)
		if(IDLE)
			change_action(IDLE)

/// We finished moving to a node, let's pick a random nearby one to travel to
/datum/ai_behavior/proc/finished_node_move()
	//SIGNAL_HANDLER
	look_for_next_node(FALSE)
	return COMSIG_MAINTAIN_POSITION

/// Cleans up signals related to the action and element(s)
/datum/ai_behavior/proc/cleanup_current_action(next_action)
	if(current_action == MOVING_TO_NODE && next_action != MOVING_TO_NODE)
		set_current_node(null)
	if(current_action == ESCORTING_ATOM && next_action != ESCORTING_ATOM && next_action != MOVING_TO_ATOM)
		clean_escorted_atom()
	unregister_action_signals(current_action)

/datum/ai_behavior/proc/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			unregister_signal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			set_next_think_ctx("ask_for_pathfinding", 0)
		if(FOLLOWING_PATH)
			unregister_signal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			set_next_think_ctx("look_for_next_node", 0)

/// Clean every signal on the ai_behavior
/datum/ai_behavior/proc/cleanup_signals()
	cleanup_current_action()
	unregister_global_signal(COMSIG_GLOB_AI_MINION_RALLY)
	unregister_global_signal(COMSIG_GLOB_AI_GOAL_SET)
	if(goal_node)
		unregister_signal(goal_node, SIGNAL_QDELETING)

/// Cleanup old state vars, start the movement towards our new target
/datum/ai_behavior/proc/change_action(next_action, atom/next_target, special_distance_to_maintain)
	if(QDELETED(mob_parent))
		return

	cleanup_current_action(next_action)
	#ifdef TESTING
	switch(next_action)
		if(MOVING_TO_NODE)
			message_admins("[mob_parent] goes to a new node")
			flick("x2_animate", next_target)
		if(MOVING_TO_ATOM)
			message_admins("[mob_parent] moves toward [next_target]")
		if(MOVING_TO_SAFETY)
			message_admins("[mob_parent] wants to escape from [next_target]")
		if(ESCORTING_ATOM)
			message_admins("[mob_parent] escorts [next_target]")
		if(FOLLOWING_PATH)
			message_admins("[mob_parent] moves toward [next_target] as part of its path")
		if(IDLE)
			message_admins("[mob_parent] is idle")
	#endif
	if(next_action)
		current_action = next_action
	if(current_action == FOLLOWING_PATH)
		distance_to_maintain = 0
	else if(current_action == ESCORTING_ATOM)
		distance_to_maintain = 1
	else
		distance_to_maintain = isnull(special_distance_to_maintain) ? initial(distance_to_maintain) : special_distance_to_maintain
	if(next_target)
		atom_to_walk_to = next_target
		if(!registered_for_move)
			INVOKE_ASYNC(src, nameof(.proc/scheduled_move))

	register_action_signals(current_action)
	if(current_action == MOVING_TO_SAFETY)
		mob_parent.a_intent = I_HELP
	else
		mob_parent.a_intent = I_HURT

/// Try to find a node to go to. If ignore_current_node is true, we will just find the closest current_node, and not the current_node best adjacent node
/datum/ai_behavior/proc/look_for_next_node(ignore_current_node = TRUE, should_reset_goal_nodes = FALSE)
	if(should_reset_goal_nodes)
		set_current_node(null)

	if(ignore_current_node || !current_node)
		var/closest_distance = MAX_NODE_RANGE
		var/avoid_node = current_node
		for(var/obj/effect/ai_node/ai_node as anything in GLOB.all_nodes)
			if(!ai_node)
				continue

			if(ai_node == avoid_node)
				continue

			if(ai_node.z != mob_parent.z || get_dist(ai_node, mob_parent) >= closest_distance)
				continue

			set_current_node(ai_node)
			closest_distance = get_dist(ai_node, mob_parent)
		if(current_node)
			change_action(MOVING_TO_NODE, current_node)
		return

	if(goal_node && goal_node != current_node)
		if(!length(goal_nodes))
			if(!registered_for_node_pathfinding)
				SSadvanced_pathfinding.node_pathfinding_to_do += src
				registered_for_node_pathfinding = TRUE
			return

		set_current_node(GLOB.all_nodes[goal_nodes[length(goal_nodes)] + 1])
		goal_nodes.len--
	else
		set_current_node(current_node.get_best_adj_node(list(NODE_LAST_VISITED = -1), identifier))
	if(!current_node)
		set_next_think_ctx("look_for_next_node", world.time + 1 SECOND, TRUE)
		return

	current_node.set_weight(identifier, NODE_LAST_VISITED, world.time)
	change_action(MOVING_TO_NODE, current_node)

/// Set the current node to next_node
/datum/ai_behavior/proc/set_current_node(obj/effect/ai_node/next_node)
	if(current_node)
		unregister_signal(current_node, SIGNAL_QDELETING)
	if(next_node)
		register_signal(current_node, SIGNAL_QDELETING, nameof(.proc/look_for_next_node))
	current_node = next_node

/// Signal handler when the ai is blocked by an obstacle
/datum/ai_behavior/proc/deal_with_obstacle(datum/source, direction)
	//SIGNAL_HANDLER
	pass()

/// Register on advanced pathfinding subsytem to get a tile pathfinding
/datum/ai_behavior/proc/ask_for_pathfinding()
	SSadvanced_pathfinding.tile_pathfinding_to_do += src

/// Look for the a* tile path to get to atom_to_walk_to
/datum/ai_behavior/proc/look_for_tile_path()
	if(QDELETED(current_node))
		return

	turfs_in_path = get_path(get_turf(mob_parent), get_turf(current_node), TILE_PATHING)
	if(!length(turfs_in_path))
		cleanup_current_action()
		late_initialize()
		return

	change_action(FOLLOWING_PATH, turfs_in_path[length(turfs_in_path)])
	turfs_in_path.len--

/// Look for the a* node path to get to goal_node
/datum/ai_behavior/proc/look_for_node_path()
	if(QDELETED(goal_node) || QDELETED(current_node))
		return

	var/goal_nodes_serialized = rustg_generate_path_astar("[current_node.unique_id]", "[goal_node.unique_id]")
	if(rustg_json_is_valid(goal_nodes_serialized))
		goal_nodes = json_decode(goal_nodes_serialized)
	else
		goal_nodes = list()
		set_current_node(null)
	look_for_next_node()

/// Signal handler when we reached our current tile goal
/datum/ai_behavior/proc/finished_path_move()
	//SIGNAL_HANDLER
	if(!length(turfs_in_path))
		cleanup_current_action()
		late_initialize()
		return

	atom_to_walk_to = turfs_in_path[length(turfs_in_path)]
	if(!registered_for_move)
		INVOKE_ASYNC(src, nameof(.proc/scheduled_move))
	turfs_in_path.len--
	return COMSIG_MAINTAIN_POSITION

/// Used for mainly looking at the world around the AI and determining if a new action must be considered and executed
/datum/ai_behavior/think()
	look_for_new_state()
	set_next_think(world.time + 1 SECOND)

/// Check if we need to adopt a new state
/datum/ai_behavior/proc/look_for_new_state()
	//SIGNAL_HANDLER
	pass()

/// Set the goal node
/datum/ai_behavior/proc/set_goal_node(datum/source, identifier, obj/effect/ai_node/new_goal_node)
	//SIGNAL_HANDLER
	if(identifier && src.identifier != identifier)
		return

	if(goal_node)
		unregister_signal(goal_node, SIGNAL_QDELETING)
	goal_node = new_goal_node
	goal_nodes = null
	register_signal(goal_node, SIGNAL_QDELETING, nameof(.proc/clean_goal_node))

/// Set the escorted atom.
/datum/ai_behavior/proc/set_escorted_atom(datum/source, atom/atom_to_escort, new_escort_is_weak)
	//SIGNAL_HANDLER
	clean_escorted_atom()
	escorted_atom = atom_to_escort
	weak_escort = new_escort_is_weak
	if(!weak_escort)
		unregister_global_signal(COMSIG_GLOB_AI_MINION_RALLY)
		base_action = ESCORTING_ATOM
	register_signal(escorted_atom, SIGNAL_QDELETING, nameof(.proc/clean_escorted_atom))
	change_action(ESCORTING_ATOM, escorted_atom)

/// Change atom to walk to if the order comes from a corresponding commander
/datum/ai_behavior/proc/global_set_escorted_atom(datum/source, atom/atom_to_escort)
	//SIGNAL_HANDLER
	if(!atom_to_escort || mob_parent.ckey)
		return

	if(get_dist(atom_to_escort, mob_parent) > target_distance)
		return

	set_escorted_atom(source, atom_to_escort)


/// Clean the escorted atom var to avoid harddels
/datum/ai_behavior/proc/clean_escorted_atom()
	//SIGNAL_HANDLER
	if(!escorted_atom)
		return

	unregister_signal(escorted_atom, SIGNAL_QDELETING)
	escorted_atom = null
	base_action = initial(base_action)
	unregister_global_signal(COMSIG_GLOB_AI_MINION_RALLY)

/// Set the target distance to be normal (initial) or very low (almost passive)
/datum/ai_behavior/proc/set_agressivity(datum/source, should_be_agressive = TRUE)
	//SIGNAL_HANDLER
	target_distance = should_be_agressive ? initial(target_distance) : 2

/// Clean the goal node
/datum/ai_behavior/proc/clean_goal_node()
	//SIGNAL_HANDLER
	goal_node = null
	goal_nodes = null
	if(current_action == MOVING_TO_NODE)
		look_for_next_node()

/*
Registering and unregistering signals related to a particular current_action
These are parameter based so the ai behavior can choose to (un)register the signals it wants to rather than based off of current_action
*/
/datum/ai_behavior/proc/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			register_signal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, nameof(.proc/finished_node_move))
			set_next_think_ctx("ask_for_pathfinding", world.time + unstuck_delay)
		if(FOLLOWING_PATH)
			register_signal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, nameof(.proc/finished_path_move))
			set_next_think_ctx("look_for_next_node", world.time + unstuck_delay, TRUE)

/// Move the ai and schedule the next move
/datum/ai_behavior/proc/scheduled_move()
	if(QDELETED(mob_parent))
		return
	if(!atom_to_walk_to)
		registered_for_move = FALSE
		return
	ai_do_move()
	var/next_move = mob_parent.cached_slowdown + mob_parent.next_move_slowdown
	if(next_move <= 0)
		next_move = 1
	set_next_think_ctx("scheduled_move", world.time + next_move)
	registered_for_move = TRUE

/mob/var/next_move_slowdown = 0

/// Returns the left and right dir of the input dir, used for AI stutter step while attacking
/proc/LeftAndRightOfDir(direction, diagonal_check = FALSE)
	if(diagonal_check)
		if(ISDIAGONALDIR(direction))
			return list(turn(direction, 45), turn(direction, -45))
	return list(turn(direction, 90), turn(direction, -90))

/// Moves the ai toward its atom_to_walk_to
/datum/ai_behavior/proc/ai_do_move()
	/// This allows minions to be buckled to their atom_to_escort without disrupting the movement of atom_to_escort
	if(get_dist(mob_parent, atom_to_walk_to) <= 0)
		SEND_SIGNAL(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
		return

	mob_parent.next_move_slowdown = 0
	var/step_dir
	if(get_dist(mob_parent, atom_to_walk_to) == distance_to_maintain)
		if(SEND_SIGNAL(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE) & COMSIG_MAINTAIN_POSITION)
			return

		if(!get_dir(mob_parent, atom_to_walk_to)) //We're right on top, move out of it
			step_dir = pick(GLOB.alldirs)
			mob_parent.moving = TRUE
			if(!mob_parent.Move(get_step(mob_parent, step_dir), step_dir))
				SEND_SIGNAL(mob_parent, COMSIG_OBSTRUCTED_MOVE, get_step(mob_parent, step_dir))
			else if(ISDIAGONALDIR(step_dir))
				mob_parent.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_parent.cached_slowdown //Not perfect but good enough
			mob_parent.moving = FALSE
			return
		if(prob(sidestep_prob))
			step_dir = pick(LeftAndRightOfDir(get_dir(mob_parent, atom_to_walk_to)))
			mob_parent.moving = TRUE
			if(!mob_parent.Move(get_step(mob_parent, step_dir), step_dir))
				SEND_SIGNAL(mob_parent, COMSIG_OBSTRUCTED_MOVE, step_dir)
			else if(ISDIAGONALDIR(step_dir))
				mob_parent.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_parent.cached_slowdown
			mob_parent.moving = FALSE
		return
	if(get_dist(mob_parent, atom_to_walk_to) < distance_to_maintain) //We're too close, back it up
		step_dir = get_dir(atom_to_walk_to, mob_parent)
	else
		step_dir = get_dir(mob_parent, atom_to_walk_to)
	var/turf/next_turf = get_step(mob_parent, step_dir)
	mob_parent.moving = TRUE
	if(!mob_parent.Move(next_turf, step_dir) && !(SEND_SIGNAL(mob_parent, COMSIG_OBSTRUCTED_MOVE, next_turf) & COMSIG_OBSTACLE_DEALT_WITH))
		step_dir = pick(LeftAndRightOfDir(step_dir))
		next_turf = get_step(mob_parent, step_dir)
		mob_parent.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_parent.cached_slowdown
	else if(ISDIAGONALDIR(step_dir))
		mob_parent.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_parent.cached_slowdown
	mob_parent.moving = FALSE

///Returns the nearest target that has the right target flag
/datum/ai_behavior/proc/get_nearest_target(atom/source, distance, target_flags, attacker_faction)
	if(!source)
		return

	var/atom/nearest_target
	var/shorter_distance = distance + 1
	if(target_flags & TARGET_HUMAN)
		for(var/mob/living/nearby_human as anything in cheap_get_humans_near(source, distance))
			if(nearby_human.is_ic_dead() || nearby_human.faction == attacker_faction)
				continue

			if(get_dist(source, nearby_human) < shorter_distance)
				nearest_target = nearby_human
				shorter_distance = get_dist(source, nearby_human)

	if(target_flags & TARGET_HUMAN_TURRETS)
		for(var/atom/nearby_turret as anything in GLOB.all_turrets)
			if(source.z != nearby_turret.z)
				continue

			if(!(get_dist(source, nearby_turret) < shorter_distance))
				continue

			nearest_target = nearby_turret

	return nearest_target
