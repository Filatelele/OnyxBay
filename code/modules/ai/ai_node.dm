//The node with a physical presence on the map; mainly exists as a actual object to be able to be highlighted easily for easy debugging and viewing purposes
//It also holds the datum ai_node, containing getter procs and handle info like weights

/atom/movable/ai_node //A effect that has a ai_node datum in it, used by AIs to pathfind over long distances as well as knowing what's happening at it
	name = "AI Node"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "ai_node" //Pure white 'X' with word "AI" beneath
	anchored = TRUE
	#ifdef TESTING
	invisibility = 0
	#else
	invisibility = INVISIBILITY_SYSTEM
	#endif
	/// static id counter for all nodes
	var/static/id_counter = 0
	/// A unique id for this node
	var/unique_id
	///Assoc list of adjacent landmark nodes by dir
	var/list/adjacent_nodes = list()

	///List of weights for scoring stuff happening here; ultilizes "identifiers" to differentiate different kinds of AI types looking at the same node.
	var/list/weights = list(
		IDENTIFIER_XENO = list(NODE_LAST_VISITED = 0),
		IDENTIFIER_ZOMBIE = list(NODE_LAST_VISITED = 0),
		IDENTIFIER_SBOT = list(NODE_LAST_VISITED = 0),
		IDENTIFIER_MALFBOT = list(NODE_LAST_VISITED = 0),
		)

/atom/movable/ai_node/Initialize(mapload)
	..()
	GLOB.all_nodes += src
	unique_id = id_counter++
	if(!mapload)
		for(var/atom/movable/ai_node/N in world)
			if(N != src && N.unique_id == unique_id)
				to_chat(world, "REDIT PENIS")
				pass()
	return INITIALIZE_HINT_LATELOAD

/atom/movable/ai_node/LateInitialize()
	make_adjacents()
	if(SSadvanced_pathfinding.initialized)
		rustg_add_node_astar(json_encode(serialize()))

/// Serialize nodes information
/atom/movable/ai_node/proc/serialize()
	. = list()
	.["unique_id"] = unique_id
	.["x"] = x
	.["y"] = y
	.["z"] = z
	.["connected_nodes_id"] = list()
	for(var/key in adjacent_nodes)
		var/atom/movable/ai_node/connected_node = adjacent_nodes[key]
		.["connected_nodes_id"] += connected_node.unique_id

///Adds to the specific weight of a specific identifier of this node
/atom/movable/ai_node/proc/increment_weight(identifier, name, amount)
	weights[identifier][name] += amount

///Sets the specific weight of a specific identifier of this node
/atom/movable/ai_node/proc/set_weight(identifier, name, amount)
	weights[identifier][name] = amount

/atom/movable/ai_node/Destroy()
	GLOB.all_nodes[unique_id + 1] = null
	rustg_remove_node_astar("[unique_id]")
	//Remove our reference to self from nearby adjacent node's adjacent nodes
	for(var/direction as anything in adjacent_nodes)
		var/atom/movable/ai_node/node = adjacent_nodes[direction]
		node.make_adjacents()
	adjacent_nodes.Cut()
	return ..()

/**
 * A proc that gets the "best" adjacent node in src based on score
 * The score is calculated by what weights are inside of the list/weight_modifiers
 * The highest number after multiplying each list/weight by the ones in the above parameter will be the node that's chosen; any nodes that have the same score won't override that node
 * Generally the number that the weight has before being multiplied by weight modifiers is the "user friendly" edition; NODE_LAST_VISITED represents in deciseconds the fe before
 * the node has been visited by a particular thing, while something like NODE_ENEMY_COUNT represents the amount of enemies
 * Parameter call example
 * GetBestAdjNode(list(NODE_LAST_VISITED = -1), IDENTIFIER_XENO)
 * Returns an adjacent node that was last visited; when a AI chose to visit a node, it will set NODE_LAST_VISITED to world.time
 */
/atom/movable/ai_node/proc/get_best_adj_node(list/weight_modifiers, identifier)
	//No weight modifiers, return a adjacent random node
	if(!length(weight_modifiers) || !identifier)
		return adjacent_nodes[safepick(adjacent_nodes)]

	var/atom/movable/ai_node/node_to_return
	var/current_best_node_score = -INFINITY
	var/current_score = 0
	for(var/direction in adjacent_nodes) //We keep a score for the nodes and see which one is best
		var/atom/movable/ai_node/node = adjacent_nodes[direction]
		current_score = 0
		for(var/weight in weight_modifiers)
			current_score += NODE_GET_VALUE_OF_WEIGHT(identifier, node, weight) * weight_modifiers[weight]

		if(current_score >= current_best_node_score)
			current_best_node_score = current_score
			node_to_return = node

	if(node_to_return)
		return node_to_return
	return adjacent_nodes[safepick(adjacent_nodes)]

///Clears the adjacencies of src and repopulates it, it will consider nodes "adjacent" to src should it be less 15 turfs away
/atom/movable/ai_node/proc/make_adjacents(bypass_diagonal_check = FALSE)
	adjacent_nodes = list()
	for(var/dir in GLOB.cardinal)
		var/turf/stepturf = get_step(src, dir)
		if(is_blocked_turf(stepturf, src, TRUE, list(
			/obj/machinery/door/airlock,
			/obj/machinery/borgizer
		)))
			continue

		var/atom/movable/ai_node/node = locate() in stepturf
		if(!istype(node) || node == src || node.z != z)
			continue

		adjacent_nodes["[get_dir(src, node)]"] = node
		node.adjacent_nodes["[get_dir(node, src)]"] = src

/atom/movable/ai_node/debug //A debug version of the AINode; makes it visible to allow for easy var editing
	icon_state = "x6" //Pure white 'X' with black borders
	color = "#ffffff"
	invisibility = 0
