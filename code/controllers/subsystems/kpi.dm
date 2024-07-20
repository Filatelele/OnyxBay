SUBSYSTEM_DEF(kpi)
	name = "KPI"
	flags = SS_NO_FIRE
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

/datum/controller/subsystem/kpi/proc/calculate_kpi_for(mob/M)
	var/list/result = list()
	for(var/datum/kpi_handler/handler in GLOB.kpi_handlers)
		var/handler_result = handler.check_mob(M)
		if(isnull(handler_result))
			continue

		result += handler_result

	adjust_kpi(result["kpi"], M.ckey)

	return result

/datum/controller/subsystem/kpi/proc/adjust_kpi(amount, ckey)
	ASSERT(amount)
	ASSERT(ckey)

	var/current_kpi = 0

	var/json_file = file("data/players/[ckey]/kpi.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")

	var/list/json = json_decode(file2text(json_file))

	if(json[ckey])
		current_kpi = json[ckey]
	current_kpi += amount

	json[ckey] = current_kpi

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

/datum/controller/subsystem/kpi/proc/get_kpi(ckey)
	ASSERT(ckey)

	var/json_file = file("data/players/[ckey]/kpi.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")

	var/list/json = json_decode(file2text(json_file))

	return json[ckey]
