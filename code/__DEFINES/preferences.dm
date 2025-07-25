
//Preference toggles
#define SOUND_ADMINHELP			(1<<0)
#define SOUND_MIDI				(1<<1)
#define SOUND_AMBIENCE			(1<<2)
#define SOUND_LOBBY				(1<<3)
#define MEMBER_PUBLIC			(1<<4)
#define INTENT_STYLE			(1<<5)
#define MIDROUND_ANTAG			(1<<6)
#define SOUND_INSTRUMENTS		(1<<7)
#define SOUND_SHIP_AMBIENCE		(1<<8)
#define SOUND_PRAYERS			(1<<9)
#define ANNOUNCE_LOGIN			(1<<10)
#define SOUND_ANNOUNCEMENTS		(1<<11)
#define DISABLE_DEATHRATTLE		(1<<12)
#define DISABLE_ARRIVALRATTLE	(1<<13)
#define COMBOHUD_LIGHTING		(1<<14)
#define DEADMIN_ALWAYS			(1<<15)
#define DEADMIN_ANTAGONIST		(1<<16)
#define DEADMIN_POSITION_HEAD	(1<<17)
#define DEADMIN_POSITION_SECURITY	(1<<18)
#define DEADMIN_POSITION_SILICON	(1<<19)
#define SOUND_ENDOFROUND		(1<<20)
#define ADMIN_IGNORE_CULT_GHOST	(1<<21)
#define SOUND_COMBATMODE		(1<<22)

#define TOGGLES_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|SOUND_ENDOFROUND|MEMBER_PUBLIC|INTENT_STYLE|MIDROUND_ANTAG|SOUND_INSTRUMENTS|SOUND_SHIP_AMBIENCE|SOUND_PRAYERS|SOUND_ANNOUNCEMENTS|SOUND_COMBATMODE)

//Chat toggles
#define CHAT_OOC			(1<<0)
#define CHAT_DEAD			(1<<1)
#define CHAT_GHOSTEARS		(1<<2)
#define CHAT_GHOSTSIGHT		(1<<3)
#define CHAT_PRAYER			(1<<4)
#define CHAT_RADIO			(1<<5)
#define CHAT_PULLR			(1<<6)
#define CHAT_GHOSTWHISPER	(1<<7)
#define CHAT_GHOSTPDA		(1<<8)
#define CHAT_GHOSTRADIO 	(1<<9)
#define CHAT_BANKCARD		(1<<10)
#define CHAT_GHOSTLAWS		(1<<11)
#define CHAT_LOGIN_LOGOUT	(1<<12)
#define CHAT_ROLL_INFO		(1<<13)

#define TOGGLES_DEFAULT_CHAT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_PULLR|CHAT_GHOSTWHISPER|CHAT_GHOSTPDA|CHAT_GHOSTRADIO|CHAT_BANKCARD|CHAT_GHOSTLAWS|CHAT_LOGIN_LOGOUT|CHAT_GHOSTEARS) // CHAT_GHOSTEARS| [ChillRaccoon] - Removed due to request //[Lucifernix] - readded because fuck you!

#define PARALLAX_INSANE -1 //for show offs
#define PARALLAX_HIGH    0 //default.
#define PARALLAX_MED     1
#define PARALLAX_LOW     2
#define PARALLAX_DISABLE 3 //this option must be the highest number

#define PIXEL_SCALING_AUTO 0
#define PIXEL_SCALING_1X 1
#define PIXEL_SCALING_1_2X 1.5
#define PIXEL_SCALING_2X 2
#define PIXEL_SCALING_3X 3

#define SCALING_METHOD_NORMAL "normal"
#define SCALING_METHOD_DISTORT "distort"
#define SCALING_METHOD_BLUR "blur"

#define PARALLAX_DELAY_DEFAULT world.tick_lag
#define PARALLAX_DELAY_MED     1
#define PARALLAX_DELAY_LOW     2

#define SEC_DEPT_NONE "None"
#define SEC_DEPT_RANDOM "Random"
#define SEC_DEPT_ENGINEERING "Engineering"
#define SEC_DEPT_MEDICAL "Medical"
#define SEC_DEPT_SCIENCE "Science"
#define SEC_DEPT_SUPPLY "Supply"

// Playtime tracking system, see jobs_exp.dm
#define EXP_TYPE_LIVING			"Living"
#define EXP_TYPE_CREW			"Kindred"
#define EXP_TYPE_GAROU     "Garou"
#define EXP_TYPE_CAMARILLIA		"Camarilla Authorities"
#define EXP_TYPE_GANG			"Gangs"
#define EXP_TYPE_TREMERE		"Tremere"
#define EXP_TYPE_ANARCH			"Anarchs"
#define EXP_TYPE_OTHER_CITIZEN "Unaligned"
#define EXP_TYPE_NEUTRALS		"Neutrals"
#define EXP_TYPE_SABBAT         "Sabbat"
#define EXP_TYPE_ANTAG			"Antag"
#define EXP_TYPE_COUNCIL        "Camarilla Primogen Council"
#define EXP_TYPE_POLICE         "Police Force"
#define EXP_TYPE_SERVICES   "City Services"
#define EXP_TYPE_CLINIC   "St. John's Clinic"
#define EXP_TYPE_GIOVANNI   "Giovanni Family"
#define EXP_TYPE_TZIMISCE   "Tzimisce Mansion"
#define EXP_TYPE_WAREHOUSE      "Warehouse"
#define EXP_TYPE_NATIONAL_SECURITY      "National Security"
#define EXP_TYPE_PAINTED_CITY      "Sept of the Painted City"
#define EXP_TYPE_AMBERGLADE    "Sept of the Amberglade"
#define EXP_TYPE_SPIRAL    "Hive of the Poisoned Shore"
#define EXP_TYPE_CHURCH         "Church"
#define EXP_TYPE_SPECIAL		"Special"
#define EXP_TYPE_GHOST			"Ghost"
#define EXP_TYPE_ADMIN			"Admin"

//Flags in the players table in the db
#define DB_FLAG_EXEMPT 1

#define DEFAULT_CYBORG_NAME "Default Cyborg Name"


//Job preferences levels
#define JP_LOW 1
#define JP_MEDIUM 2
#define JP_HIGH 3

//randomised elements
#define RANDOM_HARDCORE "random_hardcore"
#define RANDOM_NAME "random_name"
#define RANDOM_NAME_ANTAG "random_name_antag"
#define RANDOM_BODY "random_body"
#define RANDOM_BODY_ANTAG "random_body_antag"
#define RANDOM_SPECIES "random_species"
#define RANDOM_GENDER "random_gender"
#define RANDOM_GENDER_ANTAG "random_gender_antag"
#define RANDOM_AGE "random_age"
#define RANDOM_AGE_ANTAG "random_age_antag"
#define RANDOM_UNDERWEAR "random_underwear"
#define RANDOM_UNDERWEAR_COLOR "random_underwear_color"
#define RANDOM_UNDERSHIRT "random_undershirt"
#define RANDOM_SOCKS "random_socks"
#define RANDOM_BACKPACK "random_backpack"
#define RANDOM_JUMPSUIT_STYLE "random_jumpsuit_style"
#define RANDOM_HAIRSTYLE "random_hairstyle"
#define RANDOM_HAIR_COLOR "random_hair_color"
#define RANDOM_FACIAL_HAIR_COLOR "random_facial_hair_color"
#define RANDOM_FACIAL_HAIRSTYLE "random_facial_hairstyle"
#define RANDOM_SKIN_TONE "random_skin_tone"
#define RANDOM_EYE_COLOR "random_eye_color"

//recommened client FPS
#define RECOMMENDED_FPS 40

//public image

#define INFO_KNOWN_UNKNOWN "Unknown"
#define INFO_KNOWN_CLAN_ONLY "Clan Only"
#define INFO_KNOWN_FACTION "Faction Only"
#define INFO_KNOWN_PUBLIC "Famous"
