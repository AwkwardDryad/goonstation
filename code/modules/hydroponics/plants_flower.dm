
//flowers n stuff
ABSTRACT_TYPE(/datum/plant/flower)
/datum/plant/flower
	plant_icon = 'icons/obj/hydroponics/plants_flower.dmi'

/datum/plant/flower/rose
	name = "Rose"
	plant_flags = FORCE_SEED_ON_HARVEST
	seedcolor = "#AA2222"
	crop = /obj/item/plant/flower/rose
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	endurance = 0
	nectarlevel = 12
	genome = 7
	mutations = list()
	gene_strains = list(/datum/plant_gene_strain/immunity_radiation,/datum/plant_gene_strain/damage_res/bad)
	vending_details = "Every rose has its thorn, and the ones on these might prick you if you pick them up while not wearing gloves; use wirecutters to remove them. Every rose has a name too; Examine it to find it!"
