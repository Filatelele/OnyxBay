GLOBAL_LIST_INIT(bitfields, generate_bitfields())

/// Specifies a bitfield for smarter debugging
/datum/bitfield
	/// The variable name that contains the bitfield
	var/variable

	/// An associative list of the readable flag and its true value
	var/list/flags

/// Turns /datum/bitfield subtypes into a list for use in debugging
/proc/generate_bitfields()
	var/list/bitfields = list()
	for (var/_bitfield in subtypesof(/datum/bitfield))
		var/datum/bitfield/bitfield = new _bitfield
		bitfields[bitfield.variable] = bitfield.flags
	return bitfields

DEFINE_BITFIELD(appearance_flags, list(
	"KEEP_APART" = KEEP_APART,
	"KEEP_TOGETHER" = KEEP_TOGETHER,
	"LONG_GLIDE" = LONG_GLIDE,
	"NO_CLIENT_COLOR" = NO_CLIENT_COLOR,
	"PIXEL_SCALE" = PIXEL_SCALE,
	"PLANE_MASTER" = PLANE_MASTER,
	"RESET_ALPHA" = RESET_ALPHA,
	"RESET_COLOR" = RESET_COLOR,
	"RESET_TRANSFORM" = RESET_TRANSFORM,
	"TILE_BOUND" = TILE_BOUND,
	"PASS_MOUSE" = PASS_MOUSE,
	"TILE_MOVER" = TILE_MOVER,
))

DEFINE_BITFIELD(damage_flags, list(
	"DAMAGE_SHARP" = DAM_SHARP,
	"DAMAGE_EDGE" = DAM_EDGE,
	"DAMAGE_LASER" = DAM_LASER,
))

DEFINE_BITFIELD(damage_flags, list(
	"DAMAGE_SHARP" = DAM_SHARP,
	"DAMAGE_EDGE" = DAM_EDGE,
	"DAMAGE_LASER" = DAM_LASER,
))

DEFINE_BITFIELD(status, list(
	"ORGAN_CUT_AWAY" = ORGAN_CUT_AWAY,
	"ORGAN_BLEEDING" = ORGAN_BLEEDING,
	"ORGAN_BROKEN" = ORGAN_BROKEN,
	"ORGAN_DEAD" = ORGAN_DEAD,
	"ORGAN_MUTATED" = ORGAN_MUTATED,
	"ORGAN_ARTERY_CUT" = ORGAN_ARTERY_CUT,
	"ORGAN_TENDON_CUT" = ORGAN_TENDON_CUT,
	"ORGAN_DISFIGURED" = ORGAN_DISFIGURED,
	"ORGAN_SABOTAGED" = ORGAN_SABOTAGED,
	"ORGAN_ASSISTED" = ORGAN_ASSISTED,
	"ORGAN_ROBOTIC" = ORGAN_ROBOTIC,
))

DEFINE_BITFIELD(limb_flags, list(
	"CAN_AMPUTATE" = ORGAN_FLAG_CAN_AMPUTATE,
	"CAN_BREAK" = ORGAN_FLAG_CAN_BREAK,
	"CAN_GRASP" = ORGAN_FLAG_CAN_GRASP,
	"CAN_STAND" = ORGAN_FLAG_CAN_STAND,
	"HAS_TENDON" = ORGAN_FLAG_HAS_TENDON,
	"FINGERPRINT" = ORGAN_FLAG_FINGERPRINT,
	"GENDERED_ICON" = ORGAN_FLAG_GENDERED_ICON,
	"HEALS_OVERKILL" = ORGAN_FLAG_HEALS_OVERKILL,
))

DEFINE_BITFIELD(atom_flags, list(
	"INITIALIZED" = ATOM_FLAG_INITIALIZED,
	"CHECKS_BORDER" = ATOM_FLAG_CHECKS_BORDER,
	"NO_BLOOD" = ATOM_FLAG_NO_BLOOD,
	"NO_REACT" = ATOM_FLAG_NO_REACT,
	"OPEN_CONTAINER" = ATOM_FLAG_OPEN_CONTAINER,
	"FULLTILE_OBJECT" = ATOM_FLAG_FULLTILE_OBJECT,
	"ADJACENT_EXCEPTION" = ATOM_FLAG_ADJACENT_EXCEPTION,
	"IGNORE_RADIATION" = ATOM_FLAG_IGNORE_RADIATION,
	"OVERLAY_UPDATE" = ATOM_AWAITING_OVERLAY_UPDATE,
	"SILENTCONTAINER" = ATOM_FLAG_SILENTCONTAINER,
	"UNPUSHABLE" = ATOM_FLAG_UNPUSHABLE,
	"ATOM_FLAG_HOLOGRAM" = ATOM_FLAG_HOLOGRAM,
	"ATOM_FLAG_NO_DECONSTRUCTION" = ATOM_FLAG_NO_DECONSTRUCTION,
))

DEFINE_BITFIELD(species_flags, list(
	"NO_MINOR_CUT" = SPECIES_FLAG_NO_MINOR_CUT,
	"IS_PLANT" = SPECIES_FLAG_IS_PLANT,
	"NO_SCAN" = SPECIES_FLAG_NO_SCAN,
	"NO_PAIN" = SPECIES_FLAG_NO_PAIN,
	"NO_SLIP" = SPECIES_FLAG_NO_SLIP,
	"NO_EMBED" = SPECIES_FLAG_NO_EMBED,
	"CAN_NAB" = SPECIES_FLAG_CAN_NAB,
	"NO_BLOCK" = SPECIES_FLAG_NO_BLOCK,
	"NEED_DIRECT_ABSORB" = SPECIES_FLAG_NEED_DIRECT_ABSORB,
	"FLAG_NO_TANGLE" = SPECIES_FLAG_NO_TANGLE,
	"NO_BLOOD" = SPECIES_FLAG_NO_BLOOD,
	"NO_ANTAG_TARGET" = SPECIES_FLAG_NO_ANTAG_TARGET,
	"FLAG_NO_TANGLE" = SPECIES_FLAG_NO_TANGLE,
	"NO_FIRE" = SPECIES_FLAG_NO_FIRE,
))

DEFINE_BITFIELD(spawn_flags, list(
	"SPECIES_IS_WHITELISTED" = SPECIES_IS_WHITELISTED,
	"SPECIES_IS_RESTRICTED" = SPECIES_IS_RESTRICTED,
	"SPECIES_CAN_JOIN" = SPECIES_CAN_JOIN,
	"SPECIES_NO_FBP_CONSTRUCTION" = SPECIES_NO_FBP_CONSTRUCTION,
	"SPECIES_NO_FBP_CHARGEN" = SPECIES_NO_FBP_CHARGEN,
	"SPECIES_NO_LACE" = SPECIES_NO_LACE,
))

DEFINE_BITFIELD(species_appearance_flags, list(
	"HAS_SKIN_TONE_NORMAL" = HAS_SKIN_TONE_NORMAL,
	"HAS_SKIN_COLOR" = HAS_SKIN_COLOR,
	"HAS_LIPS" = HAS_LIPS,
	"HAS_UNDERWEAR" = HAS_UNDERWEAR,
	"HAS_EYE_COLOR" = HAS_EYE_COLOR,
	"RADIATION_GLOWS" = RADIATION_GLOWS,
	"HAS_SKIN_TONE_GRAV" = HAS_SKIN_TONE_GRAV,
	"HAS_SKIN_TONE_SPCR" = HAS_SKIN_TONE_SPCR,
	"SECONDARY_HAIR_IS_SKIN" = SECONDARY_HAIR_IS_SKIN,
	"HAS_A_SKIN_TONE" = HAS_A_SKIN_TONE,
	"HAS_EYE_COLOR" = HAS_EYE_COLOR,
	"RADIATION_GLOWS" = RADIATION_GLOWS,
))

DEFINE_BITFIELD(rights, list(
	"R_BUILDMODE" = R_BUILDMODE,
	"R_ADMIN" = R_ADMIN,
	"R_BAN" = R_BAN,
	"R_FUN" = R_FUN,
	"R_SERVER" = R_SERVER,
	"R_DEBUG" = R_DEBUG,
	"R_PERMISSIONS" = R_PERMISSIONS,
	"R_STEALTH" = R_STEALTH,
	"R_REJUVINATE" = R_REJUVINATE,
	"R_VAREDIT" = R_VAREDIT,
	"R_SOUNDS" = R_SOUNDS,
	"R_SPAWN" = R_SPAWN,
	"R_MOD" = R_MOD,
	"R_MENTOR" = R_MENTOR,
	"R_HOST" = R_HOST,
	"R_INVESTIGATE" = R_INVESTIGATE,
	"R_MAXPERMISSION" = R_MAXPERMISSION,
))

DEFINE_BITFIELD(rights, list(
	"R_BUILDMODE" = R_BUILDMODE,
	"R_ADMIN" = R_ADMIN,
	"R_BAN" = R_BAN,
	"R_FUN" = R_FUN,
	"R_SERVER" = R_SERVER,
	"R_DEBUG" = R_DEBUG,
	"R_PERMISSIONS" = R_PERMISSIONS,
	"R_STEALTH" = R_STEALTH,
	"R_REJUVINATE" = R_REJUVINATE,
	"R_VAREDIT" = R_VAREDIT,
	"R_SOUNDS" = R_SOUNDS,
	"R_SPAWN" = R_SPAWN,
	"R_MOD" = R_MOD,
	"R_MENTOR" = R_MENTOR,
	"R_HOST" = R_HOST,
	"R_INVESTIGATE" = R_INVESTIGATE,
	"R_MAXPERMISSION" = R_MAXPERMISSION,
))

DEFINE_BITFIELD(muted, list(
	"MUTE_IC" = MUTE_IC,
	"MUTE_OOC" = MUTE_OOC,
	"MUTE_PRAY" = MUTE_PRAY,
	"MUTE_ADMINHELP" = MUTE_ADMINHELP,
	"MUTE_DEADCHAT" = MUTE_DEADCHAT,
	"MUTE_AOOC" = MUTE_AOOC,
	"MUTE_ALL" = MUTE_ALL,
))

DEFINE_BITFIELD(flags, list(
	"ANTAG_OVERRIDE_JOB" = ANTAG_OVERRIDE_JOB,
	"ANTAG_OVERRIDE_MOB" = ANTAG_OVERRIDE_MOB,
	"ANTAG_CLEAR_EQUIPMENT" = ANTAG_CLEAR_EQUIPMENT,
	"ANTAG_CHOOSE_NAME" = ANTAG_CHOOSE_NAME,
	"ANTAG_IMPLANT_IMMUNE" = ANTAG_IMPLANT_IMMUNE,
	"ANTAG_SUSPICIOUS" = ANTAG_SUSPICIOUS,
	"ANTAG_HAS_LEADER" = ANTAG_HAS_LEADER,
	"ANTAG_HAS_NUKE" = ANTAG_HAS_NUKE,
	"ANTAG_RANDSPAWN" = ANTAG_RANDSPAWN,
	"ANTAG_VOTABLE" = ANTAG_VOTABLE,
	"ANTAG_SET_APPEARANCE" = ANTAG_SET_APPEARANCE,
	"ANTAG_RANDOM_EXCEPTED" = ANTAG_RANDOM_EXCEPTED,
))

DEFINE_BITFIELD(disabilities, list(
	"NEARSIGHTED" = NEARSIGHTED,
	"EPILEPSY" = EPILEPSY,
	"COUGHING" = COUGHING,
	"TOURETTES" = TOURETTES,
	"NERVOUS" = NERVOUS,
))

DEFINE_BITFIELD(sdisabilities, list(
	"BLIND" = BLIND,
	"MUTE" = MUTE,
	"DEAF" = DEAF,
))

DEFINE_BITFIELD(vis_flags, list(
	"VIS_INHERIT_ICON" = VIS_INHERIT_ICON,
	"VIS_INHERIT_ICON_STATE" = VIS_INHERIT_ICON_STATE,
	"VIS_INHERIT_DIR" = VIS_INHERIT_DIR,
	"VIS_INHERIT_LAYER" = VIS_INHERIT_LAYER,
	"VIS_INHERIT_PLANE" = VIS_INHERIT_PLANE,
	"VIS_INHERIT_ID" = VIS_INHERIT_DIR,
	"VIS_UNDERLAY" = VIS_UNDERLAY,
	"VIS_HIDE" = VIS_HIDE,
))

DEFINE_BITFIELD(slot_flags, list(
	"SLOT_OCLOTHING" = SLOT_OCLOTHING,
	"SLOT_ICLOTHING" = SLOT_ICLOTHING,
	"SLOT_GLOVES" = SLOT_GLOVES,
	"SLOT_EYES" = SLOT_EYES,
	"SLOT_EARS" = SLOT_EARS,
	"SLOT_MASK" = VIS_INHERIT_DIR,
	"SLOT_HEAD" = VIS_UNDERLAY,
	"SLOT_FEET" = SLOT_FEET,
	"SLOT_ID" = SLOT_ID,
	"SLOT_BELT" = SLOT_BELT,
	"SLOT_BACK" = SLOT_BACK,
	"SLOT_POCKET" = SLOT_POCKET,
	"SLOT_DENYPOCKET" = SLOT_DENYPOCKET,
	"SLOT_TWOEARS" = SLOT_TWOEARS,
	"SLOT_TIE" = SLOT_TIE,
	"SLOT_HOLSTER" = SLOT_HOLSTER,
))

DEFINE_BITFIELD(obj_flags, list(
	"OBJ_FLAG_ANCHORABLE" = OBJ_FLAG_ANCHORABLE,
	"OBJ_FLAG_CONDUCTIBLE" = OBJ_FLAG_CONDUCTIBLE,
))

DEFINE_BITFIELD(mob_flags, list(
	"MOB_FLAG_HOLY_BAD" = MOB_FLAG_HOLY_BAD,
))

DEFINE_BITFIELD(item_flags, list(
	"ITEM_FLAG_NO_BLUDGEON" = ITEM_FLAG_NO_BLUDGEON,
	"ITEM_FLAG_PLASMAGUARD" = ITEM_FLAG_PLASMAGUARD,
	"ITEM_FLAG_NO_PRINT" = ITEM_FLAG_NO_PRINT,
	"ITEM_FLAG_THICKMATERIAL" = ITEM_FLAG_THICKMATERIAL,
	"ITEM_FLAG_STOPPRESSUREDAMAGE" = ITEM_FLAG_STOPPRESSUREDAMAGE,
	"ITEM_FLAG_AIRTIGHT" = ITEM_FLAG_AIRTIGHT,
	"ITEM_FLAG_NOSLIP" = ITEM_FLAG_NOSLIP,
	"ITEM_FLAG_BLOCK_GAS_SMOKE_EFFECT" = ITEM_FLAG_BLOCK_GAS_SMOKE_EFFECT,
	"ITEM_FLAG_PREMODIFIED" = ITEM_FLAG_PREMODIFIED,
	"ITEM_FLAG_IS_BELT" = ITEM_FLAG_IS_BELT,
))

DEFINE_BITFIELD(pass_flags, list(
	"PASS_FLAG_TABLE" = PASS_FLAG_TABLE,
	"PASS_FLAG_GLASS" = PASS_FLAG_GLASS,
	"PASS_FLAG_GRILLE" = PASS_FLAG_GRILLE,
	"PASS_FLAG_MOB" = PASS_FLAG_MOB,
	"ITEM_FLAG_STOPPRESSUREDAMAGE" = ITEM_FLAG_STOPPRESSUREDAMAGE,
	"ITEM_FLAG_AIRTIGHT" = ITEM_FLAG_AIRTIGHT,
	"ITEM_FLAG_NOSLIP" = ITEM_FLAG_NOSLIP,
	"ITEM_FLAG_BLOCK_GAS_SMOKE_EFFECT" = ITEM_FLAG_BLOCK_GAS_SMOKE_EFFECT,
	"ITEM_FLAG_PREMODIFIED" = ITEM_FLAG_PREMODIFIED,
	"ITEM_FLAG_IS_BELT" = ITEM_FLAG_IS_BELT,
))

DEFINE_BITFIELD(pass_flags, list(
	"CANSTUN" = CANSTUN,
	"CANWEAKEN" = CANWEAKEN,
	"CANPARALYSE" = CANPARALYSE,
	"CANPUSH" = CANPUSH,
	"LEAPING" = LEAPING,
	"PASSEMOTES" = PASSEMOTES,
	"GODMODE" = GODMODE,
	"FAKEDEATH" = FAKEDEATH,
	"NO_ANTAG" = NO_ANTAG,
	"XENO_HOST" = XENO_HOST,
	"FAKELIVING" = FAKELIVING,
	"UNDEAD" = UNDEAD,
))

DEFINE_BITFIELD(body_parts_covered, list(
	"NO_BODYPARTS" = NO_BODYPARTS,
	"HEAD" = HEAD,
	"FACE" = FACE,
	"EYES" = EYES,
	"UPPER_TORSO" = UPPER_TORSO,
	"LOWER_TORSO" = LOWER_TORSO,
	"LEG_LEFT" = LEG_LEFT,
	"LEG_RIGHT" = LEG_RIGHT,
	"LEGS" = LEGS,
	"FOOT_LEFT" = FOOT_LEFT,
	"FOOT_RIGHT" = FOOT_RIGHT,
	"FEET" = FEET,
	"LEG_RIGHT" = LEG_RIGHT,
	"LEGS" = LEGS,
	"ARM_LEFT" = ARM_LEFT,
	"ARM_RIGHT" = ARM_RIGHT,
	"ARMS" = ARMS,
	"HAND_LEFT" = HAND_LEFT,
	"HAND_RIGHT" = HAND_RIGHT,
	"HANDS" = HANDS,
	"FULL_BODY" = FULL_BODY,
))

DEFINE_BITFIELD(stat, list(
	"BROKEN" = BROKEN,
	"NOPOWER" = NOPOWER,
	"POWEROFF" = POWEROFF,
	"MAINT" = MAINT,
	"EMPED" = EMPED,
))

DEFINE_BITFIELD(material_flags, list(
	"MATERIAL_UNMELTABLE" = MATERIAL_UNMELTABLE,
	"MATERIAL_BRITTLE" = MATERIAL_BRITTLE,
	"MATERIAL_PADDING" = MATERIAL_PADDING,
))

DEFINE_BITFIELD(spell_flags, list(
	"GHOSTCAST" = GHOSTCAST,
	"NEEDSCLOTHES" = NEEDSCLOTHES,
	"NEEDSHUMAN" = NEEDSHUMAN,
	"Z2NOCAST" = Z2NOCAST,
	"STATALLOWED" = STATALLOWED,
	"IGNOREPREV" = IGNOREPREV,
	"INCLUDEUSER" = INCLUDEUSER,
	"SELECTABLE" = SELECTABLE,
	"IGNOREDENSE" = IGNOREDENSE,
	"IGNORESPACE" = IGNORESPACE,
	"CONSTRUCT_CHECK" = CONSTRUCT_CHECK,
	"NO_BUTTON" = NO_BUTTON,
	"LEG_RIGHT" = LEG_RIGHT,
	"LEGS" = LEGS,
	"ARM_LEFT" = ARM_LEFT,
	"ARM_RIGHT" = ARM_RIGHT,
	"ARMS" = ARMS,
	"HAND_LEFT" = HAND_LEFT,
	"HAND_RIGHT" = HAND_RIGHT,
	"HANDS" = HANDS,
	"FULL_BODY" = FULL_BODY,
))

DEFINE_BITFIELD(build_type, list(
	"IMPRINTER" = IMPRINTER,
	"PROTOLATHE" = PROTOLATHE,
	"MECHFAB" = MECHFAB,
	"CHASSIS" = CHASSIS,
))

DEFINE_BITFIELD(vamp_status, list(
	"VAMP_DRAINING" = VAMP_DRAINING,
	"VAMP_HEALING" = VAMP_HEALING,
	"VAMP_FRENZIED" = VAMP_FRENZIED,
	"VAMP_ISTHRALL" = VAMP_ISTHRALL,
	"VAMP_FULLPOWER" = VAMP_FULLPOWER,
))

DEFINE_BITFIELD(language_flags, list(
	"WHITELISTED" = WHITELISTED,
	"RESTRICTED" = RESTRICTED,
	"NONVERBAL" = NONVERBAL,
	"SIGNLANG" = SIGNLANG,
	"HIVEMIND" = HIVEMIND,
	"NONGLOBAL" = NONGLOBAL,
	"INNATE" = INNATE,
	"NO_TALK_MSG" = NO_TALK_MSG,
	"NO_STUTTER" = NO_STUTTER,
	"ALT_TRANSMIT" = ALT_TRANSMIT,
))
