/**
 * Climbing. Requires walls.
 */

/datum/vertical_travel_method/climb
	var/turf/surface = null
	start_verb_visible = "%m starts climbing %d the %s"
	start_verb_personal = "You start climbing %d the %s"
	base_time = 10 SECONDS
	var/soundfile = "climb"
	var/sound_interval = 20
	slip_chance = 35 //Risky without something to hold you to the wall
	offset_down = 16

/datum/vertical_travel_method/climb/can_perform(dir)
	. = ..()
	if(!.)
		return FALSE

	if(isrobot(M))
		to_chat(M, SPAN_NOTICE("You're a robot, you can't climb.")) //Robots can't climb
		return FALSE

	var/turf/target = null
	var/turf/wall_below = null

	if(direction == UP) // Trying to climb UP.
		var/turf/simulated/open/above_user = GetAbove(M)
		if(!istype(above_user))
			return FALSE

		for(var/d in GLOB.cardinal)
			var/turf/simulated/wall/WA = get_step(origin, d)
			if(!istype(WA))
				continue

			var/turf/above_wall = GetAbove(WA)
			if(!istype(above_wall) || iswall(above_wall))
				continue

			if(M.can_fall(FALSE, above_wall))
				continue

			for(var/obj/structure/S in above_wall)
				if(S?.density && !(S.atom_flags & ATOM_FLAG_CLIMBABLE))
					continue

			target = WA

	else if(direction == DOWN)
		wall_below = GetBelow(origin)
		if(!istype(wall_below))
			return FALSE

		var/turf/simulated/open/open = get_step(M, M.dir)
		if(!istype(open))
			return FALSE

		var/turf/below_open = GetBelow(open)
		if(!istype(below_open) || iswall(below_open))
			return FALSE

		target = below_open

	if(target)
		surface = (direction == UP) ? target : wall_below
		subject = (direction == UP) ? target : wall_below
		destination = (direction == UP) ? GetAbove(target) : target
		. = TRUE
	else
		return FALSE

/datum/vertical_travel_method/climb/start_animation()
	. = ..()
	if(direction == UP)
		M.face_atom(subject)
	else
		var/dir = get_dir(M, destination)
		M.set_dir(GLOB.flip_dir[dir])
	var/mob/mob = M
	mob?.update_offsets()
	spawn(1)
	//travelsound = new /datum/repeating_sound(15,duration,0.25, M, soundfile, 80, 1)
	if(direction == DOWN)
		var/matrix/mat = matrix()
		mat.Scale(0.9)
		animate(M, pixel_y = -8, transform = mat,  time = duration * 1.2, easing = LINEAR_EASING, flags = ANIMATION_END_NOW)
	else
		animate(M, pixel_y = 32, time = duration * 1.2, easing = LINEAR_EASING, flags = ANIMATION_END_NOW)

/datum/vertical_travel_method/climb/get_destination()
	if(istype(surface))
		destination = (direction == UP) ? GetAbove(surface) : GetBelow(surface)
	else
		destination = (direction == UP) ? GetAbove(origin) : GetBelow(origin)
	return destination

//Subset of climbing using magboots. Slightly faster and much safer
/datum/vertical_travel_method/climb/mag
	start_verb_visible = "%m braces their magboots against the %s and starts walking %dwards"
	start_verb_personal = "You brace your magboots against the %s and starts walking %dwards"
	base_time = 80
	sound_interval = 9
	slip_chance = 0 //Utterly safe, magboots glue you to a wall
	soundfile = "catwalk"
	var/atom/magboots //The boots you're using

/datum/vertical_travel_method/climb/mag/can_perform(dir)
	. = ..()
	if(.)
		if(!ishuman(M))
			return FALSE
		var/mob/living/carbon/human/H = M
		if(H.Check_Shoegrip()) //This checks for magboots
			return TRUE

		else
			//If we get here, they are going to fail. But maybe we can display a helpful error message
			//Maybe they're wearing magboots but they aren't turned on?
			if (istype(H.shoes, /obj/item/clothing/shoes/magboots))
				var/obj/item/clothing/shoes/magboots/MB = H.shoes
				if (!MB.magpulse)
					to_chat(M, SPAN_NOTICE("You could use your [MB] to walk up the [surface] if they were turned on."))
					return FALSE

			to_chat(M, SPAN_NOTICE("Your shoes don't have enough grip to climb up."))
			return FALSE

/datum/vertical_travel_method/climb/mag/start_animation()
	var/matrix/mat = M.transform
	if(surface.x > M.x)
		mat.Turn(-20)
	if(surface.x < M.x)
		mat.Turn(20)
	M.transform = mat
	. = ..()

	if(direction == DOWN)
		M.face_atom(get_step(M,get_dir(surface, M)))
