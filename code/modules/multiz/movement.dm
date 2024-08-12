/mob/verb/up()
	set name = "Move Upwards"
	set category = "IC"

	zMove(UP)

/mob/verb/down()
	set name = "Move Down"
	set category = "IC"

	zMove(DOWN)

/atom/proc/CanMoveOnto(atom/movable/mover, turf/target, height=1.5, direction = 0)
	//Purpose: Determines if the object can move through this
	//Uses regular limitations plus whatever we think is an exception for the purpose of
	//moving up and down z levles
	return CanPass(mover, target, height, 0) || (direction == DOWN && (atom_flags & ATOM_FLAG_CLIMBABLE))

/mob/proc/can_overcome_gravity()
	return FALSE

/mob/living/carbon/human/can_overcome_gravity()
	if(HasMovementHandler(/datum/movement_handler/mob/incorporeal))
		return TRUE
	//First do species check
	if(species && species.can_overcome_gravity(src))
		return 1
	else
		for(var/atom/a in src.loc)
			if(a.atom_flags & ATOM_FLAG_CLIMBABLE)
				return 1

		//Last check, list of items that could plausibly be used to climb but aren't climbable themselves
		var/list/objects_to_stand_on = list(
				/obj/item/stool,
				/obj/structure/bed,
			)
		for(var/type in objects_to_stand_on)
			if(locate(type) in src.loc)
				return 1
	return 0

/mob/proc/can_ztravel()
	return 0

/mob/living/carbon/human/can_ztravel()
	if(Allow_Spacemove())
		return 1

	if(Check_Shoegrip())	//scaling hull with magboots
		for(var/turf/simulated/T in trange(1,src))
			if(T.density)
				return 1

/mob/living/silicon/robot/can_ztravel()
	if(Allow_Spacemove()) //Checks for active jetpack
		return 1

	for(var/turf/simulated/T in trange(1,src)) //Robots get "magboots"
		if(T.density)
			return 1

//FALLING STUFF

//Holds fall checks that should not be overriden by children
/atom/movable/proc/fall()
	if(!isturf(loc))
		return

	var/turf/below = GetBelow(src)
	if(!below)
		return

	var/turf/T = loc
	if(!T.CanZPass(src, DOWN) || !below.CanZPass(src, DOWN))
		return

	// No gravity in space, apparently.
	var/area/area = get_area(src)
	if(!area.has_gravity())
		return

	if(throwing)
		return

	if(can_fall())
		// We spawn here to let the current move operation complete before we start falling. fall() is normally called from
		// Entered() which is part of Move(), by spawn()ing we let that complete.  But we want to preserve if we were in client movement
		// or normal movement so other move behavior can continue.
		var/mob/M = src
		var/is_client_moving = (ismob(M) && M.moving)
		spawn(0)
			if(is_client_moving)
				M.moving = 1
			handle_fall(below)
			if(isliving(M))
				var/mob/living/L = M
				for(var/obj/item/grab/G in L.get_active_grabs())
					G.affecting.handle_fall(below)
			if(is_client_moving)
				M.moving = 0

//For children to override
/atom/movable/proc/can_fall(anchor_bypass = FALSE, turf/location_override = src.loc)
	if(!simulated)
		return FALSE

	if(anchored && !anchor_bypass)
		return FALSE

	//Override will make checks from different location used for prediction
	if(location_override)
		if(locate(/obj/structure/lattice, location_override) || locate(/obj/structure/catwalk, location_override))
			return FALSE

		var/turf/below = GetBelow(location_override)
		for(var/atom/A in below)
			if(!A.CanPass(src, location_override))
				return FALSE

	if(!has_gravity(src))
		return FALSE

	var/obj/item/tank/jetpack/thrust = get_jetpack()
	if(thrust?.allow_thrust(JETPACK_MOVE_COST, src))
		return FALSE

	return TRUE

/obj/can_fall()
	return ..(anchor_fall)

/obj/effect/can_fall()
	return FALSE

/obj/effect/decal/cleanable/can_fall()
	return TRUE

/obj/item/pipe/can_fall()
	var/turf/simulated/open/below = loc
	below = below.below

	. = ..()

	if(anchored)
		return FALSE

	if((locate(/obj/structure/disposalpipe/up) in below) || locate(/obj/machinery/atmospherics/pipe/zpipe/up) in below)
		return FALSE

/mob/living/carbon/human/can_fall()
	if(..())
		return species.can_fall(src)

/atom/movable/proc/handle_fall(turf/landing)
	forceMove(landing)
	if(locate(/obj/structure/stairs) in landing)
		return 1
	else
		handle_fall_effect(landing)

/atom/movable/proc/handle_fall_effect(turf/landing)
	if(istype(landing, /turf/simulated/open))
		visible_message("\The [src] falls from the deck above through \the [landing]!", "You hear a whoosh of displaced air.")
	else
		visible_message("\The [src] falls from the deck above and slams into \the [landing]!", "You hear something slam into the deck.")
		playsound(landing, SFX_FALL_DAMAGE, 75)
		if(fall_damage())
			for(var/mob/living/M in landing.contents)
				visible_message("\The [src] hits \the [M.name]!")
				M.take_overall_damage(fall_damage())

/atom/movable/proc/fall_damage()
	return 0

/obj/fall_damage()
	if(w_class == ITEM_SIZE_TINY)
		return 0
	if(w_class == ITEM_SIZE_NO_CONTAINER)
		return 100
	return base_storage_cost(w_class)

/mob/living/carbon/human/handle_fall_effect(turf/landing)
	if(species && species.handle_fall_special(src, landing))
		return

	var/old_stat = stat

	..()
	var/damage = 10
	apply_damage(rand(0, damage), BRUTE, BP_HEAD)
	apply_damage(rand(0, damage), BRUTE, BP_CHEST)
	apply_damage(rand(0, damage), BRUTE, BP_L_LEG)
	apply_damage(rand(0, damage), BRUTE, BP_R_LEG)
	apply_damage(rand(0, damage), BRUTE, BP_L_ARM)
	apply_damage(rand(0, damage), BRUTE, BP_R_ARM)
	weakened = max(weakened,2)
	updatehealth()

	if (old_stat != CONSCIOUS)
		return

	var/gender_prefix = gender_datums[gender].key
	if (stat == CONSCIOUS)
		playsound(loc, "[gender_prefix]_fall_alive", 25)
	else
		playsound(loc, "[gender_prefix]_fall_dead", 25)

/mob/proc/zMove(direction, method = 0)
	if(eyeobj)
		return eyeobj.zMove(direction)

	var/atom/movable/mover = src

	//If we're inside a thing, that thing is the thing that moves
	if (istype(loc, /obj))
		mover = loc

	// If were inside a mech
	if(istype(loc, /obj/mecha))
		var/obj/mecha/mech = loc
		if(src in mech.occupant)
			mover = loc

	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	var/turf/start = get_turf(src)
	if(!destination)
		to_chat(src, SPAN_NOTICE("There is nothing of interest in this direction"))
		return FALSE

	//After checking that there's a valid destination, we'll first attempt phase movement as a shortcut.
	//Since it can pass through obstacles, we'll do this before checking whether anything is blocking us
	if(istype(mover, /obj/mecha))
		var/mob/living/mech = mover
		if(mech.current_vertical_travel_method)
			to_chat(src, SPAN_NOTICE("You can't do this yet!"))
	else if(src.current_vertical_travel_method)
		to_chat(src, SPAN_NOTICE("You can't do this yet!"))
		return

	var/datum/vertical_travel_method/VTM = new Z_MOVE_PHASE(src)
	if(VTM.can_perform(direction))
		// special case for mechs
		if(istype(mover, /obj/mecha))
			var/obj/mecha/mech = mover
			mech.current_vertical_travel_method = VTM
		else
			src.current_vertical_travel_method = VTM
		VTM.attempt(direction)
		return

	var/list/possible_methods = list(
		Z_MOVE_JETPACK,
		Z_MOVE_CLIMB_NOGRAV,
		Z_MOVE_CLIMB_MAG,
		Z_MOVE_CLIMB,
	)

	// Prevent people from going directly inside or outside a shuttle through the ceiling
	// Would be possible if the shuttle is not on the highest z-level
	// Also prevent the bug where people could get in from under the shuttle
	if(istype(start, /turf/simulated/shuttle) || istype(destination, /turf/simulated/shuttle))
		to_chat(src, SPAN_WARNING("An invisible energy shield around the shuttle blocks you."))
		return FALSE

	// Check for blocking atoms at the destination.
	for(var/atom/A in destination)
		if(!A.CanPass(mover, start, 1.5, 0))
			to_chat(src, SPAN_WARNING("\The [A] blocks you."))
			return FALSE

	for(var/a in possible_methods)
		VTM = new a(src)
		if(VTM.can_perform(direction))
			// special case for mechs
			if(istype(mover, /obj/mecha))
				var/obj/mecha/mech = mover
				mech.current_vertical_travel_method = VTM
			else
				src.current_vertical_travel_method = VTM
			VTM.attempt(direction)
			return TRUE

	to_chat(src, SPAN_NOTICE("You lack a means of z-travel in that direction."))
	return FALSE

/mob/proc/zMoveUp()
	return zMove(UP)

/mob/proc/zMoveDown()
	return zMove(DOWN)
