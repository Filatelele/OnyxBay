/datum/kpi_handler/survival
	kpi_reward = 0.1

/datum/kpi_handler/survival/check_mob(mob/M)
	if(isnewplayer(M) || !M.mind)
		return

	var/list/result = list()
	if(!M.is_ooc_dead() && !isbrain(M))
		var/turf/turf = get_turf(M)
		if(!isAdminLevel(turf.z))
			result["text"] = "You managed to survive, but were marooned."
			result["kpi"] = kpi_failure
		else
			result["text"] = "You managed to survive the events on [station_name()]."
			result["kpi"] = kpi_reward

	return result
