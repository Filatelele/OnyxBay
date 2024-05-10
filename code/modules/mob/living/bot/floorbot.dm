/mob/living/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon_state = "floorbot0"
	req_one_access = list(access_construction, access_robotics)
	wait_if_pulled = 1
	min_target_dist = 0

	var/amount = 10 // 1 for tile, 2 for lattice
	var/maxAmount = 60
	var/tilemake = 0 // When it reaches 100, bot makes a tile
	var/improvefloors = 0
	var/eattiles = 0
	var/maketiles = 0
	var/floor_build_type = /decl/flooring/tiling // Basic steel floor.

/mob/living/bot/floorbot/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/station_bot/floorbot)

/mob/living/bot/floorbot/UnarmedAttack(atom/A, proximity_flag)
	if(!..())
		return

	if(get_turf(A) != loc)
		return

	if(emagged && istype(A, /turf/simulated/floor))
		var/turf/simulated/floor/F = A
		busy = 1
		update_icons()
		if(F.flooring)
			visible_message("<span class='warning'>[src] begins to tear the floor tile from the floor.</span>")
			if(do_after(src, 50, F))
				F.break_tile_to_plating()
				addTiles(1)
		else
			visible_message("<span class='danger'>[src] begins to tear through the floor!</span>")
			if(do_after(src, 150, F)) // Extra time because this can and will kill.
				F.ReplaceWithLattice()
				addTiles(1)
		update_icons()
	else if(istype(A, /turf/simulated/floor))
		var/turf/simulated/floor/F = A
		if(F.broken || F.burnt)
			busy = 1
			update_icons()
			visible_message("<span class='notice'>[src] begins to remove the broken floor.</span>")
			if(do_after(src, 50, F))
				if(F.broken || F.burnt)
					F.make_plating()
			busy = 0
			update_icons()
		else if(!F.flooring && amount)
			busy = 1
			update_icons()
			visible_message("<span class='notice'>[src] begins to improve the floor.</span>")
			if(do_after(src, 50, F))
				if(!F.flooring)
					F.set_flooring(get_flooring_data(floor_build_type))
					addTiles(-1)
			update_icons()
	else if(istype(A, /obj/item/stack/tile/floor) && amount < maxAmount)
		var/obj/item/stack/tile/floor/T = A
		visible_message("<span class='notice'>\The [src] begins to collect tiles.</span>")
		busy = 1
		update_icons()
		if(do_after(src, 20))
			if(T)
				var/eaten = min(maxAmount - amount, T.get_amount())
				T.use(eaten)
				addTiles(eaten)
		update_icons()
	else if(istype(A, /obj/item/stack/material) && amount + 4 <= maxAmount)
		var/obj/item/stack/material/M = A
		if(M.get_material_name() == MATERIAL_STEEL)
			visible_message("<span class='notice'>\The [src] begins to make tiles.</span>")
			busy = 1
			update_icons()
			if(do_after(src, 50))
				if(M)
					M.use(1)
					addTiles(4)

/mob/living/bot/floorbot/proc/addTiles(am)
	amount += am
	if(amount < 0)
		amount = 0
	else if(amount > maxAmount)
		amount = maxAmount

/* Assembly */

/obj/item/storage/toolbox/mechanical/attackby(obj/item/stack/tile/floor/T, mob/user)
	if(!istype(T, /obj/item/stack/tile/floor))
		..()
		return
	if(contents.len >= 1)
		to_chat(user, "<span class='notice'>They wont fit in as there is already stuff inside.</span>")
		return
	if(user.s_active)
		user.s_active.close(user)
	if(T.use(10))
		var/obj/item/toolbox_tiles/B = new /obj/item/toolbox_tiles
		user.pick_or_drop(B)
		to_chat(user, "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>")
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You need 10 floor tiles for a floorbot.</span>")
	return

/obj/item/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top."
	name = "tiles and toolbox"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/created_name = "Floorbot"

/obj/item/toolbox_tiles/attackby(obj/item/W, mob/user as mob)
	..()
	if(isprox(W))
		if(!user.drop(W))
			return
		qdel(W)
		var/obj/item/toolbox_tiles_sensor/B = new /obj/item/toolbox_tiles_sensor()
		B.created_name = created_name
		user.pick_or_drop(B)
		to_chat(user, "<span class='notice'>You add the sensor to the toolbox and tiles!</span>")
		qdel(src)
	else if (istype(W, /obj/item/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return
		created_name = t

/obj/item/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached."
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/created_name = "Floorbot"

/obj/item/toolbox_tiles_sensor/attackby(obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		if(!user.drop(W))
			return
		qdel(W)
		var/turf/T = get_turf(user.loc)
		var/mob/living/bot/floorbot/A = new /mob/living/bot/floorbot(T)
		A.SetName(created_name)
		to_chat(user, "<span class='notice'>You add the robot arm to the odd looking toolbox assembly! Boop beep!</span>")
		qdel(src)
	else if(istype(W, /obj/item/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return
		created_name = t
