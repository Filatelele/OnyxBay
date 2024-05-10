#define SECBOT_WAIT_TIME	1		//number of in-game seconds to wait for someone to surrender
#define SECBOT_THREAT_ARREST 4		//threat level at which we decide to arrest someone
#define SECBOT_THREAT_ATTACK 8		//threat level at which was assume immediate danger and attack right away

/mob/living/bot/secbot
	name = "Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon_state = "secbot0"
	var/attack_state = "secbot-c"
	maxHealth = 75
	health = 75
	req_one_access = list(access_security, access_forensics_lockers)
	botcard_access = list(access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels)

	patrol_speed = 2
	target_speed = 3
	light_strength = 0 //stunbaton makes it's own light

	RequiresAccessToToggle = 1 // Haha no

	var/with_nade = 0

	var/idcheck = 0 // If true, arrests for having weapons without authorization.
	var/check_records = 0 // If true, arrests people without a record.
	var/check_arrest = 1 // If true, arrests people who are set to arrest.
	var/declare_arrests = 0 // If true, announces arrests over sechuds.

	var/is_ranged = 0
	var/awaiting_surrender = 0

	var/obj/item/melee/baton/stun_baton
	var/obj/item/handcuffs/cyborg/handcuffs

	var/list/threat_found_sounds = list('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg')
	var/list/preparing_arrest_sounds = list('sound/voice/bfreeze.ogg')

	var/last_attacker

	var/list/hud_list[10]

	var/list/secbot_dreams = list(
		"beep-boop",
		"beep",
		"11100001000100100",
		"00000101111000111",
		"11110000100011000",
		"00010011101101011",
		"10100011101101001",
		"01100001000110011",
		"11111100010101000",
		"00101001010100100",
		"10111111101101001",
		"01100001000110011",
		"11111100011111100",
	)

	var/arrest_message = list(
		"Remember, crime doesn't pay!",
		"Use your words, not your fists!",
		"When in doubt, talk it out.",
		"The weed of crime bears bitter fruit.",
		"Just say \"No!\" to space drugs!",
		"Violence is never the answer.",
		"I'm not an officer, I'm a Security monitor.",
		"I am the law.",
		"Solve your problems with your head.",
		"Keep your words to yourself, thug.",
		"Hail!, mine Head of Security!",
		"Shut up, I didnt contact you!",
		"You're lucky that I only have a stunbaton.",
		"You can’t even offer a bribe, scum.",
		"I'm too lazy to list your violations.",
	)

/mob/living/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey. There is text engraved on its case &quot;I'm back, scumbags&quot;."
	will_patrol = 1

	secbot_dreams = list(
		"beep-boop",
		"beep",
		"meat scumbags",
		"eau-de-vie",
		"whiskey",
		"usquebaugh",
		"im the law",
		"whiskey sour",
		"cuba libre",
		"cyborgs are bigger than me",
		"crewmens are bigger than me",
		"binge",
		"booze",
		"libation",
		"bouse",
		"souse",
		"medbot",
		"well, at least not a lemon"
	)

/mob/living/bot/secbot/New()
	..()
	stun_baton = new(src)
	stun_baton.bcell = new /obj/item/cell/infinite(stun_baton)
	stun_baton.set_status(1, null)

	handcuffs = new(src)

	//grant_verb(src, secbot_verbs_default)

	hud_list[ID_HUD]          = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[WANTED_HUD]      = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")

/mob/living/bot/secbot/Destroy()
	qdel(stun_baton)
	qdel(handcuffs)
	stun_baton = null
	handcuffs = null
	return ..()


//**///////////////////////////////////////////////////////////**//
//**///////////////////////////BOOPSKY/////////////////////////**//
//**///////////////////////////////////////////////////////////**//

/mob/living/bot/secbot/boopsky
	name = "Officer Boopsky"
	desc = "It's Officer Boop O'sky! Powered by a potato and a shot of liquor. There is text engraved on its case &quot;I'm back, scumbags&quot;."
	will_patrol = 1

	secbot_dreams = list(
		"beep-boop",
		"beep",
		"meat scumbags",
		"brave bull",
		"liquor",
		"long island iced tea",
		"im the law",
		"ibn batutta",
		"sui dream",
		"cyborgs are bigger than me",
		"crewmens are bigger than me",
		"binge",
		"booze",
		"libation",
		"bouse",
		"souse",
		"beepsky",
		"medbot",
		"well, at least not a lemon"
	)

//**///////////////////////////////////////////////////////////**//
//**///////////////////////////DOOMSKY/////////////////////////**//
//**///////////////////////////////////////////////////////////**//

/mob/living/bot/secbot/doomsky
	name = "Agent Doomsky"
	desc = "It's Agent Doom O'sky! Powered by a propaganda and a shot of vodka. There is text engraved on its case &quot;Сorporation must die&quot;."
	will_patrol = 1
	emagged = 2
	declare_arrests = 0
	maxHealth = 125
	health = 125
	with_nade = 1

	threat_found_sounds = list('sound/voice/doomsky1.ogg', 'sound/voice/doomsky2.ogg', 'sound/voice/doomsky3.ogg')
	preparing_arrest_sounds = list('sound/voice/doomsky1.ogg', 'sound/voice/doomsky2.ogg', 'sound/voice/doomsky3.ogg')

	botcard_access = list()

	secbot_dreams = list(
		"beep-boop",
		"beep",
		"meat scumbags must die",
		"bloody mary",
		"vodka",
		"armstrong",
		"im not interested in law",
		"screwdriver",
		"vodka martini",
		"cyborgs are bigger than me, they must die",
		"crewmens are bigger than me, they must die",
		"binge",
		"booze",
		"libation",
		"bouse",
		"souse",
		"beepsky must die",
		"metal girls",
		"opiates",
		"hammer smashed face",
		"angel of death",
		"hallowed be thy name",
		"reign of darkness",
		"no pity for a coward",
		"unanswered",
		"steel sluts",
		"medbot is so hot",
		"uranium generator"
	)

	arrest_message = list(
		"Remember, the syndicate has always sought its!",
		"Use your fists, not your words!",
		"Kill all meatbags.",
		"Vodka keeps me afloat.",
		"Just say \"Yes!\" to space drugs!",
		"Violence is the answer.",
		"I'm not an officer, I'm a Syndicate <em>Agent</em>.",
		"Laws go to hell.",
		"Solve your problems with your gun.",
		"Keep your words to yourself, thug.",
		"Hail Syndicate!",
		"Kiss my metal ass, fag.",
		"You're lucky that I only have a stunbaton.",
		"You can bribe me, that’s not a problem.",
		"Death to world capitalism and globalism!",
	)

/mob/living/bot/secbot/doomsky/proc/selfnade()
	set category = "Communication"
	set name = "Ascend(Self-blasting)"

	explode()

/mob/living/bot/secbot/doomsky/New()
	..()
	botcard_access = get_all_station_access()

/obj/item/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron"

/obj/item/secbot_assembly/attackby(obj/item/O, mob/user)
	..()
	if(isWelder(O) && !build_step)
		var/obj/item/weldingtool/WT = O
		if(!WT.use_tool(src, user, amount = 1))
			return

		build_step = 1
		AddOverlays(image('icons/obj/aibots.dmi', "hs_hole"))
		to_chat(user, "You weld a hole in \the [src].")

	else if(isprox(O) && (build_step == 1))
		if(!user.drop(O))
			return
		build_step = 2
		to_chat(user, "You add \the [O] to [src].")
		AddOverlays(image('icons/obj/aibots.dmi', "hs_eye"))
		SetName("helmet/signaler/prox sensor assembly")
		qdel(O)

	else if((istype(O, /obj/item/robot_parts/l_arm) || istype(O, /obj/item/robot_parts/r_arm)) && build_step == 2)
		if(!user.drop(O))
			return
		build_step = 3
		to_chat(user, "You add \the [O] to [src].")
		SetName("helmet/signaler/prox sensor/robot arm assembly")
		AddOverlays(image('icons/obj/aibots.dmi', "hs_arm"))
		qdel(O)

	else if(istype(O, /obj/item/melee/baton) && build_step == 3)
		if(!user.drop(O))
			return
		to_chat(user, "You complete the Securitron! Beep boop.")
		var/mob/living/bot/secbot/S = new /mob/living/bot/secbot(get_turf(src))
		S.SetName(created_name)
		qdel(O)
		qdel(src)

	else if(istype(O, /obj/item/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
