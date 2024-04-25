/datum/devil_follower/greed
	starting_actions = list(/datum/action/cooldown/spell/sleight_of_hand, /datum/action/cooldown/spell/interdimensional_locker, /datum/action/cooldown/spell/infernal_lathe)
	modifiers = list(/datum/modifier/sin/greed)

/datum/action/cooldown/spell/sleight_of_hand
	name = "Sleight of Hand"
	desc = "Steal a random item from the victim's backpack."
	button_icon_state = "sleight_of_hand"

	cooldown_time = 40 SECONDS

	cast_range = 4

/datum/action/cooldown/spell/sleight_of_hand/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on) && (locate(/obj/item/storage/backpack) in cast_on.contents)

/datum/action/cooldown/spell/sleight_of_hand/cast(mob/living/carbon/human/cast_on)
	var/obj/storage_item = locate(/obj/item/storage/backpack) in cast_on.contents

	var/item = safepick(storage_item.contents)
	if(isnull(item))
		return FALSE

	to_chat(cast_on, SPAN_WARNING("Your [storage_item] feels lighter..."))
	to_chat(owner, SPAN_NOTICE("With a blink, you pull [item] out of [cast_on]'s [storage_item]."))
	owner.pick_or_drop(item)

/datum/modifier/sin/greed
	name = "Greed"
	var/weakref/item_to_find

/datum/modifier/sin/greed/New(new_holder, new_origin)
	. = ..()
	find_target()

/datum/modifier/sin/greed/Destroy()
	item_to_find = null
	return ..()

/datum/modifier/sin/greed/think()
	find_target()

/datum/modifier/sin/greed/proc/find_target()
	var/atom/former_target = item_to_find
	if(istype(former_target))
		unregister_signal(former_target, SIGNAL_QDELETING)
		unregister_signal(former_target, SIGNAL_ITEM_PICKED)

	item_to_find = null

	var/list/seeing_objs = list()
	var/list/seeing_mobs = list()
	get_mobs_and_objs_in_view_fast(get_turf(holder), world.view, seeing_mobs, seeing_objs)
	for(var/atom/I in seeing_objs)
		if(!isitem(I))
			seeing_objs.Remove(I)
			continue

		if(!isturf(I.loc))
			seeing_objs.Remove(I)

	if(!seeing_objs.len)
		set_next_think(world.time + 15 SECONDS)
		return

	var/obj/item/target = safepick(seeing_objs)
	register_signal(target, SIGNAL_QDELETING, nameof(.proc/forget_target))
	register_signal(target, SIGNAL_ITEM_PICKED, nameof(.proc/item_picked))
	item_to_find = weakref(target)
	to_chat(holder, SPAN_DANGER("I need \the [target]!"))

	var/list/images_to_show = list()
	var/image/IMG = image(null, target, layer = target.layer)
	IMG.appearance_flags |= KEEP_TOGETHER | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	IMG.vis_contents += target

	IMG.filters += filter(type = "outline", size = 2, color = COLOR_RED)
	images_to_show += IMG

	var/image/pointer = image('icons/effects/effects.dmi', target, "arrow", layer = HUD_ABOVE_ITEM_LAYER)
	pointer.pixel_x = target.pixel_x
	pointer.pixel_y = target.pixel_y
	QDEL_IN(pointer, 2 SECONDS)
	images_to_show += pointer

	holder.client?.images |= images_to_show

/datum/modifier/sin/greed/proc/forget_target()
	var/atom/former_target = item_to_find
	if(istype(former_target))
		unregister_signal(former_target, SIGNAL_QDELETING)
		unregister_signal(former_target, SIGNAL_ITEM_PICKED)
	item_to_find = null
	to_chat(holder, SPAN_DANGER("Forget about it!"))
	find_target()

/datum/modifier/sin/greed/proc/item_picked(obj/item/I, mob/user)
	if(user != holder)
		return

	unregister_signal(I, SIGNAL_QDELETING)
	unregister_signal(I, SIGNAL_ITEM_PICKED)
	item_to_find = null
	to_chat(holder, SPAN_DANGER("I FOUND IT!"))
	user.drop(I, null, TRUE)
	qdel(I)

/datum/action/cooldown/spell/interdimensional_locker
	name = "Interdimensional locker"
	desc = "VOROVSKOY KARMAN4IK."
	button_icon_state = "sleight_of_hand"
	cooldown_time = 5 SECONDS
	/// Reference to the summoned locker
	var/obj/structure/closet/locker
	/// Type of the locker to summon
	var/locker_type = /obj/structure/closet/cabinet

/datum/action/cooldown/spell/interdimensional_locker/New()
	. = ..()
	initialize_locker()

/datum/action/cooldown/spell/interdimensional_locker/Destroy()
	unregister_signal(locker, SIGNAL_QDELETING)
	locker = null
	return ..()

/datum/action/cooldown/spell/interdimensional_locker/proc/initialize_locker()
	locker = new locker_type()
	register_signal(locker, SIGNAL_QDELETING, nameof(.proc/initialize_locker))

/datum/action/cooldown/spell/interdimensional_locker/cast(atom/cast_on)
	if(!locker)
		initialize_locker()

	if(locker.loc != null)
		var/list/mobs_inside = list()
		recursive_content_check(locker, mobs_inside, recursion_limit = 3, client_check = FALSE, sight_check = FALSE, include_mobs = TRUE, include_objects = FALSE)

		for(var/i in mobs_inside)
			var/mob/M = i
			M.dropInto(get_turf(locker))
			M.reset_view()
			to_chat(M, SPAN_WARNING("You are suddenly flung out of \the [locker]!"))

		locker.forceMove(null)
		return

	var/turf/target = get_turf(cast_on)
	if(!istype(target))
		return

	for(var/atom/A in target)
		if(A.density)
			return

	locker.forceMove(target)

/datum/action/cooldown/spell/infernal_lathe
	name = "Infernal Lathe"
	desc = "VOROVSKOY KARMAN4IK."
	button_icon_state = "sleight_of_hand"
	cooldown_time = 1 SECOND
	/// Reference to the summoned locker
	var/datum/infernal_lathe/lathe

/datum/action/cooldown/spell/infernal_lathe/New()
	. = ..()
	lathe = new /datum/infernal_lathe(src, owner)

/datum/action/cooldown/spell/infernal_lathe/Destroy()
	QDEL_NULL(lathe)
	return ..()

/datum/action/cooldown/spell/infernal_lathe/cast()
	lathe.tgui_interact(owner)
