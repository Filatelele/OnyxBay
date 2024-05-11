#define COMSIG_GLOB_AI_GOAL_SET "!ai_goal_set"
#define COMSIG_GLOB_AI_MINION_RALLY "!ai_minion_rally"
#define COMSIG_GLOB_HIVE_TARGET_DRAINED "!hive_target_drained"

// Action state signal that's sent whenever the action state has a distance maintained with the target being walked to
#define COMSIG_STATE_MAINTAINED_DISTANCE "action_state_maintained_dist_with_target"
	#define COMSIG_MAINTAIN_POSITION (1<<0)
#define COMSIG_OBSTRUCTED_MOVE "unable_to_step_towards_thing" //Tried to step in a direction and there was a obstruction
	#define COMSIG_OBSTACLE_DEALT_WITH (1<<0)

// Send from cleanbot's `UnarmedAttack()`
#define SIGNAL_CLEANBOT_CLEANED "signal_cleanbot_cleaned"

#define SIGNAL_MALFBOT_TAKING_DAMAGE "signal_malfbot_taking_damage"
#define SIGNAL_MALFBOT_ABILITY_RESET "signal_malfbot_ability_reset"

#define SIGNAL_MALFBOT_HEALTH_REGEN "signal_malfbot_health_regen"
