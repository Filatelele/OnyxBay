/datum/computer_file/program/art_library
	filename = "art library"
	filedesc = "Art library"
	extended_desc = "This program can be used to view pictures from an external archive."
	program_icon_state = "word"
	program_key_state = "atmos_key"
	program_menu_icon = "note"
	program_light_color = "#4273E7"
	size = 6
	category = PROG_OFFICE
	requires_ntnet = 1
	available_on_ntnet = 1

	nanomodule_path = /datum/nano_module/art_library

//getFlatIcon

/datum/nano_module/art_library
	name = "Art library"
	var/error_message = ""
	var/sort_by = "id"
	var/list/current_art
	var/obj/machinery/libraryscanner/scanner
	var/static/list/canvas_state_to_type = list()

/datum/nano_module/art_library/New(datum/host, topic_manager)
	. = ..()
	if(!length(canvas_state_to_type))
		for(var/canvas_type in typesof(/obj/item/canvas))
			var/obj/item/canvas/C = new canvas_type()
			canvas_state_to_type[C.icon_state] = canvas_type

/datum/nano_module/art_library/Destroy()
	. = ..()

/datum/nano_module/art_library/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/list/data = host.initial_data()

	data["admin"] = check_rights(R_INVESTIGATE, FALSE, user)
	if(error_message)
		data["error"] = error_message
	else if(current_art)
		data["current_art"] = current_art
	else
		data["art_list"] = db.get_arts_ordered(sort_by)
		data["scanner"] = istype(scanner)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "art_library.tmpl", "Art library Program", 575, 700, state = state)
		ui.auto_update_layout = TRUE
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/art_library/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["viewart"])
		view_art(href_list["viewart"])
		return TRUE
	if(href_list["viewid"])
		var/id = input("Enter USBN:") as num|null
		if(isnum_safe(id))
			view_art(id)
		return TRUE
	if(href_list["closeart"])
		current_art = null
		return TRUE
	if(href_list["connectscanner"])
		if(!nano_host())
			return TRUE
		for(var/d in GLOB.alldirs)
			var/obj/machinery/libraryscanner/scn = locate(/obj/machinery/libraryscanner, get_step(nano_host(), d))
			if(scn && scn.anchored)
				scanner = scn
				return TRUE
	if(href_list["uploadart"])
		if(!scanner || !scanner.anchored)
			scanner = null
			error_message = "Hardware Error: No scanner detected. Unable to access cache."
			return TRUE
		if(!scanner.art_cache)
			error_message = "Interface Error: Scanner cache does not contain any data. Please scan a art."
			return TRUE

		var/obj/item/canvas/art_cache = scanner.art_cache

		if(!art_cache.grid)
			return

		var/choice = input(usr, "Upload [art_cache.painting_name] to the External Archive?") in list("Yes", "No")
		if(choice == "Yes")
			var/grid = json_encode(art_cache.grid)
			var/base64_icon = __get_canvas_flat_icon(art_cache, art_cache.icon_state)

			db.add_art(art_cache.painting_name, art_cache.icon_state, grid, base64_icon, art_cache.author_ckey)

			log_and_message_admins("has uploaded the art titled [art_cache.painting_name]")
			log_game("[usr.name]/[usr.key] has uploaded the art titled [art_cache.painting_name]")
			alert("Upload Complete.")

			return TRUE

		return FALSE

	if(href_list["printart"])
		if(!current_art)
			error_message = "Software Error: Unable to print; art not found."
			return TRUE

		//PRINT TO BINDER
		var/atom/lib_host = nano_host()
		if(!lib_host)
			return TRUE
		for(var/d in GLOB.alldirs)
			var/obj/machinery/bookbinder/bndr = locate(/obj/machinery/bookbinder, get_step(lib_host, d))
			if(bndr && bndr.operable())
				if(!istype(bndr.print_object, /obj/item/canvas) || bndr.print_object?.icon_state != current_art["type"])
					error_message = "Software Error: Unable to print; the wrong canvas type of canvas in book binder, or the canvas is missing."
					return TRUE
				var/obj/item/canvas/new_art = bndr.print_object
				if(!new_art.finalized)
					new_art.grid = json_decode(current_art["grid"])
					new_art.paint_image()
					new_art.finalize()
					new_art.forceMove(get_turf(bndr))
					bndr.visible_message("\The [bndr] whirs as it prints a new art.")
				return TRUE
		error_message = "Software Error: Unable to print; book binder not found."
		return TRUE
	if(href_list["sortby"])
		sort_by = href_list["sortby"]
		return TRUE
	if(href_list["reseterror"])
		if(error_message)
			current_art = null
			scanner = null
			sort_by = "id"
			error_message = ""
		return TRUE

	if(href_list["delart"])
		if(!check_rights(R_INVESTIGATE, FALSE, usr))
			href_exploit(usr.ckey, href)
			return TRUE
		if(alert(usr, "Are you sure that you want to delete that art?", "Delete Art", "Yes", "No") == "Yes")
			current_art = null
			del_art_from_db(href_list["delart"], usr)
		return TRUE

/datum/nano_module/art_library/proc/__get_canvas_flat_icon(obj/item/canvas/canvas, canvas_type)
	var/icon/pre_icon = canvas.get_flat_icon()

	switch(canvas_type)
		if("11x11")
			pre_icon.Crop(11, 21, 21, 11)
		if("19x19")
			pre_icon.Crop(8, 27, 26, 9)
		if("23x19")
			pre_icon.Crop(6, 26, 28, 8)
		if("23x23")
			pre_icon.Crop(6, 27, 28, 5)
		if("24x24")
			pre_icon.Crop(5, 27, 28, 4)

	return icon2base64(pre_icon)

/datum/nano_module/art_library/proc/view_art(id)
	if(current_art || !id)
		return FALSE

	var/list/art = db.find_art(id)

	if(isnull(art))
		return TRUE

	if(isnull(art["base64_icon"]))
		var/art_type = art["type"]
		var/canvas_type = canvas_state_to_type[art_type]
		var/obj/item/canvas/preview_canvas = new canvas_type()
		preview_canvas.icon_generated = FALSE
		preview_canvas.grid = json_decode(art["grid"])
		preview_canvas.paint_image()

		var/base64_icon = __get_canvas_flat_icon(preview_canvas, art_type)

		QDEL_NULL(preview_canvas)

		db.update_art_base64_icon(art["id"], base64_icon)
		art["base64_icon"] = base64_icon

	current_art = art

	return TRUE

/proc/del_art_from_db(id, user)
	if(!id || !user)
		return
	if(!check_rights(R_INVESTIGATE, TRUE, user))
		return

	var/list/art = db.mark_deleted_art(id)

	if(!isnull(art))
		log_and_message_admins("has deleted the art: \[[id]\] \"[art["title"]]\" by [art["author"]]", user)
