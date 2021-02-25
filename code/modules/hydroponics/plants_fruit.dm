ABSTRACT_TYPE(/datum/plant/fruit)
/datum/plant/fruit
	plant_icon = 'icons/obj/hydroponics/plants_fruit.dmi'

/datum/plant/fruit/tomato
	name = "Tomato" // You want to capitalise this, it shows up in the seed vendor and plant pot
	seedcolor = "#CC0000" // Hex string for color. Don't forget the hash!
	crop = /obj/item/reagent_containers/food/snacks/plant/tomato
	starthealth = 20
	growtime = 75
	harvtime = 110
	cropsize = 3
	harvests = 3
	endurance = 3
	nectarlevel = 5
	genome = 18
	assoc_reagents = list("juice_tomato")
	gene_strains = list(/datum/plant_gene_strain/splicing,/datum/plant_gene_strain/quality/inferior)
	vending_details = "Gene Strains : Splice Enabler, Inferior Quality"

	infuse_from_plant(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch(reagent)
			if("phlogiston","infernite","thalmerite","sorium")
				if (prob(33))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tomato/incendiary)
			if("strange_reagent")
				if (prob(50))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tomato/killer)
			if("nicotine")
				if (prob(80))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/tomato/tomacco)

/datum/plant/fruit/grape
	name = "Grape"
	seedcolor = "#8800CC"
	crop = /obj/item/reagent_containers/food/snacks/plant/grape
	starthealth = 5
	growtime = 40
	harvtime = 120
	cropsize = 5
	harvests = 2
	endurance = 0
	genome = 20
	nectarlevel = 10
	mutations = list(/datum/plantmutation/grapes/green, /datum/plantmutation/grapes/fruit)
	gene_strains = list(/datum/plant_gene_strain/metabolism_fast,/datum/plant_gene_strain/seedless)
	vending_details = "Gene Strains : Fast Metabolism, Seedless"

/datum/plant/fruit/cherry
	name = "Cherry"
	seedcolor = "#CC0000"
	crop = /obj/item/reagent_containers/food/snacks/plant/cherry
	starthealth = 5
	growtime = 40
	harvtime = 120
	cropsize = 5
	harvests = 2
	endurance = 0
	genome = 20
	nectarlevel = 10
	assoc_reagents = list("juice_cherry")
	gene_strains = list(/datum/plant_gene_strain/metabolism_fast,/datum/plant_gene_strain/seedless)
	vending_details = "Gene Strains : Fast Metabolism, Seedless"

/datum/plant/fruit/orange
	name = "Orange"
	seedcolor = "#FF8800"
	crop = /obj/item/reagent_containers/food/snacks/plant/orange
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 2
	harvests = 3
	endurance = 3
	genome = 21
	nectarlevel = 10
	mutations = list(/datum/plantmutation/orange/blood, /datum/plantmutation/orange/clockwork)
	gene_strains = list(/datum/plant_gene_strain/splicing,/datum/plant_gene_strain/damage_res/bad)
	assoc_reagents = list("juice_orange")
	vending_details = "Contains orange juice.<br><br>Gene Strains : Splice Enabler, Vulnerability"

/datum/plant/fruit/melon
	name = "Melon"
	plant_flags = USE_SPECIAL_PROC
	seedcolor = "#33BB00"
	crop = /obj/item/reagent_containers/food/snacks/plant/melon
	starthealth = 80
	growtime = 120
	harvtime = 200
	cropsize = 2
	harvests = 5
	endurance = 5
	genome = 19
	assoc_reagents = list("water")
	nectarlevel = 15
	mutations = list(/datum/plantmutation/melon/george, /datum/plantmutation/melon/bowling)
	gene_strains = list(/datum/plant_gene_strain/immortal,/datum/plant_gene_strain/seedless)
	vending_details = "Contains water, unsurprisingly.<br><br>Gene Strains : Immortal, Seedless"

	infuse_from_plant(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch(reagent)
			if("helium")
				if (prob(50))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/melon/balloon)
			if("hydrogen")
				if (prob(50))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/melon/hindenballoon)

/datum/plant/fruit/chili
	name = "Chili"
	seedcolor = "#FF0000"
	crop = /obj/item/reagent_containers/food/snacks/plant/chili
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 3
	harvests = 3
	endurance = 3
	genome = 17
	assoc_reagents = list("capsaicin")
	mutations = list(/datum/plantmutation/chili/chilly,/datum/plantmutation/chili/ghost)
	gene_strains = list(/datum/plant_gene_strain/immunity_toxin,/datum/plant_gene_strain/growth_slow)
	vending_details = "Processes into hot sauce. Contains capsaicin.<br><br>Gene Strains : Toxin Immunity, Stunted Growth"

	infuse_from_plant(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		switch(reagent)
			if("cryostylane")
				if (prob(80))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/chili/chilly)
			if("cryoxadone")
				if (prob(40))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/chili/chilly)
			if("el_diablo")
				if (prob(60))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/chili/ghost)
			if("phlogiston")
				if (prob(95))
					DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/chili/ghost)

/datum/plant/fruit/apple
	name = "Apple"
	seedcolor = "#00AA00"
	crop = /obj/item/reagent_containers/food/snacks/plant/apple
	starthealth = 40
	growtime = 200
	harvtime = 260
	cropsize = 3
	harvests = 10
	endurance = 5
	genome = 19
	mutations = list(/datum/plantmutation/apple/poison)
	assoc_reagents = list("juice_apple")
	gene_strains = list(/datum/plant_gene_strain/quality,/datum/plant_gene_strain/unstable)
	vending_details = "Contains apple juice. Heals 1 unit of TOX, BURN, BRUTE, OXY, and BRAIN per bite.<br><br>Gene Strains : Superior Quality, Unstable"

/datum/plant/fruit/banana
	name = "Banana"
	seedcolor = "#CCFF99"
	crop = /obj/item/reagent_containers/food/snacks/plant/banana
	starthealth = 15
	growtime = 120
	harvtime = 160
	cropsize = 5
	harvests = 4
	endurance = 3
	genome = 15
	assoc_reagents = list("potassium")
	gene_strains = list(/datum/plant_gene_strain/immortal,/datum/plant_gene_strain/growth_slow)
	vending_details = "Contains potassium. Yummy.<br><br>Gene Strains : Immortal, Stunted Growth"

/datum/plant/fruit/lime
	name = "Lime"
	seedcolor = "#00FF00"
	crop = /obj/item/reagent_containers/food/snacks/plant/lime
	starthealth = 30
	growtime = 30
	harvtime = 100
	cropsize = 3
	harvests = 3
	endurance = 3
	genome = 21
	gene_strains = list(/datum/plant_gene_strain/photosynthesis,/datum/plant_gene_strain/splicing/bad)
	assoc_reagents = list("juice_lime")
	vending_details = "Contains lime juice, as you'd expect.<br><br>Gene Strains : Photosynthesis, Splice Blocker"

/datum/plant/fruit/lemon
	name = "Lemon"
	seedcolor = "#FFFF00"
	crop = /obj/item/reagent_containers/food/snacks/plant/lemon
	starthealth = 30
	growtime = 100
	harvtime = 130
	cropsize = 3
	harvests = 3
	endurance = 3
	genome = 21
	assoc_reagents = list("juice_lemon")
	vending_details = "Contains lemon juice. Clearly."

/datum/plant/fruit/pumpkin
	name = "Pumpkin"
	seedcolor = "#DD7733"
	crop = /obj/item/reagent_containers/food/snacks/plant/pumpkin
	starthealth = 60
	growtime = 100
	harvtime = 175
	cropsize = 2
	harvests = 4
	endurance = 10
	genome = 19
	gene_strains = list(/datum/plant_gene_strain/damage_res,/datum/plant_gene_strain/stabilizer)
	vending_details = "Make your own lantern!<br><br>Gene Strains : Damage Resistance, Stabilizer"

/datum/plant/fruit/avocado
	name = "Avocado"
	seedcolor = "#00CC66"
	crop = /obj/item/reagent_containers/food/snacks/plant/avocado
	starthealth = 20
	growtime = 65
	harvtime = 110
	cropsize = 3
	harvests = 2
	endurance = 4
	genome = 18

/datum/plant/fruit/eggplant
	name = "Eggplant"
	seedcolor = "#CCCCCC"
	crop = /obj/item/reagent_containers/food/snacks/plant/eggplant
	starthealth = 25
	growtime = 70
	harvtime = 110
	cropsize = 4
	harvests = 2
	endurance = 2
	genome = 18
	gene_strains = list(/datum/plant_gene_strain/mutations,/datum/plant_gene_strain/terminator)
	mutations = list(/datum/plantmutation/eggplant/literal)
	assoc_reagents = list("nicotine")
	vending_details = "Contains nicotine.<br><br>Gene Strains : Mutagenic, Terminator"

	infuse_from_plant(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if(reagent == "eggnog" && prob(80))
			DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/eggplant/literal)

/datum/plant/fruit/strawberry
	name = "Strawberry"
	seedcolor = "#FF2244"
	crop = /obj/item/reagent_containers/food/snacks/plant/strawberry
	starthealth = 10
	growtime = 60
	harvtime = 120
	cropsize = 2
	harvests = 3
	endurance = 1
	genome = 18
	nectarlevel = 10
	assoc_reagents = list("juice_strawberry")
	vending_details = "Contains strawberry juice."

/datum/plant/fruit/blueberry
	name = "Blueberry"
	seedcolor = "#0000FF"
	crop = /obj/item/reagent_containers/food/snacks/plant/blueberry
	starthealth = 10
	growtime = 60
	harvtime = 120
	cropsize = 2
	harvests = 3
	endurance = 1
	genome = 18
	nectarlevel = 10
	assoc_reagents = list("juice_blueberry")
	vending_details = "Contains blueberry juice."

/datum/plant/fruit/coconut
	name = "Coconut"
	seedcolor = "#4D2600"
	crop = /obj/item/reagent_containers/food/snacks/plant/coconut
	starthealth = 80
	growtime = 120
	harvtime = 200
	cropsize = 2
	harvests = 5
	endurance = 5
	genome = 19
	assoc_reagents = list("coconut_milk")
	vending_details = "Contains coconut milk, which is distinct from regular space milk."

/datum/plant/fruit/pineapple
	name = "Pineapple"
	seedcolor = "#F8D016"
	crop = /obj/item/reagent_containers/food/snacks/plant/pineapple
	starthealth = 30
	growtime = 100
	harvtime = 175
	cropsize = 3
	harvests = 4
	endurance = 10
	genome = 21
	vending_details = "Contains pineapple juice. Don't get in it your eyes."

/datum/plant/fruit/pear
	name = "Pear"
	seedcolor = "#3FB929"
	crop = /obj/item/reagent_containers/food/snacks/plant/pear
	starthealth = 40
	growtime = 200
	harvtime = 260
	cropsize = 3
	harvests = 10
	endurance = 5
	genome = 19
	nectarlevel = 10
	gene_strains = list(/datum/plant_gene_strain/quality)
	vending_details = "Can be fermented into cider.<br><br>Gene Strains : Superior Quality"


/*
	mutations = list(/datum/plantmutation/pear/sickly)
	infuse_from_plant(var/obj/item/seed/S,var/reagent)
		..()
		var/datum/plantgenes/DNA = S.plantgenes
		if (!DNA) return
		if(reagent == "urine")
			if (prob(50))
				DNA.mutation = HY_get_mutation_from_path(/datum/plantmutation/pear/sickly)
*/

/datum/plant/fruit/peach
	name = "Peach"
	seedcolor = "#DEBA5F"
	crop = /obj/item/reagent_containers/food/snacks/plant/peach
	starthealth = 40
	growtime = 200
	harvtime = 260
	cropsize = 3
	harvests = 10
	endurance = 5
	genome = 17
	nectarlevel = 10
	assoc_reagents = list("juice_peach")
	gene_strains = list(/datum/plant_gene_strain/quality)
	vending_details = "Contains peach juice. May contain The Presidents of the United States of America song references.<br><br>Gene Strains : Superior Quality"
