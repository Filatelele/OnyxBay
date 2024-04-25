/datum/devil_follower
	var/list/datum/action/starting_actions
	var/list/datum/modifier/modifiers
	var/weakref/follower

/datum/devil_follower/New(mob/living/carbon/human/follower)
	if(!istype(follower))
		return qdel_self()

	src.follower = weakref(follower)
	for(var/action in starting_actions)
		var/datum/action/act = new action(follower)
		act.Grant(follower)

	for(var/modifier in modifiers)
		ADD_TRAIT(follower, modifier)

/datum/devil_follower/Destroy()
	var/mob/living/carbon/human/former_follower = follower.resolve()
	if(istype(former_follower))
		for(var/datum/action/action in starting_actions)
			action.Remove(former_follower)

		for(var/modifier in modifiers)
			REMOVE_TRAIT(former_follower, modifier)

	return ..()
