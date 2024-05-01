/datum/devil_follower/gluttony
	starting_actions = list(/datum/action/cooldown/spell/gluttony_heal)
	modifiers = list(/datum/modifier/sin/gluttony)

/datum/modifier/sin/gluttony
	name = "Gluttony"
	desc = "GLUTTONY."

	metabolism_percent = 2
	incoming_healing_percent = 1.5

	var/sin_points = 0

/datum/modifier/sin/gluttony/tick()
	var/mob/living/carbon/human/H = holder
	ASSERT(H)

	var/normalized_nutrition = H.nutrition / H.body_build.stomach_capacity
	if(normalized_nutrition >= STOMACH_FULLNESS_HIGH)
		sin_points += 1 * SSmobs.wait
