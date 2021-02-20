// This file is arguably where all the "content" of Hydroponics lies, the framework being taken
// care of mostly in plantpot.dm - though some of it is also based here. This file contains
// all plant species and mutations that aren't ones created specifically for setpieces.
//
// Other files you'll want if you're looking up on Hydroponics stuff:
// obj/item/plants_food_etc.dm: Most of the seed and produce items are in here.
// obj/item/hydroponics.dm: The tools players use to do hydro work are here.
// obj/machinery/plantpot.dm: The plantpot file, where most of the Stuff happens.
// obj/submachine/seed.dm: The splicer and reagent extractor are in here.

ABSTRACT_TYPE(/datum/plant)
/datum/plant/
	//Name and Sprites
	//--------------//
	var/name = "plant species name" 	// Name of the plant species
	var/sprite = null 					// The plant's normal sprite - overridden by special_icon
	var/plant_icon = null 				// If you need a new DMI for whatever reason. why not!
	var/override_icon_state = null 		// If you need the icon to be different to the name
	var/seedcolor = "#000000"			// color on the seed packet, if applicable

	//Stats
	//---//
	var/starthealth = 0 				// What health does this plant start at?
	var/endurance = 0 					// How much endurance this species normally has
	var/growtime = 0 					// How much faster this plant matures
	var/harvtime = 0 					// How much faster this plant produces harvests after maturing
	var/cropsize = 0 					// How many items you get per harvest
	var/harvests = 1 					// How many times you can harvest this species
	var/nectarlevel = 0 				//If nonzero, slowly tries to maintain this level of nectar reagent.
	var/genome = 0 						// Used for splicing - how "similar" the plants are = better odds of splice
	var/preferred_water_level = 3		//1-4 : amount of reagent in the pot

	//Vending
	//-----//
	var/in_vendor = 1					// Is this seed vendable?
	var/vending_details = "no description"	// Extra information on a given seed : appears in the seed market
	var/ticket_cost = 0					// How many tickets does this seed cost?
	var/category = null 				// Used for vendor filtering

	//Other
	//---//
	var/lasterr = 0						// logged error code when bad things happen
	var/harvest_tool_message 			// An output message for plants with unique harvest messages (string)
	var/harvest_tool_fail_message 		// A helpful output message to players when they attempt to harvest a plant by hand
	var/hybrid = 0 						// used for seed manipulator stuff
	var/unique_seed = null 				// Does this plant produce a paticular instance of seeds?
	var/crop = null 					// What crop does this plant produce?

	//Lists
	//---//
	var/plant_flags
	var/list/required_reagents 			// reagents required for the plant to grow - formated like: list(list(id="poo",amount=100),list(id="thing",amount=number))
	var/list/harvest_tools 				// For plants that don't harvest normally and need some sort of special tool (mixed list of tool flags and item paths)
	var/list/mutations = list() 		// what mutant variants does this plant have?
	var/list/commuts = list() 			// What general mutations can occur in this plant?
	var/list/assoc_reagents = list() 	// Used for extractions, harvesting, etc

	// fixed some runtime errors here - singh
	// hyp procs now return 0 for success and continue, any other number for error codes
	// for now its setup as ABB where A = proc type and B = error
	// proc 100: HYPspecial
	// proc 200: HYPattacked
	// proc 300: HYPharvested
	// proc 400: HYPspecial_M
	// proc 500: HYPattacked_M
	// error  1: called with null pot
	// error  2: called when plant is dead or no plant exists
	// error  3: called with a plant that is not ready to harvest
	// when overriding these in child types start the child proc with
	/*
		..()
		if (.) return
	*/
	// ..() calls the parent type which performs the check and returns 0 or an error code
	// . holds the return value, after ..() executes the child version continues running
	// so it needs to check . to check the return of the parent type and decide whether
	// or not to continue
	proc/HYPaction_bar(var/obj/machinery/plantpot/POT,var/mob/user,var/duration,var/datum/action/bar/icon/ACTION = /datum/action/bar/icon/harvest_plant)
		actions.start(new ACTION(POT,user,duration),user)
	#define POT_ACTIONNONE 0
	#define POT_ACTIONPASSED 1
	#define POT_ACTIONFAILED 2
	//defines for action bar harvesting yay :D 0 = no action, 1 = action passed, 2 = action cancelled
		while(!POT.actionpassed)
			sleep(10)
			if(POT.actionpassed == POT_ACTIONFAILED)
				POT.actionpassed = POT_ACTIONNONE
				return 1
			else if(POT.actionpassed == POT_ACTIONPASSED)
				break
		if(!POT.actionpassed)
			return 1
		if(POT.actionpassed == POT_ACTIONFAILED)
			POT.actionpassed = POT_ACTIONNONE
			return 1
		POT.actionpassed = POT_ACTIONNONE

	proc/HYPspecial_proc(var/obj/machinery/plantpot/POT)
		lasterr = 0
		if (!POT) lasterr = 101
		if (POT.dead || !POT.current) lasterr = 102
		if (lasterr)
			logTheThing("debug", null, null, "<b>Plant HYP</b> [src] in pot [POT] failed with error [.]")
			remove_plant_flag(src,USE_SPECIAL_PROC)
		return lasterr

	proc/HYPattacked_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		// If it returns 0, it should halt the proc that called it also
		lasterr = 0
		if (!POT || !user) lasterr = 201
		if (POT.dead || !POT.current) lasterr = 202
		if (lasterr)
			logTheThing("debug", null, null, "<b>Plant HYP</b> [src] in pot [POT] failed with error [.]")
			remove_plant_flag(src,USE_ATTACKED_PROC)
		return lasterr

	proc/HYPharvested_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		lasterr = 0
		if (!POT || !user) return 301
		if (POT.dead || !POT.current) return 302
		if (has_plant_flag(src,NO_HARVEST) || !src.crop) return 303
		if (lasterr)
			logTheThing("debug", null, null, "<b>Plant HYP</b> [src] in pot [POT] failed with error [.]")
			remove_plant_flag(src,USE_HARVESTED_PROC)
		return lasterr

	proc/HYPinfusionP(var/obj/item/seed/S,var/reagent)
		var/datum/plantgenes/DNA = S.plantgenes

		var/damage_prob = 100 - (src.endurance + DNA.endurance)
		damage_prob = max(0,min(100,damage_prob))
		var/damage_amt = 0
		switch (reagent)
			if ("phlogiston","infernite","thalmerite","sorium")
				damage_amt = rand(80,100)
			if ("pacid")
				damage_amt = rand(75,80)
			if ("acid")
				damage_amt = rand(40,50)
			if ("weedkiller")
				if (!HYPCheckCommut(DNA,/datum/plant_gene_strain/immunity_toxin) && has_plant_flag(src,GROWTHMODE_WEED))
					damage_amt = rand(50,60)
			if ("toxin","mercury","chlorine","fluorine","fuel","oil","cleaner")
				if (!HYPCheckCommut(DNA,/datum/plant_gene_strain/immunity_toxin))
					damage_amt = rand(15,30)
			if ("plasma")
				if (!HYPCheckCommut(DNA,/datum/plant_gene_strain/immunity_toxin))
					damage_amt = rand(15,30)
			if ("blood","bloodc")
				if (has_plant_flag(src,GROWTHMODE_CARNIVORE))
					DNA.growtime += rand(5,10)
					DNA.harvtime += rand(5,10)
					DNA.endurance += rand(10,30)
			if ("radium","uranium")
				damage_amt = rand(5,15)
				HYPmutateDNA(DNA,1)
				HYPnewcommutcheck(src,DNA)
				HYPnewmutationcheck(src,DNA)
			if ("dna_mutagen")
				HYPmutateDNA(DNA,1)
				HYPnewcommutcheck(src,DNA)
				HYPnewmutationcheck(src,DNA)
				if (prob(2))
					HYPaddCommut(DNA,/datum/plant_gene_strain/unstable)
			if ("mutagen")
				HYPmutateDNA(DNA,2)
				HYPnewcommutcheck(src,DNA)
				HYPnewmutationcheck(src,DNA)
				if (prob(5))
					HYPaddCommut(DNA,/datum/plant_gene_strain/unstable)
			if ("ammonia")
				damage_amt = rand(10,20)
				DNA.growtime += rand(5,10)
				DNA.harvtime += rand(2,5)
				if (prob(5))
					HYPaddCommut(DNA,/datum/plant_gene_strain/accelerator)
			if ("potash")
				DNA.cropsize += rand(1,4)
				DNA.harvests -= rand(0,2)
			if ("saltpetre")
				DNA.potency += rand(2,8)
				DNA.cropsize += rand(0,2)
			if ("space_fungus")
				DNA.endurance += rand(1,3)
				if (prob(3))
					HYPaddCommut(DNA,/datum/plant_gene_strain/damage_res)
			if ("mutadone")
				if (DNA.growtime < 0)
					DNA.growtime++
				if (DNA.harvtime < 0)
					DNA.harvtime++
				if (DNA.harvests < 0)
					DNA.harvests++
				if (DNA.cropsize < 0)
					DNA.cropsize++
				if (DNA.potency < 0)
					DNA.potency++
				if (DNA.endurance < 0)
					DNA.endurance++

		if (damage_amt)
			if (prob(damage_prob)) S.seeddamage += damage_amt
		if (S.seeddamage > 99)
			return 99 // destroy the seed

/datum/plantgenes/
	var/growtime = 0 // These vars are pretty much bonuses/penalties applied on top of the
	var/harvtime = 0 // same vars found in /datum/plant honestly. They go largely towards
	var/harvests = 0 // the same purpose for the most part.
	var/cropsize = 0
	var/potency = 0  // Apart from this one - this one deals with reagents.
	var/endurance = 0
	var/list/commuts = null // General transferrable mutations
	var/datum/plantmutation/mutation = null // is it mutated? if so which variation?
	var/list/alleles = list(0,0,0,0,0,0,0)
	// Order goes:
	// Species, Growtime, Harvtime, Cropsize, Harvests, Potency, Endurance
	// Species allele controls name, appearance, crop produce and mutations
	// 1 is dominant, else recessive

	New(var/loc,var/random_alleles = 1)
		..()
		if (random_alleles)
			src.alleles[1] = rand(0,1)
			src.alleles[2] = rand(0,1)
			src.alleles[3] = rand(0,1)
			src.alleles[4] = rand(0,1)
			src.alleles[5] = rand(0,1)
			src.alleles[6] = rand(0,1)
			src.alleles[7] = rand(0,1)
			// optimise this later

/datum/action/bar/icon/harvest_plant  //In the words of my forebears, "I really don't know a good spot to put this, so im putting it here, fuck you." Adds a channeled action to harvesting flagged plants.
	id = "harvest_plant"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 50
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

	var/obj/machinery/plantpot/plant_pot
	var/mob/living/carbon/human/source
	var/obj/item/toolcheck

	proc/reset()
		duration = 50
		icon = 'icons/mob/screen1.dmi'
		icon_state = "grabbed"

	New(var/obj/machinery/plantpot/POT,var/mob/living/carbon/human/sourcerelay,var/duration2)
		if(POT)
			plant_pot = POT
		if(sourcerelay)
			source = sourcerelay
		if(duration2)
			duration = duration2
		if(plant_pot.current.harvest_tools && (source.equipped() != null))
			var/obj/item/I = source.equipped()
			toolcheck = I
		..()

	onUpdate()
		if(plant_pot == null || source == null || (get_dist(source, plant_pot) > 1))
			interrupt(INTERRUPT_ALWAYS)
			plant_pot.actionpassed = POT_ACTIONFAILED
			reset()
			return
		if(source && (source.equipped() != toolcheck))
			interrupt(INTERRUPT_ALWAYS)
			plant_pot.actionpassed = POT_ACTIONFAILED
			reset()
			return
		if(!plant_pot.current)
			interrupt(INTERRUPT_ALWAYS)
			plant_pot.actionpassed = POT_ACTIONFAILED
			reset()
			return
		if(plant_pot.dead == 1)
			interrupt(INTERRUPT_ALWAYS)
			plant_pot.actionpassed = POT_ACTIONFAILED
			reset()
			return
		..()

	onEnd()
		..()
		plant_pot.actionpassed = POT_ACTIONPASSED
		reset()
