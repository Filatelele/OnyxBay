/datum/devil_follower/wrath
	starting_actions = list(/datum/action/cooldown/spell/beam/chained/devil_arc_lighting, /datum/action/cooldown/wrath_modifier)
	modifiers = list(/datum/modifier/sin/wrath)

/datum/modifier/sin/wrath
	outgoing_melee_damage_percent = 1.5
	incoming_damage_percent = 1.5

/datum/action/cooldown/spell/beam/chained/devil_arc_lighting
	name = "Arc lighting"
	button_icon_state = "devil_arc_lighting"
	max_beam_bounces = 5
	beam_sound = 'sound/magic/sound_magic_lightningshock.ogg'
	cooldown_time = 30 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED | AB_CHECK_RESTRAINED

/datum/action/cooldown/spell/beam/chained/devil_arc_lighting/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE

	return TRUE

/datum/action/cooldown/wrath_modifier
	cooldown_time = 0
	action_type = AB_INNATE
	name = "Wrath"
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_spell"
	button_icon_state = "spell_default"
	overlay_icon_state = "bg_spell_border"
	active_overlay_icon_state = "bg_spell_border_active_blue"

/datum/action/cooldown/wrath_modifier/Activate()
	var/mob/living/living_owner = owner
	if(!istype(living_owner))
		return

	active = TRUE
	build_button_icon(button, UPDATE_BUTTON_OVERLAY)
	living_owner.add_modifier(/datum/modifier/sin/wrath)

/datum/action/cooldown/wrath_modifier/Deactivate()
	var/mob/living/living_owner = owner
	if(!istype(living_owner))
		return

	active = FALSE
	build_button_icon(button, UPDATE_BUTTON_OVERLAY)
	living_owner.remove_modifiers_of_type(/datum/modifier/sin/wrath)
