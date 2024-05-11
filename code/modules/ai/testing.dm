/mob/living/carbon/human/node_pathing //A human using the basic random node traveling

/mob/living/carbon/human/node_pathing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior)

/mob/living/carbon/human/station_bot/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/station_bot)

/mob/living/goblin/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/station_bot)

/mob/living/carbon/human/malf_robot
	faction = "Malfunctioning Robots"

/mob/living/carbon/human/malf_robot/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/malfbot)
	var/datum/action/cooldown/malfbot/energynet/enet = new (src)
	enet.Grant(src)

/mob/living/carbon/human/malf_robot/can_stand_overridden()
	for(var/limbcheck in list(BP_L_LEG,BP_R_LEG))
		var/obj/item/organ/affecting = get_organ(limbcheck)
		if(!affecting)
			return FALSE

	return TRUE

/mob/living/carbon/human/malf_robot
