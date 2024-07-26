/obj/item/gun/custom_ka
	name = null // Abstract
	var/official_name
	var/custom_name
	desc = "A kinetic accelerator assembly."
	icon = 'icons/obj/guns/kinetic_accelerators.dmi'
	icon_state = ""
	item_state = "kineticgun"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	matter = list(DEFAULT_WALL_MATERIAL = 2000)
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_MATERIAL = 2, TECH_ENGINEERING = 2)

	burst = 1
	fire_delay = 0 	//delay after shooting before the gun can be used again
	burst_delay = 2	//delay between shots, if firing in bursts
	move_delay = 1
	fire_sound = 'sound/effects/weapons/energy/kinetic_accel.ogg'
	fire_sound_text = "blast"

	screen_shake = 0
	silenced = FALSE
	//muzzle_flash = 3

	accuracy = 0   //accuracy is measured in tiles. +1 accuracy means that everything is effectively one tile closer for the purpose of miss chance, -1 means the opposite. launchers are not supported, at the moment.
	scoped_accuracy = null
	dispersion = list(0)
	//reliability = 100

	var/obj/item/projectile/projectile_type = /obj/item/projectile/kinetic

	sel_mode = 1 //index of the currently selected mode
	firemodes = list()

	var/require_wield = FALSE

	var/build_name = ""

	//Custom stuff
	var/obj/item/custom_ka_upgrade/cells/installed_cell
	var/obj/item/custom_ka_upgrade/barrels/installed_barrel
	var/obj/item/custom_ka_upgrade/upgrade_chips/installed_upgrade_chip

	var/damage_increase = 0 //The amount of damage this weapon does, in total.
	var/firedelay_increase = 0 //How long it takes for the weapon to fire, in deciseconds.
	var/range_increase = 0
	var/recoil_increase = 0 //The amount of recoil this weapon has, in total.
	var/cost_increase = 0 //How much energy to take per shot, in total.
	var/cell_increase = 0 //The total increase in battery. This actually doesn't do anything and is just a display variable. Power is handled in their own parts.
	var/capacity_increase = 0 //How much/big this frame can hold a mod.
	var/mod_limit_increase = 0 //Maximum size of a mod this frame can take.
	var/aoe_increase = 0

	var/current_highest_mod = 0

	var/is_emagged = 0
	var/is_emped = 0

	var/can_disassemble_cell = TRUE
	var/can_disassemble_barrel = TRUE

	var/static/list/warning_messages = list(
		"ERROR CODE: ERROR CODE",
		"ERROR CODE: PLEASE REPORT THIS",
		"ERROR CODE: OH GOD HELP",
		"ERROR CODE: 404 NOT FOUND",
		"ERROR CODE: KEYBOARD NOT FOUND, PRESS F11 TO CONTINUE",
		"ERROR CODE: CLICK OKAY TO CONTINUE",
		"ERROR CODE: AN ERROR HAS OCCURED TRYING TO DISPLAY AN ERROR CODE",
		"ERROR CODE: NO ERROR CODE FOUND",
		"ERROR CODE: LOADING.."
	)

/obj/item/gun/custom_ka/Initialize()
	. = ..()

	START_PROCESSING(SSprocessing, src)

	if(installed_cell)
		installed_cell = new installed_cell(src)
	if(installed_barrel)
		installed_barrel = new installed_barrel(src)
	if(installed_upgrade_chip)
		installed_upgrade_chip = new installed_upgrade_chip(src)

	update_stats()
	update_icon()

/obj/item/gun/custom_ka/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/obj/item/gun/custom_ka/think()
	if(installed_cell)
		installed_cell.on_update(src)

	if(installed_barrel)
		installed_barrel.on_update(src)

	if(installed_upgrade_chip)
		installed_upgrade_chip.on_update(src)

/obj/item/gun/custom_ka/examine(mob/user, infix)
	. = ..()
	if(installed_upgrade_chip)
		. += "It is equipped with \the [installed_barrel], \the [installed_cell], and \the [installed_upgrade_chip]."
	else if(installed_barrel)
		. += "It is equipped with \the [installed_barrel] and \the [installed_cell]. It has space for an upgrade chip."
	else if(installed_cell)
		. += "It is equipped with \the [installed_cell]. The assembly lacks a barrel installation."

	if(installed_barrel)
		if(custom_name)
			. += "[custom_name] is written crudely in pen across the side, covering up the offical designation."
		else
			. += "The official designation \"[official_name]\" is etched neatly on the side."

	if(installed_cell)
		. += "It has <b>[get_ammo()]</b> shots remaining."

/obj/item/gun/custom_ka/proc/get_ammo()
	if(!installed_cell || !installed_cell.stored_charge)
		return 0

	return round(installed_cell.stored_charge / cost_increase)

/obj/item/gun/custom_ka/emag_act(remaining_charges, mob/user)
	show_splash_text(user, "Safeties overriden!", SPAN_WARNING("You override the safeties on the [src]..."))
	is_emagged = TRUE
	return 1

/obj/item/gun/custom_ka/emp_act(severity)
	. = ..()

	is_emped = TRUE
	return TRUE

/obj/item/gun/custom_ka/Fire(atom/target, atom/movable/firer, clickparams, pointblank = FALSE, reflex = FALSE, target_zone = BP_CHEST)
	if(require_wield && !is_held_twohanded(firer))
		to_chat(firer, SPAN_WARNING("\The [src] is too heavy to fire with one hand!"))
		return

	//if(!fire_checks(target,user,clickparams,pointblank,reflex))
	//	return

	var/warning_message
	var/disaster

	if((is_emped && prob(10)) || prob(1))
		if(is_emped)
			warning_message = pick(warning_messages)
			spark()
	else if(!installed_cell || !installed_barrel)
		if(!is_emagged || (is_emped && prob(5)) )
			warning_message = "ERROR CODE: 0"
		else
			disaster = "spark"
	else if(damage_increase <= 0)
		if(!is_emagged || (is_emped && prob(5)))
			warning_message = "ERROR CODE: 100"
		else
			disaster = "overheat"
	else if(range_increase < 2)
		if(!is_emagged || (is_emped && prob(5)))
			warning_message = "ERROR CODE: 101"
		else
			disaster = "explode"
	else if(cost_increase > cell_increase)
		if(!is_emagged || (is_emped && prob(5)))
			warning_message = "ERROR CODE: 102"
		else
			disaster = "overheat"
	else if(capacity_increase < 0)
		if(!is_emagged || (is_emped && prob(5)))
			warning_message = "ERROR CODE: 201"
		else
			disaster = "overheat"
	else if(mod_limit_increase < current_highest_mod)
		if(is_emagged || (is_emped && prob(5)))
			warning_message = "ERROR CODE: 202"
		else
			disaster = "overheat"

	if(warning_message)
		to_chat(firer, "<b>[src]</b> flashes, \"[warning_message].\"")
		playsound(src,'sound/machines/buzz-two.ogg', 50, 0)
		handle_click_empty(firer)
		var/mob/user = firer
		user?.setClickCooldown(DEFAULT_ATTACK_COOLDOWN * 4)
		return
	else
		switch(disaster)
			if("spark")
				to_chat(firer, SPAN_DANGER("\The [src] sparks!"))
				spark()
			if("overheat")
				to_chat(firer, SPAN_DANGER("\The [src] turns red hot!"))
				var/mob/living/L = firer
				L?.IgniteMob()
			if("explode")
				to_chat(firer, SPAN_DANGER("\The [src] violently explodes!"))
				explosion(get_turf(src.loc), 0, 1, 2, 4)
				qdel(src)

	//actually attempt to shoot
	var/turf/targloc = get_turf(target) //cache this in case target gets deleted during shooting, e.g. if it was a securitron that got destroyed.
	for(var/i in 1 to burst)
		var/obj/projectile = consume_next_projectile(firer)
		if(!projectile)
			handle_click_empty(firer)
			break

		process_accuracy(projectile, firer, target, i, is_held_twohanded(firer))

		if(pointblank)
			process_point_blank(projectile, firer, target)

		if(process_projectile(projectile, firer, target, target_zone, clickparams))
			handle_post_fire(firer, target, pointblank, reflex, i == burst)
			update_icon()

		if(i < burst)
			sleep(burst_delay)

		if(!(target && target.loc))
			target = targloc
			pointblank = 0

	update_held_icon()
	//update timing
	var/mob/user = firer
	user?.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	user?.setMoveCooldown(move_delay)
	next_fire_time = world.time + fire_delay

/obj/item/gun/custom_ka/consume_next_projectile()
	if(!installed_cell || !installed_barrel || installed_cell.stored_charge < cost_increase)
		return null

	installed_cell.stored_charge -= cost_increase

	//Send fire events
	if(installed_cell)
		installed_cell.on_fire(src)
	if(installed_upgrade_chip)
		installed_upgrade_chip.on_fire(src)
	if(installed_barrel)
		installed_barrel.on_fire(src)

	var/turf/T = get_turf(src)

	if(T)
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = (environment)? environment.return_pressure() : 0
		if(ispath(installed_barrel.projectile_type, /obj/item/projectile/kinetic))
			var/obj/item/projectile/kinetic/shot_projectile = new installed_barrel.projectile_type(get_turf(src))
			shot_projectile.damage = damage_increase
			shot_projectile.range = range_increase
			shot_projectile.aoe = max(1, aoe_increase)
			//If pressure is greater than about 40 kPA, reduce damage
			if(pressure > ONE_ATMOSPHERE*0.4)
				shot_projectile.base_damage = 5
				return shot_projectile
			else
				shot_projectile.base_damage = damage_increase
				return shot_projectile

		if(ispath(installed_barrel.projectile_type, /obj/item/projectile/beam))
			var/obj/item/projectile/beam/shot_projectile = new installed_barrel.projectile_type(get_turf(src))
			shot_projectile.damage = damage_increase
			shot_projectile.range = range_increase
			return shot_projectile

/obj/item/gun/custom_ka/update_icon()
	. = ..()
	ClearOverlays()
	var/name_list = list("","","","")

	name_list[3] = src.build_name

	if(installed_upgrade_chip)
		AddOverlays(installed_upgrade_chip.icon_state)
		name_list[4] = installed_upgrade_chip.build_name

	if(installed_cell)
		AddOverlays(installed_cell.icon_state)
		name_list[1] = installed_cell.build_name

	if(installed_barrel)
		AddOverlays(installed_barrel.icon_state)
		name_list[2] = installed_barrel.build_name

	official_name = sanitize(jointext(name_list," "))

	if(installed_barrel)
		if(custom_name)
			name = custom_name
		else
			name = "custom kinetic accelerator"
	else
		name = initial(name)

/obj/item/gun/custom_ka/proc/update_stats()
	//pls don't bully me for this code
	damage_increase = initial(damage_increase)
	firedelay_increase = initial(firedelay_increase)
	range_increase = initial(range_increase)
	recoil_increase = initial(recoil_increase)
	cost_increase = initial(cost_increase)
	cell_increase = initial(cell_increase)
	capacity_increase = initial(capacity_increase)
	mod_limit_increase = initial(mod_limit_increase)
	aoe_increase = initial(aoe_increase)

	if(installed_cell)
		damage_increase += installed_cell.damage_increase
		firedelay_increase += installed_cell.firedelay_increase
		range_increase += installed_cell.range_increase
		recoil_increase += installed_cell.recoil_increase
		cost_increase += installed_cell.cost_increase
		cell_increase += installed_cell.cell_increase
		capacity_increase += installed_cell.capacity_increase
		mod_limit_increase += installed_cell.mod_limit_increase
		aoe_increase += installed_cell.aoe_increase
		current_highest_mod = max(-installed_cell.capacity_increase,current_highest_mod)

	if(installed_barrel)
		fire_sound = installed_barrel.fire_sound
		damage_increase += installed_barrel.damage_increase
		firedelay_increase += installed_barrel.firedelay_increase
		range_increase += installed_barrel.range_increase
		recoil_increase += installed_barrel.recoil_increase
		cost_increase += installed_barrel.cost_increase
		cell_increase += installed_barrel.cell_increase
		capacity_increase += installed_barrel.capacity_increase
		mod_limit_increase += installed_barrel.mod_limit_increase
		aoe_increase += installed_barrel.aoe_increase
		current_highest_mod = max(-installed_barrel.capacity_increase,current_highest_mod)

	if(installed_upgrade_chip)
		damage_increase += installed_upgrade_chip.damage_increase
		firedelay_increase += installed_upgrade_chip.firedelay_increase
		range_increase += installed_upgrade_chip.range_increase
		recoil_increase += installed_upgrade_chip.recoil_increase
		cost_increase += installed_upgrade_chip.cost_increase
		cell_increase += installed_upgrade_chip.cell_increase
		capacity_increase += installed_upgrade_chip.capacity_increase
		mod_limit_increase += installed_upgrade_chip.mod_limit_increase
		aoe_increase += installed_upgrade_chip.aoe_increase
		current_highest_mod = max(-installed_upgrade_chip.capacity_increase,current_highest_mod)

	//Explot fixing
	cell_increase = max(cell_increase,0)
	cost_increase = max(cost_increase,1)
	recoil_increase = max(recoil_increase,1)
	firedelay_increase = max(firedelay_increase,0.125 SECONDS)

	aoe_increase += round(damage_increase/30)
	aoe_increase = max(1, aoe_increase)

	//Gun stats
	//recoil = recoil_increase*0.25
	//recoil = recoil*0.5

	//fire_delay = firedelay_increase
	//fire_delay_wielded = accuracy * 0.9

	//accuracy = round(recoil_increase*0.25)
	//accuracy_wielded = accuracy * 0.5

/obj/item/gun/custom_ka/proc/unique_action(mob/user)
	if(!is_held_twohanded())
		to_chat(user,SPAN_WARNING("You must be holding \the [src] with two hands to do this!"))
		return

	if(installed_cell)
		installed_cell.attack_self(user)
	if(installed_barrel)
		installed_barrel.attack_self(user)
	if(installed_upgrade_chip)
		installed_upgrade_chip.attack_self(user)

/obj/item/gun/custom_ka/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/pen))
		custom_name = sanitize(tgui_input_text(user, "Enter a custom name for your [name]", "Set Name"))
		to_chat(user, "You label \the [name] as \"[custom_name]\"")
		update_icon()
		return TRUE

	else if(isWrench(attacking_item))
		if(installed_upgrade_chip)
			attacking_item.play_tool_sound(get_turf(src), 50)
			to_chat(user,"You remove \the [installed_upgrade_chip].")
			installed_upgrade_chip.forceMove(user.loc)
			installed_upgrade_chip.update_icon()
			installed_upgrade_chip = null
			update_stats()
			update_icon()
		else if(installed_barrel && can_disassemble_barrel)
			attacking_item.play_tool_sound(get_turf(src), 50)
			to_chat(user,"You remove \the [installed_barrel].")
			installed_barrel.forceMove(user.loc)
			installed_barrel.update_icon()
			installed_barrel = null
			update_stats()
			update_icon()
		else if(installed_cell && can_disassemble_cell)
			attacking_item.play_tool_sound(get_turf(src), 50)
			to_chat(user,"You remove \the [installed_cell].")
			installed_cell.forceMove(user.loc)
			installed_cell.update_icon()
			installed_cell = null
			update_stats()
			update_icon()
		else
			to_chat(user,"There is nothing to remove from \the [src].")
		return TRUE
	else if(istype(attacking_item,/obj/item/custom_ka_upgrade/cells))
		if(installed_cell)
			to_chat(user,"There is already \an [installed_cell] installed.")
		else
			var/obj/item/custom_ka_upgrade/cells/tempvar = attacking_item
			installed_cell = tempvar
			user.drop(installed_cell, src)
			installed_cell.forceMove(src)
			update_stats()
			update_icon()
			playsound(src,'sound/items/Wirecutter.ogg', 50, 0)
		return TRUE
	else if(istype(attacking_item,/obj/item/custom_ka_upgrade/barrels))
		if(!installed_cell)
			to_chat(user,"You must install a power cell before installing \the [attacking_item].")
		else if(installed_barrel)
			to_chat(user,"There is already \an [installed_barrel] installed.")
		else
			var/obj/item/custom_ka_upgrade/barrels/tempvar = attacking_item
			installed_barrel = tempvar
			user.drop(installed_barrel, src)
			installed_barrel.forceMove(src)
			update_stats()
			update_icon()
			playsound(src,'sound/items/Wirecutter.ogg', 50, 0)
		return TRUE
	else if(istype(attacking_item,/obj/item/custom_ka_upgrade/upgrade_chips))
		if(!installed_cell || !installed_barrel)
			to_chat(user,"A barrel and a cell need to be installed before you install \the [attacking_item].")
		else if(installed_upgrade_chip)
			to_chat(user,"There is already \an [installed_upgrade_chip] installed.")
		else if(installed_cell.disallow_chip == TRUE)
			to_chat(user,"\The [installed_cell] prevents you from installing \the [attacking_item]!")
		else if(installed_barrel.disallow_chip == TRUE)
			to_chat(user,"\The [installed_barrel] prevents you from installing \the [attacking_item]!")
		else
			var/obj/item/custom_ka_upgrade/upgrade_chips/tempvar = attacking_item
			installed_upgrade_chip = tempvar
			user.drop(installed_upgrade_chip, src)
			installed_upgrade_chip.forceMove(src)
			update_stats()
			update_icon()
			playsound(src,'sound/items/Wirecutter.ogg', 50, 0)
		return TRUE

	if(installed_cell)
		installed_cell.attackby(attacking_item,user)
		return TRUE
	if(installed_barrel)
		installed_barrel.attackby(attacking_item,user)
		return TRUE
	if(installed_upgrade_chip)
		installed_upgrade_chip.attackby(attacking_item,user)
		return TRUE

/obj/item/gun/custom_ka/proc/spark()
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(3, 0, loc)
	spark_system.start()
