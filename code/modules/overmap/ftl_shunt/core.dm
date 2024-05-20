/obj/machinery/computer/ship/ftl_core
	name = "\improper Thirring Drive manifold"
	desc = "The Lense-Thirring Precession Drive, an advanced method of FTL propulsion that utilizes exotic energy to twist space around the ship. Exotic energy must be supplied via drive pylons."
	//icon = 'icons/obj/machinery/FTL_drive.dmi'
	//icon_state = "core_idle"
	pixel_x = -64
	bound_x = -64
	bound_height = 128
	bound_width = 160
	appearance_flags = PIXEL_SCALE
	icon_screen = null
	icon_keyboard = null
	var/ftl_state = FTL_STATE_IDLE
	var/progress = 0 // charge progress, 0 to req_charge
	var/req_charge = 100
	var/can_cancel_jump = FALSE
	var/max_range = 30000
	var/lockout = FALSE //Used for our end round shenanigains

/obj/machinery/computer/ship/ftl_core/proc/cancel_ftl()
	ftl_state = FTL_STATE_SPOOLING

/obj/machinery/computer/ship/ftl_core/proc/jump(datum/star_system/target_system, force=FALSE)
	ftl_state = FTL_STATE_JUMPING
	linked.begin_jump(target_system, force)
