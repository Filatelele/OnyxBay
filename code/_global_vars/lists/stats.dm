GLOBAL_LIST_INIT(all_stats, init_all_stats())

/proc/init_all_stats()
	var/list/stats = list()
	for(var/path in subtypesof(/datum/stat))
		var/datum/stat/stat = new path()
		stats[stat.name] = stat

	return stats
