/datum/stat_holder
	var/mob/living/holder
	var/list/stat_list = list()
	var/list/datum/trait/modifier/skill/traits = list()
	var/list/obj/effect/perk_stats = list() // Holds effects representing traits, to display them in stat()

/datum/stat_holder/New(mob/living/L)
	holder = L
	for(var/sttype in subtypesof(/datum/stat))
		var/datum/stat/S = new sttype
		stat_list[S.name] = S

/datum/stat_holder/Destroy()
	holder = null
	QDEL_LIST(traits)
	QDEL_LIST(perk_stats)
	return ..()

/datum/stat_holder/proc/check_for_shared_perk(ability_bitflag)
	return FALSE

/datum/stat_holder/proc/addTempStat(statName, Value, timeDelay, id = null)
	var/datum/stat/S = stat_list[statName]
	S.addModif(timeDelay, Value, id)

/datum/stat_holder/proc/removeTempStat(statName, id)
	if(!id)
		CRASH("no id passed to removeTempStat(")
	var/datum/stat/S = stat_list[statName]
	S.remove_modifier(id)

/datum/stat_holder/proc/getTempStat(statName, id)
	if(!id)
		CRASH("no id passed to getTempStat(")
	var/datum/stat/S = stat_list[statName]
	return S.get_modifier(id)

/datum/stat_holder/proc/changeStat(statName, Value)
	var/datum/stat/S = stat_list[statName]
	S.changeValue(Value)

/datum/stat_holder/proc/set_stat(statName, Value)
	var/datum/stat/S = stat_list[statName]
	S.setValue(Value)

/datum/stat_holder/proc/getStat(statName, pure = FALSE)
	if(!islist(statName))
		var/datum/stat/S = stat_list[statName]
		return S ? S.getValue(pure) : 0
	else
		log_debug("passed list to getStat()")

//	Those are accept list of stats
//	Compound stat checks.
//	Lowest value among the stats passed in
/datum/stat_holder/proc/getMinStat(list/namesList, pure = FALSE)
	if(!islist(namesList))
		log_debug("passed non-list to getMinStat()")
		return 0
	var/lowest = INFINITY
	for (var/name in namesList)
		if(getStat(name, pure) < lowest)
			lowest = getStat(name, pure)
	return lowest

//	Get the highest value among the stats passed in
/datum/stat_holder/proc/getMaxStat(list/namesList, pure = FALSE)
	if(!islist(namesList))
		log_debug("passed non-list to getMaxStat()")
		return 0
	var/highest = -INFINITY
	for (var/name in namesList)
		if(getStat(name, pure) > highest)
			highest = getStat(name, pure)
	return highest

//	Sum total of the stats
/datum/stat_holder/proc/getSumOfStat(list/namesList, pure = FALSE)
	if(!islist(namesList))
		log_debug("passed non-list to getSumStat()")
		return 0
	var/sum = 0
	for (var/name in namesList)
		sum += getStat(name, pure)
	return sum

//	Get the average (mean) value of the stats
/datum/stat_holder/proc/getAvgStat(list/namesList, pure = FALSE)
	if(!islist(namesList))
		log_debug("passed non-list to getAvgStat()")
		return 0
	var/avg = getSumOfStat(namesList, pure)
	return avg / namesList.len

/datum/stat_holder/proc/copyTo(datum/stat_holder/recipient)
	for(var/i in stat_list)
		var/datum/stat/S = stat_list[i]
		var/datum/stat/RS = recipient.stat_list[i]
		S.copyTo(RS)

	//for(var/datum/perk/P in perks)
	//	recipient.addPerk(P.type)

// return value from 0 to 1 based on value of stat, more stat value less return value
// use this proc to get multiplier for decreasing delay time (exaple: "50 * getMult(STAT_ROB, STAT_LEVEL_ADEPT)"  this will result in 5 seconds if stat STAT_ROB = 0 and result will be 0 if STAT_ROB = STAT_LEVEL_ADEPT)
/datum/stat_holder/proc/getMult(statName, statCap = STAT_LEVEL_MAX, pure = FALSE)
    if(!statName)
        return
    return 1 - max(0,min(1,getStat(statName, pure)/statCap))

/datum/stat_holder/proc/getPerk(perkType)
	var/datum/trait/modifier/skill/path = ispath(perkType) ? perkType : text2path(perkType) // Adds support for textual argument so that it can be called through VV easily
	if(path)
		return locate(path) in holder?.modifiers

/// The main, public proc to add a perk to a mob. Accepts a path or a stringified path.
/datum/stat_holder/proc/addPerk(perkType)
	. = FALSE
	if(!getPerk(perkType))
		var/datum/trait/modifier/skill/P = new perkType
		traits += P
		holder.add_modifier(P)
		. = TRUE

/// The main, public proc to remove a perk from a mob. Accepts a path or a stringified path.
/datum/stat_holder/proc/removePerk(perkType)
	var/datum/trait/modifier/skill/P = getPerk(perkType)
	if(P)
		traits -= P
		P.remove_trait_from_mob(holder)

/datum/stat_holder/proc/copy_from_prefs(list/attributes)
	for(var/A in attributes)
		set_stat(A, attributes[A])

/mob/var/datum/stat_holder/stats

/mob/Initialize(mapload)
	. = ..()
	stats = new (src)

// Use to perform stat checks
/mob/proc/stat_check(stat_path, needed)
	var/points = src.stats.getStat(stat_path)
	return points >= needed
