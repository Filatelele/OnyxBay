/datum/devil_follower/sloth
	starting_actions = list(/datum/action/cooldown/expand_sight)

/datum/action/cooldown/expand_sight
	name = "Expand Sight"
	desc = "Boosts your sight range considerably, allowing you to see enemies from much further away."
	/// How far we expand the range to.
	var/range_expansion = 3
	cooldown_time = 1 SECOND
	action_type = AB_INNATE
	background_icon_state = "bg_spell"
	button_icon_state = "spell_default"
	overlay_icon_state = "bg_spell_border"
	active_overlay_icon_state = "bg_spell_border_active_blue"

/datum/action/cooldown/expand_sight/Activate()
	active = TRUE
	build_button_icon(button, UPDATE_BUTTON_OVERLAY)
	owner.client?.view = world.view + range_expansion

/datum/action/cooldown/expand_sight/Deactivate()
	active = FALSE
	build_button_icon(button, UPDATE_BUTTON_OVERLAY)
	owner.client?.view = world.view

#define DEFAULT_TELEPORT_TIME 10

/obj/structure/deity/devil_teleport
	name = "Teleport"
	desc = "TELEPORT."
	icon_state = "jew"
	var/destination

/obj/structure/deity/devil_teleport/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	destination = A.name

/obj/structure/deity/devil_teleport/Destroy()
	return ..()

/obj/structure/deity/devil_teleport/attack_hand(mob/user)
	//if(user.mind?.godcultist?.linked_deity == linked_deity || user.mind?.deity == linked_deity)
	teleport(user)

/obj/structure/deity/devil_teleport/proc/teleport(mob/user)
	var/list/possible_destinations = list()
	//for(var/obj/structure/deity/devil_teleport/tp in linked_deity.buildings)
	for(var/obj/structure/deity/devil_teleport/tp in world)
		if(tp == src)
			continue

		possible_destinations.Add(tp.destination)

	var/destination = tgui_input_list(user, "Choose a destination", "Teleport", sort_list(possible_destinations))

	for(var/obj/structure/deity/devil_teleport/tp in world)
		if(tp.destination != destination)
			continue

		playsound(get_turf(src), 'sound/magic/teleport_sound.ogg', 50, FALSE, -1)
		var/obj/effect/devilsteleport/portal_effect = new /obj/effect/devilsteleport(get_turf(user))
		INVOKE_ASYNC(src, nameof(.proc/teleport_animation), user, portal_effect)
		if(!do_after(user, DEFAULT_TELEPORT_TIME, src, FALSE))
			animate(user, alpha = 255, time = 2)
			qdel(portal_effect)
			return

		else
			qdel(portal_effect)
			user.forceMove(get_turf(tp))
			user.alpha = 255

/obj/structure/deity/devil_teleport/proc/teleport_animation(mob/user, obj/effect/devilsteleport/portal_effect)
	animate(portal_effect, alpha = 255, time = DEFAULT_TELEPORT_TIME / 1.2, flags = ANIMATION_PARALLEL)
	animate(user, alpha = 0, time = DEFAULT_TELEPORT_TIME, flags = ANIMATION_PARALLEL)

/obj/effect/devilsteleport
	icon_state = "portal"
	icon = 'icons/obj/cult.dmi'
	anchored = TRUE
	mouse_opacity = 0
	alpha = 100

/obj/effect/warp/devilsteleport
	icon_state = "build"
	icon = 'icons/obj/cult.dmi'
	anchored = TRUE
	plane = WARP_EFFECT_PLANE
	appearance_flags = PIXEL_SCALE
