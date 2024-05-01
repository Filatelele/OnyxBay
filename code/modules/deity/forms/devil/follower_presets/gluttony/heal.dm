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

#undef GLUTTONY_HEAL_REDUCTION
