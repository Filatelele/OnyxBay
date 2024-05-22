/datum/ai_controller/basic_controller/pet_cult
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/swarm,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/swarm,
		BB_FRIENDLY_MESSAGE = "eagerly awaits your command...",
	)

	ai_movement = /datum/ai_movement/rustg
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/befriend_cultists,
		/datum/ai_planning_subtree/find_occupied_rune,
		/datum/ai_planning_subtree/find_dead_cultist,
		/datum/ai_planning_subtree/drag_target_to_rune,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
	)
	ai_traits = PAUSE_DURING_DO_AFTER

/datum/ai_controller/basic_controller/pet_cult/proc/delete_pull_target(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER

	unregister_signal(src, SIGNAL_MOB_STOPPED_PULLING)

	if(was_pulling == blackboard[BB_SWARM_TARGET])
		clear_blackboard_key(BB_SWARM_TARGET)

/datum/targeting_strategy/basic/swarm

/datum/targeting_strategy/basic/swarm/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	return (the_target.faction == "Swarm")

/datum/ai_planning_subtree/befriend_swarmers

/datum/ai_planning_subtree/befriend_cultists/SelectBehaviors(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_FRIENDLY_SWARMER))
		controller.queue_behavior(/datum/ai_behavior/befriend_target, BB_FRIENDLY_SWARMER)
		return

	controller.queue_behavior(/datum/ai_behavior/find_and_set/friendly_cultist, BB_FRIENDLY_SWARMER, /mob/living/carbon)

/datum/ai_behavior/find_and_set/friendly_cultist
	action_cooldown = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_and_set/friendly_cultist/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/mob/living/possible_swarmer in oview(search_range, controller.pawn))
		if(possible_swarmer.faction == "Swarm")
			return possible_swarmer

	return null

///subtree to find a rune with a viable target on it, so we can go activate it
/datum/ai_planning_subtree/find_occupied_rune

/datum/ai_planning_subtree/find_occupied_rune/SelectBehaviors(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_SWARM_BORGIZER))
		controller.queue_behavior(/datum/ai_behavior/activate_rune, BB_SWARM_BORGIZER)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/occupied_rune, BB_SWARM_BORGIZER, /obj/machinery/implantchair)

/datum/ai_behavior/find_and_set/occupied_rune

/datum/ai_behavior/find_and_set/occupied_rune/search_tactic(datum/ai_controller/controller, locate_path)
	var/min_dist
	var/obj/machinery/borgizer/closest = null
	for(var/obj/machinery/borgizer/target in GLOB.borgizer_list)
		var/dist = get_dist(controller.pawn, target)
		if(dist < min_dist)
			continue

		min_dist = dist
		closest = target

	return closest

/datum/ai_behavior/activate_rune
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 3 SECONDS

/datum/ai_behavior/activate_rune/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/activate_rune/perform(datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/revive_mob = locate(/mob/living) in get_turf(target)

	if(isnull(revive_mob) || revive_mob.is_ic_dead())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_pawn = controller.pawn
	living_pawn.UnarmedAttack(target)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/activate_rune/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

///find targets that we can revive
/datum/ai_planning_subtree/find_dead_cultist

/datum/ai_planning_subtree/find_dead_cultist/SelectBehaviors(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	if(!isnull(living_pawn.pulling))
		return

	if(controller.blackboard_key_exists(BB_SWARM_TARGET))
		controller.queue_behavior(/datum/ai_behavior/pull_target/cult_revive, BB_SWARM_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/dead_cultist, BB_SWARM_TARGET, /mob/living/carbon/human)

/datum/ai_behavior/find_and_set/dead_cultist

/datum/ai_behavior/find_and_set/dead_cultist/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/mob/living/carbon/human/target in oview(search_range, controller.pawn))
		if(target.is_ic_dead())
			continue

		return target
	return null

/datum/ai_behavior/pull_target/cult_revive

/datum/ai_behavior/pull_target/cult_revive/finish_action(datum/ai_controller/basic_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		return

	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return
	controller.register_signal(controller.pawn, SIGNAL_MOB_STOPPED_PULLING, nameof(/datum/ai_controller/basic_controller/pet_cult.proc/delete_pull_target), override = TRUE)

/datum/ai_planning_subtree/drag_target_to_rune

/datum/ai_planning_subtree/drag_target_to_rune/SelectBehaviors(datum/ai_controller/controller)
	if(!controller.blackboard_key_exists(BB_SWARM_TARGET)) //no target, we dont need to do anything
		return

	var/mob/living/our_pawn = controller.pawn

	if(isnull(our_pawn.pulling))
		return

	var/atom/target_rune = controller.blackboard[BB_SWARM_BORGIZER]

	//if(QDELETED(target_rune))
		//controller.queue_behavior(/datum/ai_behavior/use_mob_ability, BB_RUNE_ABILITY)
	//	return SUBTREE_RETURN_FINISH_PLANNING

	if(!can_see(our_pawn, target_rune, 9))
		controller.clear_blackboard_key(BB_SWARM_BORGIZER)
		return

	controller.queue_behavior(/datum/ai_behavior/travel_towards/drag_target_to_rune, BB_SWARM_BORGIZER, BB_SWARM_TARGET)

///behavior to drag the target onto the rune
/datum/ai_behavior/travel_towards/drag_target_to_rune
	clear_target = TRUE
	new_movement_type = /datum/ai_movement/rustg

/datum/ai_behavior/travel_towards/drag_target_to_rune/setup(datum/ai_controller/controller, target_key, cultist_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE

	set_movement_target(controller, target)

/datum/ai_behavior/travel_towards/drag_target_to_rune/finish_action(datum/ai_controller/controller, success, target_key, cultist_key)
	. = ..()
	if(success)
		var/atom/revival_rune = controller.blackboard[target_key]
		controller.set_blackboard_key(BB_SWARM_OCCUPIED_BORGIZER, revival_rune)
	controller.clear_blackboard_key(cultist_key)
	controller.clear_blackboard_key(target_key)

///command ability to draw runes
/datum/pet_command/untargeted_ability/draw_rune

/mob/living/carbon/human/swarmer
	ai_controller = /datum/ai_controller/basic_controller/pet_cult

/mob/living/carbon/human/swarmer/Initialize()
	. = ..()
	zone_sel = new /atom/movable/screen/zone_sel()
	ai_controller = new ai_controller(src)
