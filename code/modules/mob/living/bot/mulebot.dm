#define MULE_IDLE 0
#define MULE_MOVING 1
#define MULE_UNLOAD 2
#define MULE_LOST 3
#define MULE_CALC_MIN 4
#define MULE_CALC_MAX 10
#define MULE_PATH_DONE 11
// IF YOU CHANGE THOSE, UPDATE THEM IN pda.tmpl TOO

/mob/living/bot/mulebot
	name = "Mulebot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	anchored = 1
	density = 1
	health = 150
	maxHealth = 150
	mob_bump_flag = HEAVY

	min_target_dist = 0
	max_target_dist = 250
	target_speed = 3
	max_frustration = 5
	botcard_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)

	var/atom/movable/load

	var/paused = 1
	var/crates_only = 1
	var/auto_return = 1
	var/safety = 1

	var/targetName
	var/turf/home
	var/homeName

	var/global/amount = 0

/mob/living/bot/mulebot/New()
	..()

	var/turf/T = get_turf(loc)
	var/obj/machinery/navbeacon/N = locate() in T
	if(N)
		home = T
		homeName = N.location
	else
		homeName = "Unset"

	suffix = num2text(++amount)
	name = "Mulebot #[suffix]"

/mob/living/bot/mulebot/MouseDrop_T(atom/movable/C, mob/user)
	if(user.stat)
		return

	if(!istype(C) || C.anchored || get_dist(user, src) > 1 || get_dist(src, C) > 1 )
		return

	//load
