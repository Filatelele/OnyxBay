//Ship piloting console, most of the code is already in ship.dm
/obj/machinery/computer/ship/helm
	name = "Seegson model HLM flight control console"
	desc = "A computerized ship piloting package which allows a user to set a ship's speed, attitude, bearing and more!"
	icon_screen = "helm"
	position = OVERMAP_USER_ROLE_PILOT

/obj/machinery/computer/ship/helm/Destroy()
	if(linked && linked.helm == src)
		linked.helm = null
	return ..()

/obj/machinery/computer/ship/helm/set_position(obj/structure/overmap/OM)
	OM.helm = src
	return

/**
	Allows boarding pilots to toggle autopilot! This is locked to boarding ships for obvious reasons...
*/

// Helm and tactical in one console, useful for debugging
// This console should not be made available for the player ship, looking at you mappers
/obj/machinery/computer/ship/helm/allinone
	name = "debug ship"
	desc = "You shouldn't be seeing this"
	color = "red"

/obj/machinery/computer/ship/helm/allinone/tgui_interact(mob/user)
	. = ..()
	if(!linked.gunner && isliving(user))
		linked.gunner = user
