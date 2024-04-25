/datum/deity_form/devil
	name = "Devil"
	desc = "What’s better than a devil you don’t know? A devil you do."
	form_state = "devil"

	//buildables = list(/datum/deity_power/structure/devil_teleport)

	phenomena = list(/datum/deity_power/phenomena/conversion)

	boons = list()

	resources = list(/datum/deity_resource/souls)

	/// Path to an associated bane
	var/bane

	var/mob/living/carbon/current_devil_shell

	var/respawn_points = 1

/datum/deity_form/devil/setup_form(mob/living/deity/D)
	. = ..()
	bane = pick(DEVIL_BANES)

	var/datum/map_template/devil_level/dlevel = new /datum/map_template/devil_level()
	dlevel.load_new_z()
	create_devils_shell(D, TRUE)

/datum/deity_form/devil/proc/create_devils_shell(mob/living/deity/D, free_respawn = FALSE)
	if(!free_respawn)
		if(respawn_points <= 0)
			to_chat(D, "GG WP!")
			return

		respawn_points--

	var/mob/living/carbon/human/devil_new = new /mob/living/carbon/human(get_turf(pick(GLOB.devilspawns)))
	D.mind.deity = D
	current_devil_shell = devil_new
	ADD_TRAIT(devil_new, bane)
	D.mind?.transfer_to(devil_new)

/datum/deity_form/devil/proc/on_shell_death(datum/mind/m)
	m.transfer_to(deity)

/datum/deity_resource/souls
	name = "Souls"
