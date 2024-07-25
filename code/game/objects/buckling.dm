/obj
	var/can_buckle = 0
	var/buckle_movable = 0
	var/buckle_relaymove = 0 //lets obj's relaymove() to be used without allowing turning it
	var/buckle_dir = 0
	var/buckle_lying = -1 //bed-like behavior, forces mob.lying = buckle_lying if != -1
	var/buckle_pixel_shift = "x=0;y=0" //where the buckled mob should be pixel shifted to, or null for no pixel shift control
	var/buckle_require_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes

/obj/attack_hand(mob/living/user)
	. = ..()
	if(can_buckle && buckled_mob)
		user_unbuckle_mob(user)

/obj/MouseDrop_T(atom/movable/dropping, mob/living/user)
	. = ..()
	if(can_buckle && isliving(dropping))
		user_buckle_mob(dropping, user)

/obj/Destroy()
	unbuckle_mob()
	return ..()


/obj/proc/buckle_mob(mob/living/M)
	if(buckled_mob) //unless buckled_mob becomes a list this can cause problems
		return 0
	if(!istype(M) || (M.loc != loc) || M.buckled || LAZYLEN(M.pinned) || (buckle_require_restraints && !M.restrained()))
		return 0
	if(ismob(src))
		var/mob/living/carbon/C = src //Don't wanna forget the xenos.
		if(M != src && C.incapacitated())
			return 0

	if(M.throwing)
		// can't throwing mob if it's buckled
		M.throwing = 0
	M.buckled = src
	M.facing_dir = null
	M.set_dir(buckle_dir ? buckle_dir : dir)
	M.update_canmove()
	M.update_floating()
	buckled_mob = M

	post_buckle_mob(M)
	return 1

/obj/proc/unbuckle_mob()
	if(buckled_mob && buckled_mob.buckled == src)
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_canmove()
		buckled_mob.update_floating()
		buckled_mob = null

		post_buckle_mob(.)

/obj/proc/post_buckle_mob(mob/living/M)
	for(var/obj/item/grab/G in M.grabbed_by) // It is crucial to drop all grabs. Otherwise you will encounter extreme offset shenanigans.
		G.force_drop()

	M.update_offsets(1)

/obj/proc/user_buckle_mob(mob/living/M, mob/user)
	if(isanimal(user) || istype(M, /mob/living/simple_animal/hostile))
		return 0
	if(!user.Adjacent(M) || user.restrained() || user.incapacitated(INCAPACITATION_ALL) || user.stat || istype(user, /mob/living/silicon/pai))
		return 0
	if(M == buckled_mob)
		return 0
	if(istype(M, /mob/living/carbon/metroid))
		to_chat(user, SPAN("warning", "\The [M] is too squishy to buckle in."))
		return 0
	if(issilicon(M) && !is_drone(M))
		to_chat(user, SPAN("warning", "\The [M] is too heavy to buckle in."))
		return 0

	add_fingerprint(user)
	unbuckle_mob()

	//can't buckle unless you share locs so try to move M to the obj.
	if(M.loc != src.loc)
		if(M != user && M.a_intent != I_HELP && !(M.restrained() || M.lying))
			to_chat(user, SPAN("warning", "\The [M.name] resists buckling!"))
			to_chat(M, SPAN("warning", "You resist getting buckled by \the [user.name]!"))
			return 0
		step_towards(M, src)

	. = buckle_mob(M)
	if(.)
		if(M == user)
			M.visible_message(\
				SPAN("notice", "\The [M.name] buckles themselves to \the [src]."),\
				SPAN("notice", "You buckle yourself to \the [src]."),\
				SPAN("notice", "You hear metal clanking."))
		else
			M.visible_message(\
				SPAN("danger", "\The [M.name] is buckled to \the [src] by \the [user.name]!"),\
				SPAN("danger", "You are buckled to \the [src] by \the [user.name]!"),\
				SPAN("notice", "You hear metal clanking."))

/obj/proc/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		show_unbuckle_message(M, user)
		for(var/obj/item/grab/G as anything in (M.grabbed_by | grabbed_by))
			qdel(G)
		add_fingerprint(user)
	return M

/atom/movable/proc/show_unbuckle_message(mob/buckled, mob/buckling)
	if(buckled == buckling)
		var/datum/gender/G = gender_datums[buckled.gender]
		visible_message(
			SPAN_NOTICE("\The [buckled] unbuckled [G.self] from \the [src]!"),
			SPAN_NOTICE("You unbuckle yourself from \the [src]."),
			SPAN_NOTICE("You hear metal clanking.")
		)
	else
		visible_message(
			SPAN_NOTICE("\The [buckled] was unbuckled from \the [src] by \the [buckling]!"),
			SPAN_NOTICE("You were unbuckled from \the [src] by \the [buckling]."),
			SPAN_NOTICE("You hear metal clanking.")
		)
