#define FIRE_INTERCEPTED 2

/datum/ship_weapon
	var/name = "Ship weapon"
	var/default_projectile_type
	var/burst_size = 1
	var/fire_delay
	var/burst_fire_delay = 1
	var/range_modifier
	var/select_alert
	var/failure_alert
	var/list/overmap_firing_sounds
	var/overmap_select_sound
	var/list/weapons = list()
	var/range = 255 //Todo, change this
	var/obj/structure/overmap/holder = null
	var/requires_physical_guns = TRUE //Set this to false for any fighter weapons we may have
	var/lateral = TRUE //Does this weapon need you to face the enemy? Mostly no.
	var/special_fire_proc = null //Override this if you need to replace the firing weapons behaviour with a custom proc. See torpedoes and missiles for this.
	var/screen_shake = 0
	var/firing_arc = null //If this weapon only fires in an arc (for ai ships)
	var/weapon_class = WEAPON_CLASS_HEAVY //Do AIs need to resupply with ammo to use this weapon?
	var/miss_chance = 5 // % chance the AI intercept calculator will be off a step
	var/max_miss_distance = 4 // Maximum number of tiles the AI will miss by
	var/autonomous = FALSE // Is this a gun that can automatically fire? Keep in mind variables selectable and autonomous can both be TRUE
	var/permitted_ams_modes = list( "Anti-ship" = 1, "Anti-missile countermeasures" = 1 ) // Overwrite the list with a specific firing mode if you want to restrict its targets
	var/allowed_roles = OVERMAP_USER_ROLE_GUNNER

	var/next_firetime = 0

	var/ai_fire_delay = 0 // make it fair on the humans who have to reload and stuff

/datum/ship_weapon/New(obj/structure/overmap/source)
	. = ..()
	if(!source)
		qdel_self()
		return

	holder = source
	weapons["loaded"] = list() //Weapons that are armed and ready.
	weapons["all"] = list() //All weapons, regardless of ammo state
	if(istype(holder, /obj/structure/overmap))
		requires_physical_guns = (length(holder.occupying_levels) && !holder.ai_controlled) //AIs don't have physical guns, but anything with linked areas is very likely to.

/datum/ship_weapon/fighter_primary
	name = "Primary Equipment Mount"
	default_projectile_type = null//obj/item/projectile/bullet/light_cannon_round //This is overridden anyway
	burst_size = 1
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	overmap_select_sound = 'sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('sound/effects/fighters/autocannon.ogg')
	select_alert = "<span class='notice'>Primary mount selected.</span>"
	failure_alert = "<span class='warning'>DANGER: Primary mount not responding to fire command.</span>"
	lateral = FALSE
	special_fire_proc = /obj/structure/overmap/proc/primary_fire

/datum/ship_weapon/fighter_secondary
	name = "Secondary Equipment Mount"
	default_projectile_type = null//obj/item/projectile/guided_munition/missile //This is overridden anyway
	burst_size = 1
	fire_delay = 0.5 SECONDS
	range_modifier = 30
	select_alert = "<span class='notice'>Secondary mount selected.</span>"
	failure_alert = "<span class='warning'>DANGER: Secondary mount not responding to fire command.</span>"
	overmap_firing_sounds = list(
		'sound/effects/ship/torpedo.ogg',
		'sound/effects/ship/freespace2/m_shrike.wav',
		'sound/effects/ship/freespace2/m_stiletto.wav',
		'sound/effects/ship/freespace2/m_tsunami.wav',
		'sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'sound/effects/ship/reload.ogg'
	firing_arc = 45 //Broad side of a barn...
	special_fire_proc = /obj/structure/overmap/proc/secondary_fire
	ai_fire_delay = 1 SECONDS
