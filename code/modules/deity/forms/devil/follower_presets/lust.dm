/datum/devil_follower/lust
	starting_actions = list(/datum/action/cooldown/spell/suggest, /datum/action/cooldown/spell/aoe/void_pull)

/datum/action/cooldown/spell/suggest
	name = "Sleight of Hand"
	desc = "Steal a random item from the victim's backpack."
	button_icon_state = "sleight_of_hand"

	cooldown_time = 30 SECONDS

	spell_max_level = 2
	cast_range = 3

/datum/action/cooldown/spell/suggest/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/suggest/cast(mob/living/carbon/human/cast_on)
	var/command
	if(spell_level == 1)
		command = tgui_input_text(owner, "Command your victim with a single word.", "Your command")
		command = sanitizeSafe(command)
		var/spaceposition = findtext_char(command, " ")
		if(spaceposition)
			command = copytext_char(command, 1, spaceposition + 1)
	else if(spell_level == 2)
		command = tgui_input_text(owner, "Command your victim.", "Your command")

	if(!command)
		cast_on.show_splash_text(owner, "cancelled!", "Spell [src] was cancelled!")
		return

	owner.say(command)

	if(cast_on.is_deaf() || !cast_on.say_understands(owner, owner.get_default_language()))
		cast_on.show_splash_text(owner, "can't understand!", SPAN_WARNING("Target does not understand you!"))
		return

	tgui_alert(cast_on, "You feel a strong presence enter your mind, silencing your thoughts and compelling to act without hesitation: [command]!", "Dominated!")
	to_chat(cast_on, SPAN_DANGER("You feel a strong presence enter your mind, silencing your thoughts and compelling to act without hesitation: [command]!"))
	to_chat(owner, SPAN_DANGER("You command [cast_on], and they will obey."))

#define SPELL_CAST_DURATION 6
#define SPELL_CAST_INTERVAL 0.5 SECONDS

/datum/action/cooldown/spell/aoe/void_pull
	name = "Void Pull"
	cooldown_time = 40 SECONDS

	aoe_radius = 7
	/// The radius of the actual damage circle done before cast
	var/damage_radius = 1
	/// The radius of the stun applied to nearby people on cast
	var/stun_radius = 4

/datum/action/cooldown/spell/aoe/void_pull/cast(atom/target)
	var/obj/effect/voidin = new /obj/effect/voidin(get_turf(target))
	var/list/atom/things_to_cast_on = get_things_to_cast_on(target)

	var/spell_duration = 0
	while(do_after(owner, SPELL_CAST_INTERVAL, target = target, can_move = FALSE) && spell_duration < SPELL_CAST_DURATION)
		if(!(spell_duration % 2))
			playsound(get_turf(target), 'sound/magic/air_whistling.ogg', 100, FALSE)
		for(var/thing_to_target in things_to_cast_on)
			cast_on_thing_in_aoe(thing_to_target, target)
		spell_duration++

	qdel(voidin)

/datum/action/cooldown/spell/aoe/void_pull/get_things_to_cast_on(atom/center)
	var/list/things = list()
	// Default behavior is to get all atoms in range, center and owner not included.
	for(var/mob/living/nearby_thing in range(aoe_radius, center))
		if(nearby_thing == owner)
			continue

		things += nearby_thing

	return things

// For the actual cast, we microstun people nearby and pull them in
/datum/action/cooldown/spell/aoe/void_pull/cast_on_thing_in_aoe(mob/living/victim, atom/target)
	// If the victim's within the stun radius, they're stunned / knocked down
	if(get_dist(victim, target) < stun_radius)
		victim.AdjustParalysis(5)
		victim.AdjustWeakened(5)

	// Otherwise, they take a few steps closer
	victim.forceMove(get_step_towards(victim, target))

/obj/effect/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	pixel_x = -32
	pixel_y = -32
	var/obj/effect/effect/warp/voidpull/warp

/obj/effect/voidin/Initialize(mapload)
	. = ..()
	warp = new /obj/effect/effect/warp/voidpull(get_turf(src))
	QDEL_IN(src, 5 SECONDS)
	return ..()

/obj/effect/voidin/Destroy()
	QDEL_NULL(warp)
	return ..()

/obj/effect/effect/warp/voidpull
	icon = 'icons/effects/160x160.dmi'
	icon_state = "singularity_s5"
	anchored = TRUE
	plane = WARP_EFFECT_PLANE
	appearance_flags = PIXEL_SCALE
	pixel_x = -64
	pixel_y = -64

#undef SPELL_CAST_DURATION
#undef SPELL_CAST_INTERVAL
