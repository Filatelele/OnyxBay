/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon_state = "unloader-map"
	gameicon = "unloader"

	component_types = list(
		/obj/item/circuitboard/unloading_machine,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/scanning_module
	)

	holodir_helper_path = /obj/effect/holodir_helper

	var/corner_turn_dir = 0

/obj/machinery/mineral/unloading_machine/pickup_item(datum/source, atom/movable/target, atom/old_loc)
	if(!..())
		return

	if(istype(target, /obj/structure/ore_box))
		var/obj/structure/ore_box/ore_box = target
		for(var/obj/item/I in ore_box)
			unload_item(I)

	else if(istype(target, /obj/item))
		unload_item(target)

/obj/machinery/mineral/unloading_machine/attack_hand(mob/user)
	if(stat & (NOPOWER | BROKEN)) // Unfortunately we can't simply call parent here as parent checks include POWEROFF flag.
		return

	if(user.lying || user.is_ic_dead())
		return

	if(!ishuman(user) && !issilicon(user))
		to_chat(usr, SPAN_WARNING("You don't have the dexterity to do this!"))
		return

	toggle()
	to_chat(user, SPAN_NOTICE("You toggle \the [src] [stat & POWEROFF ? "on" : "off"]."))

/obj/machinery/mineral/unloading_machine/attackby(obj/item/W, mob/user)
	..()
	if(!isMultitool(W))
		return

	var/choice = tgui_input_list(user, "Select the desired mode.", "Selection", list("default", "angled", "angled (mirrored)"))
	if(!choice || !Adjacent(user))
		return

	switch(choice)
		if("default")
			gameicon = "unloader"
			corner_turn_dir = 0
			holodir_helper_path = /obj/effect/holodir_helper
		if("angled")
			gameicon = "unloader-corner"
			corner_turn_dir = 90
			holodir_helper_path = /obj/effect/holodir_helper/corner
		if("angled (mirrored)")
			gameicon = "unloader-corner"
			corner_turn_dir = -90
			holodir_helper_path = /obj/effect/holodir_helper/corner_mirrored
	show_splash_text(user, "you tweak \the [src]!")
	update_icon()

/obj/machinery/mineral/unloading_machine/register_input_turf()
	input_turf = get_step(src, GLOB.flip_dir[dir])
	if(input_turf)
		register_signal(input_turf, SIGNAL_ENTERED, nameof(.proc/pickup_item))

/obj/machinery/mineral/unloading_machine/unload_item(atom/movable/item_to_unload)
	item_to_unload.forceMove(drop_location())
	var/turf/unload_turf = get_step(src, turn(dir, corner_turn_dir))
	if(unload_turf)
		item_to_unload.forceMove(unload_turf)

/obj/effect/holodir_helper/corner
	icon_state = "holo-arrows-corner"

/obj/effect/holodir_helper/corner_mirrored
	icon_state = "holo-arrows-corner-mirrored"

/// Prefab for mapping
/obj/machinery/mineral/unloading_machine/angled
	icon_state = "unloader-corner-map"
	gameicon = "unloader-corner"
	holodir_helper_path = /obj/effect/holodir_helper/corner
	corner_turn_dir = 90

/// Prefab for mapping
/obj/machinery/mineral/unloading_machine/angled_mirrored
	icon_state = "unloader-corner-map"
	gameicon = "unloader-corner"
	holodir_helper_path = /obj/effect/holodir_helper/corner_mirrored
	corner_turn_dir = -90
