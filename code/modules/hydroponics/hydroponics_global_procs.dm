proc/Hydro_seed_setup(var/datum/plant/PLANT,var/generic) // Creates a spawnable seed!
    var/obj/item/seed/SEED
    if(PLANT.unique_seed)
        SEED = unpool(PLANT.unique_seed)
    else
        SEED = unpool(/obj/item/seed)
        SEED.removecolor()

    if(generic)
        SEED.generic_seed_setup(PLANT)

    . = SEED

proc/Hydro_mutate_DNA(var/datum/plantgenes/DNA,var/severity = 1) // This proc jumbles up the variables in a plant's genes.
    if(!DNA)
        return
    if(Hydro_check_strain(/datum/plant_gene_strain/stabilizer))
        return
    DNA.growtime += rand(-10 * severity,10 * severity)
    DNA.harvtime += rand(-10 * severity,10 * severity)
    DNA.cropsize += rand(-2 * severity,2 * severity)
    if(prob(33)) DNA.harvests += rand(-1 * severity,1 * severity)
    DNA.potency += rand(-5 * severity,5 * severity)
    DNA.endurance += rand(-3 * severity,3 * severity)

proc/Hydro_new_mutation_check(var/datum/plant/P,var/datum/plantgenes/DNA,var/obj/machinery/plantpot/T)	// The check to see if a new mutation will be generated. 
    if(!P || !DNA)
        return
    if(Hydro_check_strain(/datum/plant_gene_strain/stabilizer))
        return
    if(P.mutations.len)
        for(var/datum/plantmutation/MUT in P.mutations)
            var/chance = MUT.chance
            if(DNA.gene_strains)
                for (var/datum/plant_gene_strain/mutations/M in DNA.gene_strains)
                    if(M.negative)
                        chance -= M.chance_mod
                    else
                        chance += M.chance_mod
            chance = max(0,min(chance,100))
            if(prob(chance) && Hydro_full_mutation_check(DNA))
                DNA.mutation = HY_get_mutation_from_path(MUT.type)
                if(T)
                    T.update_plant_overlays()
                    T.update_name()
                break

proc/Hydro_full_mutation_check(var/datum/plantgenes/DNA)	// This proc iterates through all of the various boundaries and requirements a mutation must have to appear.
    if(!DNA || !DNA.mutation)
        return
    var/datum/plantmutation/MUT = DNA.mutation
    if(!Hydro_sub_mutation_check(MUT.GTrange[1],MUT.GTrange[2],DNA.growtime))
        return 0
    if(!Hydro_sub_mutation_check(MUT.HTrange[1],MUT.HTrange[2],DNA.harvtime))
        return 0
    if(!Hydro_sub_mutation_check(MUT.HVrange[1],MUT.HVrange[2],DNA.harvests))
        return 0
    if(!Hydro_sub_mutation_check(MUT.CZrange[1],MUT.CZrange[2],DNA.cropsize))
        return 0
    if(!Hydro_sub_mutation_check(MUT.PTrange[1],MUT.PTrange[2],DNA.potency))
        return 0
    if(!Hydro_sub_mutation_check(MUT.ENrange[1],MUT.ENrange[2],DNA.endurance))
        return 0
    if(MUT.gene_strain && !Hydro_check_strain(DNA,MUT.gene_strain))
        return 0
    return 1

proc/Hydro_sub_mutation_check(var/lowerbound,var/upperbound,var/checkedvariable)
    // Part of mutationcheck_full. Just a simple mathematical check to keep the prior proc more compact and efficient.
    if(lowerbound || upperbound)
        if(lowerbound && checkedvariable < lowerbound)
            return 0
        if(upperbound && checkedvariable > upperbound)
            return 0
        return 1
    else return 1

proc/Hydro_add_strain(var/datum/plantgenes/DNA,var/strain)
    if(!DNA || !strain) return
    if(!ispath(strain)) return
    if(DNA.gene_strains)
        for (var/datum/plant_gene_strain/X in DNA.gene_strains)
            if(X.type == strain)
                return
    if(DNA.gene_strains)	// create a new list here (i.e. do not use +=) so as to not affect related seeds/plants
        DNA.gene_strains = DNA.gene_strains + HY_get_strain_from_path(strain)
    else
        DNA.gene_strains = list(HY_get_strain_from_path(strain))

proc/Hydro_new_strain_check(var/datum/plant/P,var/datum/plantgenes/DNA)	// This is the proc for checking if a new random gene strain will appear in the plant.
    if(!P || !DNA)
        return
    if(Hydro_check_strain(DNA,/datum/plant_gene_strain/stabilizer))
        return
    if(P.gene_strains.len > 0)
        var/datum/plant_gene_strain/MUT = null
        for(var/datum/plant_gene_strain/X in P.gene_strains)
            if(Hydro_check_strain(DNA,X.type))
                continue
            if(prob(X.chance))
                MUT = X
                break
        if(MUT)	// create a new list here (i.e. do not use +=) so as to not affect related seeds/plants
            if(DNA.gene_strains)
                DNA.gene_strains = DNA.gene_strains + MUT
            else
                DNA.gene_strains = list(MUT)

proc/Hydro_check_strain(var/datum/plantgenes/DNA, var/strain)	// This just checks to see if we have a paticular gene strain active.
    if(!DNA || !strain)
        return 0
    if(DNA.gene_strains)
        for(var/datum/plant_gene_strain/X in DNA.gene_strains)
            if(X.type == strain)
                return 1

proc/Hydro_pass_DNA(var/datum/plantgenes/PARENT,var/datum/plantgenes/CHILD)	// This is a proc used to copy genes from PARENT to CHILD.
    var/datum/plantmutation/MUT = PARENT.mutation
    CHILD.growtime = PARENT.growtime
    CHILD.harvtime = PARENT.harvtime
    CHILD.harvests = PARENT.harvests
    CHILD.cropsize = PARENT.cropsize
    CHILD.potency = PARENT.potency
    CHILD.endurance = PARENT.endurance
    
    CHILD.gene_strains = PARENT.gene_strains
    if(MUT) CHILD.mutation = new MUT.type(CHILD)

proc/Hydro_scan_DNA(var/mob/user,var/obj/scanned,var/datum/plant/P,var/datum/plantgenes/DNA)
	// This is the proc plant analyzers use to pop up their readout for the player.
	// Should be mostly self-explanatory to read through.
	//
	// I made some tweaks here for calls in the global scan_plant() proc (Convair880).
	if(!user || !DNA)
		return

	var/datum/plantmutation/MUT = DNA.mutation
	var/generation = 0

	if(has_plant_flag(P,NO_SCAN))
		user.show_text("<B>ERROR:</B> Genetic structure not recognized. Cannot scan.","red")
		return

	if(istype(scanned, /obj/machinery/plantpot))
		var/obj/machinery/plantpot/PP = scanned
		generation = PP.generation
	if(istype(scanned, /obj/item/seed/))
		var/obj/item/seed/S = scanned
		generation = S.generation
	if(istype(scanned, /obj/item/reagent_containers/food/snacks/plant/))
		var/obj/item/reagent_containers/food/snacks/plant/F = scanned
		generation = F.generation

	//would it not be better to put this information in the scanner itself?
	var/message = {"
		<table style='border-collapse: collapse; border: 1px solid black; margin: 0 0.25em; width: 100%;'>
			<caption>Analysis of \the <b>[scanned.name]</b></caption>
			<tr>
				<th style='white-space: nowrap;' width=0>Species</th><td colspan='3'>[P.name] ([DNA.alleles[1] ? "D" : "r"])</td>
			</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Generation</th><td style='text-align: right; white-space: nowrap;'>[generation]</td><td colspan=2 width=100%>&nbsp;</td>
			</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Maturation Rate</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.growtime]</td>
				<td width=0 style='text-align: center;'>[DNA.alleles[2] ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.growtime), 0, 100)]%; background-color: [DNA.growtime > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Production Rate</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.harvtime]</td>
				<td width=0 style='text-align: center;'>[DNA.alleles[3] ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.harvtime), 0, 100)]%; background-color: [DNA.harvtime > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Lifespan</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.harvests]</td>
				<td width=0 style='text-align: center;'>[DNA.alleles[4] ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.harvests), 0, 100)]%; background-color: [DNA.harvests > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Yield</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.cropsize]</td>
				<td width=0 style='text-align: center;'>[DNA.alleles[5] ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.cropsize), 0, 100)]%; background-color: [DNA.cropsize > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Potency</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.potency]</td>
				<td width=0 style='text-align: center;'>[DNA.alleles[6] ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.potency), 0, 100)]%; background-color: [DNA.potency > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Endurance</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.endurance]</td>
				<td width=0 style='text-align: center;'>[DNA.alleles[7] ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.endurance), 0, 100)]%; background-color: [DNA.endurance > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
		</table>
	[MUT ? "<font color='red'>Abnormal genetic patterns detected.</font>" : ""]
	"}

	if(DNA.gene_strains)
		var/list/gene_strains = list()
		for (var/datum/plant_gene_strain/X in DNA.gene_strains)
			gene_strains += "[X.name] [X.strain_type]"
		if(gene_strains.len)
			message += "[MUT ? "" : "<br>"]<font color='red'><b>Gene strains detected:</b> [gene_strains.Join(", ")]</font>"

	boutput(user, message)
	return