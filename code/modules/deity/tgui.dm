/mob/living/deity
	var/page = 0

/mob/living/deity/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Deity", name)
		ui.open()

/mob/living/deity/tgui_state()
	return GLOB.tgui_always_state

/mob/living/deity/tgui_data(mob/user)
	var/list/data = list(
		"forms" = list(),
		"followers" = list(),
		"buildings" = list()
	)

	data["user"] = list(
			"form" = form?.type,
			"name" = user.name,
		)

	for(var/datum/deity_form/form in GLOB.deity_forms)
		var/icon/form_icon = new /icon("icon" = 'icons/mob/deity.dmi', "icon_state" = form.form_state)
		var/list/form_data = list(
			"name" = form.name,
			"icon" = icon2base64html(form_icon),
			"desc" = form.desc,
		)

		data["forms"] += list(form_data)

	if(!form)
		return data

	var/list/powers = form.buildables
	powers.Add(form.boons)
	powers.Add(form.phenomena)

	data["items"] = list()
	for(var/datum/deity_power/power in form?.buildables)
		var/list/building_data = list(
			"name" = power._get_name(),
			"icon" = icon2base64html(power._get_image()),
			"desc" = power.desc,
			"type" = power.type
		)

		data["items"] += list(building_data)

	data["evolutionItems"] = list()
	for(var/datum/evolution_category/cat in form?.evolution_categories)
		var/list/cat_data = list(
			"name" = cat.name
			//"desc" = cat.desc,
			//"icon" = cat.icon,
		)

		for(var/datum/evolution_package/pack in cat.items)
			var/list/pack_data = list(
				"name" = pack.name,
				"desc" = pack.desc,
				"icon" = pack.icon,
				"tier" = pack.tier,
				"unlocked" = pack.unlocked
			)
			cat_data["packages"] += list(pack_data)

		data["evolutionItems"] += list(cat_data)

	for(var/datum/mind/M in followers)
		var/list/follower_data = list(
			"name" = M.name,
			"stat" = M.current?.stat,
			"ref" = "\ref[M]"
		)

		data["followers"] += list(follower_data)

	return data

/mob/living/deity/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("change_page")
			page = params["page"]
			return TRUE

		if("choose_form")
			set_form(params["path"])
			return TRUE

		if("select_building")
			set_selected_power(text2path(params["building_type"]), form.buildables)
			return TRUE

		if("select_boon")
			set_selected_power(text2path(params["building_type"]), form.boons)
			return TRUE

		if("select_phenomenon")
			set_selected_power(text2path(params["building_type"]), form.phenomena)
			return TRUE

		if("reward_follower")
			reward_follower(params["ref"])
			return TRUE

		if("punish_follower")
			punish_follower(params["ref"])
			return TRUE

/mob/living/deity/proc/reward_follower(follower_ref = null)
	if(isnull(follower_ref))
		return

	var/datum/mind/M = locate(follower_ref) in followers
	var/mob/living/carbon/current = M?.current
	if(!istype(current))
		return

	current.adjustBruteLoss(-15)
	current.adjustFireLoss(-15)
	current.adjustToxLoss(-15)
	current.adjustOxyLoss(-15)
	current.adjustBrainLoss(-5)
	current.updatehealth()

/mob/living/deity/proc/punish_follower(follower_ref = null)
	if(isnull(follower_ref))
		return

	var/datum/mind/M = locate(follower_ref) in followers
	var/mob/living/carbon/current = M?.current
	if(!istype(current))
		return

	var/turf/lightning_source = get_step(get_step(current, NORTH), NORTH)
	lightning_source.Beam(current, icon_state="lightning[rand(1,12)]", time = 5)
	playsound(get_turf(current), 'sound/magic/sound_magic_lightningbolt.ogg', 50, TRUE)
	var/burn_damage = current.electrocute_act(40, src, pick(BP_ALL_LIMBS))
	if(burn_damage > 15 && current.can_feel_pain())
		current.emote(pick("scream", "scream_long"))

/mob/living/deity/verb/choose_form()
	set name = "Choose Form"
	set category = "Godhood"

	tgui_interact(src)

/mob/living/deity/proc/open_building_menu()
	tgui_interact(src)
