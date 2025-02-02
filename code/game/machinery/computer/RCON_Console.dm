/obj/machinery/computer/rcon
	name = "\improper RCON console"
	desc = "Console used to remotely control machinery."
	icon_keyboard = "power_key"
	icon_screen = "ai-fixer"
	light_color = "#a97faa"
	circuit = /obj/item/circuitboard/rcon_console
	req_one_access = list(access_engine)
	var/current_tag = null
	var/datum/nano_module/rcon/rcon

/obj/machinery/computer/rcon/New()
	..()
	rcon = new(src)

/obj/machinery/computer/rcon/Destroy()
	qdel(rcon)
	rcon = null

	return ..()

// Proc: attack_hand()
// Parameters: 1 (user - Person which clicked this computer)
// Description: Opens UI of this machine.
/obj/machinery/computer/rcon/attack_hand(mob/user)
	..()
	ui_interact(user)

// Proc: ui_interact()
// Parameters: 4 (standard NanoUI parameters)
// Description: Uses dark magic (NanoUI) to render this machine's UI
/obj/machinery/computer/rcon/ui_interact(mob/user, ui_key = "rcon", datum/nanoui/ui = null, force_open = 1)
	rcon.ui_interact(user, ui_key, ui, force_open)

/obj/machinery/computer/rcon/on_update_icon()
	..()
	if(is_operable())
		AddOverlays(OVERLAY('icons/obj/computer.dmi', "ai-fixer-empty"))
