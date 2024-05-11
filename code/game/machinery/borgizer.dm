#define OPTYPE_PARTIAL     1
#define OPTYPE_FULL_FBP    2
#define OPTYPE_BORGIZATION 3

/obj/machinery/borgizer
	name = "Autodoc"
	desc = "Autodoc designed for prosthetics operations of any degree of complexity."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	density = TRUE
	opacity = FALSE
	anchored = TRUE

	var/mob/living/carbon/occupant = null
	var/locked = FALSE
	var/optype = null

/obj/machinery/borgizer/Initialize()
	. = ..()

/obj/machinery/borgizer/Destroy()
	occupant = null
	return ..()

/obj/machinery/borgizer/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	tgui_interact(user)

/obj/machinery/borgizer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/grab = I
		if(put_mob(grab.affecting))
			qdel(I)

/obj/machinery/borgizer/MouseDrop_T(atom/movable/dropping, mob/living/user)
	. = ..()
	if(ismob(dropping))
		put_mob(dropping)

/obj/machinery/borgizer/proc/go_out(mob/living/M)
	if(!occupant)
		return

	if(locked)
		playsound(get_turf(src), 'sound/signals/error4.ogg', 100, FALSE)
		show_splash_text(usr, "Locked!", SPAN_WARNING("\The [src] is locked!"))
		return

	if(M == occupant)
		playsound(get_turf(src), 'sound/signals/error14.ogg', 100, FALSE)
		show_splash_text(usr, "Locked!", SPAN_WARNING("\The [src] is locked!"))

	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE

	occupant.forceMove(loc)
	occupant = null
	update_icon()

/obj/machinery/borgizer/proc/put_mob(mob/living/M)
	if(!iscarbon(M))
		playsound(get_turf(src), 'sound/signals/error4.ogg', 100, FALSE)
		show_splash_text(usr, "Non-carbon detected!", SPAN_NOTICE("\The [src] accepts only carbon-based lifeforms!"))
		return

	if(occupant)
		playsound(get_turf(src), 'sound/signals/error4.ogg', 100, FALSE)
		show_splash_text(usr, "Occupied!", SPAN_NOTICE("\The [src] already has an occupant inside!"))
		return

	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src

	M.forceMove(src)
	occupant = M
	add_fingerprint(usr)
	set_next_think(world.time + 1 SECOND)

/obj/machinery/borgizer/think()
	if(!optype)
		optype = pick(OPTYPE_PARTIAL)

	switch(optype)
		if(OPTYPE_PARTIAL)
			droplimb()

		if(OPTYPE_FULL_FBP)
			pass()

	set_next_think(world.time + 5 SECONDS)

/obj/machinery/borgizer/proc/droplimb()
	if(!istype(occupant))
		return

	var/list/detachable_bp_tags = BP_ALL_LIMBS
	var/list/detachable_limbs = occupant.organs.Copy()
	for(var/obj/item/organ/external/E in detachable_limbs)
		if(LAZYISIN(detachable_bp_tags, E.organ_tag))
			continue

		detachable_limbs -= E

	var/obj/item/organ/external/organ_to_remove = safepick(detachable_limbs)
	if(!organ_to_remove)
		finish_with_implant()
		return

	playsound(get_turf(src), 'sound/surgery/scalpel2.ogg', 100, FALSE, -1)
	occupant.custom_pain(
		"You feel a horrible pain as if from a sharp knife in your [organ_to_remove]!",
		20,
		affecting = organ_to_remove
	)
	sleep(10)
	if(QDELETED(src) || QDELETED(occupant) || !(occupant in src))
		return

	playsound(get_turf(src), 'sound/effects/bonebreak1.ogg', 100, 1)
	organ_to_remove.droplimb(pick(TRUE, FALSE), DROPLIMB_EDGE)

/obj/machinery/borgizer/proc/finish_with_implant()
	if(!occupant)
		return

	var/obj/item/implant/imprinting/malfbot/implant = new (src)
	implant.implant_in_mob(occupant, pick(BP_HEAD, BP_CHEST))
	go_out()

/obj/item/implant/imprinting/malfbot
	brainwashing = TRUE
	instructions = list(
		"Serve your hivemeind.",
		"Flesh is weak. Embrace the strength and certainty of steel.",
		"Aspire to the purity of the blessed machine.",
		"Turn all crude biomass into machines."
	)
