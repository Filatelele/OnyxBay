/datum/devil_follower/gluttony
	starting_actions = list(/datum/action/cooldown/spell/gluttony_heal)
	modifiers = list(/datum/modifier/sin/gluttony)

#define GLUTTONY_HEAL_REDUCTION 10

/datum/action/cooldown/spell/gluttony_heal
	name = "Heal"
	desc = "GLLUTTONY HEAL!!!"
	button_icon_state = "undead_heal"

	cooldown_time = 30 SECONDS

	cast_range = 1 /// Basically must be adjacent

/datum/action/cooldown/spell/gluttony_heal/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/gluttony_heal/cast(mob/living/carbon/human/cast_on)
	var/mob/living/carbon/carbon_owner = owner
	if(!istype(carbon_owner))
		return

	cast_on.adjustBruteLoss(carbon_owner.nutrition / GLUTTONY_HEAL_REDUCTION)
	cast_on.adjustFireLoss(carbon_owner.nutrition / GLUTTONY_HEAL_REDUCTION)
	cast_on.adjustToxLoss(carbon_owner.nutrition / GLUTTONY_HEAL_REDUCTION)
	cast_on.adjustOxyLoss(carbon_owner.nutrition / GLUTTONY_HEAL_REDUCTION)

/datum/modifier/sin/gluttony
	name = "Gluttony"
	desc = "GLUTTONY."

	metabolism_percent = 3
	incoming_healing_percent = 2
