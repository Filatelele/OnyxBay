/datum/stat
	var/name = "Character stat"
	var/desc = "Basic characteristic, you are not supposed to see this. Report to admins."
	var/value = STAT_LEVEL_AVERAGE
	var/list/mods = list()

/datum/stat/proc/points_to_level(points = null)
	switch(isnull(points) ? value : points)
		if(STAT_LEVEL_NONE to STAT_LEVEL_WEAK)
			return "Awful"
		if(STAT_LEVEL_WEAK to STAT_LEVEL_ABOVE_AVERAGE)
			return "Average"
		if(STAT_LEVEL_ABOVE_AVERAGE to STAT_LEVEL_TRAINED)
			return "Adept"
		if(STAT_LEVEL_TRAINED to STAT_LEVEL_EXCEPTIONAL)
			return "Trained"
		if(STAT_LEVEL_EXCEPTIONAL to STAT_LEVEL_LEGENDARY)
			return "Legendary"
		if(STAT_LEVEL_GODLIKE to INFINITY)
			return "Godlike"

/datum/stat/proc/addModif(delay, affect, id)
	for(var/elem in mods)
		var/datum/stat_mod/SM = elem
		if(SM.id == id)
			if(delay == INFINITY)
				SM.time = -1
			else
				SM.time = world.time + delay
			SM.value = affect
			return
	mods += new /datum/stat_mod(delay, affect, id)

/datum/stat/proc/remove_modifier(id)
	for(var/elem in mods)
		var/datum/stat_mod/SM = elem
		if(SM.id == id)
			mods.Remove(SM)
			return

/datum/stat/proc/get_modifier(id)
	for(var/elem in mods)
		var/datum/stat_mod/SM = elem
		if(SM.id == id)
			return SM

/datum/stat/proc/changeValue(affect)
	if(value + affect > STAT_LEVEL_ABS_MIN)
		value = STAT_LEVEL_ABS_MAX
	else
		value = value + affect

/datum/stat/proc/getValue(pure = FALSE)
	if(pure)
		return value
	else
		. = value
		for(var/elem in mods)
			var/datum/stat_mod/SM = elem
			if(SM.time != -1 && SM.time < world.time)
				mods -= SM
				qdel(SM)
				continue
			. += SM.value

/datum/stat/proc/setValue(value)
	if(value > STAT_LEVEL_ABS_MAX)
		src.value = STAT_LEVEL_ABS_MAX
	else
		src.value = value

/datum/stat/proc/copyTo(datum/stat/recipient)
	recipient.value = getValue(TRUE)

/datum/stat/strength
	name = STAT_STR
	desc = "ROBUST"

/datum/stat/strength/points_to_level(points)
	switch(points)
		if(STAT_LEVEL_NONE to STAT_LEVEL_WEAK)
			return "Weak"
		if(STAT_LEVEL_WEAK to STAT_LEVEL_ABOVE_AVERAGE)
			return "Average"
		if(STAT_LEVEL_ABOVE_AVERAGE to STAT_LEVEL_TRAINED)
			return "Adept"
		if(STAT_LEVEL_TRAINED to STAT_LEVEL_EXCEPTIONAL)
			return "Trained"
		if(STAT_LEVEL_EXCEPTIONAL to STAT_LEVEL_LEGENDARY)
			return "Legendary"
		if(STAT_LEVEL_GODLIKE to INFINITY)
			return "Godlike"

/datum/stat/fitness
	name = STAT_FIT
	desc = "FINTESS."

/datum/stat/dexterity/points_to_level(points)
	switch(points)
		if(STAT_LEVEL_NONE to STAT_LEVEL_WEAK)
			return "Klutz "
		if(STAT_LEVEL_WEAK to STAT_LEVEL_ABOVE_AVERAGE)
			return "Average"
		if(STAT_LEVEL_ABOVE_AVERAGE to STAT_LEVEL_TRAINED)
			return "Adept"
		if(STAT_LEVEL_TRAINED to STAT_LEVEL_EXCEPTIONAL)
			return "Trained"
		if(STAT_LEVEL_EXCEPTIONAL to STAT_LEVEL_LEGENDARY)
			return "Legendary"
		if(STAT_LEVEL_GODLIKE to INFINITY)
			return "Godlike"

/datum/stat/dexterity
	name = STAT_DEX
	desc = "ROGUE)))."

/datum/stat/dexterity/points_to_level(points)
	switch(points)
		if(STAT_LEVEL_NONE to STAT_LEVEL_WEAK)
			return "Klutz "
		if(STAT_LEVEL_WEAK to STAT_LEVEL_ABOVE_AVERAGE)
			return "Average"
		if(STAT_LEVEL_ABOVE_AVERAGE to STAT_LEVEL_TRAINED)
			return "Adept"
		if(STAT_LEVEL_TRAINED to STAT_LEVEL_EXCEPTIONAL)
			return "Trained"
		if(STAT_LEVEL_EXCEPTIONAL to STAT_LEVEL_LEGENDARY)
			return "Legendary"
		if(STAT_LEVEL_GODLIKE to INFINITY)
			return "Godlike"

/datum/stat/cognition
	name = STAT_COG
	desc = "BRAINZZZ."

/datum/stat/willpower
	name = STAT_WILL
	desc = "WILL INSANITY."

/datum/stat/civ_mech
	name =  SKILL_CIV_MECH
	desc = "Faster moving speed of piloted civilian exosuits: Ripley and Odysseus."

/datum/stat/combat_mech
	name = SKILL_COMBAT_MECH
	desc = "Faster moving speed of piloted combat exosuits."

/datum/stat/police
	name = SKILL_POLICE
	desc = "Usage of tasers and stun batons. Higher levels allows for faster handcuffing."

/datum/stat/firearms
	name = SKILL_FIREARMS
	desc = "Affects recoil from firearms. Proficiency in firearms allows for tactical reloads. Usage of mines and explosives."

/datum/stat/melee
	name = SKILL_MELEE
	desc = "Higher levels means more damage with melee weapons."

/datum/stat/atmospherics
	name = SKILL_ATMOS
	desc = "Interacting with atmos related devices: pumps, scrubbers and filters. Usage of atmospherics computers. Faster pipes unwrenching."

/datum/stat/construction
	name = SKILL_CONSTRUCTION
	desc = "Construction of walls, windows, computers and crafting."

/datum/stat/chemistry
	name = SKILL_CHEMISTRY
	desc = "Chemistry related machinery: grinders, chem dispensers and chem robusts. You can recognize reagents in pills and bottles."

/datum/stat/research
	name = SKILL_RESEARCH
	desc = "Usage of complex machinery and computers. AI law modification, xenoarcheology and xenobiology consoles, exosuit fabricators."

/datum/stat/medical
	name = SKILL_MEDICAL
	desc = "Faster usage of syringes. Proficiency with defibrilators, medical scanners, cryo tubes, sleepers and life support machinery."

/datum/stat/surgery
	name = SKILL_SURGERY
	desc = "Higher level means faster surgical operations."

/datum/stat/command
	name = SKILL_COMMAND
	desc = "Usage of identification computers, communication consoles and fax."

/datum/stat/engineering
	name = SKILL_ENGINEERING
	desc = "Tools usage, hacking, wall repairs and deconstruction. Engine related tasks and configuring of telecommunications."
