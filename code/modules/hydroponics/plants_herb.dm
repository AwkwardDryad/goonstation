ABSTRACT_TYPE(/datum/plant/herb)
/datum/plant/herb
	plant_icon = 'icons/obj/hydroponics/plants_herb.dmi'
	category = "Herb"

/datum/plant/herb/contusine
	name = "Contusine"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#DD00AA"
	crop = /obj/item/plant/herb/contusine
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 10
	genome = 3
	assoc_reagents = list("salicylic_acid")
	mutations = list(/datum/plantmutation/contusine/shivering,/datum/plantmutation/contusine/quivering)

/datum/plant/herb/nureous
	name = "Nureous"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#226600"
	crop = /obj/item/plant/herb/nureous
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 10
	genome = 3
	mutations = list(/datum/plantmutation/nureous/fuzzy)
	commuts = list(/datum/plant_gene_strain/immunity_radiation,/datum/plant_gene_strain/damage_res/bad)
	assoc_reagents = list("anti_rad")

/datum/plant/herb/asomna
	name = "Asomna"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#00AA77"
	crop = /obj/item/plant/herb/asomna
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 15
	genome = 3
	assoc_reagents = list("ephedrine")
	mutations = list(/datum/plantmutation/asomna/robust)

/datum/plant/herb/commol
	name = "Commol"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#559900"
	crop = /obj/item/plant/herb/commol
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	genome = 16
	nectarlevel = 5
	commuts = list(/datum/plant_gene_strain/resistance_drought,/datum/plant_gene_strain/yield/stunted)
	assoc_reagents = list("silver_sulfadiazine")
	mutations = list(/datum/plantmutation/commol/burning)

/datum/plant/herb/ipecacuanha
	name = "Ipecacuanha"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#063c0f"
	crop = /obj/item/plant/herb/ipecacuanha
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	genome = 16
	nectarlevel = 5
	commuts = list(/datum/plant_gene_strain/resistance_drought,/datum/plant_gene_strain/yield/stunted)
	assoc_reagents = list("ipecac")
	mutations = list(/datum/plantmutation/ipecacuanha/bilious,/datum/plantmutation/ipecacuanha/invigorating)

/datum/plant/herb/venne
	name = "Venne"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#DDFF99"
	crop = /obj/item/plant/herb/venne
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 5
	genome = 1
	assoc_reagents = list("charcoal")
	mutations = list(/datum/plantmutation/venne/toxic,/datum/plantmutation/venne/curative)

/datum/plant/herb/mint
	name = "Mint"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#258934"
	crop = /obj/item/plant/herb/mint
	starthealth = 20
	growtime = 80
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 3
	nectarlevel = 5
	genome = 1
	assoc_reagents = list("mint")

/datum/plant/herb/cannabis
	name = "Cannabis"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#66DD66"
	crop = /obj/item/plant/herb/cannabis
	starthealth = 10
	growtime = 30
	harvtime = 80
	cropsize = 6
	harvests = 1
	endurance = 0
	vending = 2
	nectarlevel = 5
	genome = 2
	assoc_reagents = list("THC","CBD")
	mutations = list(/datum/plantmutation/cannabis/rainbow,/datum/plantmutation/cannabis/death,
	/datum/plantmutation/cannabis/white,/datum/plantmutation/cannabis/ultimate)
	commuts = list(/datum/plant_gene_strain/resistance_drought,/datum/plant_gene_strain/yield/stunted)

/datum/plant/herb/catnip
	name = "Nepeta Cataria"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#00CA70"
	crop = /obj/item/plant/herb/catnip
	starthealth = 10
	growtime = 30
	harvtime = 80
	cropsize = 6
	harvests = 1
	endurance = 0
	vending = 2
	genome = 1
	assoc_reagents = list("catonium")

/datum/plant/herb/hcordata
	name = "Houttuynia Cordata"
	plant_flags = FORCE_SEED_ON_HARVEST | USE_SPECIAL_PROC | USE_HARVESTED_PROC
	override_icon_state = "Houttuynia" //To avoid REALLY long icon state names
	seedcolor = "#00CA70"
	crop = /obj/item/plant/herb/hcordata
	mutations = list(/datum/plantmutation/hcordata/fish)
	starthealth = 10
	growtime = 30
	harvtime = 80
	cropsize = 6
	harvests = 1
	endurance = 0
	vending = 1
	genome = 1
	assoc_reagents = list("mercury")

/datum/plant/herb/poppy
	name = "Poppy"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#FF1500"
	crop = /obj/item/plant/herb/poppy
	starthealth = 10
	growtime = 50
	harvtime = 80
	cropsize = 4
	harvests = 1
	endurance = 0
	vending = 2
	genome = 1
	assoc_reagents = list("morphine")

/datum/plant/herb/aconite
	name = "Aconite"
	seedcolor = "#990099"
	crop = /obj/item/plant/herb/aconite
	starthealth = 10
	growtime = 60
	harvtime = 80
	cropsize = 2
	harvests = 1
	endurance = 0
	vending = 2
	genome = 1
	assoc_reagents = list("wolfsbane")

/datum/plant/herb/tobacco
	name = "Tobacco"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#82D213"
	crop = /obj/item/plant/herb/tobacco
	starthealth = 20
	growtime = 30
	harvtime = 80
	cropsize = 6
	harvests = 1
	endurance = 1
	genome = 2 //no idea if this was set to the right thing aaa
	nectarlevel = 5
	assoc_reagents = list("nicotine")
	mutations = list(/datum/plantmutation/tobacco/twobacco)
	commuts = list(/datum/plant_gene_strain/resistance_drought,/datum/plant_gene_strain/yield/stunted)

/datum/plant/herb/grass
	name = "Grass"
	plant_flags = SINGLE_HARVEST
	category = "Miscellaneous" //this seems inconsistent, shouldn't  this mean it belongs in plants_crop?
	seedcolor = "#00CC00"
	crop = /obj/item/plant/herb/grass
	starthealth = 10
	growtime = 15
	harvtime = 50
	harvests = 1
	cropsize = 8
	endurance = 10
	vending = 2
	genome = 4
	assoc_reagents = list("grassgro")
	commuts = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/health_poor)

/datum/plant/herb/witchhazel
	name = "Witch Hazel"
	plant_flags = NO_SIZE_SCALE | USE_SPECIAL_PROC
	seedcolor = "#B7B02D"
	crop = /obj/item/plant/herb/hazel
	starthealth = 10
	growtime = 200
	harvtime = 260
	cropsize = 2
	harvests = 1
	endurance = 0
	vending = 1 //temporary
	genome = 20
	assoc_reagents = list("witch_hazel")
	harvest_tools = list(TOOL_CUTTING,TOOL_SAWING,TOOL_SNIPPING)
	harvest_tool_message = "<span style=\"color:green\"><b>You carefully slice segments off the plant and harvest the sprigs of witch hazel.</b></span>"
	harvest_tool_fail_message = "<b>Hmm...You'll need a tool capable of cutting these branches...</b>"

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.harvtime + DNA.harvtime) && prob((10+DNA.cropsize))) //incrase probability with yield (10% is decent as a base level)
			var/obj/item/seed/S
			if (POT.current.unique_seed)
				S = unpool(POT.current.unique_seed)
				S.set_loc(POT)
			else
				S = unpool(/obj/item/seed)
				S.set_loc(POT)
				S.removecolor()
			var/datum/plantgenes/HDNA = DNA
			var/datum/plantgenes/SDNA = S.plantgenes

			if (!POT.current.unique_seed && !POT.current.hybrid)
				S.generic_seed_setup(POT.current)
			var/seedname = "[POT.current.name]"
			var/datum/plantmutation/MUT = POT.plantgenes.mutation

			if (istype(MUT,/datum/plantmutation/))
				if (!MUT.name_prefix && !MUT.name_prefix && MUT.name)
					seedname = "[MUT.name]"
				else if (MUT.name_prefix || MUT.name_suffix)
					seedname = "[MUT.name_prefix][POT.current.name][MUT.name_suffix]"
			S.name = "[seedname] seed"
			HYPpassplantgenes(HDNA,SDNA)
			S.generation = POT.generation

			if (POT.current.hybrid)
				var/datum/plant/hybrid = new /datum/plant(S)
				for(var/V in POT.current.vars)
					if (issaved(POT.current.vars[V]) && V != "holder")
						hybrid.vars[V] = POT.current.vars[V]
				S.planttype = hybrid
			S.set_loc(get_turf(POT))

			S.throwforce = DNA.potency
			playsound(POT,"sound/weapons/Gunshot.ogg",45,1)
			var/list/throw_targets = list()
			throw_targets += get_offset_target_turf(POT.loc, rand(5)-rand(5), rand(5)-rand(5))
			S.throw_at(pick(throw_targets), 5, 1)
			spawn(15)
				S.throwforce = 0

/datum/plant/herb/mandrake
	name = "Mandrake"
	plant_flags = NO_SIZE_SCALE | USE_HARVESTED_PROC
	seedcolor = "#bb7418"
	crop = /obj/item/reagent_containers/food/snacks/mandrake
	starthealth = 1
	growtime = 200
	harvtime = 260
	cropsize = 1
	harvests = 0
	endurance = 1
	vending = 1 //temporary
	genome = 16
	assoc_reagents = list("mandrake")
	required_reagents = list(list(id="poo",amount=100))

	HYPharvested_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		if (.) return
		POT.visible_message("<span style='color:red'><b>[user.name] places their foot against the hydroponics tray and violently tugs on the leaves of the mandrake!</b></span>")
		if(HYPaction_bar(POT,user,50)==1) //if it returned the escape value
			return 1 //escape harvest
		user.visible_message("<span style='color:red'><b>[user.name] yanks the mandrake out of the pot!</b></span>")
		if((POT.current.cropsize+POT.plantgenes.cropsize) > 0) //Caps the max output to 1 Mandrake by doing a fucky-wucky to the genes on harvest.
			POT.plantgenes.cropsize = 0
		POT.health = 1
		if((POT.current.cropsize+POT.plantgenes.cropsize) > 0)
			playsound(POT.loc, 'sound/voice/screams/mandrake_scree.ogg', 100, 0, 0, null)
			for (var/mob/living/M in all_hearers(world.view, POT.loc))
				if(issilicon(M) || isintangible(M))
					continue

				if(!M.ears_protected_from_sound()) //modified Hootingium effect
					boutput(M, "<span style=\"color:red\">The mandrake <b>SCREEEEEEAMS!!!</b></span>")
					var/checkdist = get_dist(M, POT.loc)
					var/weak = max(0, 30 * 0.2 * (3 - checkdist))
					var/misstep = 40
					var/ear_damage = max(0, 30 * 0.2 * (3 - checkdist))
					var/ear_tempdeaf = max(0, 30 * 0.2 * (5 - checkdist))

					M.apply_sonic_stun(weak, 0, misstep, 0, 0, ear_damage, ear_tempdeaf)
					take_bleeding_damage(M, null, 80, DAMAGE_CUT, 1, M.loc)  //Very Lound, much earbleeding
				else
					continue

/datum/plant/herb/Heather
	name = "Heather"
	plant_flags = NO_SIZE_SCALE
	seedcolor = "#872872"
	crop = /obj/item/plant/herb/heather
	starthealth = 1
	growtime = 100
	harvtime = 130
	cropsize = 1
	harvests = 0
	endurance = 1
	vending = 1 //temporary
	genome = 1
	preferred_water_level = 4
	assoc_reagents = list("heather_oil")
