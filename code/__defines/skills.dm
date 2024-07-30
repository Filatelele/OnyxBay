#define STAT_STR "Strength"
#define STAT_FIT "Fintess"
#define STAT_DEX "Dexterity"
#define STAT_COG "Cognition"
#define STAT_WILL "Willpower"
#define SKILL_CIV_MECH "Civilian exosuits"
#define SKILL_COMBAT_MECH "Combat exosuits"
#define SKILL_POLICE "Police"
#define SKILL_FIREARMS "Firearms"
#define SKILL_MELEE "Melee weapons"
#define SKILL_ENGINEERING "Engineering"
#define SKILL_ATMOS "Atmospherics"
#define SKILL_CONSTRUCTION "Construction"
#define SKILL_CHEMISTRY "Chemistry"
#define SKILL_RESEARCH "Research"
#define SKILL_MEDICAL "Medical"
#define SKILL_SURGERY "Surgery"
#define SKILL_COMMAND "Command"

#define ALL_STATS	list(STAT_STR, STAT_FIT, STAT_DEX, STAT_COG, STAT_WILL)

// base task time, not mandatory but helps to keep tasks difficulty consistent
// usually final time will be modified by task and user skills
#define SKILL_TASK_TRIVIAL 1 SECONDS
#define SKILL_TASK_VERY_EASY 2 SECONDS
#define SKILL_TASK_EASY 3 SECONDS
#define SKILL_TASK_AVERAGE 5 SECONDS
#define SKILL_TASK_TOUGH 8 SECONDS
#define SKILL_TASK_DIFFICULT 10 SECONDS
#define SKILL_TASK_CHALLENGING 15 SECONDS
#define SKILL_TASK_FORMIDABLE 20 SECONDS
#define HELP_OTHER_TIME 20 SECONDS

#define STAT_LEVEL_NONE           0
#define STAT_LEVEL_AWFUL          6
#define STAT_LEVEL_WEAK           8
#define STAT_LEVEL_AVERAGE       10
#define STAT_LEVEL_ABOVE_AVERAGE 12
#define STAT_LEVEL_TRAINED       14
#define STAT_LEVEL_EXCEPTIONAL   16
#define STAT_LEVEL_LEGENDARY     18
#define STAT_LEVEL_GODLIKE       20

/// Min stat value selectable
#define STAT_LEVEL_MIN      4
#define STAT_LEVEL_DEFAULT 9
/// Max stat value selectable
#define STAT_LEVEL_MAX      16

#define STAT_LEVEL_ABS_MIN 0
#define STAT_LEVEL_ABS_MAX 30
