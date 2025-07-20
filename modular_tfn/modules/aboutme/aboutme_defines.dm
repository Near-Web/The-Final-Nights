
// ================================
// AboutMe System Defines
// ================================

// ================================
// Chronicle Tags / Types
// ================================
#define CHRONICLE_TAG_EVENT        "event"
#define CHRONICLE_TAG_WAR          "war"
#define CHRONICLE_TAG_ROMANCE      "romance"
#define CHRONICLE_TAG_POLITICAL    "political"
#define CHRONICLE_TAG_PERSONAL     "personal"
#define CHRONICLE_TAG_TRAGEDY      "tragedy"
#define CHRONICLE_TAG_VICTORY      "victory"
#define CHRONICLE_TAG_DISCOVERY    "discovery"
#define CHRONICLE_TAG_RELATIONSHIP "relationship"

/// List of standard chronicle tags
#define CHRONICLE_TAGS list(\
	CHRONICLE_TAG_EVENT, \
	CHRONICLE_TAG_WAR, \
	CHRONICLE_TAG_ROMANCE, \
	CHRONICLE_TAG_POLITICAL, \
	CHRONICLE_TAG_PERSONAL, \
	CHRONICLE_TAG_TRAGEDY, \
	CHRONICLE_TAG_VICTORY, \
	CHRONICLE_TAG_DISCOVERY, \
	CHRONICLE_TAG_RELATIONSHIP \
)


// -------------------------
// Relationship Types
// -------------------------
#define REL_TYPE_SIRE         "sire"
#define REL_TYPE_CHILDE       "childe"
#define REL_TYPE_LOVER        "lover"
#define REL_TYPE_RIVAL        "rival"
#define REL_TYPE_ENEMY        "enemy"
#define REL_TYPE_FRIEND       "friend"
#define REL_TYPE_ALLY         "ally"
#define REL_TYPE_ACQUAINTANCE "acquaintance"
#define REL_TYPE_CONFIDANT    "confidant"
#define REL_TYPE_TARGET       "target"
#define REL_TYPE_OBSESSION    "obsession"
#define REL_TYPE_MAKER        "maker"
#define REL_TYPE_VICTIM       "victim"
#define REL_TYPE_COTERIE      "coterie"

// -------------------------
// Relationship Flags
// -------------------------
#define REL_FLAG_SECRET     (1 << 0) // Hidden from public view
#define REL_FLAG_POLITICAL  (1 << 1) // Involves clan/sect goals
#define REL_FLAG_BROKEN     (1 << 2) // Formerly close
#define REL_FLAG_OBSESSIVE  (1 << 3) // Extreme fixation
#define REL_FLAG_TENSION    (1 << 4) // On the verge of collapse
#define REL_FLAG_MAINTAINED (1 << 5) // Maintained consistently
#define REL_FLAG_NPC_ONLY   (1 << 6) // Invisible to players

// -------------------------
// Memory Tags
// -------------------------
// ================================
// Memory Tags
// ================================
#define MEMORY_TAG_BACKGROUND   "background"
#define MEMORY_TAG_CURRENT      "current"
#define MEMORY_TAG_RECENT       "recent"
#define MEMORY_TAG_GOAL         "goal"
#define MEMORY_TAG_SECRET       "secret"
#define MEMORY_TAG_REPUTATION   "reputation"
#define MEMORY_TAG_CHARACTER    "character"
#define MEMORY_TAG_GROUP        "group"
#define MEMORY_TAG_SECT         "sect"
#define MEMORY_TAG_CLAN         "clan"
#define MEMORY_TAG_COTERIE      "coterie"
#define MEMORY_TAG_EVENT        "event"
#define MEMORY_TAG_RELATIONSHIP "relationship"
#define MEMORY_TAG_PATH         "path"
#define MEMORY_TAG_DISCIPLINE   "discipline"

/// List of standard memory tags for AboutMe filtering
#define MEMORY_TAGS list(\
	MEMORY_TAG_BACKGROUND, \
	MEMORY_TAG_CURRENT, \
	MEMORY_TAG_RECENT, \
	MEMORY_TAG_GOAL, \
	MEMORY_TAG_SECRET, \
	MEMORY_TAG_REPUTATION, \
	MEMORY_TAG_CHARACTER, \
	MEMORY_TAG_GROUP, \
	MEMORY_TAG_SECT, \
	MEMORY_TAG_CLAN, \
	MEMORY_TAG_COTERIE, \
	MEMORY_TAG_EVENT, \
	MEMORY_TAG_RELATIONSHIP, \
	MEMORY_TAG_PATH, \
	MEMORY_TAG_DISCIPLINE \
)
