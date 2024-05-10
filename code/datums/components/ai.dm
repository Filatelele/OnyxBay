/*
 * AI CONTROLLER COMPONENT
 *
 * Holds AI behavior datum, sets initial AI behavior and cleans up it on qdel.
*/

/**
 * An absolute hardcap on the # of instances of /datum/component/ai_controller that can exist.
 * Keeps shitcoders and admins with braindamage from fucking our server up.
 * Will prevent initialization of the component in case hardcap is reached.
 */
/** */

#define AI_INSTANCE_HARDCAP 150

/datum/component/ai_controller
	/// "The brain" of the system which decides what to do based on given parameters.
	var/datum/ai_behavior/ai_behavior

/datum/component/ai_controller/Initialize(behavior_type, atom/atom_to_escort)
	. = ..()

	if(!ismob(parent)) // Mob is an absolute requirement as AI behavior takes into account such vars as cached_slowdown
		util_crash_with("An AI controller was initialized on a parent that isn't compatible with the ai component. Parent type: [parent.type]")
		return COMPONENT_INCOMPATIBLE
	if(isnull(behavior_type))
		util_crash_with("An AI controller was initialized without a mind to initialize parameter; component removed")
		return COMPONENT_INCOMPATIBLE
	ai_behavior = new behavior_type(src, parent, atom_to_escort, isliving(parent))
	start_ai()

/datum/component/ai_controller/clear_from_parent()
	clean_up(FALSE)
	return ..()

/// Stop the ai behaviour from processing and cleans all signals
/datum/component/ai_controller/proc/clean_up(register_for_logout = TRUE)
	SIGNAL_HANDLER
	GLOB.ai_instances_active -= src
	unregister_signal(parent, SIGNAL_LOGGED_IN)
	unregister_signal(parent, SIGNAL_MOB_DEATH)
	if(ai_behavior)
		ai_behavior.set_next_think(0)
		ai_behavior.cleanup_signals()
		ai_behavior.atom_to_walk_to = null
		if(register_for_logout)
			register_signal(parent, SIGNAL_LOGGED_OUT, nameof(.proc/start_ai))
			return
		ai_behavior = null

/// Start the ai behaviour
/datum/component/ai_controller/proc/start_ai()
	//SIGNAL_HANDLER
	if(!ai_behavior || QDELETED(parent))
		return

	var/mob/living/living_parent = parent
	if(living_parent.stat == DEAD)
		return

	if((length(GLOB.ai_instances_active) + 1) >= AI_INSTANCE_HARDCAP)
		message_admins("Notice: An AI controller failed resume because there's already too many AI controllers existing.")
		ai_behavior = null
		return

	for(var/obj/effect/ai_node/node in range(7))
		ai_behavior.current_node = node
		break

	ai_behavior.start_ai()
	register_signal(parent, SIGNAL_MOB_DEATH, nameof(.proc/clear_from_parent))
	register_signal(parent, SIGNAL_LOGGED_IN, nameof(.proc/clean_up))
	unregister_signal(parent, SIGNAL_LOGGED_OUT)
	GLOB.ai_instances_active += src

/datum/component/ai_controller/Destroy()
	clean_up(FALSE)
	return ..()
