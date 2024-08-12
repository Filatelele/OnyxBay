/datum/keybinding/living
	category = CATEGORY_HUMAN

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/rest
	hotkey_keys = list("ShiftB")
	name = "rest"
	full_name = "Rest"
	description = "You lay down/get up"

/datum/keybinding/living/rest/down(client/user)
	var/mob/living/L = user.mob
	L.lay_down()
	return TRUE

/datum/keybinding/living/resist
	hotkey_keys = list("R")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffed? On fire? Resist!"

/datum/keybinding/living/resist/down(client/user)
	var/mob/living/L = user.mob
	L.resist()
	return TRUE

/datum/keybinding/living/drop_item
	hotkey_keys = list("Q", "Northwest") // HOME
	name = "drop_item"
	full_name = "Drop Item"
	description = ""

/datum/keybinding/living/drop_item/down(client/user)
	var/mob/living/L = user.mob
	L.drop_active_hand()
	return TRUE

/datum/keybinding/living/look_up
	hotkey_keys = list("ShiftF")
	name = "look_up"
	full_name = "Look Up"
	description = "Look at what's above you, if you are under an open space."

/datum/keybinding/living/look_up/down(client/user)
	var/mob/living/L = user.mob
	THROTTLE(cooldown, (1.5 SECONDS))
	if(!cooldown)
		return FALSE

	L.look_up()
	return TRUE
