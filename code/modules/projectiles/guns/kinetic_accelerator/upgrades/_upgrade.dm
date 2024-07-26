/obj/item/custom_ka_upgrade
	name = null
	icon = 'icons/obj/guns/kinetic_accelerators.dmi'
	icon_state = ""
	var/build_name = ""
	var/damage_increase = 0
	var/firedelay_increase = 0
	var/range_increase = 0
	var/recoil_increase = 0
	var/cost_increase = 0
	var/cell_increase = 0
	var/capacity_increase = 0
	var/mod_limit_increase = 0
	var/aoe_increase = 0

	var/is_emagged = 0
	var/is_emped = 0

	var/disallow_chip = FALSE //Prevent installation of an upgrade chip.

/obj/item/custom_ka_upgrade/proc/on_update(obj/item/gun/custom_ka)
	//Do update related things here

/obj/item/custom_ka_upgrade/proc/on_fire(obj/item/gun/custom_ka)
	//Do fire related things here

/obj/item/custom_ka_upgrade/cells
	name = null //Abstract
	icon = 'icons/obj/guns/kinetic_accelerators.dmi'
	icon_state = ""
	damage_increase = 0
	firedelay_increase = 0
	range_increase = 0
	recoil_increase = 0
	cost_increase = 0
	cell_increase = 0
	capacity_increase = 0
	mod_limit_increase = 0
	var/last_pump = 0 // Set to world.time to determine last pump; prevents to_chat spam
	var/stored_charge = 0
	var/pump_restore = 0
	var/pump_delay = 0
	var/is_pumping = FALSE //Prevents from pumping stupidly fast do to a do_after exploit
	origin_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 2, TECH_MAGNET = 2, TECH_POWER=2)

/obj/item/custom_ka_upgrade/barrels
	name = null //Abstract
	icon = 'icons/obj/guns/kinetic_accelerators.dmi'
	icon_state = ""
	damage_increase = 0
	firedelay_increase = 0
	range_increase = 0
	recoil_increase = 0
	cost_increase = 0
	cell_increase = 0
	capacity_increase = 0
	mod_limit_increase = 0
	var/fire_sound = 'sound/effects/weapons/energy/kinetic_accel.ogg'
	var/projectile_type = /obj/item/projectile/kinetic
	origin_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 2, TECH_MAGNET = 2)

/obj/item/custom_ka_upgrade/upgrade_chips
	name = null //Abstract
	icon = 'icons/obj/guns/kinetic_accelerators.dmi'
	damage_increase = 0
	firedelay_increase = 0
	range_increase = 0
	recoil_increase = 0
	cost_increase = 0
	cell_increase = 0
	capacity_increase = 0
	mod_limit_increase = 0

	origin_tech = list(TECH_POWER = 4, TECH_MAGNET = 4, TECH_DATA = 4)


/obj/item/device/kinetic_analyzer
	name = "kinetic analyzer"
	desc = "Analyzes the kinetic accelerator and prints useful information on it's statistics."
	icon = 'icons/obj/device.dmi'
	icon_state = "kinetic_anal"


/obj/item/device/kinetic_analyzer/afterattack(atom/target, mob/living/user, proximity, params)
	user.visible_message(
		SPAN_WARNING("\The [user] scans \the [target] with \the [src]."),
		SPAN_WARNING("You scan \the [target] with \the [src].")
	)

	if(istype(target, /obj/item/gun/custom_ka))
		playsound(src, 'sound/machines/ping.ogg', 10, 1)

		var/obj/item/gun/custom_ka/ka = target

		var/total_message = "<b>Kinetic Accelerator Stats:</b><br>\
		Damage Rating: [ka.damage_increase*0.1]MJ<br>\
		Energy Rating: [ka.cost_increase]MJ<br>\
		Cell Rating: [ka.cell_increase]MJ<br>\
		Fire Delay: [ka.firedelay_increase]<br>\
		Range: [ka.range_increase]<br>\
		Recoil Rating: [ka.recoil_increase]kJ<br>\
		<b>Software Stats:</b><br>\
		Software Version: [ka.mod_limit_increase].[ka.mod_limit_increase*32 % 10].[ka.mod_limit_increase*64 % 324]<br>\
		Available Power Flow: [ka.capacity_increase*10]kW<br>"

		to_chat(user, SPAN_NOTICE("[total_message]"))
	else
		to_chat(user, SPAN_NOTICE("Nothing happens."))

	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
