/datum/kpi_handler/synth_hrt
	kpi_reward = 0.1

/datum/kpi_handler/synth_hrt/check_mob(mob/M)
	if(!M.isSynthetic())
		return null

	var/mob/living/carbon/human/H = M
	var/found = FALSE
	for(var/obj/item/organ/O in H?.organs)
		var/obj/item/organ_module/hormone_regulator/hr = locate() in O
		if(!istype(hr))
			continue

		if(hr.from_roundstart)
			return null

		found = TRUE
		break

	var/list/result = list()
	if(found)
		result["text"] = "You managed to get the HR-module. Thanks to its hormone dispersal system that mimics the environment of a living body, your brain will be able to live long enough."
		result["kpi"] = kpi_reward
	else
		result = "You are a synth without the HR module. Your faith is unenviable, and your brain will quickly decay outside of a body-like environment."
		result["kpi"] = kpi_failure
