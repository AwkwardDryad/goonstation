ABSTRACT_TYPE(/datum/plant/crop)
/datum/plant/crop
	plant_icon = 'icons/obj/hydroponics/plants_crop.dmi'

/datum/plant/crop/bamboo
	name = "Bamboo"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#FCDA91"
	crop = /obj/item/material_piece/organic/bamboo
	starthealth = 15
	growtime = 20
	harvtime = 40
	cropsize = 5
	harvests = 1
	endurance = 0
	genome = 10
	preferred_water_level = 4
	gene_strains = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/health_poor)
	vending_details = "Produces bamboo stalks, which can be cut down to produce edible shoots.<br><br>Gene Strains : Rapid Growth, Poor Health"

/datum/plant/crop/wheat
	name = "Wheat"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#FFFF88"
	crop = /obj/item/plant/wheat
	starthealth = 15
	growtime = 40
	harvtime = 80
	cropsize = 5
	harvests = 1
	endurance = 0
	genome = 10
	preferred_water_level = 2
	mutations = list(/datum/plantmutation/wheat/steelwheat, /datum/plantmutation/wheat/durum)
	gene_strains = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/health_poor)
	vending_details = "Processes into flour.<br><br>Gene Strains : Rapid Growth, Poor Health"

	infuse_from_plant(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if (reagent == "iron")
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/wheat/steelwheat)

/datum/plant/crop/oat
	name = "Oat"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#CCFF88"
	crop = /obj/item/plant/oat
	starthealth = 20
	growtime = 60
	harvtime = 120
	cropsize = 5
	harvests = 1
	endurance = 0
	genome = 10
	gene_strains = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/health_poor)
	vending_details = "Processes into oatmeal.<br><br>Gene Strains : Rapid Growth, Poor Health"

/datum/plant/crop/rice
	name = "Rice"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#FFFFAA"
	crop = /obj/item/reagent_containers/food/snacks/ingredient/rice_sprig
	starthealth = 20
	growtime = 30
	harvtime = 70
	cropsize = 4
	harvests = 1
	endurance = 0
	genome = 8
	preferred_water_level = 4
	gene_strains = list(/datum/plant_gene_strain/yield,/datum/plant_gene_strain/health_poor)
	vending_details = "Processes into rice.<br><br>Gene Strains : Enhanced Yield, Poor Health"

/datum/plant/crop/beans
	name = "Bean"
	seedcolor = "#AA7777"
	crop = /obj/item/reagent_containers/food/snacks/plant/bean
	starthealth = 40
	growtime = 50
	harvtime = 130
	cropsize = 2
	harvests = 4
	endurance = 0
	genome = 6
	preferred_water_level = 4
	mutations = list(/datum/plantmutation/beans/jelly)
	gene_strains = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/metabolism_slow)
	assoc_reagents = list("nitrogen")
	vending_details = "Contains nitrogen. Eating it allows fart propulsion in Space!<br><br>Gene Strains : Toxic, Slow Metabolism"

/datum/plant/crop/peas
	name = "Peas"
	seedcolor = "#77AA77"
	crop = /obj/item/reagent_containers/food/snacks/plant/peas
	starthealth = 40
	growtime = 50
	harvtime = 130
	cropsize = 2
	harvests = 4
	endurance = 0
	genome = 8
	gene_strains = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/metabolism_slow)
	vending_details = "Gene Strains : Toxin Immunity, Slow Metabolsim"

/datum/plant/crop/corn
	name = "Corn"
	seedcolor = "#FFFF00"
	crop = /obj/item/reagent_containers/food/snacks/plant/corn
	starthealth = 20
	growtime = 60
	harvtime = 110
	cropsize = 3
	harvests = 3
	endurance = 2
	genome = 10
	mutations = list(/datum/plantmutation/corn/clear)
	gene_strains = list(/datum/plant_gene_strain/photosynthesis,/datum/plant_gene_strain/splicing/bad)
	assoc_reagents = list("cornstarch")
	vending_details = "Processes into popcorn. Contains corn starch.<br><br>Gene Strains : Photosynthesis, Splice Blocker"

/datum/plant/crop/synthmeat
	name = "Synthmeat"
	plant_flags = FORCE_SEED_ON_HARVEST | USE_SPECIAL_PROC
	seedcolor = "#550000"
	crop = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	starthealth = 5
	growtime = 60
	harvtime = 120
	cropsize = 3
	harvests = 2
	endurance = 3
	genome = 7
	preferred_water_level = 4
	assoc_reagents = list("synthflesh")
	required_reagents = list(list(id="blood",amount=10))
	mutations = list(/datum/plantmutation/synthmeat/butt,/datum/plantmutation/synthmeat/limb,/datum/plantmutation/synthmeat/brain,/datum/plantmutation/synthmeat/heart,/datum/plantmutation/synthmeat/eye)
	gene_strains = list(/datum/plant_gene_strain/yield,/datum/plant_gene_strain/unstable)
	vending_details = "Requires at least 10 units of blood to grow<br><br>Gene Strains : Enhanced Yield, Unstable"

	infuse_from_plant(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if (reagent == "nanites" && (DNA.mutation && istype(DNA.mutation,/datum/plantmutation/synthmeat/butt)))
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/synthmeat/butt/buttbot)

/obj/machinery/bot/buttbot/synth //Opinion: i personally think this should be in the same file as buttbots
	name = "Organic Buttbot" //TODO: This and synthbutts need to use the new green synthbutt sprites
	desc = "What part of this even makes any sense."

/datum/plant/crop/sugar
	name = "Sugar"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#BBBBBB"
	crop = /obj/item/plant/sugar
	starthealth = 10
	growtime = 30
	harvtime = 60
	cropsize = 7
	harvests = 1
	endurance = 0
	genome = 8
	preferred_water_level = 4
	gene_strains = list(/datum/plant_gene_strain/quality,/datum/plant_gene_strain/terminator)
	assoc_reagents = list("sugar")
	vending_details = "Processes into sugar. Contains, you guessed it, sugar.<br><br>Gene Strains : Superior Quality, Terminator"

/datum/plant/crop/soy
	name = "Soybean"
	seedcolor = "#CCCC88"
	crop = /obj/item/reagent_containers/food/snacks/plant/soy
	starthealth = 15
	growtime = 60
	harvtime = 105
	cropsize = 4
	harvests = 3
	endurance = 1
	genome = 7
	preferred_water_level = 4
	gene_strains = list(/datum/plant_gene_strain/metabolism_fast,/datum/plant_gene_strain/quality/inferior)
	assoc_reagents = list("grease")
	mutations = list(/datum/plantmutation/soy/soylent)
	vending_details = "Processes into milk. Conveniently contains space soybean oil.<br><br>Gene Strains : Fast Metabolism, Inferior Quality"

/datum/plant/crop/peanut
	name = "Peanut"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#999900"
	crop = /obj/item/reagent_containers/food/snacks/plant/peanuts
	starthealth = 40
	growtime = 80
	harvtime = 160
	cropsize = 4
	harvests = 1
	endurance = 10
	genome = 6
	vending_details = "Processes into peanut butter."

	infuse_from_plant(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch(reagent)
			if("bread")
				if (prob(10))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/peanut/sandwich)

/datum/plant/crop/cotton
	name = "Cotton"
	plant_flags = FORCE_SEED_ON_HARVEST | NO_RENAME_HARVEST
	seedcolor = "#FFFFFF"
	crop = /obj/item/raw_material/cotton
	starthealth = 10
	growtime = 40
	harvtime = 150
	cropsize = 4
	harvests = 4
	endurance = 0
	genome = 5
	preferred_water_level = 4
	gene_strains = list(/datum/plant_gene_strain/immunity_radiation,/datum/plant_gene_strain/metabolism_slow)
	vending_details = "Processes into fabric when used in a material processor.<br><br>Gene Strains : Radiation Immunity, Slow Metabolism"

/datum/plant/crop/tree // :effort:
	name = "Tree"
	plant_flags = FORCE_SEED_ON_HARVEST | USE_SPECIAL_PROC | USE_ATTACKED_PROC | NO_RENAME_HARVEST
	seedcolor = "#9C5E13"
	crop = /obj/item/material_piece/organic/wood
	starthealth = 40
	growtime = 200
	harvtime = 260
	cropsize = 3
	harvests = 10
	endurance = 5
	genome = 20
	preferred_water_level = 4
	mutations = list(/datum/plantmutation/tree/money, /datum/plantmutation/tree/rubber,/datum/plantmutation/tree/sassafras, /datum/plantmutation/tree/dog,/datum/plantmutation/tree/paper)
	gene_strains = list(/datum/plant_gene_strain/metabolism_fast,/datum/plant_gene_strain/metabolism_slow,/datum/plant_gene_strain/resistance_drought)
	vending_details = "Chainsaw the resulting log to get your very own barricade.<br><br>Gene Strains : Fast Metabolism, Slow Metabolism, Drought Resistance"

/datum/plant/crop/coffee
	name = "Coffee"
	seedcolor = "#302013"
	crop = /obj/item/reagent_containers/food/snacks/plant/coffeeberry
	starthealth = 40
	growtime = 50
	harvtime = 130
	cropsize = 4
	harvests = 5
	endurance = 0
	genome = 6
	gene_strains = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/metabolism_slow)
	vending_details = "Extracts into...coffee.<br><br>Gene Strains : Toxin Immunity, Slow Metabolism"
