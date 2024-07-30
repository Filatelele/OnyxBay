/datum/preferences
	var/max_attribute_points = 20
	var/attribute_points
	var/list/attributes = list(
		STAT_STR = 12,
		STAT_FIT = 12,
		STAT_DEX = 12,
		STAT_COG = 12,
		STAT_WILL = 12,
	)

/datum/preferences/New(client/C)
	. = ..()
	attribute_points = max_attribute_points

/datum/category_item/player_setup_item/general/attributes
	name = "Attributes"
	sort_order = 4

/datum/category_item/player_setup_item/general/attributes/load_character(datum/pref_record_reader/R)
	pref.attributes = R.read("attributes")

/datum/category_item/player_setup_item/general/attributes/save_character(datum/pref_record_writer/W)
	W.write("attributes", pref.attributes)

/datum/category_item/player_setup_item/general/attributes/sanitize_character()
	var/datum/species/species = all_species[pref.species]
	var/datum/body_build/body_build = null
	for(var/datum/body_build/bb in species.body_builds)
		if(bb.name != pref.body)
			continue

		body_build = bb

	if(!islist(pref.attributes))
		pref.attributes = list()

	var/total_points_spent = 0
	for(var/A in ALL_STATS)
		if(!(A in pref.attributes))
			pref.attributes[A] = STAT_LEVEL_DEFAULT

		//if(LAZYACCESSASSOC(body_build.stats_modifiers, A, "min") > pref.attributes[A])
		//	pref.attributes[A] = body_build.stats_modifiers[A]["min"]

		//if(LAZYACCESSASSOC(body_build.stats_modifiers, A, "max") < pref.attributes[A])
		//	pref.attributes[A] = body_build.stats_modifiers[A]["max"]

		total_points_spent += (pref.attributes[A] - STAT_LEVEL_DEFAULT)
		if(total_points_spent > pref.max_attribute_points)
			pref.attributes[A] -= total_points_spent - pref.max_attribute_points

	pref.attribute_points = pref.max_attribute_points - total_points_spent

/datum/category_item/player_setup_item/general/attributes/content()
	. += "<b>Attributes: [pref.attribute_points]/[pref.max_attribute_points]</b><br>"
	. += "<table>"
	for(var/attribute in ALL_STATS)
		var/datum/stat/stat = GLOB.all_stats[attribute]
		. += "<tr><td>[attribute]: </td><td>"
		. += "<b>[stat.points_to_level(pref.attributes[attribute])]</b>"
		. += " <a href='?src=\ref[src];decrease_attribute=[attribute]'><font color=cc5555>-</font></a>"
		. += " <a href='?src=\ref[src];increase_attribute=[attribute]'><font color=55cc55>+</font></a>"
		. += "</td></tr>"
	. += "</table><br>"

/datum/category_item/player_setup_item/general/attributes/OnTopic(href, list/href_list, mob/user)
	if(href_list["increase_attribute"])
		pref.attributes[href_list["increase_attribute"]]++
		pref.attribute_points--
		return TOPIC_REFRESH

	else if(href_list["decrease_attribute"])
		pref.attributes[href_list["decrease_attribute"]]--
		pref.attribute_points++
		return TOPIC_REFRESH

	return ..()
