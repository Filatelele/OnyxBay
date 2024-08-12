/*********************************************************
	Generic climbing, without using any special equipment

**********************************************************/
/datum/vertical_travel_method/climb_nograv
	start_verb_visible = "%m pushes off and starts floating %d"
	start_verb_personal = "You push yourself %d"
	base_time = 5 SECONDS
	var/soundfile = "climb"
	var/sound_interval = 20
	slip_chance = 0 //Risky without something to hold you to the wall

/datum/vertical_travel_method/climb_nograv/can_perform(dir)
	. = ..()
	if(!.)
		return FALSE

	if(has_gravity(M))
		return FALSE

	if(!get_destination())
		to_chat(M, SPAN_NOTICE("There is nothing in that direction."))
		return FALSE

	if(isrobot(M))
		to_chat(M, SPAN_NOTICE("You're a robot, you can't climb."))
		return FALSE

	if(!get_destination())
		to_chat(M, SPAN_NOTICE("There is nothing in that direction."))
		return FALSE

	return TRUE
