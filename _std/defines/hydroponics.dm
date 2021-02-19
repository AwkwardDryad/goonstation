//#define GROWTHMODE_NORMAL (1<<0)
#define GROWTHMODE_WEED (1<<0)
#define GROWTHMODE_PLASMAVORE (1<<1)
#define GROWTHMODE_CARNIVORE (1<<2)

#define NO_SCAN (1<<3)
#define NO_THIRST (1<<4) //Won't die or halt growth from drought
#define NO_HARVEST (1<<5)
#define NO_EXTRACT (1<<6)
#define NO_SIZE_SCALE (1<<7) //Won't change produce sprite based on quality

#define SIMPLE_GROWTH (1<<8) //For boring decorative plants that don't do anything
#define FORCE_SEED_ON_HARVEST (1<<9) //An override so plants like synthmeat can give seeds
#define SINGLE_HARVEST (1<<10) //Dies after one harvest
#define NO_RENAME_HARVEST (1<<11) //Don't name the crop after the plant

#define USE_SPECIAL_PROC (1<<12) //Does this plant do something special when it's in the pot?
#define USE_ATTACKED_PROC (1<<13) //Does this plant react if you try to attack it?
#define USE_HARVESTED_PROC (1<<14)

#define has_plant_flag(x,y) HAS_FLAG(x:plant_flags, y)
#define add_plant_flag(x, y) (x:plant_flags |= y)
#define remove_plant_flag(x, y) (x:plant_flags &= ~y)
