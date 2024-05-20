/obj/structure/overmap
	var/datum/star_system/current_system
	var/role = NORMAL_OVERMAP
	var/obj/machinery/computer/ship/ftl_core/ftl_drive
	var/starting_system = null //Where do we start in the world?

/obj/structure/overmap/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/overmap/LateInitialize()
	GLOB.overmap_objects += src
	if(role == MAIN_OVERMAP)
		SSstar_system.main_overmap = src
	if(role > NORMAL_OVERMAP)
		SSstar_system.add_ship(src)

/obj/structure/overmap/Destroy()
	. = ..()
	GLOB.overmap_objects -= src
