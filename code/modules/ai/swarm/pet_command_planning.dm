/**
 * # Pet Planning
 * Perform behaviour based on what pet commands you have received. This is delegated to the pet command datum.
 * When a command is set, we blackboard a key to our currently active command.
 * The blackboard also has a weak reference to every command datum available to us.
 * We use the key to figure out which datum to run, then ask it to figure out how to execute its action.
 */
/datum/ai_planning_subtree/pet_planning
