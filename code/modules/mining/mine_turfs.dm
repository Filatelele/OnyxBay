var/list/mining_walls = list()
var/list/mining_floors = list()

/**********************Mineral deposits**************************/
/turf/unsimulated/mineral
	name = "impassable rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock-dark"
	blocks_air = 1
	density = 1
	opacity = 1

/turf/simulated/mineral //Rock piece
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	initial_gas = null
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = 0 CELSIUS
	var/mined_turf = /turf/simulated/floor/asteroid
	var/ore/mineral
	var/last_act = 0
	var/rock_type = "z"
	var/durability = 100  //How many hits can our rock take

	var/datum/geosample/geologic_data
	var/excavation_level = 0
	var/list/finds
	var/next_rock = 0
	var/archaeo_overlay = ""
	var/excav_overlay = ""
	var/obj/item/last_find
	var/datum/artifact_find/artifact_find
	var/image/ore_overlay
	has_resources = 1
	var/ore_left = 0

/turf/simulated/mineral/medium
	icon_state = "rock-medium"
	rock_type = "-medium"
	durability = 200

/turf/simulated/mineral/hard
	icon_state = "rock-hard"
	rock_type = "-hard"
	durability = 300

/turf/simulated/mineral/Initialize()
	. = ..()
	if (!mining_walls["[src.z]"])
		mining_walls["[src.z]"] = list()
	mining_walls["[src.z]"] += src
	update_icon()
	add_debris_element()

/turf/simulated/mineral/Destroy()
	if (mining_walls["[src.z]"])
		mining_walls["[src.z]"] -= src
	return ..()

/turf/simulated/mineral/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -10, 5, 1)

/turf/simulated/mineral/can_build_cable()
	return !density

/turf/simulated/mineral/is_plating()
	return 1

/turf/simulated/mineral/on_update_icon(update_neighbors)
	if(!mineral)
		SetName(initial(name))
		icon_state = initial(icon_state)
	else
		SetName("[mineral.display_name] deposit")

	ClearOverlays()

	for(var/direction in GLOB.cardinal)
		var/turf/turf_to_check = get_step(src,direction)
		if(update_neighbors && istype(turf_to_check, /turf/simulated/floor/asteroid))
			var/turf/simulated/floor/asteroid/T = turf_to_check
			T.update_icon()
		else if(istype(turf_to_check, /turf/space) || istype(turf_to_check, /turf/simulated/floor) || istype(turf_to_check, /turf/simulated/open))
			var/image/rock_side = image('icons/turf/walls.dmi', "rock_side[rock_type]", dir = turn(direction, 180))
			rock_side.turf_decal_layerise()
			switch(direction)
				if(NORTH)
					rock_side.pixel_y += world.icon_size
				if(SOUTH)
					rock_side.pixel_y -= world.icon_size
				if(EAST)
					rock_side.pixel_x += world.icon_size
				if(WEST)
					rock_side.pixel_x -= world.icon_size
			AddOverlays(rock_side)

	if(ore_overlay)
		AddOverlays(ore_overlay)

	if(excav_overlay)
		AddOverlays(excav_overlay)

	if(archaeo_overlay)
		AddOverlays(archaeo_overlay)

/turf/simulated/mineral/ex_act(severity)
	switch(severity)
		if(2.0)
			if(prob(70))
				if(mineral)
					ore_left -= 1 //Some of the stuff gets blown up
				GetDrilled()
		if(1.0)
			if(mineral)
				ore_left -= 2 //Some of the stuff gets blown up
			GetDrilled()

/turf/simulated/mineral/bullet_act(obj/item/projectile/Proj)

	// Emitter blasts
	if(istype(Proj, /obj/item/projectile/beam/emitter))
		durability -= 30

		if(durability <= 0) // 3 blasts per basic tile
			if(mineral)
				ore_left -= 1
			GetDrilled()

/turf/simulated/mineral/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand, /obj/item/pickaxe/drill)) && (!H.hand))
			attackby(H.l_hand, H)
		else if((istype(H.r_hand, /obj/item/pickaxe/drill)) && H.hand)
			attackby(H.r_hand, H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active, /obj/item/pickaxe/drill))
			attackby(R.module_active, R)

	else if(istype(AM, /obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected, /obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)

/turf/simulated/mineral/proc/MineralSpread()
	if(mineral && mineral.spread)
		for(var/trydir in GLOB.cardinal)
			if(prob(mineral.spread_chance))
				var/turf/simulated/mineral/target_turf = get_step(src, trydir)
				if(istype(target_turf) && !target_turf.mineral)
					target_turf.mineral = mineral
					target_turf.UpdateMineral()
					target_turf.MineralSpread()


/turf/simulated/mineral/proc/UpdateMineral()
	clear_ore_effects()
	ore_overlay = image('icons/obj/mining.dmi', "rock_[mineral.icon_tag]")
	ore_overlay.appearance_flags = DEFAULT_APPEARANCE_FLAGS | RESET_COLOR
	ore_overlay.turf_decal_layerise()
	ore_left = mineral.result_amount
	update_icon()
	if(mineral.icon_tag == "diamond")
		explosion_block = 3

//Not even going to touch this pile of spaghetti
/turf/simulated/mineral/attackby(obj/item/W, mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(usr, FEEDBACK_YOU_LACK_DEXTERITY)
		return

	if(istype(W, /obj/item/device/core_sampler))
		geologic_data.UpdateNearbyArtifactInfo(src)
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return

	if(istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/D = W
		D.scan_atom(user, src)
		return

	if(istype(W, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = W
		user.visible_message(SPAN_NOTICE("\The [user] extends [P] towards [src]."), SPAN_NOTICE("You extend [P] towards [src].</span>"))
		if(do_after(user, 10, src))
			to_chat(user, SPAN_NOTICE("\The [src] has been excavated to a depth of [excavation_level]cm."))
		return

	if(istype(W, /obj/item/pickaxe))
		if(!istype(user.loc, /turf))
			return

		var/obj/item/pickaxe/P = W

		if(!istype(P, /obj/item/pickaxe/drill))
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		else
			var/obj/item/pickaxe/drill/D = P
			if(last_act + D.digspeed > world.time) //Prevents message spam
				return
			last_act = world.time

		playsound(user, P.drill_sound, 20, 1)

		var/newDepth = excavation_level + P.excavation_amount // Used commonly below
		//handle any archaeological finds we might uncover
		var/fail_message = ""
		if(finds && finds.len)
			var/datum/find/F = finds[1]
			if(newDepth > F.excavation_required) // Digging too deep can break the item. At least you won't summon a Balrog (probably)
				fail_message = ". <b>[pick("There is a crunching noise", "[W] collides with some different rock", "Part of the rock face crumbles away", "Something breaks under [W]")]</b>"

		to_chat(user, "<span class='notice'>You are digging \the [src][fail_message].</span>")

		if(fail_message && prob(90))
			if(prob(25))
				excavate_find(prob(5), finds[1])
			else if(prob(50))
				finds.Remove(finds[1])
				if(prob(50))
					artifact_debris()

		if(istype(P, /obj/item/pickaxe/drill))
			var/obj/item/pickaxe/drill/D = P
			if(!do_after(user, D.digspeed, src))
				return
		durability -= P.power
		if(finds && finds.len)
			var/datum/find/F = finds[1]
			if(newDepth == F.excavation_required) // When the pick hits that edge just right, you extract your find perfectly, it's never confined in a rock
				excavate_find(1, F)
			else if(newDepth > F.excavation_required - F.clearance_range) // Not quite right but you still extract your find, the closer to the bottom the better, but not above 80%
				excavate_find(prob(80 * (F.excavation_required - newDepth) / F.clearance_range), F)

		if(istype(P, /obj/item/pickaxe/drill))
			to_chat(user, "<span class='notice'>You finish [P.drill_verb] \the [src].</span>")

		if(newDepth >= 200)
			excavation_level = 200

		if(durability <= 0 || excavation_level >= 200) // This means the rock is mined out fully
			var/obj/structure/boulder/B
			if(artifact_find)
				if(excavation_level > 0 || prob(15))
					//boulder with an artifact inside
					B = new(src)
					if(artifact_find)
						B.artifact_find = artifact_find
				else
					artifact_debris(1)
			else if(prob(5))
				//Empty boulder
				B = new(src)

			if(B)
				GetDrilled(0)
			else
				GetDrilled(1)
			return
		else if(mineral && durability < initial(durability) - initial(durability) / max(ore_left, 1))
			DropMineral(user.dir)

		excavation_level += P.excavation_amount
		var/updateIcon = 0

		//Archaeo overlays
		if(!archaeo_overlay && finds && finds.len)
			var/datum/find/F = finds[1]
			if(F.excavation_required <= excavation_level + F.view_range)
				archaeo_overlay = "overlay_archaeo[rand(1,3)]"
				updateIcon = 1

		else if(archaeo_overlay && (!finds || !finds.len))
			archaeo_overlay = null
			updateIcon = 1

		//There's got to be a better way to do this
		var/update_excav_overlay = FALSE
		if (excavation_level >= 150 && (excavation_level - P.excavation_amount < 150) || \
			excavation_level >= 100 && (excavation_level - P.excavation_amount < 100) || \
			excavation_level >= 50  && (excavation_level - P.excavation_amount < 50))
			update_excav_overlay = TRUE

		//update overlays displaying excavation level
		if( !(excav_overlay && excavation_level > 0) || update_excav_overlay )
			var/excav_quadrant = round(excavation_level / 50) + 1
			excav_overlay = "overlay_excv[excav_quadrant]_[rand(1,3)]"
			updateIcon = 1

		if(updateIcon)
			update_icon()

		//drop some rocks
		next_rock += P.excavation_amount
		while(next_rock > 50)
			next_rock -= 50
			var/obj/item/ore/O = new(src)
			geologic_data.UpdateNearbyArtifactInfo(src)
			O.geologic_data = geologic_data

	if(istype(W, /obj/item/autochisel))

		if(last_act + 80 > world.time)//prevents message spam
			return
		last_act = world.time

		to_chat(user, "<span class='warning'>You start chiselling [src] into a sculptable block.</span>")

		if(!do_after(user,80))
			return

		if (!istype(src, /turf/simulated/mineral))
			return

		to_chat(user, "<span class='notice'>You finish chiselling [src] into a sculptable block.</span>")
		new /obj/structure/sculpting_block(src)
		GetDrilled(1)

	else
		return ..()

/turf/simulated/mineral/proc/clear_ore_effects()
	CutOverlays(ore_overlay)
	ore_overlay = null

/turf/simulated/mineral/proc/DropMineral(direction = null)
	if(!mineral || ore_left <= 0)
		return

	var/obj/item/ore/O = null

	if(direction)
		O = new mineral.ore(get_step(src, turn(direction, 180)))
	else
		O = new mineral.ore(src)

	ore_left -= 1

	if(!ore_left)
		clear_ore_effects()

	if(O && geologic_data && istype(O))
		geologic_data.UpdateNearbyArtifactInfo(src)
		O.geologic_data = geologic_data
	return O

/turf/simulated/mineral/proc/GetDrilled(artifact_fail = 0)
	//var/destroyed = 0 //used for breaking strange rocks
	if(mineral && ore_left)

		while(ore_left > 0)
			DropMineral()

	if(artifact_find && artifact_fail)
		for(var/mob/living/M in range(src, 200))
			to_chat(M, "<font color='red'><b>[pick("A high pitched [pick("keening","wailing","whistle")]","A rumbling noise like [pick("thunder","heavy machinery")]")] somehow penetrates your mind before fading away!</b></font>")

	//Add some rubble,  you did just clear out a big chunk of rock.

	var/turf/simulated/floor/asteroid/N = ChangeTurf(mined_turf)

	if(istype(N))
		N.overlay_detail = "asteroid[rand(0,9)]"
		N.update_icon(1)

	for(var/direction in GLOB.cardinal)
		var/turf/simulated/mineral/T = get_step(src,direction)
		if(istype(T))
			T.update_icon()

/turf/simulated/mineral/proc/excavate_find(prob_clean = 0, datum/find/F)

	//many finds are ancient and thus very delicate - luckily there is a specialised energy suspension field which protects them when they're being extracted
	if(prob(F.prob_delicate))
		var/obj/effect/suspension_field/S = locate() in src
		if(!S)
			visible_message("<span class='danger'>[pick("An object in the rock crumbles away into dust.","Something falls out of the rock and shatters onto the ground.")]</span>")
			finds.Remove(F)
			return

	//with skill and luck, players can cleanly extract finds
	//otherwise, they come out inside a chunk of rock
	if(prob_clean)
		var/find = get_archeological_find_by_findtype(F.find_type)
		new find(src)
	else
		var/obj/item/ore/strangerock/rock = new(src, inside_item_type = F.find_type)
		geologic_data.UpdateNearbyArtifactInfo(src)
		rock.geologic_data = geologic_data

	finds.Remove(F)


/turf/simulated/mineral/proc/artifact_debris(severity = 0)
	//cael's patented random limited drop componentized loot system!
	//sky's patented not-fucking-retarded overhaul!

	//Give a random amount of loot from 1 to 3 or 5, varying on severity.
	for(var/j in 1 to rand(1, 3 + max(min(severity, 1), 0) * 2))
		switch(rand(1,7))
			if(1)
				var/obj/item/stack/rods/R = new(src)
				R.amount = rand(5,25)

			if(2)
				var/obj/item/stack/material/plasteel/R = new(src)
				R.amount = rand(5,25)

			if(3)
				var/obj/item/stack/material/steel/R = new(src)
				R.amount = rand(5,25)

			if(4)
				var/obj/item/stack/material/plasteel/R = new(src)
				R.amount = rand(5,25)

			if(5)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					new /obj/item/material/shard(src)

			if(6)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					new /obj/item/material/shard/plasma(src)

			if(7)
				var/obj/item/stack/material/uranium/R = new(src)
				R.amount = rand(5,25)

/turf/simulated/mineral/random
	name = "Mineral deposit"
	var/mineralChance = 100 //10 //means 10% chance of this plot changing to a mineral deposit
	var/mineralSpawnChanceList = list(
		MATERIAL_URANIUM = 5,
		MATERIAL_PLATINUM = 5,
		MATERIAL_IRON = 35,
		MATERIAL_CARBON = 35,
		MATERIAL_DIAMOND = 1,
		MATERIAL_GOLD = 5,
		MATERIAL_SILVER = 5,
		MATERIAL_PLASMA = 10
		)

/turf/simulated/mineral/random/low_chance
	mineralChance = 5

/turf/simulated/mineral/random/Initialize()
	. = ..()
	if(prob(mineralChance) && !mineral)
		var/mineral_name = util_pick_weight(mineralSpawnChanceList) //temp mineral name
		mineral_name = lowertext(mineral_name)
		if(mineral_name && (mineral_name in GLOB.ore_data))
			mineral = GLOB.ore_data[mineral_name]
			UpdateMineral()
	MineralSpread()

/turf/simulated/mineral/random/high_chance
	mineralChance = 100 //25
	mineralSpawnChanceList = list(
		MATERIAL_URANIUM = 10,
		MATERIAL_PLATINUM = 10,
		MATERIAL_IRON = 20,
		MATERIAL_CARBON = 20,
		MATERIAL_DIAMOND = 2,
		MATERIAL_GOLD = 10,
		MATERIAL_SILVER = 10,
		MATERIAL_PLASMA = 20
		)

/turf/simulated/mineral/frozen //Rock piece
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = 0 CELSIUS
	mined_turf = /turf/simulated/floor/natural/frozenground/cave

/turf/simulated/mineral/frozen/medium
	icon_state = "rock-medium"
	rock_type = "-medium"
	durability = 200

/turf/simulated/mineral/frozen/hard
	icon_state = "rock-hard"
	rock_type = "-hard"
	durability = 300

/turf/simulated/mineral/frozen/random
	name = "Mineral deposit"
	var/mineralChance = 100 //10 //means 10% chance of this plot changing to a mineral deposit
	var/mineralSpawnChanceList = list(
		MATERIAL_URANIUM = 5,
		MATERIAL_PLATINUM = 5,
		MATERIAL_IRON = 35,
		MATERIAL_CARBON = 35,
		MATERIAL_DIAMOND = 1,
		MATERIAL_GOLD = 5,
		MATERIAL_SILVER = 5,
		MATERIAL_PLASMA = 10
		)

/turf/simulated/mineral/frozen/random/Initialize()
	. = ..()
	if(prob(mineralChance) && !mineral)
		var/mineral_name = util_pick_weight(mineralSpawnChanceList) //temp mineral name
		mineral_name = lowertext(mineral_name)
		if(mineral_name && (mineral_name in GLOB.ore_data))
			mineral = GLOB.ore_data[mineral_name]
			UpdateMineral()
	MineralSpread()

/turf/simulated/mineral/frozen/random/high_chance
	mineralChance = 100 //25
	mineralSpawnChanceList = list(
		MATERIAL_URANIUM = 10,
		MATERIAL_PLATINUM = 10,
		MATERIAL_IRON = 20,
		MATERIAL_CARBON = 20,
		MATERIAL_DIAMOND = 2,
		MATERIAL_GOLD = 10,
		MATERIAL_SILVER = 10,
		MATERIAL_PLASMA = 20
		)

/turf/simulated/mineral/air
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = 30 CELSIUS
	mined_turf = /turf/simulated/floor/asteroid/air

/**********************Asteroid**************************/

// Setting icon/icon_state initially will use these values when the turf is built on/replaced.
// This means you can put grass on the asteroid etc.
/turf/simulated/floor/asteroid
	name = "sand"
	desc = "Gritty and unpleasant."
	icon = 'icons/turf/flooring/asteroid.dmi'
	icon_state = "asteroid"
	base_name = "sand"
	base_desc = "Gritty and unpleasant."
	base_icon = 'icons/turf/flooring/asteroid.dmi'
	base_icon_state = "asteroid"

	initial_flooring = null
	initial_gas = null
	temperature = TCMB
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug
	var/overlay_detail
	var/floor_variance = 0
	has_resources = 1
	footstep_sound = SFX_FOOTSTEP_ASTEROID

/turf/simulated/floor/asteroid/Initialize()
	. = ..()
	if (!mining_floors["[src.z]"])
		mining_floors["[src.z]"] = list()
	mining_floors["[src.z]"] += src
	if(prob(20))
		overlay_detail = "asteroid[rand(0,9)]"

/turf/simulated/floor/asteroid/Destroy()
	if (mining_floors["[src.z]"])
		mining_floors["[src.z]"] -= src
	return ..()

/turf/simulated/floor/asteroid/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				gets_dug()
		if(1.0)
			gets_dug()
	return

/turf/simulated/floor/asteroid/is_plating()
	return !density

/turf/simulated/floor/asteroid/attackby(obj/item/W as obj, mob/user as mob)
	if(!W || !user)
		return 0

	var/list/usable_tools = list(
		/obj/item/shovel,
		/obj/item/pickaxe/drill/diamonddrill,
		/obj/item/pickaxe/drill,
		/obj/item/pickaxe/drill/borgdrill
		)

	var/valid_tool
	for(var/valid_type in usable_tools)
		if(istype(W,valid_type))
			valid_tool = 1
			break

	if(valid_tool)
		if (dug)
			to_chat(user, "<span class='warning'>This area has already been dug</span>")
			return

		var/turf/T = user.loc
		if (!(istype(T)))
			return

		to_chat(user, "<span class='warning'>You start digging.</span>")

		if(!do_after(user,40, src)) return

		to_chat(user, "<span class='notice'>You dug a hole.</span>")
		gets_dug()

	else if(istype(W,/obj/item/storage/ore))
		var/obj/item/storage/ore/S = W
		if(S.collection_mode)
			for(var/obj/item/ore/O in contents)
				O.attackby(W,user)
				return
	else if(istype(W,/obj/item/storage/bag/fossils))
		var/obj/item/storage/bag/fossils/S = W
		if(S.collection_mode)
			for(var/obj/item/fossil/F in contents)
				F.attackby(W,user)
				return

	else
		..(W,user)
	return

/turf/simulated/floor/asteroid/proc/gets_dug()

	if(dug)
		return

	for(var/i=0;i<(rand(3)+2);i++)
		new /obj/item/ore/glass(src)

	dug = 1
	icon_state = "asteroid_dug"
	return

/turf/simulated/floor/asteroid/on_update_icon()
	ClearOverlays()

	//todo cache
	if(overlay_detail)
		var/image/floor_decal = image(icon = 'icons/turf/flooring/decals.dmi', icon_state = overlay_detail)
		floor_decal.turf_decal_layerise()
		AddOverlays(floor_decal)

/turf/simulated/floor/asteroid/Entered(atom/movable/M as mob|obj)
	..()
	if(istype(M,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		if(R.module)
			if(istype(R.module_state_1,/obj/item/storage/ore))
				attackby(R.module_state_1,R)
			else if(istype(R.module_state_2,/obj/item/storage/ore))
				attackby(R.module_state_2,R)
			else if(istype(R.module_state_3,/obj/item/storage/ore))
				attackby(R.module_state_3,R)
			if (istype(R.module,/obj/item/robot_module/miner/adv))
				var/obj/item/robot_rack/miner/C
				if(istype(R.module_state_1,/obj/item/robot_rack/miner))
					C = R.module_state_1
					if (length(C.held))
						var/obj/structure/ore_box/OB = locate(/obj/structure/ore_box) in C
						for(var/obj/item/ore/ore in R.loc)
							ore.Move(OB)
				else if(istype(R.module_state_2,/obj/item/robot_rack/miner))
					C = R.module_state_2
					if (length(C.held))
						var/obj/structure/ore_box/OB = locate(/obj/structure/ore_box) in C
						for(var/obj/item/ore/ore in R.loc)
							ore.Move(OB)
				else if(istype(R.module_state_3,/obj/item/robot_rack/miner))
					C = R.module_state_3
					if (length(C.held))
						var/obj/structure/ore_box/OB = locate(/obj/structure/ore_box) in C
						for(var/obj/item/ore/ore in R.loc)
							ore.Move(OB)

/turf/simulated/floor/asteroid/air
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)

// Contains extra CO2 for better breathing.
/turf/simulated/floor/asteroid/air/prison
	initial_gas = list("oxygen" = 1.05 * MOLES_O2STANDARD, "nitrogen" = 1.05 * MOLES_N2STANDARD, "carbon_dioxide" = MOLES_CELLSTANDARD * 0.1)
	temperature = 30 CELSIUS

/turf/simulated/floor/asteroid/swamp_dirt
	name = "sand"
	desc = "Gritty and unpleasant."
	icon = 'icons/turf/flooring/swamp.dmi'
	icon_state = "dirt"
	base_name = "dirt"
	base_desc = "Gritty and unpleasant."
	base_icon = 'icons/turf/flooring/swamp.dmi'
	base_icon_state = "dirt"

	footstep_sound = SFX_FOOTSTEP_GRASS
	temperature = 30 CELSIUS
	initial_gas = list("oxygen" = 1.05 * MOLES_O2STANDARD, "nitrogen" = 1.05 * MOLES_N2STANDARD, "carbon_dioxide" = MOLES_CELLSTANDARD * 0.1)

/turf/simulated/floor/asteroid/swamp_dirt/Initialize()
	. = ..()
	if(prob(25))
		set_light(0.25, 1, 2.5, 1.5, "#dbbfbf")

/turf/simulated/mineral/swamp
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "swamp_rock"
	temperature = 0 CELSIUS
	mined_turf = /turf/simulated/floor/asteroid/swamp_dirt

/turf/unsimulated/swamp_bedrock
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "swamp_rock"

/turf/simulated/floor/asteroid/swamp
	name = "water"
	desc = "Smells awfully."
	icon = 'icons/turf/flooring/swamp.dmi'
	temperature = 30 CELSIUS
	icon_state = "swamp"
	footstep_sound = SFX_FOOTSTEP_WATER
	temperature = 30 CELSIUS
	initial_gas = list("oxygen" = 1.05 * MOLES_O2STANDARD, "nitrogen" = 1.05 * MOLES_N2STANDARD, "carbon_dioxide" = MOLES_CELLSTANDARD * 0.1)

/turf/simulated/floor/asteroid/jungle
	name = "grass"
	desc = "A dirty surface completly covered in low, dense grass. It looks nice."
	icon = 'icons/turf/grass.dmi'
	icon_state = "grass_green"
	footstep_sound = SFX_FOOTSTEP_GRASS

/turf/simulated/floor/asteroid/jungle/dirt
	name = "dirt"
	desc = "Looks dirty."
	icon_state = "dirt"

/turf/simulated/floor/asteroid/jungle/water
	name = "water"
	desc = "Looks wet."
	icon = 'icons/misc/beach.dmi'
	icon_state = "seashallow"
	footstep_sound = SFX_FOOTSTEP_SWAMP
	var/overlay = TRUE

/turf/simulated/floor/asteroid/jungle/water/Initialize()
	. = ..()
	if(overlay)
		AddOverlays(image("icon"='icons/misc/beach.dmi',"icon_state"="riverwater","layer"=MOB_LAYER+1))

/turf/simulated/floor/asteroid/jungle/water/update_dirt()
	return

/turf/simulated/floor/asteroid/jungle/wasteland
	name = "cracked earth"
	desc = "Looks a bit dry."
	icon = 'icons/turf/flooring/wasteland.dmi'
	icon_state = "wasteland1"
	floor_variance = 15

/turf/simulated/floor/asteroid/jungle/wasteland/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "wasteland[rand(1, 13)]"

/turf/simulated/floor/asteroid/rockplanet
	name = "iron sand"
	desc = "Reddish sand, probably because it contain too much iron in it."
	icon = 'icons/turf/flooring/sand.dmi'
	icon_state = "dry_soft1"
	floor_variance = 100

/turf/simulated/floor/asteroid/rockplanet/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "dry_soft[rand(1, 8)]"

/turf/simulated/floor/asteroid/rockplanet/cracked
	name = "iron cracked sand"
	icon_state = "dry_cracked1"

/turf/simulated/floor/asteroid/rockplanet/cracked/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "dry_cracked[rand(1, 8)]"

/turf/simulated/floor/asteroid/rockplanet/wet
	icon_state = "wet_soft1"

/turf/simulated/floor/asteroid/rockplanet/wet/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "wet_soft[rand(1, 8)]"

/turf/simulated/floor/asteroid/rockplanet/wet/cracked
	name = "iron cracked sand"
	icon_state = "wet_cracked1"

/turf/simulated/floor/asteroid/rockplanet/wet/cracked/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "wet_cracked[rand(1, 8)]"

/turf/simulated/floor/asteroid/whitesands
	name = "salted sand"
	desc = "Dead-white sand that made almost entirely out of salt."
	icon = 'icons/turf/flooring/whitesand.dmi'
	icon_state = "sand1"
	floor_variance = 80

/turf/simulated/floor/asteroid/whitesands/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "sand[rand(1, 13)]"

/turf/simulated/floor/asteroid/whitesands/dried
	icon_state = "dry1"

/turf/simulated/floor/asteroid/whitesands/dried/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "dry[rand(1, 13)]"

/turf/simulated/floor/asteroid/whitesands/grass
	name = "purple grass"
	desc = "The few known flora on Whitesands are in a purplish color."
	icon = 'icons/turf/grass.dmi'
	icon_state = "grass_purple"
	footstep_sound = SFX_FOOTSTEP_GRASS

/turf/simulated/floor/asteroid/whitesands/grass/dead
	name = "dry grass"
	icon = 'icons/turf/grass.dmi'
	icon_state = "grass_white"
	desc = "The few known flora on Whitesands also don't tend to live for very long, especially after the war."

/turf/simulated/floor/asteroid/snow
	name = "snow"
	desc = "Just a snow."
	icon = 'icons/turf/planetsnow.dmi'
	icon_state = "snow1"
	footstep_sound = SFX_FOOTSTEP_SNOW
	floor_variance = 100

/turf/simulated/floor/asteroid/snow/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "snow[rand(1, 13)]"

/turf/simulated/floor/asteroid/snow/icerock
	name = "icy rock"
	desc = "The coarse rock that covers the surface."
	icon_state = "icemoon_ground_coarse1"
	footstep_sound = SFX_FOOTSTEP_ASTEROID
	floor_variance = 100

/turf/simulated/floor/asteroid/snow/icerock/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "icemoon_ground_coarse[rand(1, 8)]"

/turf/simulated/floor/asteroid/snow/icerock/smooth
	icon_state = "icemoon_ground_smooth"

/turf/simulated/floor/asteroid/snow/icerock/cracked
	icon_state = "icemoon_ground_cracked"

/turf/simulated/floor/asteroid/snow/iceberg
	name = "cracked ice floor"
	desc = "A sheet of solid ice. It seems too cracked to be slippery anymore."
	icon_state = "iceberg1"
	floor_variance = 100

/turf/simulated/floor/asteroid/snow/iceberg/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "iceberg[rand(1, 8)]"

/turf/simulated/floor/asteroid/basalt
	name = "volcanic floor"
	desc = "Some dark, rough volcanic rock."
	icon = 'icons/turf/basalt.dmi'
	icon_state = "basalt1"
	footstep_sound = SFX_FOOTSTEP_PLATING
	floor_variance = 20

/turf/simulated/floor/asteroid/basalt/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "basalt[rand(1, 13)]"

/turf/simulated/floor/asteroid/basalt/lavaplanet

/turf/simulated/floor/asteroid/basalt/purple
	name = "purple volcanic floor"
	desc = "Dark volcanic rock, tinted by the chemicals in the atmosphere to an uncanny shade of purple."
	icon = 'icons/turf/basalt_purple.dmi'
	icon_state = "basalt1"

/turf/simulated/floor/asteroid/basalt/purple/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "basalt[rand(1, 13)]"

/turf/simulated/floor/asteroid/basalt/purple/sand
	name = "ashen sand"
	desc = "Sand, tinted by the chemicals in the atmosphere to an uncanny shade of purple."
	icon = 'icons/turf/basalt_purple.dmi'
	icon_state = "sand1"
	footstep_sound = SFX_FOOTSTEP_ASTEROID

/turf/simulated/floor/asteroid/basalt/purple/sand/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(floor_variance))
		icon_state = "sand[rand(1, 13)]"

/turf/simulated/floor/asteroid/lavaplanet/grass
	name = "red grass"
	desc = "Common grass, tinged to unnatural colours by chemicals in the atmosphere."
	icon = 'icons/turf/grass.dmi'
	icon_state = "grass_red"

/turf/simulated/floor/asteroid/lavaplanet/grass/purple
	name = "purple grass"
	icon_state = "grass_purple"

/turf/simulated/floor/asteroid/lavaplanet/grass/orange
	name = "orange grass"
	icon_state = "grass_orange"

/turf/simulated/floor/asteroid/beach
	name = "sand"
	desc = "Looks sandy."
	icon = 'icons/misc/beach.dmi'
	icon_state = "desert0"
	floor_variance = 35

/turf/simulated/floor/asteroid/beach/Initialize()
	. = ..()
	if(prob(floor_variance))
		icon_state = "desert[rand(0, 8)]"

/turf/simulated/floor/asteroid/beach/grass
	name = "grass"
	desc = "Light grass that grows on sandy surface."
	icon = 'icons/turf/grass.dmi'
	icon_state = "grass_green"
	footstep_sound = SFX_FOOTSTEP_GRASS

/turf/simulated/floor/asteroid/beach/grass/fairy
	name = "fairygrass"
	desc = "Something about this grass makes you want to frolic. Or get high."
	icon = 'icons/turf/grass.dmi'
	icon_state = "grass_cyan"

/turf/simulated/floor/asteroid/beach/water
	name = "water"
	desc = "Looks wet."
	icon = 'icons/misc/beach.dmi'
	icon_state = "seashallow"
	footstep_sound = SFX_FOOTSTEP_SWAMP
	var/overlay = TRUE

/turf/simulated/floor/asteroid/beach/water/Initialize()
	. = ..()
	if(overlay)
		AddOverlays(image("icon"='icons/misc/beach.dmi',"icon_state"="riverwater","layer"=MOB_LAYER+1))

/turf/simulated/floor/asteroid/beach/water/update_dirt()
	return

/turf/simulated/floor/asteroid/waste
	name = "iron sand"
	desc = "Reddish sand, probably because it contain too much iron in it."
	icon = 'icons/turf/flooring/wasteland.dmi'
	icon_state = "wasteland_dry1"
	floor_variance = 100
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	temperature = 15 CELSIUS

/turf/simulated/floor/asteroid/waste/Initialize(mapload)
	. = ..()
	if(prob(floor_variance))
		icon_state = "wasteland_dry[rand(1, 12)]"

/turf/simulated/floor/asteroid/rust
	name = "iron sand"
	desc = "Reddish sand, probably because it contain too much iron in it."
	icon = 'icons/turf/flooring/plating.dmi'
	icon_state = "plating_rust"
	floor_variance = 100
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	temperature = 15 CELSIUS

/turf/simulated/floor/asteroid/tar_water
	name = "water"
	desc = "Looks wet."
	icon = 'icons/turf/flooring/swamp.dmi'
	icon_state = "swamp"
	footstep_sound = SFX_FOOTSTEP_SWAMP
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	temperature = 15 CELSIUS

/turf/simulated/floor/asteroid/tar_water/update_dirt()
	return

/turf/simulated/wall/mineral
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "waste"
	material = MATERIAL_WASTELAND
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	temperature = 15 CELSIUS

/turf/simulated/wall/mineral/Initialize(mapload)
	. = ..(mapload, MATERIAL_WASTELAND, MATERIAL_WASTELAND) //3strong
