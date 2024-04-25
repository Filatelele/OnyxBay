#define DOMIANTE_MIND_CHANNEL_DURATION 10 SECONDS

/datum/action/cooldown/spell/mind_dominate
	name = "Dominate Mind"
	desc = "Dominate Mind."
	button_icon_state = "sleight_of_hand"
	click_to_activate = TRUE

	cooldown_time = 1 MINUTE

	cast_range = 1
	var/instructions = "Server your master!"

/datum/action/cooldown/spell/mind_dominate/Destroy()
	QDEL_NULL(instructions)
	return ..()

/datum/action/cooldown/spell/mind_dominate/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/mind_dominate/before_cast(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	if(cast_on == owner)
		to_chat(owner, SPAN_DANGER("You tried to control yourself, thankfully spell didn't worked!"))
		return FALSE

	instructions = tgui_input_text(owner, "What is the vote for?", "Custom Vote", instructions, MAX_PAPER_MESSAGE_LEN, TRUE)

	if(!do_mob(owner, cast_on, DOMIANTE_MIND_CHANNEL_DURATION, BP_HEAD, FALSE, TRUE))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/mind_dominate/cast(mob/living/carbon/human/cast_on)
	var/datum/magical_imprint/magical_imprint = new(instructions)
	magical_imprint.implant_in_mob(cast_on, BP_HEAD)

#undef DOMIANTE_MIND_CHANNEL_DURATION
