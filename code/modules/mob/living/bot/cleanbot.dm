/mob/living/bot/cleanbot
	name = "Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon_state = "cleanbot0"
	req_one_access = list(access_janitor, access_robotics)
	botcard_access = list(access_janitor, access_maint_tunnels)

	var/cleaning = TRUE
	var/screwloose = TRUE
	var/oddbutton = FALSE
	var/blood = TRUE
	var/static/list/target_types = list(
		/obj/effect/decal/cleanable/blood/oil,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/crayon,
		/obj/effect/decal/cleanable/liquid_fuel,
		/obj/effect/decal/cleanable/mucus,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/blood,
	)

/mob/living/bot/cleanbot/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/station_bot/cleanbot)

/obj/item/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3.0
	throwforce = 10.0
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/created_name = "Cleanbot"

/obj/item/bucket_sensor/attackby(obj/item/O, mob/user)
	..()
	if(istype(O, /obj/item/robot_parts/l_arm) || istype(O, /obj/item/robot_parts/r_arm))
		qdel(O)
		var/turf/T = get_turf(loc)
		var/mob/living/bot/cleanbot/A = new /mob/living/bot/cleanbot(T)
		A.SetName(created_name)
		to_chat(user, "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>")
		qdel_self()

	else if(istype(O, /obj/item/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return

		if(!in_range(src, usr) && src.loc != usr)
			return

		created_name = t

/mob/living/bot/cleanbot/update_icons()
	if(busy)
		icon_state = "cleanbot-c"
	else
		icon_state = "cleanbot[on]"

/mob/living/bot/cleanbot/UnarmedAttack(obj/effect/decal/cleanable/D, proximity)
	if(!..())
		return

	if(!istype(D))
		return

	if(D.loc != loc)
		return

	busy = TRUE
	visible_message("\The [src] begins to clean up \the [D]")
	update_icons()
	var/cleantime = istype(D, /obj/effect/decal/cleanable/dirt) ? 10 : 50
	if(do_after(src, cleantime, progress = 0))
		if(istype(loc, /turf/simulated))
			var/turf/simulated/f = loc
			f.dirt = 0

		if(!D)
			return

		qdel(D)
		SEND_SIGNAL(src, SIGNAL_CLEANBOT_CLEANED)
	busy = FALSE
	update_icons()

/mob/living/bot/cleanbot/explode()
	on = FALSE
	visible_message(SPAN_DANGER("\The [src] blows apart!"))
	var/turf/turfloc = get_turf(src)

	new /obj/item/reagent_containers/vessel/bucket(turfloc)
	new /obj/item/device/assembly/prox_sensor(turfloc)
	if(prob(50))
		new /obj/item/robot_parts/l_arm(turfloc)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	explosion(turfloc, 0, 0, 1, 2, FALSE, FALSE)
	qdel_self()

/mob/living/bot/cleanbot/emag_act(remaining_uses, mob/user)
	. = ..()

	if(!screwloose || !oddbutton)
		if(user)
			show_splash_text(user, "Emagged!", SPAN_NOTICE("\The [src] buzzes and beeps!"))
		oddbutton = TRUE
		screwloose = TRUE
		return 1

/obj/item/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3.0
	throwforce = 10.0
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	created_name = "Cleanbot"

/obj/item/bucket_sensor/attackby(obj/item/O, mob/user)
	..()
	if(istype(O, /obj/item/robot_parts/l_arm) || istype(O, /obj/item/robot_parts/r_arm))
		qdel(O)
		var/turf/T = get_turf(loc)
		var/mob/living/bot/cleanbot/A = new /mob/living/bot/cleanbot(T)
		A.SetName(created_name)
		to_chat(user, "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>")
		qdel(src)

	else if(istype(O, /obj/item/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return
		created_name = t
