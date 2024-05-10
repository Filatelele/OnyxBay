/mob/living/goblin
	name = "Goblin"
	//icon = 'icons/mob/goblins.dmi'
	icon_state = "goblin_cave"
	var/obj/item/grab/current_grab_type 	// What type of grab they use when they grab someone.
	var/datum/emote/twitch_violently/tv
	var/poise = 65

/mob/living/goblin/Initialize()
	. = ..()
	zone_sel = new (src)
	tv = new (src)
	zone_sel.selecting = BP_GROIN

/mob/living/goblin/proc/make_grab(mob/living/goblin/attacker, mob/living/carbon/human/victim, grab_tag)
	var/obj/item/grab/G

	if(!victim.get_organ(BP_GROIN))
		to_chat(attacker, SPAN("warning", "[victim] is missing the body part you tried to grab!"))
		. = FALSE

	if(!grab_tag)
		G = new attacker.current_grab_type(attacker, victim)
	else
		var/obj/item/grab/given_grab_type = all_grabobjects[grab_tag]
		G = new given_grab_type(attacker, victim)

	if(!G.pre_check())
		qdel(G)
		. = FALSE

	if(G.can_grab())
		G.init()
		. = TRUE
	else
		qdel(G)
		. = FALSE

	if(.)
		var/datum/component/ai_controller/ai = get_component(/datum/component/ai_controller)
		ai.clean_up()
		add_think_ctx("twitch_fuck", CALLBACK(src, nameof(.proc/twitch_fuck)), world.time + 3 SECONDS)
		set_next_think(world.time + 0.5 SECONDS)

/mob/living/goblin/think()
	var/obj/item/grab/grab = locate(/obj/item/grab) in src
	var/ndir = get_dir(src, grab.assailant)
	var/turf/t = get_step(src, ndir)
	grab.upgrade(TRUE)
	Move(t)
	face_atom(t)

/mob/living/goblin/proc/twitch_fuck()
	tv.do_emote(src, "twitch_v")
	set_next_think_ctx("twitch_fuck", world.time + 3)
