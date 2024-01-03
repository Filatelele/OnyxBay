/obj/machinery/mineral/mint
	name = "Coin press"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "coinpress0"

	var/list/stored_material = list(MATERIAL_GOLD = 0, MATERIAL_SILVER = 0, MATERIAL_DIAMOND = 0, MATERIAL_PLASMA = 0, MATERIAL_URANIUM = 0, MATERIAL_IRON = 0)
	/// How many coins the machine made in it's last cycle
	var/produced_coins = 0
	var/processing = FALSE
 	/// Which material will be used to make coins
	var/chosen_material

/obj/machinery/mineral/mint/pickup_item(datum/source, atom/movable/target, atom/old_loc)
	var/obj/item/stack/material/incoming_material = target
	if(!istype(incoming_material))
		return

	for(var/material in stored_material)
		if(material != incoming_material.default_type)
			continue

		stored_material[material] += incoming_material.amount
		qdel(incoming_material)

/obj/machinery/mineral/mint/proc/mint()
	pass()

/obj/machinery/mineral/mint/attack_hand(mob/user)
	if(!..())
		return

	add_fingerprint(user)
	tgui_interact(user)

/obj/machinery/mineral/mint/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CoinPress", name)
		ui.open()

/obj/machinery/mineral/mint/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("start")
			if(!processing)
				produced_coins = 0
			processing = TRUE
			return TRUE

		if("stop")
			processing = FALSE
			return TRUE

		if("changematerial")
			for(var/material in stored_material)
				if(params["material_name"] != material)
					continue

				chosen_material = material
			return TRUE

/obj/machinery/mineral/mint/tgui_data(mob/user)
	var/list/data = list()
	for(var/material in stored_material)
		var/amount = stored_material[material]

		data["inserted_materials"] += list(list(
			"material" = material,
			"amount" = amount
		))

	data["chosen_material"] = chosen_material

	data["produced_coins"] = produced_coins
	data["processing"] = processing

	return data;
