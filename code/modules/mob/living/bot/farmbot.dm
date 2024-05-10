#define FARMBOT_COLLECT 1
#define FARMBOT_WATER 2
#define FARMBOT_UPROOT 3
#define FARMBOT_NUTRIMENT 4

/mob/living/bot/farmbot
	name = "Farmbot"
	desc = "The botanist's best friend."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "farmbot0"
	health = 50
	maxHealth = 50
	req_one_access = list(access_hydroponics, access_robotics)

	var/action = "" // Used to update icon
	var/waters_trays = 1
	var/refills_water = 1
	var/uproots_weeds = 1
	var/replaces_nutriment = 0
	var/collects_produce = 0
	var/removes_dead = 0

	var/obj/structure/reagent_dispensers/watertank/tank

/mob/living/bot/farmbot/New(newloc, newTank)
	..(newloc)
	if(!newTank)
		newTank = new /obj/structure/reagent_dispensers/watertank(src)
	tank = newTank
	tank.forceMove(src)

/mob/living/bot/farmbot/update_icons()
	if(on && action)
		icon_state = "farmbot_[action]"
	else
		icon_state = "farmbot[on]"

/mob/living/bot/farmbot/explode()
	visible_message("<span class='danger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/material/minihoe(Tsec)
	new /obj/item/reagent_containers/vessel/bucket(Tsec)
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/device/analyzer/plant_analyzer(Tsec)

	if(tank)
		tank.dropInto(Tsec)

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return
// Assembly

/obj/item/farmbot_arm_assembly
	name = "water tank/robot arm assembly"
	desc = "A water tank with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "water_arm"
	var/build_step = 0
	var/created_name = "Farmbot"
	var/obj/tank
	w_class = ITEM_SIZE_NORMAL

/obj/item/farmbot_arm_assembly/New(newloc, theTank)
	..(newloc)
	if(!theTank) // If an admin spawned it, it won't have a watertank it, so lets make one for em!
		tank = new /obj/structure/reagent_dispensers/watertank(src)
	else
		tank = theTank
		tank.forceMove(src)


/obj/structure/reagent_dispensers/watertank/attackby(obj/item/robot_parts/S, mob/user as mob)
	if((!istype(S, /obj/item/robot_parts/l_arm)) && (!istype(S, /obj/item/robot_parts/r_arm)))
		..()
		return
	if(!user.drop(S))
		return
	to_chat(user, "You add the robot arm to [src].")
	qdel(S)
	new /obj/item/farmbot_arm_assembly(loc, src)

/obj/item/farmbot_arm_assembly/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if((istype(W, /obj/item/device/analyzer/plant_analyzer)) && (build_step == 0))
		if(!user.drop(W))
			return
		build_step++
		to_chat(user, "You add the plant analyzer to [src].")
		SetName("farmbot assembly")
		qdel(W)

	else if((istype(W, /obj/item/reagent_containers/vessel/bucket)) && (build_step == 1))
		if(!user.drop(W))
			return
		build_step++
		to_chat(user, "You add a bucket to [src].")
		SetName("farmbot assembly with bucket")
		qdel(W)

	else if((istype(W, /obj/item/material/minihoe)) && (build_step == 2))
		if(!user.drop(W))
			return
		build_step++
		to_chat(user, "You add a minihoe to [src].")
		SetName("farmbot assembly with bucket and minihoe")
		qdel(W)

	else if((isprox(W)) && (build_step == 3))
		build_step++
		to_chat(user, "You complete the Farmbot! Beep boop.")
		var/mob/living/bot/farmbot/S = new /mob/living/bot/farmbot(get_turf(src), tank)
		S.SetName(created_name)
		qdel(W)
		qdel(src)

	else if(istype(W, /obj/item/pen))
		var/t = input(user, "Enter new robot name", name, created_name) as text
		t = sanitize(t, MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return

		created_name = t

/obj/item/farmbot_arm_assembly/attack_hand(mob/user as mob)
	return //it's a converted watertank, no you cannot pick it up and put it in your backpack
