/datum/infernal_lathe
	var/list/lathe_recipes = null
	var/show_category = "All"
	var/owner

/datum/infernal_lathe/New(owner)
	. = ..()
	src.owner = owner

/datum/infernal_lathe/tgui_state()
	return GLOB.tgui_always_state

/datum/infernal_lathe/tgui_data(mob/user)
	if(!lathe_recipes)
		lathe_recipes = autolathe_recipes

	var/list/data = list(
		"storage" = list(),
		"category" = list(
			"selected" = show_category,
			"total" = autolathe_categories + "All"
		),
		"recipes" = list()
	)

	var/index = 0
	for(var/datum/autolathe/recipe/R in lathe_recipes)
		index++

		if(show_category != "All" && show_category != R.category)
			continue

		var/list/recipe_data = list(
			"name" = R.name,
			"index" = index,
			"canMake" = TRUE,
			"category" = R.category,
			"cost" = list(),
			"icon" = icon2base64html(R.path)
		)

		data["recipes"] += list(recipe_data)

	return data

/datum/infernal_lathe/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "InfernalLathe", "Infernal Lathe")
		ui.open()

/datum/infernal_lathe/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("change_category")
			var/choice = params["category"]
			if(!choice || !(choice in autolathe_categories + "All"))
				return TRUE
			show_category = choice
			tgui_update()
			return TRUE

		if("make")
			if(!lathe_recipes)
				return TRUE

			var/index = text2num(params["make"])
			var/multiplier = text2num(params["multiplier"])
			var/datum/autolathe/recipe/making

			if(index > 0 && index <= lathe_recipes.len)
				making = lathe_recipes[index]

			var/obj/item/I = new making.path(get_turf(owner))
			if(istype(I, /obj/item/stack))
				var/obj/item/stack/S = I
				S.amount = multiplier
				S.update_icon()

			tgui_update()
