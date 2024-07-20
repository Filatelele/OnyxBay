GLOBAL_LIST_INIT(kpi_handlers, init_kpi_handlers())

/proc/init_kpi_handlers()
	var/list/handlers = list()
	for(var/path in subtypesof(/datum/kpi_handler))
		handlers += new path()

	return handlers
