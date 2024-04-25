/datum/action/cooldown/spell/summon_contract
	name = "Summon Contract"
	desc = "Summon Contract"
	button_icon_state = "spell_default"
	click_to_activate = TRUE

	cooldown_time = 1 MINUTE

	cast_range = 1
	var/instructions = "Server your master!"

/datum/action/cooldown/spell/summon_contract/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/summon_contract/cast(mob/living/carbon/human/cast_on)
	var/mob/living/deity/deity = owner.mind?.deity
	ASSERT(deity)

	var/list/choices = list(
		"gluttony" = /datum/devil_follower/gluttony,
		"greed" = /datum/devil_follower/greed,
		"lust" = /datum/devil_follower/lust,
		"sloth" = /datum/devil_follower/sloth,
		"wrath" = /datum/devil_follower/wrath,
		//"pride" = /datum/devil_follower/pride
	)

	var/choice = tgui_input_list(owner, "Select power", "Select", choices)

	var/turf/target_turf = get_turf(cast_on)
	var/obj/item/paper/infernal_contract/contract = new /obj/item/paper/infernal_contract(target_turf, deity, choices[choice])
	cast_on.pick_or_drop(contract, target_turf)

/obj/item/paper/infernal_contract
	var/datum/devil_follower/follower_prefab
	var/mob/living/deity/owner

/obj/item/paper/infernal_contract/Initialize(mapload, owner, follower_prefab)
	. = ..()
	src.follower_prefab = follower_prefab
	src.owner = owner

/obj/item/paper/infernal_contract/attack_self(mob/living/user)
	ASSERT(owner && follower_prefab)

	var/datum/deity_power/phenomena/conversion/convert_spell = locate(/datum/deity_power/phenomena/conversion) in owner.form.phenomena
	ASSERT(convert_spell)

	if(convert_spell.manifest(user, owner))
		var/datum/deity_form/devil/devil_form = owner.form
		user.add_modifier(/datum/modifier/noattack, origin = owner, additional_params = devil_form.current_devil_shell)
