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

/obj/machinery/computer/ship/helm/docked_or_landed_behavior(mob/user)
	var/result = tgui_alert(user, "Initiate takeoff procedure?", "Helm control", "Yes, No")

	if(result == "No")
		return FALSE

	if(istype(linked.loc, /obj/effect/overmap_anomaly/visitable/planetoid))
		linked.takeoff()
		return TRUE

	if(istype(linked.loc, /obj/effect/overmap_anomaly/outpost))
		linked.undock(linked.loc)
		return TRUE

	return FALSE
