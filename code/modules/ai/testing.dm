/mob/living/carbon/human/node_pathing //A human using the basic random node traveling

/mob/living/carbon/human/node_pathing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior)

/mob/living/carbon/human/xenos/node_pathing

/mob/living/carbon/human/xenos/node_pathing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/human/station_bot/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/station_bot)

/mob/living/goblin/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/station_bot)
