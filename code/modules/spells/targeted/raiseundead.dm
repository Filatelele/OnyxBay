#define RAISE_UNDEAD_TIMEOUT 30 SECONDS

/datum/spell/targeted/raiseundead
	name = "Raise the dead"
	desc = "This spell raises the dead by turning them into your un-dead servants with no free will."
	feedback = "RU"
	school = "necromancy"
	spell_flags = SELECTABLE | NEEDSCLOTHES
	invocation = "De sepulchro suscitate et servite mihi!"
	invocation_type = SPI_SHOUT

	max_targets = 1

	charge_max = 6000
	cooldown_min = 3000
	cooldown_reduc = 1000

	var/should_lichify = FALSE

	level_max = list(SP_TOTAL = 3, SP_SPEED = 3, SP_POWER = 0)

	compatible_mobs = list(/mob/living/carbon/human)

	icon_state = "wiz_raiseundead"

	override_base = "const"

/datum/spell/targeted/raiseundead/choose_targets(mob/user = usr)
	var/list/possible_targets = list()

	for(var/mob/living/target in view(world.view, user))
		if(!target.is_ic_dead() || target.isSynthetic())
			continue

		possible_targets += target

	var/mob/target = tgui_input_list(user, "Choose the target for the spell.", "Targeting", possible_targets)

	return target

/datum/spell/targeted/raiseundead/cast(mob/living/carbon/human/target, mob/user = usr)
	var/target_player = null
	if(target.client)
		target_player = target.client

	if(!target.client || target.mind)
		for(var/mob/observer/ghost/ghost in GLOB.ghost_mob_list)
			if(ghost.mind.key != target.mind.key)
				continue

			ghost.can_reenter_corpse = TRUE
			target_player = ghost

	if(!target_player)
		draft_ghosts(target, user)

	var/player_choice = tgui_alert(target_player, "A necromancer is attempting to raise your body as an undead", "Would you like to return to your body?", list("Yes", "No"), RAISE_UNDEAD_TIMEOUT)
	if(player_choice == "Yes")
		if(istype(target_player, /mob/observer/ghost))
			var/mob/observer/ghost/player = target_player
			player.reenter_corpse()
		target.make_undead(user, should_lichify)
	else
		draft_ghosts(target, user)

/datum/spell/targeted/raiseundead/proc/draft_ghosts(mob/living/carbon/human/target, mob/user = usr)
	var/mob/living/carbon/human/H = target
	var/datum/ghosttrap/undead/trap = get_ghost_trap("undead")
	trap.request_player(H, "A necromancer is requesting a soul to animate an undead body.", RAISE_UNDEAD_TIMEOUT, user, should_lichify)
	addtimer(CALLBACK(src, .proc/draft_failure), RAISE_UNDEAD_TIMEOUT)

/datum/spell/targeted/raiseundead/proc/draft_failure()
	to_chat(holder, SPAN_WARNING("Your spell has failed. Perhaps you should try again later?"))
	charge_counter = charge_max

/mob/living/carbon/human/proc/make_undead(mob/necromancer, should_lichify = FALSE)
	if(!mind)
		return

	if(!istype(mind.wizard, /datum/wizard/undead))
		GLOB.wizards.add_antagonist_mind(mind, TRUE, "undead", "<b>You are undead! Your job is to serve your master!</b>")
		mind.wizard = new /datum/wizard/undead(src, necromancer)

	if(!isundead(src))
		status_flags |= UNDEAD
		does_not_breathe = TRUE
		remove_blood(species.blood_volume)
		oxygen_alert = 0
		update_canmove()
		for(var/datum/modifier/mod in modifiers)
			if(!isnull(mod.metabolism_percent))
				mod.metabolism_percent = 0

	revive(ignore_prosthetic_prefs = TRUE) // Complete regeneration

	if(necromancer.mind && necromancer.mind.wizard)
		//var/datum/mind/wizard/necromind = necromancer.mind.wizard
		necromancer.mind.wizard.thralls |= mind.wizard

	to_chat(src, SPAN_DANGER("<font size=6>Your consciousness awakens in a cold body. You are alive, but at what cost?</font>"))

	if(should_lichify)
		var/datum/wizard/undead/undead = mind.wizard
		necromancer.mind?.wizard?.lich = src
		undead.lichify()
		to_chat(necromancer, SPAN_WARNING("You feel a new connection forming... Now, you have a lich under your control!"))
		to_chat(src, SPAN_DANGER("<font size=6>You are now a lich serving as an apprentice to your master, \the [necromancer].</font>"))
	else
		to_chat(necromancer, SPAN_WARNING("You feel a soul answering your call. You now have a new thrall."))
		to_chat(src, SPAN_DANGER("<font size=6>Your consciousness awakens in a cold body. You are alive, but at what cost?</font>"))
		to_chat(src, SPAN_DANGER("<font size=6>Raised as undead, stripped of free will you now have one task - obey your master, \the [necromancer].</font>"))

#undef RAISE_UNDEAD_TIMEOUT
