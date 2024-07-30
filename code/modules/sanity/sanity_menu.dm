/datum/asset/simple/sanity
	assets = list(
		"desire.png" = 'tgui/packages/tgui/assets/sanity/desire.png',
		"style.png" = 'tgui/packages/tgui/assets/sanity/style.png',
		"insight.png" = 'tgui/packages/tgui/assets/sanity/insight.png',
		"kneeling.png" = 'tgui/packages/tgui/assets/sanity/kneeling.png',
		"sanity.png" = 'tgui/packages/tgui/assets/sanity/sanity.png'
	)

/datum/sanity/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/sanity/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Sanity", owner.name)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/sanity/tgui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/sanity)
	)

/datum/sanity/tgui_data(mob/user)
	var/list/data = list()

	//data["style"] = list(
	//	"value" = owner.get_total_style(),
	//	"min" = MIN_HUMAN_STYLE,
	//	"max" = MAX_HUMAN_STYLE
	//)

	data["sanity"] = list(
		"value" = level,
		"max" = max_level
	)

	data["desires"] = list(
		"resting" = resting,
		"desires" = desires,
		"value" = insight_rest,
	)

	//var/obj/item/implant/core_implant/cruciform/C = owner.get_core_implant(/obj/item/implant/core_implant/cruciform)
	//data["righteous"] = list(
	//	"present" = C ? TRUE : FALSE,
	//	"value" = C?.righteous_life
	//)

	data["insight"] = insight

	return data
