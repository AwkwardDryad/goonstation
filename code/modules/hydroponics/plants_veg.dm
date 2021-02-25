ABSTRACT_TYPE(/datum/plant/veg)
/datum/plant/veg
	plant_icon = 'icons/obj/hydroponics/plants_veg.dmi'

/datum/plant/veg/lettuce
	name = "Lettuce"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#006622"
	crop = /obj/item/reagent_containers/food/snacks/plant/lettuce
	starthealth = 30
	growtime = 40
	harvtime = 80
	cropsize = 8
	harvests = 1
	endurance = 5
	genome = 12
	gene_strains = list(/datum/plant_gene_strain/reagent_adder,/datum/plant_gene_strain/damage_res/bad)

/datum/plant/veg/cucumber
	name = "Cucumber"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#005622"
	crop = /obj/item/reagent_containers/food/snacks/plant/cucumber
	starthealth = 25
	growtime = 50
	harvtime = 100
	cropsize = 8
	harvests = 1
	endurance = 6
	genome = 19
	gene_strains = list(/datum/plant_gene_strain/damage_res,/datum/plant_gene_strain/stabilizer)

/datum/plant/veg/carrot
	name = "Carrot"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#774400"
	crop = /obj/item/reagent_containers/food/snacks/plant/carrot
	starthealth = 20
	growtime = 50
	harvtime = 100
	cropsize = 6
	harvests = 1
	endurance = 5
	genome = 16
	nectarlevel = 10
	gene_strains = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/mutations/bad)

/datum/plant/veg/potato
	name = "Potato"
	plant_flags = SINGLE_HARVEST
	seedcolor = "#555500"
	crop = /obj/item/reagent_containers/food/snacks/plant/potato
	starthealth = 40
	growtime = 80
	harvtime = 160
	cropsize = 4
	harvests = 1
	endurance = 10
	genome = 16
	nectarlevel = 6
	gene_strains = list(/datum/plant_gene_strain/damage_res,/datum/plant_gene_strain/stabilizer)
	vending_details = "Makes great French fries, batteries and captains.<br><br>Gene Strains : Damage Resistance, Stabilizer"

/datum/plant/veg/onion
	name = "Onion"
	seedcolor = "#DDFFDD"
	crop = /obj/item/reagent_containers/food/snacks/plant/onion
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 3
	harvests = 1
	endurance = 3
	genome = 13
	gene_strains = list(/datum/plant_gene_strain/splicing,/datum/plant_gene_strain/reagent_adder/toxic)
	vending_details = "Gene Strains : Splice Enabler, Toxic"

/datum/plant/veg/garlic
	name = "Garlic"
	seedcolor = "#BBDDBB"
	crop = /obj/item/reagent_containers/food/snacks/plant/garlic
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 3
	harvests = 1
	endurance = 3
	genome = 13
	gene_strains = list(/datum/plant_gene_strain/growth_fast,/datum/plant_gene_strain/terminator)
	vending_details = "Contains holy water. Not recommended for vampires.<br><br>Gene Strains : Rapid Growth, Terminator"
