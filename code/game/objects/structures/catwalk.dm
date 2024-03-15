/obj/structure/catwalk
	name = "catwalk"
	desc = "Cats really don't like these things."
	icon = 'icons/obj/catwalks.dmi'
	icon_state = "catwalk"
	density = 0
	anchored = 1.0
	layer = CATWALK_LAYER

/obj/structure/catwalk/Initialize()
	. = ..()
	for(var/obj/structure/catwalk/C in get_turf(src))
		if(C != src)
			util_crash_with("Multiple catwalks on one turf! ([loc.x], [loc.y], [loc.z])")
			qdel(C)
	update_icon()
	redraw_nearby_catwalks()


/obj/structure/catwalk/Destroy()
	redraw_nearby_catwalks()
	return ..()

/obj/structure/catwalk/proc/redraw_nearby_catwalks()
	for(var/direction in GLOB.alldirs)
		var/obj/structure/catwalk/L = locate() in get_step(src, direction)
		if(L)
			L.update_icon() //so siding get updated properly


/obj/structure/catwalk/on_update_icon()
	var/connectdir = 0
	for(var/direction in GLOB.cardinal)
		if(locate(/obj/structure/catwalk, get_step(src, direction)))
			connectdir |= direction

	//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
	var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW
	var/dirs = list(1,2,4,8)
	var/i = 1
	for(var/diag in list(NORTHEAST, SOUTHEAST,NORTHWEST,SOUTHWEST))
		if((connectdir & diag) == diag)
			if(locate(/obj/structure/catwalk, get_step(src, diag)))
				diagonalconnect |= dirs[i]
		i += 1

	icon_state = "catwalk[connectdir]-[diagonalconnect]"


/obj/structure/catwalk/ex_act(severity)
	switch(severity)
		if(1)
			new /obj/item/stack/rods(src.loc)
			qdel(src)
		if(2)
			new /obj/item/stack/rods(src.loc)
			qdel(src)

/obj/structure/catwalk/attackby(obj/item/C, mob/user)
	if(isWelder(C))
		var/obj/item/weldingtool/WT = C
		if(!WT.use_tool(src, user, amount = 1))
			return

		to_chat(user, SPAN("notice", "Slicing catwalk joints ..."))
		new /obj/item/stack/rods(loc)
		new /obj/item/stack/rods(loc)
		//Lattice would delete itself, but let's save ourselves a new obj
		if((istype(loc, /turf/space) || istype(loc, /turf/simulated/open)) && !(locate(/obj/structure/lattice) in loc))
			new /obj/structure/lattice(loc)
		qdel_self()

/obj/structure/catwalk/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 1 SECONDS, "cost" = 5)

	return FALSE

/obj/structure/catwalk/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_DECONSTRUCT)
		qdel_self()
		return TRUE
