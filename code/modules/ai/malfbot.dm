//Generic template for application to a malfbot/ mob, contains specific obstacle dealing alongside targeting only humans, malfbots of a different hive and sentry turrets

/datum/ai_behavior/malfbot
	sidestep_prob = 25
	identifier = IDENTIFIER_MALFBOT
	///List of abilities to consider doing every think()
	var/list/ability_list = list()
	///If the mob parent can heal itself and so should flee
	var/can_heal = TRUE

/datum/ai_behavior/malfbot/New(loc, parent_to_assign, escorted_atom, can_heal = TRUE)
	..()
	refresh_abilities()
	mob_parent.a_intent = I_HURT //Killing time
	src.can_heal = can_heal

/datum/ai_behavior/malfbot/start_ai()
	register_signal(mob_parent, COMSIG_OBSTRUCTED_MOVE, nameof(.proc/deal_with_obstacle))
	register_signal(mob_parent, SIGNAL_MOB_ACTION_GIVEN, nameof(.proc/refresh_abilities))
	register_signal(mob_parent, SIGNAL_MOB_ACTION_REMOVED, nameof(.proc/refresh_abilities))
	register_signal(mob_parent, SIGNAL_MALFBOT_TAKING_DAMAGE, nameof(.proc/check_for_critical_health))
	return ..()

///Refresh abilities-to-consider list
/datum/ai_behavior/malfbot/proc/refresh_abilities()
	SIGNAL_HANDLER
	ability_list = list()
	var/mob/living/action_parent = mob_parent
	if(!istype(action_parent))
		return

	for(var/datum/action/action as anything in action_parent.actions)
		if(action.ai_should_start_consider())
			ability_list += action

/datum/ai_behavior/malfbot/think()
	//var/mob/living/action_parent = mob_parent
	//if(action_parent.do_actions) //No activating more abilities if they're already in the progress of doing one
	//	return ..()

	for(var/datum/action/action in ability_list)
		if(!action.ai_should_use(atom_to_walk_to))
			continue

		INVOKE_ASYNC(action, nameof(/datum/action/.proc/Activate), atom_to_walk_to)

	return ..()

#define ESCORTING_MAX_DISTANCE 10

/datum/ai_behavior/malfbot/look_for_new_state()
	var/mob/living/living_parent = mob_parent
	switch(current_action)
		if(ESCORTING_ATOM)
			if(get_dist(escorted_atom, mob_parent) > ESCORTING_MAX_DISTANCE)
				look_for_next_node()
				return

			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)
				return

			if(living_parent.pulling)
				return

			change_action(MOVING_TO_ATOM, next_target)
		if(MOVING_TO_NODE, FOLLOWING_PATH)
			var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)
				if(can_heal && living_parent.health <= minimum_health * 2 * living_parent.maxHealth)
					try_to_heal()
				return

			if(living_parent.pulling)
				return

			change_action(MOVING_TO_ATOM, next_target)
		if(MOVING_TO_ATOM)
			if(!weak_escort && escorted_atom && get_dist(escorted_atom, mob_parent) > target_distance)
				change_action(ESCORTING_ATOM, escorted_atom)
				return

			var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)//We didn't find a target
				cleanup_current_action()
				late_initialize()
				return

			if(next_target == atom_to_walk_to)//We didn't find a better target
				return

			if(living_parent.pulling)
				return

			change_action(null, next_target)//We found a better target, change course!
		if(MOVING_TO_SAFETY)
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)//We are safe, try to find some weeds
				target_distance = initial(target_distance)
				cleanup_current_action()
				late_initialize()
				register_signal(mob_parent, SIGNAL_MALFBOT_TAKING_DAMAGE, nameof(.proc/check_for_critical_health))
				return

			if(next_target == atom_to_walk_to)
				return

			change_action(null, next_target, INFINITY)
		if(IDLE)
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_HOSTILE, mob_parent.faction)
			if(!next_target)
				return

			change_action(MOVING_TO_ATOM, next_target)

/datum/ai_behavior/malfbot/deal_with_obstacle(datum/source, direction)
	var/turf/obstacle_turf = source

	for(var/thing in obstacle_turf.contents)
		if(istype(thing, /obj/structure/window_frame))
			mob_parent.forceMove(thing)
			return COMSIG_OBSTACLE_DEALT_WITH

		if(istype(thing, /obj/structure))
			var/obj/structure/closet/closet = thing
			if(closet.open(mob_parent))
				return COMSIG_OBSTACLE_DEALT_WITH

			qdel(thing)
			return COMSIG_OBSTACLE_DEALT_WITH


		else if(istype(thing, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/lock = thing
			if(!lock.density)
				continue

			if(lock.operating)
				continue

			if(lock.welded || lock.locked)
				qdel(thing)
				continue

			lock.open(TRUE)
			return COMSIG_OBSTACLE_DEALT_WITH

		if(istype(thing, /obj/vehicle))
			INVOKE_ASYNC(src, nameof(.proc/attack_target), null, thing)
			return COMSIG_OBSTACLE_DEALT_WITH

	if(ISDIAGONALDIR(direction) && ((deal_with_obstacle(null, turn(direction, -45)) & COMSIG_OBSTACLE_DEALT_WITH) || (deal_with_obstacle(null, turn(direction, 45)) & COMSIG_OBSTACLE_DEALT_WITH)))
		return COMSIG_OBSTACLE_DEALT_WITH

	//Ok we found nothing, yet we are still blocked. Check for blockers on our current turf
	obstacle_turf = get_turf(mob_parent)
	for(var/obj/structure/obstacle in obstacle_turf.contents)
		if(obstacle.dir & direction)
			INVOKE_ASYNC(src, nameof(.proc/attack_target), null, obstacle)
			return COMSIG_OBSTACLE_DEALT_WITH

/datum/ai_behavior/malfbot/cleanup_current_action(next_action)
	. = ..()
	if(next_action == MOVING_TO_NODE)
		return

	if(!istype(mob_parent, /mob/living/carbon/human/malf_robot))
		return

	var/mob/living/living_mob = mob_parent
	if(can_heal && living_mob.resting)
		SEND_SIGNAL(mob_parent, SIGNAL_MALFBOT_ABILITY_RESET)
		unregister_signal(mob_parent, SIGNAL_MALFBOT_HEALTH_REGEN)

/datum/ai_behavior/malfbot/cleanup_signals()
	. = ..()
	unregister_signal(mob_parent, COMSIG_OBSTRUCTED_MOVE)
	unregister_signal(mob_parent, list(SIGNAL_MOB_ACTION_GIVEN, SIGNAL_MOB_ACTION_REMOVED))
	unregister_signal(mob_parent, SIGNAL_MALFBOT_TAKING_DAMAGE)

///Signal handler to try to attack our target
/datum/ai_behavior/malfbot/proc/attack_target(datum/soure, atom/attacked)
	SIGNAL_HANDLER
	if(world.time < mob_parent.next_move)
		return

	if(!attacked)
		attacked = get_atom_on_turf(atom_to_walk_to)

	if(get_dist(attacked, mob_parent) > 1)
		return

	mob_parent.face_atom(attacked)
	var/mob/living/carbon/carbon_target = attacked
	if(istype(carbon_target))
		if(carbon_target.lying && !iscuffed(carbon_target))
			var/obj/item/handcuffs/cuffs = new /obj/item/handcuffs(mob_parent)
			cuffs.forceMove(get_turf(carbon_target))
			carbon_target.equip_to_slot(cuffs, slot_handcuffed)
			playsound(carbon_target.loc, GET_SFX(SFX_USE_CABLE_HANDCUFFS), 30, 1, -2)
			return

		if(!carbon_target.lying)
			mob_parent.a_intent = I_HELP
			var/obj/item/melee/baton/loaded/baton = new /obj/item/melee/baton/loaded(src)
			playsound(carbon_target.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			baton.status = TRUE
			baton.attack(carbon_target, mob_parent, pick(list(BP_L_FOOT, BP_R_FOOT, BP_L_LEG, BP_R_LEG)))
			return

		if(iscuffed(carbon_target) && !istype(mob_parent.pulling))
			mob_parent.start_pulling(carbon_target)
			var/obj/machinery/borgizer/borgizer = safepick(GLOB.borgizer_list)
			if(!istype(borgizer))
				return

			var/atom/movable/ai_node/node = locate() in get_turf(borgizer)
			set_goal_node(null, null, node)
			look_for_next_node(TRUE, FALSE)

/datum/ai_behavior/malfbot/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			register_signal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, nameof(.proc/attack_target))
			if(ishuman(atom_to_walk_to))
				register_signal(atom_to_walk_to, SIGNAL_MOB_DEATH, nameof(.proc/look_for_new_state))
				return

	return ..()

/datum/ai_behavior/malfbot/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			unregister_signal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			if(ishuman(atom_to_walk_to))
				unregister_signal(atom_to_walk_to, SIGNAL_MOB_DEATH)
				return

	return ..()

///Will try finding and resting on weeds
/datum/ai_behavior/malfbot/proc/try_to_heal()
	var/mob/living/carbon/human/malf_robot/living_mob = mob_parent
	//if(!living_mob.loc_weeds_type)
	///	if(living_mob.resting)//We are resting on no weeds
	//		SEND_SIGNAL(mob_parent, SIGNAL_MALFBOT_ABILITY_RESET)
	//		unregister_signal(mob_parent, SIGNAL_MALFBOT_HEALTH_REGEN)
	//	return FALSE

	if(living_mob.resting)//Already resting
		if(living_mob.fire_stacks)
			living_mob.resist()
		return TRUE

	SEND_SIGNAL(mob_parent, SIGNAL_MALFBOT_HEALTH_REGEN)
	register_signal(mob_parent, SIGNAL_MALFBOT_ABILITY_RESET, nameof(.proc/check_for_health))
	return TRUE

///Wait for the malfbot to be full life and plasma to unrest
/datum/ai_behavior/malfbot/proc/check_for_health(mob/living/carbon/human/malf_robot/healing, list/heal_data)
	SIGNAL_HANDLER
	if(healing.health + heal_data[1] >= healing.maxHealth)
		SEND_SIGNAL(mob_parent, SIGNAL_MALFBOT_ABILITY_RESET)
		unregister_signal(mob_parent, SIGNAL_MALFBOT_HEALTH_REGEN)

///Wait for the malfbot to be full life and plasma to unrest
/datum/ai_behavior/malfbot/proc/check_for_plasma(mob/living/carbon/human/malf_robot/healing, list/plasma_data)
	SIGNAL_HANDLER
	if(healing.health >= healing.maxHealth)
		SEND_SIGNAL(mob_parent, SIGNAL_MALFBOT_ABILITY_RESET)
		unregister_signal(mob_parent, SIGNAL_MALFBOT_HEALTH_REGEN)

///Called each time the ai takes damage; if we are below a certain health threshold, try to retreat
/datum/ai_behavior/malfbot/proc/check_for_critical_health(datum/source, damage)
	SIGNAL_HANDLER
	var/mob/living/living_mob = mob_parent
	if(!can_heal || living_mob.health - damage > minimum_health * living_mob.maxHealth)
		return

	var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction)
	if(!next_target)
		return

	target_distance = 15
	change_action(MOVING_TO_SAFETY, next_target, INFINITY)
	unregister_signal(mob_parent, SIGNAL_MALFBOT_TAKING_DAMAGE)

///Move the ai mob on top of the window_frame
/datum/ai_behavior/malfbot/proc/climb_window_frame(turf/window_turf)
	mob_parent.loc = window_turf
	mob_parent.next_move_slowdown = world.time
	//LAZYDECREMENT(mob_parent.do_actions, window_turf)

/datum/ai_behavior/malfbot/finished_node_move()
	if(current_node == goal_node)
		if(mob_parent.pulling)
			var/obj/machinery/borgizer/borgizer = locate(/obj/machinery/borgizer) in view(2, mob_parent)
			if(istype(borgizer))
				borgizer.put_mob(mob_parent.pulling)

	return ..()

/datum/action/cooldown/malfbot/energynet
	name = "Energy net"
	action_type = AB_INNATE
	var/fire_force = 1
	var/fire_distance = 10
	cooldown_time = 30 SECONDS

/datum/action/cooldown/malfbot/energynet/ai_should_start_consider()
	return TRUE

/datum/action/cooldown/malfbot/energynet/ai_should_use(atom/target)
	var/mob/living/carbon/carbon_target = target
	if(!istype(carbon_target))
		return

	if(iscuffed(target))
		return FALSE

	if(get_dist(target, owner) > 5)
		return FALSE

	if(!Checks() || !IsAvailable())
		return FALSE

	if(istype(carbon_target?.buckled, /obj/effect/energy_net))
		return FALSE

	return TRUE

/datum/action/cooldown/malfbot/energynet/Activate(atom/target)
	StartCooldownSelf()
	owner.Beam(target, "n_beam", time = 1 SECOND)
	var/obj/item/firing = new /obj/item/energy_net()
	firing.forceMove(get_turf(owner))
	firing.throw_at(target, fire_distance, fire_force)
