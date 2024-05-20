/datum/star_system
	var/name = null //Parent type, please ignore
	var/desc = null
	var/parallax_property = null //If you want things to appear in the background when you jump to this system, do this.
	var/level_trait = null //The Ztrait of the zlevel that this system leads to
	var/visitable = FALSE //Can you directly travel to this system? (You shouldnt be able to jump directly into hyperspace)
	var/list/enemies_in_system = list() //For mission completion.
	var/reward = 5000 //Small cash bonus when you clear a system, allows you to buy more ammo
	var/difficulty_budget = 2
	var/list/asteroids = list() //Keep track of how many asteroids are in system. Don't want to spam the system full of them
	var/mission_sector = FALSE
	var/objective_sector = FALSE
	var/threat_level = THREAT_LEVEL_NONE

	var/x = 0 //Maximum: 1000 for now
	var/y = 0 //Maximum: 1000 for now
	//Current list of valid alignments (from Map.scss in TGUI): null, whiterapids, solgov, nanotrasen, syndicate, unaligned, pirate, uncharted
	var/alignment = "unaligned"
	var/owner = "unaligned" //Same as alignment, but only changes when a system is definitively captured (for persistent starmaps)
	var/visited = FALSE
	var/hidden = FALSE //Secret systems
	var/list/system_type = null //Set this to pre-spawn systems as a specific type.
	var/event_chance = 0
	var/list/possible_events = list()
	var/list/active_missions = list()

	var/list/contents_positions = list()
	var/list/system_contents = list()
	var/list/enemy_queue = list()

	var/danger_level = 0
	var/system_traits = 0
	var/is_capital = FALSE
	var/list/adjacency_list = list() //Which systems are near us, by name
	///List of adjacencies this system started with. Should never be edited. Cannot be initialed due to the json loading to system adjacencies.
	var/list/initial_adjacencies = list()
	var/occupying_z = 0 //What Z-level is this  currently stored on? This will always be a number, as Z-levels are "held" by ships.
	var/list/wormhole_connections = list() //Where did we dun go do the wormhole to honk
	var/fleet_type = null //Wanna start this system with a fleet in it?
	var/list/fleets = list() //Fleets that are stationed here.
	var/sector = 1 //What sector of space is this in?
	var/is_hypergate = FALSE //Used to clearly mark sector jump points on the map
	var/preset_trader = null
	var/datum/trader/trader = null
	var/list/audio_cues = null //if you want music to queue on system entry. Format: list of youtube or media URLS.
	var/already_announced_combat = FALSE
	var/mappath = /datum/map_template/empty127

/datum/star_system/New(name, desc, threat_level, alignment, owner, hidden, system_type, system_traits, is_capital, adjacency_list, wormhole_connections, fleet_type, x, y, parallax_property, visitable, sector, is_hypergate, audio_cues)
	. = ..()
	//Load props first.
	if(name)
		src.name = name
	if(desc)
		src.desc = desc
	if(threat_level)
		src.threat_level = threat_level
	if(alignment)
		src.alignment = alignment
	if(owner)
		src.owner = owner
	if(hidden)
		src.hidden = hidden
	if(system_type)
		src.system_type = system_type
	if(system_traits)
		src.system_traits = system_traits
	if(is_capital)
		src.is_capital = is_capital
	if(adjacency_list)
		var/list/cast_adjacency_list = adjacency_list
		src.adjacency_list = cast_adjacency_list
		src.initial_adjacencies = cast_adjacency_list.Copy()
	if(wormhole_connections)
		src.wormhole_connections = wormhole_connections
	if(fleet_type)
		src.fleet_type = fleet_type
	if(x)
		src.x = x
	if(y)
		src.y = y
	if(parallax_property)
		src.parallax_property = parallax_property
	if(visitable)
		src.visitable = visitable
	if(sector)
		src.sector = sector
	if(is_hypergate)
		src.is_hypergate = is_hypergate
	if(audio_cues)
		src.audio_cues = audio_cues

/datum/star_system/proc/generate_anomaly()
	if(prob(15)) //Low chance of spawning a wormhole twixt us and another system.
		create_wormhole()
	if(system_type) //Already have a preset system type. Apply its effects.
		apply_system_effects()
		return
	switch(threat_level)
		if(THREAT_LEVEL_NONE) //Threat level 0 denotes starter systems, so they just have "fluff" anomalies like gas clouds and whatever.
			system_type = pick(
				list(
					tag = "safe",
					label = "Empty space",
				),
				list(
					tag = "nebula",
					label = "Nebula",
				),
				list(
					tag = "gas",
					label = "Gas cloud",
				),
				list(
					tag = "icefield",
					label = "Ice field",
				),
				list(
					tag = "ice_planet",
					label = "Planetary system",
				),
			)
		if(THREAT_LEVEL_UNSAFE) //Unaligned and Syndicate systems have a chance to spawn threats. But nothing major.
			system_type = pick(
				list(
					tag = "debris",
					label = "Asteroid field",
				),
				list(
					tag = "pirate",
					label = "Debris",
				),
				list(
					tag = "nebula",
					label = "Nebula",
				),
				list(
					tag = "hazardous",
					label = "Untagged hazard",
				),
			)
		if(THREAT_LEVEL_DANGEROUS) //Extreme threat level. Time to break out the most round destroying anomalies.
			system_type = pick(
				list(
					tag = "quasar",
					label = "Quasar",
				),
				list(
					tag = "radioactive",
					label = "Radioactive",
				),
				list(
					tag = "blackhole",
					label = "Black hole",
				),
			)
	apply_system_effects()

/datum/star_system/proc/spawn_asteroids()
	pass()
	//.for(var/I = 0; I <= rand(3, 6); I++)
	//..	var/roid_type = pick(/obj/structure/overmap/asteroid, /obj/structure/overmap/asteroid/medium, /obj/structure/overmap/asteroid/large)
	//	SSstar_system.spawn_ship(roid_type, src)

/datum/star_system/proc/apply_system_effects()
	pass()
	/*

	event_chance = 15 //Very low chance of an event happening
	var/anomaly_type = null
	difficulty_budget = threat_level
	var/list/sys = system_type
	if("blacksite") //this a special one!
		adjacency_list += SSstar_system.return_system.name //you're going to risa, damnit.
		SSstar_system.spawn_anomaly(/obj/effect/overmap_anomaly/wormhole, src, center=TRUE)
	//if(alignment == "syndicate")
		//spawn_enemies() //Syndicate systems are even more dangerous, and come pre-loaded with some Syndie ships.

	if(alignment == "unaligned")
		if(prob(25))
			spawn_enemies()
		else if (prob(33))
			var/pickedF = pick(list(/datum/fleet/nanotrasen/light, /datum/fleet/nanotrasen)) //This should probably be a seperate proc to spawn friendlies
			var/datum/fleet/F = new pickedF
			F.current_system = src
			fleets += F
			F.assemble(src)
	if(!anomaly_type)
		anomaly_type = pick(subtypesof(/obj/effect/overmap_anomaly/safe))
	SSstar_system.spawn_anomaly(anomaly_type, src)
	*/

/datum/star_system/proc/dist(datum/star_system/other)
	var/dx = other.x - x
	var/dy = other.y - y
	return sqrt((dx * dx) + (dy * dy))

/datum/star_system/proc/add_ship(obj/structure/overmap/OM, turf/target_turf)
	if(!system_contents.Find(OM))
		system_contents += OM

	if(OM.role == MAIN_OVERMAP)
		var/datum/map_template/map = new mappath()
		var/turf/new_center = map.load_new_z()
		occupying_z = new_center.z

	var/turf/destination
	destination = locate(rand(TRANSITION_EDGE, 127 - TRANSITION_EDGE), rand(TRANSITION_EDGE, 127 - TRANSITION_EDGE), occupying_z)

	OM.forceMove(destination)
	if(istype(OM, /obj/structure/overmap))
		OM.current_system = src //Debugging purposes only

	after_enter(OM)

/datum/star_system/proc/after_enter(obj/structure/overmap/OM)
	pass()
