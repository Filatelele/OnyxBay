/obj/item/fighter_component/primary
	name = "Fuck you"
	slot = HARDPOINT_SLOT_PRIMARY
	fire_mode = FIRE_MODE_ANTI_AIR
	var/overmap_select_sound = 'sound/effects/ship/pdc_start.ogg'
	var/overmap_firing_sounds = list('sound/effects/fighters/autocannon.ogg')
	var/accepted_ammo = /obj/item/ammo_magazine
	var/obj/item/ammo_magazine/magazine = null
	var/list/ammo = list()
	var/burst_size = 1
	var/fire_delay = 0
	var/allowed_roles = OVERMAP_USER_ROLE_GUNNER
	var/bypass_safety = FALSE

/obj/item/fighter_component/primary/dump_contents()
	. = ..()
	for(var/atom/movable/AM as() in .)
		if(AM == magazine)
			magazine = null
			ammo = list()
			playsound(loc, 'sound/effects/ship/mac_load.ogg', 100, 1)

/obj/item/fighter_component/primary/get_ammo()
	return length(ammo)

/obj/item/fighter_component/primary/get_max_ammo()
	return magazine ? magazine.max_ammo : 500 //Default.

/obj/item/fighter_component/primary/load(obj/structure/overmap/target, atom/movable/AM)
	if(!istype(AM, accepted_ammo))
		return FALSE

	if(magazine)
		if(magazine.stored_ammo.len >= magazine.max_ammo)
			return FALSE

		else
			magazine.forceMove(get_turf(target))
	AM.forceMove(src)
	magazine = AM
	ammo = magazine.stored_ammo
	playsound(target, 'sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/primary/fire(obj/structure/overmap/target)
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE

	if(!ammo.len)
		//F.relay('sound/weapons/gun_dry_fire.ogg')
		return FALSE

	var/obj/item/ammo_casing/chambered = ammo[ammo.len]
	var/datum/ship_weapon/SW = F.weapon_types[fire_mode]
	SW.default_projectile_type = chambered.projectile_type
	SW.fire_fx_only(target)
	ammo -= chambered
	qdel(chambered)
	return TRUE

/obj/item/fighter_component/primary/on_install(obj/structure/overmap/target)
	. = ..()
	if(!fire_mode)
		return FALSE

	var/datum/ship_weapon/SW = target.weapon_types[fire_mode]
	SW.overmap_firing_sounds = overmap_firing_sounds
	SW.overmap_select_sound = overmap_select_sound
	SW.burst_size = burst_size
	SW.fire_delay = fire_delay
	SW.allowed_roles = allowed_roles

/obj/item/fighter_component/primary/remove_from(obj/structure/overmap/target)
	. = ..()
	magazine = null
	ammo = list()

//Dumbed down proc used to allow fighters to fire their weapons in a sane way.
/datum/ship_weapon/proc/fire_fx_only(atom/target, lateral = FALSE)
	if(overmap_firing_sounds)
		var/sound/chosen = pick(overmap_firing_sounds)
		holder.relay_to_nearby(chosen)

	holder.fire_projectile(default_projectile_type, target, lateral = lateral)

/obj/structure/overmap/proc/fire_projectile(proj_type, atom/target, speed=null, user_override=null, lateral=FALSE, ai_aim = FALSE, miss_chance=5, max_miss_distance=5, broadside=FALSE) //Fire one shot. Used for big, hyper accelerated shots rather than PDCs
	if(!z || QDELETED(src))
		return FALSE

	var/turf/T = get_center()
	var/obj/item/projectile/proj = new proj_type(T)
	if(ai_aim && !proj.can_home && !proj.hitscan)
		target = calculate_intercept(target, proj, miss_chance=miss_chance, max_miss_distance=max_miss_distance)
	proj.starting = T
	if(user_override)
		proj.firer = user_override
	else if(gunner)
		proj.firer = gunner
	else
		proj.firer = src
	proj.def_zone = "chest"
	proj.original = target
	proj.overmap_firer = src
	proj.pixel_x = round(pixel_x)
	proj.pixel_y = round(pixel_y)
	proj.faction = faction
	if(physics2d && physics2d.collider2d)
		proj.setup_collider()
	if(proj.can_home)	// Handles projectile homing and alerting the target
		if(!isturf(target))
			proj.set_homing_target(target)
		else if((length(target_painted) > 0))
			if(!target_lock) // no selected target, fire at the first one in our list
				proj.set_homing_target(target_painted[1])
			else if(target_painted.Find(target_lock)) // Fire at a manually selected target
				proj.set_homing_target(target_lock)
			else // something fucked up, dump the lock
				target_lock = null
		if(isovermap(proj.homing_target))
			var/obj/structure/overmap/overmap_target = proj.homing_target
			overmap_target.on_missile_lock(src, proj)

	LAZYINITLIST(proj.impacted) //The spawn call after this might be causing some issues so the list should exist before async actions.

	spawn()
		proj.preparePixelProjectileOvermap(target, src, null, round((rand() - 0.5) * proj.spread), lateral=lateral)
		proj.fire()
		if(!lateral)
			proj.setAngle(src.angle)
		if(broadside)
			if(angle2dir_ship(overmap_angle(src, target) - angle) == SOUTH)
				proj.setAngle(src.angle + rand(90 - proj.spread, 90 + proj.spread))
			else
				proj.setAngle(src.angle + rand(270 - proj.spread, 270 + proj.spread))
		//Sometimes we want to override speed.
		if(speed)
			proj.set_pixel_speed(speed)
	//	else
	//		proj.set_pixel_speed(proj.speed)
	return proj
