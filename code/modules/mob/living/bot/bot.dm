/// How many times bot will try to find a path from the same X,Y before becoming inactive
#define MAX_SAMEPOS_COUNT 15

/mob/living/bot
	name = "Bot"
	health = 20
	maxHealth = 20
	icon = 'icons/obj/aibots.dmi'
	universal_speak = TRUE
	density = FALSE
	/// Botcard for opening doors
	var/obj/item/card/id/botcard = null
	/// List of accesses that will be transfered to a newly created var/botcard on init
	var/list/botcard_access = list()
	/// Whether this bot is on or off
	var/on = TRUE
	/// State of the maintenance panel
	var/open = FALSE
	/// Whether the maintenance panel is locked or not
	var/locked = TRUE
	var/emagged = FALSE
	var/busy = FALSE
	var/light_strength = 3

	/// Virtual access scanner. Accessess of possible perpetrators are checked against this obj's access lists.
	var/obj/access_scanner = null
	/// Accesses for var/access scanner.
	var/list/req_access = list()
	/// Accesses for var/access scanner.
	var/list/req_one_access = list()

	/// Will stop AI behavior if pulled
	var/wait_if_pulled = TRUE // Only applies to moving to the target

	var/will_patrol = FALSE // If set to 1, will patrol, duh
	var/patrol_speed = 1 // How many times per tick we move when patrolling
	var/target_speed = 2 // Ditto for chasing the target
	var/min_target_dist = 1 // How close we try to get to the target
	var/max_target_dist = 50 // How far we are willing to go
	var/max_patrol_dist = 250
	var/RequiresAccessToToggle = 0 // If 1, will check access to be turned on/off

	var/target_patience = 5
	var/frustration = 0
	var/max_frustration = 0

/mob/living/bot/Initialize()
	. = ..()

	botcard = new /obj/item/card/id (src)
	botcard.access = botcard_access.Copy()

	access_scanner = new /obj(src)
	access_scanner.req_access = req_access.Copy()
	access_scanner.req_one_access = req_one_access.Copy()

	if(on)
		turn_on()
	else
		turn_off()

/mob/living/bot/Life()
	..()

	if(health <= 0)
		death()
		return

	weakened = 0
	stunned = 0
	paralysis = 0

	update_icons()

/mob/living/bot/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		set_stat(CONSCIOUS)
	else
		health = maxHealth - getFireLoss() - getBruteLoss()
	setOxyLoss(0)
	setToxLoss(0)

/mob/living/bot/adjustBruteLoss(amount)
	if(amount > 0)
		health -= amount

/mob/living/bot/adjustFireLoss(amount)
	if(amount > 0)
		health -= amount

/mob/living/bot/death()
	stat = DEAD
	explode()

/mob/living/bot/attackby(obj/item/O, mob/user)
	if(O.get_id_card())
		if(access_scanner.allowed(user) && !open)
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked." : "unlocked."]</span>")
			//Interact(usr)
		else if(open)
			to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	else if(isScrewdriver(O))
		if(!locked)
			open = !open
			to_chat(user, "<span class='notice'>Maintenance panel is now [open ? "opened" : "closed"].</span>")
			//Interact(usr)
		else
			to_chat(user, "<span class='notice'>You need to unlock the controls first.</span>")
		return
	else if(isWelder(O))
		if(health < maxHealth)
			if(open)
				health = min(maxHealth, health + 10)
				user.visible_message("<span class='notice'>\The [user] repairs \the [src].</span>","<span class='notice'>You repair \the [src].</span>")
			else
				to_chat(user, "<span class='notice'>Unable to repair with the maintenance panel closed.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] does not need a repair.</span>")
		return
	else
		..()

/mob/living/bot/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species?.can_shred(H) && H.a_intent == "harm")
			attack_generic(H, rand(10, 20), "slashes at")
			return

/mob/living/bot/say(message)
	var/verb = "beeps"

	message = sanitize(message)

	..(message, null, verb)

/mob/living/bot/Bump(atom/A)
	if(on && botcard && istype(A, /obj/machinery/door))
		var/obj/machinery/door/D = A
		if(!istype(D, /obj/machinery/door/firedoor) && !istype(D, /obj/machinery/door/blast) && D.check_access(botcard))
			D.open()
	else
		..()

/mob/living/bot/emag_act(remaining_charges, mob/user)
	return 0

/mob/living/bot/proc/turn_on()
	if(stat)
		return FALSE

	on = TRUE
	set_light(0.5, 0.1, light_strength)
	update_icons()
	return TRUE

/mob/living/bot/proc/turn_off()
	on = FALSE
	set_light(0)
	update_icons()

/mob/living/bot/proc/explode()
	qdel(src)

/******************************************************************/
// Navigation procs
// Used for A-star pathfinding


// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(obj/item/card/id/ID)
	var/L[] = new()

	//	for(var/turf/simulated/t in oview(src,1))

	for(var/d in GLOB.cardinal)
		var/turf/simulated/T = get_step(src, d)
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L


// Returns true if a link between A and B is blocked
// Movement through doors allowed if ID has access
/proc/LinkBlockedWithAccess(turf/A, turf/B, obj/item/card/id/ID)

	if(A == null || B == null) return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlockedWithAccess(A,iStep, ID) && !LinkBlockedWithAccess(iStep,B,ID))
			return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlockedWithAccess(A,pStep,ID) && !LinkBlockedWithAccess(pStep,B,ID))
			return 0
		return 1

	if(DirBlockedWithAccess(A,adir, ID))
		return 1

	if(DirBlockedWithAccess(B,rdir, ID))
		return 1

	for(var/obj/O in B)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.atom_flags & ATOM_FLAG_CHECKS_BORDER))
			return 1

	return 0

// Returns true if direction is blocked from loc
// Checks doors against access with given ID
/proc/DirBlockedWithAccess(turf/loc,dir,obj/item/card/id/ID)
	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue

		if(D.dir == SOUTHWEST)
			return TRUE

		if(D.dir == dir)
			return TRUE

	for(var/obj/machinery/door/D in loc)
		if(!D.density)
			continue

		if(istype(D, /obj/machinery/door/window))
			if(dir & D.dir)
				return !D.check_access(ID)

			//if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return !D.check_access(ID)
			//if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return !D.check_access(ID)
		else return !D.check_access(ID)	// it's a real, air blocking door
	return 0
