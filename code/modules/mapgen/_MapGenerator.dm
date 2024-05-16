/// Management class used to handle successive calls used to generate a list of turfs.
/datum/map_generator
	/// List of necessary ruins that will always spawn
	var/list/necessary_ruins

	/// Weighed list of random ruins
	var/list/random_ruins

/// Given a list of turfs, asynchronously changes a list of turfs and their areas.
/// Does not fill them with objects; this should be done with populate_turfs.
/// This is a wrapper proc for generate_turf(), handling batch processing of turfs.
/datum/map_generator/proc/generate_turfs(list/turf/turfs)
	var/start_time = REALTIMEOFDAY
	var/message = "MAPGEN: MAPGEN any2ref [any2ref(src)] ([type]) STARTING TURF GEN"
	to_world_log(message)

	for(var/turf/gen_turf in turfs)
		if(!istype(gen_turf))
			continue

		// deferring AfterChange() means we don't get huge atmos flows in the middle of making changes
		generate_turf(gen_turf, CHANGETURF_IGNORE_AIR | CHANGETURF_DEFER_CHANGE | CHANGETURF_DEFER_BATCH)
		CHECK_TICK

	for(var/turf/gen_turf in turfs)
		if(!istype(gen_turf))
			continue

		//gen_turf.AfterChange(CHANGETURF_IGNORE_AIR)

		//QUEUE_SMOOTH(gen_turf)
		//QUEUE_SMOOTH_NEIGHBORS(gen_turf)

		for(var/turf/space/S in RANGE_TURFS(1, gen_turf))
			S.update_starlight()

		// CHECK_TICK here is fine -- we are assuming that the turfs we're generating are staying relatively constant
		CHECK_TICK

	message = "MAPGEN: MAPGEN REF [any2ref(src)] ([type]) HAS FINISHED TURF GEN IN [(REALTIMEOFDAY - start_time)/10]s"
	to_world_log(message)

/// Given a list of turfs, presumed to have been previously changed by generate_turfs,
/// asynchronously fills them with objects and decorations.
/// This is a wrapper proc for _populate_turf(), handling batch processing of turfs to improve speed.
/datum/map_generator/proc/populate_turfs(list/turf/turfs)
	var/start_time = REALTIMEOFDAY
	var/message = "MAPGEN: MAPGEN REF [any2ref(src)] ([type]) STARTING TURF POPULATION"
	to_world_log(message)

	for(var/turf/gen_turf in turfs)
		if(!istype(gen_turf))
			continue

		_populate_turf(gen_turf)
		CHECK_TICK

	message = "MAPGEN: MAPGEN REF [any2ref(src)] ([type]) HAS FINISHED TURF POPULATION IN [(REALTIMEOFDAY - start_time)/10]s"
	to_world_log(message)

/// Internal proc that actually calls ChangeTurf on and changes the area of
/// a turf passed to generate_turfs(). Should never sleep; should always
/// respect changeturf_flags in the call to ChangeTurf.
/datum/map_generator/proc/generate_turf(turf/gen_turf, changeturf_flags)
	SHOULD_NOT_SLEEP(TRUE)
	return

/// Internal proc that actually adds objects to a turf passed to populate_turfs().
/datum/map_generator/proc/_populate_turf(turf/gen_turf)
	SHOULD_NOT_SLEEP(TRUE)
	return

/datum/map_generator/proc/load_necessary_ruins(z_level)
	for(var/path in necessary_ruins)
		var/datum/map_template/ruin = new path()
		var/turf/ruin_turf = locate(
			rand(0 + world.view, 255 - ruin.height - world.view),
			rand(0 + world.view, 255 - ruin.width -  world.view),
			z_level
		)
		ruin.load(ruin_turf)
