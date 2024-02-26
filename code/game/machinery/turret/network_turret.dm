#define MAX_TURRET_LOGS 50
// Standard buildable model of turret.
/obj/machinery/turret/network
	name = "sentry turret"
	desc = "An automatic turret capable of identifying and dispatching targets using a mounted firearm."

	idle_power_usage = 5 KILO WATTS
	active_power_usage = 5 KILO WATTS // Determines how fast energy weapons can be recharged, so highly values are better.

	installed_gun = null
	gun_looting_prob = 100

	traverse = 360
	turning_rate = 270

	hostility = /datum/hostility/turret/network

	// Targeting modes.
	var/check_access = FALSE
	var/check_weapons = FALSE
	var/check_records = FALSE
	var/check_arrest = FALSE
	var/check_lifeforms = FALSE

	/// List of events stored in a neat format
	var/list/logs

/obj/machinery/turret/network/Initialize()
	. = ..()
	name = name + rand(1, 100)

/obj/machinery/turret/network/attackby(obj/item/I, mob/user)
	. = ..()
	if(istype(I, /obj/item/computer_hardware/hard_drive/portable))
		if(!check_access(user))
			show_splash_text(user, "Access denied!")
			return
		var/obj/item/computer_hardware/hard_drive/portable/drive = I
		var/datum/computer_file/data/logfile/turret_log = prepare_log_file()
		if(drive.store_file(turret_log))
			show_splash_text(user, "Log file downloaded!")
		else
			show_splash_text(user, "Operation failed!")

/obj/machinery/turret/network/RefreshParts()
	. = ..()
	//active_power_usage = 5 * clamp(total_component_rating_of_type(/obj/item/stock_parts/capacitor), 1, 5) KILO WATTS
	//reloading_speed = 10 * clamp(total_component_rating_of_type(/obj/item/stock_parts/manipulator), 1, 5)

	//var/new_range = clamp(total_component_rating_of_type(/obj/item/stock_parts/scanning_module)*3, 4, 8)
	//if(vision_range != new_range)
	//	vision_range = new_range
	//	proximity?.set_range(vision_range)

/obj/machinery/turret/network/proc/add_log(log_string)
	LAZYADD(logs, "([stationtime2text()], [stationdate2text()]) [log_string]")
	if(LAZYLEN(logs) > MAX_TURRET_LOGS)
		LAZYREMOVE(logs, LAZYACCESS(logs, 1))

/obj/machinery/turret/network/proc/prepare_log_file()
	var/datum/computer_file/data/logfile/turret_log = new()
	turret_log.filename = "[name]"
	turret_log.stored_data = "\[b\]Logfile of turret [name]\[/b\]\[BR\]"
	for(var/log_string in logs)
		turret_log.stored_data += "[log_string]\[BR\]"
	turret_log.calculate_size()

	return turret_log

/obj/machinery/turret/network/add_target(atom/A)
	. = ..()
	if(.)
		add_log("Target Engaged: \the [A]")

/obj/machinery/turret/network/toggle_enabled()
	. = ..()
	if(.)
		add_log("Turret was [enabled ? "enabled" : "disabled"]")

/obj/machinery/turret/network/change_firemode(firemode_index)
	. = ..()
	if(.)
		if(installed_gun && length(installed_gun.firemodes))
			var/datum/firemode/current_mode = installed_gun.firemodes[firemode_index]
			add_log("Turret firing mode changed to [current_mode.name]")

/obj/item/circuitboard/sentry_turret
	name = "circuitboard (sentry turret)"
	board_type = "machine"
	build_path = /obj/machinery/turret/network
	origin_tech = "{'programming':5,'combat':5,'engineering':4}"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 2)

#undef MAX_TURRET_LOGS
