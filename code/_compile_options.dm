//#define TESTING				//By using the testing("message") proc you can create debug-feedback for people with this
								//uncommented, but not visible in the release version)

//#define DATUMVAR_DEBUGGING_MODE	//Enables the ability to cache datum vars and retrieve later for debugging which vars changed.

// Comment this out if you are debugging problems that might be obscured by custom error handling in world/Error
#ifdef DEBUG
#define USE_CUSTOM_ERROR_HANDLER
#endif

#ifdef TESTING
#define DATUMVAR_DEBUGGING_MODE

/*
* Enables extools-powered reference tracking system, letting you see what is referencing objects that refuse to hard delete.
*
* * Requires TESTING to be defined to work.
*/
//#define REFERENCE_TRACKING

///Method of tracking references without using extools. Slower, kept to avoid over-reliance on extools.
//#define LEGACY_REFERENCE_TRACKING
#ifdef LEGACY_REFERENCE_TRACKING

///Use the legacy reference on things hard deleting by default.
//#define GC_FAILURE_HARD_LOOKUP
#ifdef GC_FAILURE_HARD_LOOKUP
#define FIND_REF_NO_CHECK_TICK
#endif //ifdef GC_FAILURE_HARD_LOOKUP

#endif //ifdef LEGACY_REFERENCE_TRACKING

#define VISUALIZE_ACTIVE_TURFS	//Highlights atmos active turfs in green
#define TRACK_MAX_SHARE	//Allows max share tracking, for use in the atmos debugging ui
#endif //ifdef TESTING

/// If this is uncommented, we set up the ref tracker to be used in a live environment
/// And to log events to [log_dir]/harddels.log
//#define REFERENCE_DOING_IT_LIVE
#ifdef REFERENCE_DOING_IT_LIVE
// compile the backend
#define REFERENCE_TRACKING
// actually look for refs
#define GC_FAILURE_HARD_LOOKUP
#endif // REFERENCE_DOING_IT_LIVE

// If this is uncommented, we do a single run though of the game setup and tear down process with unit tests in between
// #define UNIT_TESTS

// If this is uncommented, will attempt to load and initialize prof.dll/libprof.so.
// We do not ship byond-tracy. Build it yourself here: https://github.com/mafemergency/byond-tracy/
// #define USE_BYOND_TRACY

// If defined, we will NOT defer asset generation till later in the game, and will instead do it all at once, during initiialize
//#define DO_NOT_DEFER_ASSETS

/// If this is uncommented, Autowiki will generate edits and shut down the server.
/// Prefer the autowiki build target instead.
// #define AUTOWIKI

/// If this is uncommented, will profile mapload atom initializations
// #define PROFILE_MAPLOAD_INIT_ATOM

/// If this is uncommented, force our verb processing into just the 2% of a tick
/// We normally reserve for it
/// NEVER run this on live, it's for simulating highpop only
// #define VERB_STRESS_TEST

#ifdef VERB_STRESS_TEST
/// Uncomment this to force all verbs to run into overtime all of the time
/// Essentially negating the reserve 2%

// #define FORCE_VERB_OVERTIME
#warn Hey brother, you're running in LAG MODE.
#warn IF YOU PUT THIS ON LIVE I WILL FIND YOU AND MAKE YOU WISH YOU WERE NEVE-
#endif

#ifndef PRELOAD_RSC //set to:
#define PRELOAD_RSC 2 // 0 to allow using external resources or on-demand behaviour;
#endif // 1 to use the default behaviour;
								// 2 for preloading absolutely everything;

#ifdef LOWMEMORYMODE
#define FORCE_MAP "_maps/runtimetown.json"
#endif

#if (DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD) && !defined(SPACEMAN_DMM)
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 516.1658 or higher
#endif

//Additional code for the above flags.
#ifdef TESTING
#warn compiling in TESTING mode. testing() debug messages will be visible.
#endif

#ifdef CIBUILDING
#define UNIT_TESTS
#endif

#ifdef CITESTING
#define TESTING
#endif

// A reasonable number of maximum overlays an object needs
// If you think you need more, rethink it
#define MAX_ATOM_OVERLAYS 100
