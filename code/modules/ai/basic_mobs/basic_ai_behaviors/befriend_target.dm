///behavior to befriend any targets
/datum/ai_behavior/befriend_target

/datum/ai_behavior/befriend_target/perform(datum/ai_controller/controller, target_key, befriend_message)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, any2ref(living_target))
	var/befriend_text = controller.blackboard[befriend_message]
	if(befriend_text)
		to_chat(living_target, SPAN_NOTICE("[living_pawn] [befriend_text]"))

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/befriend_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
