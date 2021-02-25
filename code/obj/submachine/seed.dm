/obj/submachine/seed_manipulator/
	name = "PlantMaster Mk3"
	desc = "An advanced machine used for manipulating the genes of plant seeds. It also features an inbuilt seed extractor."
	density = 1
	anchored = 1
	mats = 10
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	icon = 'icons/obj/objects.dmi'
	icon_state = "geneman-on"
	flags = NOSPLASH
	var/mode = "overview"
	var/list/seeds = list()
	var/seedfilter = null
	var/seedoutput = 1
	var/dialogue_open = 0
	var/obj/item/seed/splicing1 = null
	var/obj/item/seed/splicing2 = null
	var/list/extractables = list()
	var/obj/item/reagent_containers/glass/inserted = null
	var/const/genes_header = {"
							<th><abbr title="Plant species">Type</abbr></th>
							<th class="genes"><abbr title="Genome">GN</abbr></th>
							<th class="genes"><abbr title="Generation">Gen</abbr></th>
							<th class="genes"><abbr title="Maturity Rate (how fast the plant reaches maturity)">MR<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Production Rate (how fast the plant produces harvests)">PR<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Lifespan (how many harvests it gives; higher is better)">LS<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Yield (how many crops are produced per harvest; higher is better)">Y<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Potency (how potent crops are; higher is better)">P<sup>?</sup></abbr></th>
							<th class="genes"><abbr title="Endurance (how resilient to damage the plant is; higher is better)">E<sup>?</sup></abbr></th>
							"}
	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attack_hand(var/mob/user as mob)
		src.add_dialog(user)

		//var/header_thing_chui_toggle = (user.client && !user.client.use_chui) ? "<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\"><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><meta http-equiv=\"pragma\" content=\"no-cache\"><style type='text/css'>body { font-family: Tahoma, sans-serif; font-size: 10pt; }</style></head><body>" : ""
		var/dat = list()
		dat += {"
			<style type="text/css">.l { text-align: left; } .r { text-align: right; } .c { text-align: center; } .hyp-dominant { font-weight: bold; background-color: rgba(160, 160, 160, 0.33);} .buttonlink { background: #66c; width: 1.1em; height: 1.2em; padding: 0.2em 0.2em; margin-bottom: 2px; border-radius: 4px; font-size: 90%; color: white; text-decoration: none; display: inline-block; vertical-align: middle; } .genes { min-width: 2em; } table { width: 100%; } td, th { border-bottom: 1px solid rgb(160, 160, 160); padding: 0.1em 0.2em; } .splicing { background-color: rgba(0, 255, 0, 0.5); } thead { background: rgba(160, 160, 160, 0.6); } abbr { text-decoration: underline; } .buttonlinks { white-space: nowrap; padding: 0; text-align: center; } </style>
			<h3 style='margin: 0;'>[src.name]</h3>
			<div style="float: right;">
				[src.inserted ? "<a href='?src=\ref[src];ejectbeaker=1' class='buttonlink'>&#9167;</a> [src.inserted] ([src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume]) &bull; " : "" ]
				[src.extractables.len > 0 ? "<a href='?src=\ref[src];ejectextractables=1' class='buttonlink'>&#9167;</a> " : "" ][src.extractables.len] extractable\s &bull;
				[src.seeds.len > 0 ? "<a href='?src=\ref[src];ejectseeds=1' class='buttonlink'>&#9167;</a> " : "" ][src.seeds.len] seed\s
			</div>
			<strong><a href='?src=\ref[src];page=1'>Overview</a> &bull; <a href='?src=\ref[src];page=2'>Seed Extraction</a> &bull; <a href='?src=\ref[src];page=3'>Seed List</a></strong>
			<hr>
		"}
		if (src.mode == "overview")
			dat += "<b><u>Overview</u></b><br><br>"

			if (src.inserted)
				dat += "<B>Receptacle:</B> [src.inserted] ([src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume]) <A href='?src=\ref[src];ejectbeaker=1'>(Eject)</A><BR>"
				dat += "<b>Contents:</b> "
				if(src.inserted.reagents.reagent_list.len)
					for(var/current_id in inserted.reagents.reagent_list)
						var/datum/reagent/current_reagent = inserted.reagents.reagent_list[current_id]
						dat += "<BR><i>[current_reagent.volume] units of [current_reagent.name]</i>"
				else
					dat += "Empty"
			else
				dat += "<B>No receptacle inserted!</B>"

			dat += "<br>"

			if(src.seeds.len)
				dat += "<BR><B>[src.seeds.len] Seeds Ready for Experimentation</B>"
			else
				dat += "<BR><B>No Seeds inserted!</B>"

			dat += "<br>"

			if(src.extractables.len)
				dat += "<BR><B>[src.extractables.len] Items Ready for Extraction</B>"
			else
				dat += "<BR><B>No Extractable Produce inserted!</B>"

		else if (src.mode == "extraction")
			dat += "<b><u>Seed Extraction</u></b><br>"
			if (src.seedoutput)
				dat += "<A href='?src=\ref[src];outputmode=1'>Extracted seeds will be ejected from the machine.</A>"
			else
				dat += "<A href='?src=\ref[src];outputmode=1'>Extracted seeds will be retained within the machine.</A>"
			dat += {"<br><br>
				<table>
					<thead>
					<tr>
						<th colspan="2">Name</th>
						<th colspan='1'>Controls</th>
						[genes_header]
					</tr>
					</thead>
					<tbody>
				"}

			if(src.extractables.len)
				for (var/obj/item/I in src.extractables)
					var/geneout = ""
					if (istype(I, /obj/item/seed))
						var/obj/item/seed/S = I
						geneout = QuickAnalysisRow(S, S.planttype, S.plantgenes)
					else if (istype(I, /obj/item/reagent_containers/food/snacks/plant))
						var/obj/item/reagent_containers/food/snacks/plant/S = I
						geneout = QuickAnalysisRow(S, S.planttype, S.plantgenes)

					dat += {"
					<tr>
						<td class='buttonlinks'><a href='?src=\ref[src];label=\ref[I]' title='Rename' class='buttonlink'>&#9998;</a>
						<a href='?src=\ref[src];analyze=\ref[I]' title='Analyze' class='buttonlink'>&#128269;</a>
						<a href='?src=\ref[src];eject=\ref[I]' title='Eject' class='buttonlink'>&#9167;</a></td>
						<th class='l'>[I.name]</th>
						<td><a href='?src=\ref[src];extract=\ref[I]'>Extract</a></td>
						[geneout]
					</tr>

					"}
			else
				dat += "<tr><th colspan='12'>No extractable produce inserted!</th></tr>"
			dat += "</table>"

		else if (src.mode == "seedlist")
			dat += "<b><u>Seed List</u></b><br>"
			if (src.seedfilter)
				dat += "<b><A href='?src=\ref[src];filter=1'>Filter:</A></b> \"[src.seedfilter]\"<br>"
			else
				dat += "<b><A href='?src=\ref[src];filter=1'>Filter:</A></b> None<br>"
			dat += "<br>"

			var/allow_infusion = 0
			if (src.inserted)
				if (src.inserted.reagents.total_volume) allow_infusion = 1

			dat += {"
				<table>
					<thead>
					<tr>
						<th colspan="2">Name</th>
						<th>Damage</th>
						<th colspan='2'>Controls</th>
						[genes_header]
					</tr>
					</thead>
					<tbody>
					"}
			if(src.seeds.len)
				for (var/obj/item/seed/S in src.seeds)
					if (!src.seedfilter || findtext(src.seedfilter, S.name, 1, null))
						dat += {"
							<tr [S == src.splicing1 ? "class='splicing'" : ""]>
								<td class='buttonlinks'><a href='?src=\ref[src];label=\ref[S]' title='Rename' class='buttonlink'>&#9998;</a>
								<a href='?src=\ref[src];analyze=\ref[S]' title='Analyze' class='buttonlink'>&#128269;</a>
								<a href='?src=\ref[src];eject=\ref[S]' title='Eject' class='buttonlink'>&#9167;</a></td>
								<th class='l'>[S.name]</th>
								<td class='r'>[S.seeddamage]%</td>
								<td class='c'>[S == src.splicing1 ? "<a href='?src=\ref[src];splice_cancel=1'>Cancel</a>" : "<a href='?src=\ref[src];splice_select=\ref[S]'>Splice</a>"]</td>
								<td class='c'>[allow_infusion ? "<a href='?src=\ref[src];infuse=\ref[S]'>Infuse</a>" : "Infuse"]</td>
								[QuickAnalysisRow(S, S.planttype, S.plantgenes)]
							</tr>
						"}
					else
						continue
			else
				dat += "<tr><th colspan='12'>No seeds inserted!</th></tr>"

			dat += "</tbody></table>"

		else if (src.mode == "splicing")
			if (src.splicing1 && src.splicing2)
				dat += {"<b><u>Seed Splicing</u></b><br>
				<table>
					<thead>
					<tr>
						<th>Seed</th>
						[genes_header]
					</tr>
					</thead>
					<tbody>
					<tr>
						<th class='l'><a href='?src=\ref[src];analyze=\ref[src.splicing1]'>[src.splicing1]</a></th>
						[QuickAnalysisRow(src.splicing1, src.splicing1.planttype, src.splicing1.plantgenes)]
					</tr>
					<tr>
						<th class='l'><a href='?src=\ref[src];analyze=\ref[src.splicing2]'>[src.splicing2]</a></th>
						[QuickAnalysisRow(src.splicing2, src.splicing2.planttype, src.splicing2.plantgenes)]
					</tr>
					</tbody>
				</table>
				"}

				var/splice_chance = 100
				var/datum/plant/P1 = src.splicing1.planttype
				var/datum/plant/P2 = src.splicing2.planttype

				var/genome_difference = 0
				if (P1.genome > P2.genome)
					genome_difference = P1.genome - P2.genome
				else
					genome_difference = P2.genome - P1.genome
				splice_chance -= genome_difference * 10

				splice_chance -= src.splicing1.seeddamage
				splice_chance -= src.splicing2.seeddamage

				if (src.splicing1.plantgenes.gene_strains)
					for (var/datum/plant_gene_strain/splicing/S in src.splicing1.plantgenes.gene_strains)
						if (S.negative)
							splice_chance -= S.splice_mod
						else
							splice_chance += S.splice_mod

				if (src.splicing2.plantgenes.gene_strains)
					for (var/datum/plant_gene_strain/splicing/S in src.splicing2.plantgenes.gene_strains)
						if (S.negative)
							splice_chance -= S.splice_mod
						else
							splice_chance += S.splice_mod

				splice_chance = max(0,min(splice_chance,100))

				dat += "<b>Chance of Successful Splice:</b> [splice_chance]%<br>"
				dat += "<A href='?src=\ref[src];splice=1'>(Proceed)</A> <A href='?src=\ref[src];splice_cancel=1'>(Cancel)</A><BR>"
				if (src.seedoutput)
					dat += "<A href='?src=\ref[src];outputmode=1'>New seeds will be ejected from the machine.</A>"
				else
					dat += "<A href='?src=\ref[src];outputmode=1'>New seeds will be retained within the machine.</A>"

			else
				dat += {"<b>Splice Error.</b><br>
				<A href='?src=\ref[src];page=3'>Please click here to return to the Seed List.</A>"}
		else
			dat += {"<b>Software Error.</b><br>
			<A href='?src=\ref[src];page=1'>Please click here to return to the Overview.</A>"}

		dat += {"<hr>
		Genetic display key: <span class='hyp-dominant'>Dominant</span> / Recessive
		"}

		user.Browse(jointext(dat, ""), "window=plantmaster;size=800x400")
		onclose(user, "rextractor")

	Topic(href, href_list)
		if((get_dist(usr,src) > 1) && !issilicon(usr) && !isAI(usr))
			boutput(usr, "<span class='alert'>You need to be closer to the machine to do that!</span>")
			return
		if(href_list["page"])
			var/ops = text2num(href_list["page"])
			switch(ops)
				if(2) src.mode = "extraction"
				if(3) src.mode = "seedlist"
				else src.mode = "overview"
			src.updateUsrDialog()

		else if(href_list["ejectbeaker"])
			if (!src.inserted) boutput(usr, "<span class='alert'>No receptacle found to eject.</span>")
			else
				src.inserted.set_loc(src.loc)
				usr.put_in_hand_or_eject(src.inserted) // try to eject it into the users hand, if we can
				src.inserted = null
			src.updateUsrDialog()

		else if(href_list["ejectseeds"])
			for (var/obj/item/seed/S in src.seeds)
				src.seeds.Remove(S)
				S.set_loc(src.loc)
				usr.put_in_hand_or_eject(S) // try to eject it into the users hand, if we can

			src.updateUsrDialog()

		else if(href_list["ejectextractables"])
			for (var/obj/item/I in src.extractables)
				src.extractables.Remove(I)
				I.set_loc(src.loc)
				usr.put_in_hand_or_eject(I) // try to eject it into the users hand, if we can

			src.updateUsrDialog()

		else if(href_list["eject"])
			var/obj/item/I = locate(href_list["eject"]) in src
			if (!istype(I))
				return
			if (istype(I,/obj/item/seed)) src.seeds.Remove(I)
			else src.extractables.Remove(I)
			I.set_loc(src.loc)
			usr.put_in_hand_or_eject(I) // try to eject it into the users hand, if we can
			src.updateUsrDialog()

		else if(href_list["label"])
			var/obj/item/I = locate(href_list["label"]) in src
			if (istype(I))
				var/newName = copytext(strip_html(input(usr,"What do you want to label [I.name]?","[src.name]",I.name) ),1, 129)
				if(newName && newName != I.name)
					phrase_log.log_phrase("seed", newName, no_duplicates=TRUE)
				if (newName && I && get_dist(src, usr) < 2)
					I.name = newName
			src.updateUsrDialog()

		else if(href_list["filter"])
			src.seedfilter = copytext(strip_html(input(usr,"Search for seeds by name? (Enter nothing to clear filter)","[src.name]",null)), 1, 257)
			src.updateUsrDialog()

		else if(href_list["analyze"])
			var/obj/item/I = locate(href_list["analyze"]) in src

			if (istype(I,/obj/item/seed/))
				var/obj/item/seed/S = I
				if (!istype(S.planttype,/datum/plant/) || !istype(S.plantgenes,/datum/plantgenes/))
					boutput(usr, "<span class='alert'>Genetic structure of seed corrupted. Cannot scan.</span>")
				else
					Hydro_scan_DNA(usr,S,S.planttype,S.plantgenes)

			else if (istype(I,/obj/item/reagent_containers/food/snacks/plant/))
				var/obj/item/reagent_containers/food/snacks/plant/P = I
				if (!istype(P.planttype,/datum/plant/) || !istype(P.plantgenes,/datum/plantgenes/))
					boutput(usr, "<span class='alert'>Genetic structure of item corrupted. Cannot scan.</span>")
				else
					Hydro_scan_DNA(usr,P,P.planttype,P.plantgenes)

			else
				boutput(usr, "<span class='alert'>Item cannot be scanned.</span>")
			src.updateUsrDialog()

		else if(href_list["outputmode"])
			src.seedoutput = !src.seedoutput
			src.updateUsrDialog()

		else if(href_list["extract"])
			var/obj/item/I = locate(href_list["extract"]) in src
			if (istype(I,/obj/item/reagent_containers/food/snacks/plant/))
				var/obj/item/reagent_containers/food/snacks/plant/P = I
				var/datum/plant/stored = P.planttype
				var/datum/plantgenes/DNA = P.plantgenes
				var/give = rand(2,5)

				if (!stored || !DNA)
					give = 0
				if (Hydro_check_strain(DNA,/datum/plant_gene_strain/seedless))
					give = 0
				if(has_plant_flag(stored,NO_EXTRACT))
					give = 0
				if (!give)
					boutput(usr, "<span class='alert'>No viable seeds found in [I].</span>")
				else
					boutput(usr, "<span class='notice'>Extracted [give] seeds from [I].</span>")
					while (give > 0)
						var/obj/item/seed/S
						if (stored.unique_seed) S = new stored.unique_seed(src)
						else S = new /obj/item/seed(src,0)
						var/datum/plantgenes/SDNA = S.plantgenes
						if (!stored.unique_seed && !stored.hybrid)
							S.generic_seed_setup(stored)
						Hydro_pass_DNA(DNA,SDNA)

						S.name = stored.name
						if (stored.hybrid)
							var/datum/plant/hybrid = new /datum/plant(S)
							for(var/V in stored.vars)
								if (issaved(stored.vars[V]) && V != "holder")
									hybrid.vars[V] = stored.vars[V]
							S.planttype = hybrid
							S.name = hybrid.name

						var/seedname = S.name
						if (DNA.mutation && istype(DNA.mutation,/datum/plantmutation/))
							var/datum/plantmutation/MUT = DNA.mutation
							if (!MUT.name_prefix && !MUT.name_prefix && MUT.name)
								seedname = "[MUT.name]"
							else if (MUT.name_prefix || MUT.name_suffix)
								seedname = "[MUT.name_prefix][seedname][MUT.name_suffix]"

						S.name = "[seedname] seed"

						S.generation = P.generation
						if (!src.seedoutput) src.seeds.Add(S)
						else S.set_loc(src.loc)
						give -= 1
				src.extractables.Remove(I)
				qdel(I)

			else
				boutput(usr, "<span class='alert'>This item is not viable extraction produce.</span>")
			src.updateUsrDialog()

		else if(href_list["splice_select"])
			var/obj/item/I = locate(href_list["splice_select"]) in src
			if (!istype(I))
				return
			if (src.splicing1)
				if (I == src.splicing1)
					src.splicing1 = null
				else
					src.splicing2 = I
					src.mode = "splicing"
			else
				src.splicing1 = I
			src.updateUsrDialog()

		else if(href_list["splice_cancel"])
			src.splicing1 = null
			src.splicing2 = null
			src.mode = "seedlist"
			src.updateUsrDialog()

		else if(href_list["infuse"])
			if (dialogue_open)
				return
			var/obj/item/seed/S = locate(href_list["infuse"]) in src
			if (!istype(S))
				return
			if (!src.inserted)
				boutput(usr, "<span class='alert'>No reagent container available for infusions.</span>")
			else
				if (src.inserted.reagents.total_volume < 10)
					boutput(usr, "<span class='alert'>You require at least ten units of a reagent to infuse a seed.</span>")
				else
					var/list/usable_reagents = list()
					var/datum/reagent/R = null
					for(var/current_id in src.inserted.reagents.reagent_list)
						var/datum/reagent/current_reagent = src.inserted.reagents.reagent_list[current_id]
						if (current_reagent.volume >= 10) usable_reagents += current_reagent

					if (!usable_reagents.len)
						boutput(usr, "<span class='alert'>You require at least ten units of a reagent to infuse a seed.</span>")
					else
						dialogue_open = 1
						R = input(usr, "Use which reagent to infuse the seed?", "[src.name]", 0) in usable_reagents
						if (!R || !S)
							return
						switch(S.infuse_from_seed(R.id,src))
							if (1) boutput(usr, "<span class='alert'>ERROR: Seed has been destroyed.</span>")
							if (2) boutput(usr, "<span class='alert'>ERROR: Reagent lost.</span>")
							if (3) boutput(usr, "<span class='alert'>ERROR: Unknown error. Please try again.</span>")
							else boutput(usr, "<span class='notice'>Infusion of [R.name] successful.</span>")
						src.inserted.reagents.remove_reagent(R.id,10)
						dialogue_open = 0

			src.updateUsrDialog()

		else if(href_list["splice"])
			// Get the seeds being spliced first
			var/obj/item/seed/seed1 = src.splicing1
			var/obj/item/seed/seed2 = src.splicing2

			// Now work out whether we fail to splice or not based on species compatability
			// And the health of the two seeds you're using
			var/splice_chance = 100
			var/datum/plant/P1 = seed1.planttype
			var/datum/plant/P2 = seed2.planttype
			// Sanity check - if something's wrong, just fail the splice and be done with it
			if (!P1 || !P2) splice_chance = 0
			else
				// Seeds from different families aren't easy to splice
				var/genome_difference = 0
				if (P1.genome > P2.genome)
					genome_difference = P1.genome - P2.genome
				else
					genome_difference = P2.genome - P1.genome
				splice_chance -= genome_difference * 10

				// Deduct chances if the seeds are damaged from infusing or w/e else
				splice_chance -= seed1.seeddamage
				splice_chance -= seed2.seeddamage

				if (seed1.plantgenes.gene_strains)
					for (var/datum/plant_gene_strain/splicing/S in seed1.plantgenes.gene_strains)
						if (S.negative)
							splice_chance -= S.splice_mod
						else
							splice_chance += S.splice_mod

				if (seed2.plantgenes.gene_strains)
					for (var/datum/plant_gene_strain/splicing/S in seed2.plantgenes.gene_strains)
						if (S.negative)
							splice_chance -= S.splice_mod
						else
							splice_chance += S.splice_mod

			// Cap probability between 0 and 100
			splice_chance = max(0,min(splice_chance,100))
			if (prob(splice_chance)) // We're good, so start splicing!
				// Create the new seed
				var/obj/item/seed/S = unpool(/obj/item/seed)
				S.set_loc(src)
				var/datum/plant/P = new /datum/plant(S)
				var/datum/plantgenes/DNA = new /datum/plantgenes(S)
				S.planttype = P
				S.plantgenes = DNA
				P.hybrid = 1
				S.generation = max(seed1.generation, seed2.generation) + 1

				var/datum/plantgenes/P1DNA = seed1.plantgenes
				var/datum/plantgenes/P2DNA = seed2.plantgenes

				var/dominance = P1DNA.alleles[1] - P2DNA.alleles[1]
				var/datum/plant/dominantspecies = null
				var/datum/plant/submissivespecies = null
				var/datum/plantgenes/dominantDNA = null
				var/datum/plantgenes/submissiveDNA = null

				// Establish which species allele is dominant
				if (dominance > 0)
					dominantspecies = P1
					submissivespecies = P2
					dominantDNA = P1DNA
					submissiveDNA = P2DNA
				else if (dominance < 0)
					dominantspecies = P2
					submissivespecies = P1
					dominantDNA = P2DNA
					submissiveDNA = P1DNA
				else
					// If neither, we pick randomly unlike the rest of the allele resolutions
					if (prob(50))
						dominantspecies = P1
						submissivespecies = P2
						dominantDNA = P1DNA
						submissiveDNA = P2DNA
					else
						dominantspecies = P2
						submissivespecies = P1
						dominantDNA = P2DNA
						submissiveDNA = P1DNA

				// Set up the base variables first
				/*
				if (!dominantspecies.hybrid)
					P.name = "Hybrid [dominantspecies.name]"
				else
					// Just making sure we dont get hybrid hybrid hybrid tomato seed or w/e
					P.name = "[dominantspecies.name]"
					*/
				if (dominantspecies.name != submissivespecies.name)
					var/part1 = copytext(dominantspecies.name, 1, round(length(dominantspecies.name) * 0.65 + 1.5))
					var/part2 = copytext(submissivespecies.name, round(length(submissivespecies.name) * 0.45 + 1), 0)
					P.name = "[part1][part2]"
				else
					P.name = dominantspecies.name

				P.sprite = dominantspecies.sprite
				if(dominantspecies.override_icon_state)
					P.override_icon_state = dominantspecies.override_icon_state
				else
					P.override_icon_state = dominantspecies.name
				P.plant_icon = dominantspecies.plant_icon
				P.crop = dominantspecies.crop
				if(has_plant_flag(dominantspecies,FORCE_SEED_ON_HARVEST))
					add_plant_flag(P,FORCE_SEED_ON_HARVEST)
				if(has_plant_flag(dominantspecies,SINGLE_HARVEST))
					add_plant_flag(P,SINGLE_HARVEST)
				if(has_plant_flag(dominantspecies,NO_HARVEST))
					add_plant_flag(P,NO_HARVEST)
				if(has_plant_flag(dominantspecies,NO_SCAN))
					add_plant_flag(P,NO_SCAN)
				if(has_plant_flag(dominantspecies,NO_SIZE_SCALE))
					add_plant_flag(P,NO_SIZE_SCALE)
				if(dominantspecies.harvest_tools)
					P.harvest_tools = dominantspecies.harvest_tools
					P.harvest_tool_message = dominantspecies.harvest_tool_message
					P.harvest_tool_fail_message = dominantspecies.harvest_tool_fail_message
				if(dominantspecies.preferred_water_level > P.preferred_water_level)
					P.preferred_water_level++
				else if(dominantspecies.preferred_water_level < P.preferred_water_level)
					P.preferred_water_level--
				P.harvests = dominantspecies.harvests
				P.nectarlevel = dominantspecies.nectarlevel
				S.name = "[P.name] seed"

				var/newgenome = P1.genome + P2.genome
				if (newgenome)
					newgenome = round(newgenome / 2)
				P.genome = newgenome

				for (var/datum/plantmutation/MUT in dominantspecies.mutations)
					// Only share the dominant species mutations or else shit might get goofy
					P.mutations += new MUT.type(P)

				if (dominantDNA.mutation)
					DNA.mutation = new dominantDNA.mutation.type(DNA)

				P.gene_strains = P1.gene_strains | P2.gene_strains // We merge these and share them
				DNA.gene_strains = P1DNA.gene_strains | P2DNA.gene_strains
				if(submissiveDNA.mutation)
					P.assoc_reagents = P1.assoc_reagents | P2.assoc_reagents | submissiveDNA.mutation.assoc_reagents // URS EDIT -- BOTANY UNLEASHED?
				else
					P.assoc_reagents = P1.assoc_reagents | P2.assoc_reagents

				// Now we start combining genetic traits based on allele dominance
				// If one is dominant and the other recessive, use the dominant value
				// If both are dominant or recessive, average the values out

				P.growtime = SpliceMK2(P1DNA.alleles[2],P2DNA.alleles[2],P1.vars["growtime"],P2.vars["growtime"])
				DNA.growtime = SpliceMK2(P1DNA.alleles[2],P2DNA.alleles[2],P1DNA.vars["growtime"],P2DNA.vars["growtime"])

				P.harvtime = SpliceMK2(P1DNA.alleles[3],P2DNA.alleles[3],P1.vars["harvtime"],P2.vars["harvtime"])
				DNA.harvtime = SpliceMK2(P1DNA.alleles[3],P2DNA.alleles[3],P1DNA.vars["harvtime"],P2DNA.vars["harvtime"])

				P.cropsize = SpliceMK2(P1DNA.alleles[4],P2DNA.alleles[4],P1.vars["cropsize"],P2.vars["cropsize"])
				DNA.cropsize = SpliceMK2(P1DNA.alleles[4],P2DNA.alleles[4],P1DNA.vars["cropsize"],P2DNA.vars["cropsize"])

				P.harvests = SpliceMK2(P1DNA.alleles[5],P2DNA.alleles[5],P1.vars["harvests"],P2.vars["harvests"])
				DNA.harvests = SpliceMK2(P1DNA.alleles[5],P2DNA.alleles[5],P1DNA.vars["harvests"],P2DNA.vars["harvests"])

				DNA.potency = SpliceMK2(P1DNA.alleles[6],P2DNA.alleles[6],P1DNA.vars["potency"],P2DNA.vars["potency"])

				P.endurance = SpliceMK2(P1DNA.alleles[7],P2DNA.alleles[7],P1.vars["endurance"],P2.vars["endurance"])
				DNA.endurance = SpliceMK2(P1DNA.alleles[7],P2DNA.alleles[7],P1DNA.vars["endurance"],P2DNA.vars["endurance"])

				boutput(usr, "<span class='notice'>Splice successful.</span>")
				if (!src.seedoutput) src.seeds.Add(S)
				else S.set_loc(src.loc)

			else
				// It fucked up - we don't need to do anything else other than tell the user
				boutput(usr, "<span class='alert'>Splice failed.</span>")

			// Now get rid of the old seeds and go back to square one
			src.seeds.Remove(seed1)
			src.seeds.Remove(seed2)
			src.splicing1 = null
			src.splicing2 = null
			qdel(seed1)
			qdel(seed2)
			src.mode = "seedlist"
			src.updateUsrDialog()

		else
			src.updateUsrDialog()

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if(src.inserted)
				boutput(user, "<span class='alert'>A container is already loaded into the machine.</span>")
				return
			src.inserted =  W
			user.drop_item()
			W.set_loc(src)
			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
			src.updateUsrDialog()

		else if(istype(W, /obj/item/reagent_containers/food/snacks/plant/) || istype(W, /obj/item/seed/))
			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
			user.u_equip(W)
			W.set_loc(src)
			if (istype(W, /obj/item/seed/)) src.seeds += W
			else src.extractables += W
			W.dropped()
			src.updateUsrDialog()
			return

		else if(istype(W,/obj/item/satchel/hydro))
			var/obj/item/satchel/S = W
			var/select = input(user, "Load what from the satchel?", "[src.name]", 0) in list("Everything","Fruit Only","Seeds Only","Never Mind")
			if (select != "Never Mind")
				var/loadcount = 0
				for (var/obj/item/I in S.contents)
					if (istype(I,/obj/item/seed/) && (select == "Everything" || select == "Seeds Only"))
						I.set_loc(src)
						src.seeds += I
						loadcount++
						continue
					if (istype(I,/obj/item/reagent_containers/food/snacks/plant/) && (select == "Everything" || select == "Fruit Only"))
						I.set_loc(src)
						src.extractables += I
						loadcount++
						continue
				if (loadcount)
					boutput(user, "<span class='notice'>[loadcount] items were loaded from the satchel!</span>")
				else
					boutput(user, "<span class='alert'>No items were loaded from the satchel!</span>")
				S.satchel_updateicon()
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!O || !user)
			return
		if (!isitem(O))
			return
		if (istype(O, /obj/item/reagent_containers/glass/) || istype(O, /obj/item/reagent_containers/food/drinks/) || istype(O,/obj/item/satchel/hydro))
			return src.attackby(O, user)
		if (istype(O, /obj/item/reagent_containers/food/snacks/plant/) || istype(O, /obj/item/seed/))
			user.visible_message("<span class='notice'>[user] begins quickly stuffing [O.name] into [src]!</span>")
			var/staystill = user.loc
			for(var/obj/item/P in view(1,user))
				sleep(0.2 SECONDS)
				if (!P) continue
				if (user.loc != staystill) break
				if (P.type == O.type)
					if (istype(O, /obj/item/seed/)) src.seeds.Add(P)
					else src.extractables.Add(P)
					P.set_loc(src)
				else continue
			boutput(user, "<span class='notice'>You finish stuffing items into [src]!</span>")
		else ..()

	proc/SpliceMK2(var/allele1,var/allele2,var/value1,var/value2)
		var/dominance = allele1 - allele2

		if (dominance > 0)
			return value1
		else if (dominance < 0)
			return value2
		else
			var/average = (value1 + value2)
			if (average != 0) average /= 2
			return round(average)




	proc/QuickAnalysisRow(var/obj/scanned, var/datum/plant/P, var/datum/plantgenes/DNA)
		// Largely copied from plantpot.dm
		if (!DNA) return

		var/generation = 0

		if (has_plant_flag(P,NO_SCAN))
			return "<td colspan='9' class='c'>Can't scan!</td>"

		if (istype(scanned, /obj/item/seed/))
			var/obj/item/seed/S = scanned
			generation = S.generation
		if (istype(scanned, /obj/item/reagent_containers/food/snacks/plant/))
			var/obj/item/reagent_containers/food/snacks/plant/F = scanned
			generation = F.generation

		return {"
		<td class='l [DNA.alleles[1] ? "hyp-dominant" : ""]'>[P.name]</td>
		<td class='r'>[P.genome]</td>
		<td class='r'>[generation]</td>
		<td class='r [DNA.alleles[2] ? "hyp-dominant" : ""]'>[DNA.growtime]</td>
		<td class='r [DNA.alleles[3] ? "hyp-dominant" : ""]'>[DNA.harvtime]</td>
		<td class='r [DNA.alleles[4] ? "hyp-dominant" : ""]'>[DNA.harvests]</td>
		<td class='r [DNA.alleles[5] ? "hyp-dominant" : ""]'>[DNA.cropsize]</td>
		<td class='r [DNA.alleles[6] ? "hyp-dominant" : ""]'>[DNA.potency]</td>
		<td class='r [DNA.alleles[7] ? "hyp-dominant" : ""]'>[DNA.endurance]</td>
		"}

////// Reagent Extractor

/obj/submachine/chem_extractor/
	name = "Reagent Extractor"
	desc = "A machine which can extract reagents from organic matter."
	density = 1
	anchored = 1
	mats = 6
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	icon = 'icons/obj/objects.dmi'
	icon_state = "reex-off"
	flags = NOSPLASH
	var/mode = "overview"
	var/autoextract = 0
	var/obj/item/reagent_containers/glass/extract_to = null
	var/obj/item/reagent_containers/glass/inserted = null
	var/obj/item/reagent_containers/glass/storage_tank_1 = null
	var/obj/item/reagent_containers/glass/storage_tank_2 = null
	var/list/ingredients = list()
	var/list/allowed = list(/obj/item/reagent_containers/food/snacks/,/obj/item/plant/,/obj/item/seashell)
	var/output_target = null

	New()
		..()
		src.storage_tank_1 = new /obj/item/reagent_containers/glass/beaker/extractor_tank(src)
		src.storage_tank_2 = new /obj/item/reagent_containers/glass/beaker/extractor_tank(src)
		var/count = 1
		for (var/obj/item/reagent_containers/glass/beaker/extractor_tank/ST in src.contents)
			ST.name = "Storage Tank [count]"
			count++
		output_target = src.loc

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attack_hand(var/mob/user as mob)
		src.add_dialog(user)

		var/list/dat = list("<B>Reagent Extractor</B><BR><HR>")
		if (src.mode == "overview")
			dat += "<b><u>Extractor Overview</u></b><br><br>"
			// Overview mode is just a general outline of what's in the machine at the time
			// Internal Storage Tanks
			if (src.storage_tank_1)
				dat += "<b>Storage Tank 1:</b> ([src.storage_tank_1.reagents.total_volume]/[src.storage_tank_1.reagents.maximum_volume])<br>"
				if(src.storage_tank_1.reagents.reagent_list.len)
					for(var/current_id in storage_tank_1.reagents.reagent_list)
						var/datum/reagent/current_reagent = storage_tank_1.reagents.reagent_list[current_id]
						dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i><br>"
				else dat += "Empty<BR>"
				dat += "<br>"
			else dat += "<b>Storage Tank 1 Missing!</b><br>"
			if (src.storage_tank_2)
				dat += "<b>Storage Tank 2:</b> ([src.storage_tank_2.reagents.total_volume]/[src.storage_tank_2.reagents.maximum_volume])<br>"
				if(src.storage_tank_2.reagents.reagent_list.len)
					for(var/current_id in storage_tank_2.reagents.reagent_list)
						var/datum/reagent/current_reagent = storage_tank_2.reagents.reagent_list[current_id]
						dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i><br>"
				else dat += "Empty<BR>"
				dat += "<br>"
			else dat += "<b>Storage Tank 2 Missing!</b><br>"
			// Inserted Beaker or whatever
			if (src.inserted)
				dat += "<B>Receptacle:</B> [src.inserted] ([src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume]) <A href='?src=\ref[src];ejectbeaker=1'>(Eject)</A><BR>"
				dat += "<b>Contents:</b> "
				if(src.inserted.reagents.reagent_list.len)
					for(var/current_id in inserted.reagents.reagent_list)
						var/datum/reagent/current_reagent = inserted.reagents.reagent_list[current_id]
						dat += "<BR><i>[current_reagent.volume] units of [current_reagent.name]</i>"
				else dat += "Empty<BR>"
			else dat += "<B>No receptacle inserted!</B><BR>"

			if(src.ingredients.len)
				dat += "<BR><B>[src.ingredients.len] Items Ready for Extraction</B>"
			else
				dat += "<BR><B>No Items inserted!</B>"

		else if (src.mode == "extraction")
			dat += "<b><u>Extraction Management</u></b><br><br>"
			if (src.autoextract)
				dat += "<b>Auto-Extraction:</b> <A href='?src=\ref[src];autoextract=1'>Enabled</A>"
			else
				dat += "<b>Auto-Extraction:</b> <A href='?src=\ref[src];autoextract=1'>Disabled</A>"
			dat += "<br>"
			if (src.extract_to)
				dat += "<b>Extraction Target:</b> <A href='?src=\ref[src];extracttarget=1'>[src.extract_to]</A> ([src.extract_to.reagents.total_volume]/[src.extract_to.reagents.maximum_volume])"
				if (src.extract_to == src.inserted) dat += "<A href='?src=\ref[src];ejectbeaker=1'>(Eject)</A>"
			else dat += "<A href='?src=\ref[src];extracttarget=1'><b>No current extraction target set.</b></A>"

			if(src.ingredients.len)
				dat += "<br><br><B>Extractable Items:</B><br><br>"
				for (var/obj/item/I in src.ingredients)
					dat += "* [I]<br>"
					dat += "<A href='?src=\ref[src];extractingred=\ref[I]'>(Extract)</A> <A href='?src=\ref[src];ejectingred=\ref[I]'>(Eject)</A><br>"
			else dat += "<br><br><B>No Items inserted!</B>"

		else if (src.mode == "transference")
			dat += "<b><u>Transfer Management</u></b><br><br>"

			if (src.inserted)
				dat += "<A href='?src=\ref[src];chemtransfer=\ref[src.inserted]'><b>[src.inserted]:</b></A> ([src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume]) <A href='?src=\ref[src];flush=\ref[src.inserted]'>(Flush All)</A> <A href='?src=\ref[src];ejectbeaker=1'>(Eject)</A><br>"
				if(src.inserted.reagents.reagent_list.len)
					for(var/current_id in inserted.reagents.reagent_list)
						var/datum/reagent/current_reagent = inserted.reagents.reagent_list[current_id]
						dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i> <A href='?src=\ref[src];flush=\ref[src.inserted];flush_reagent=[current_id]'>(X)</A><br>"
				else dat += "Empty<BR>"
			else dat += "<b>No receptacle inserted!</b><br>"

			dat += "<br>"

			dat += "<A href='?src=\ref[src];chemtransfer=\ref[src.storage_tank_1]'><b>Storage Tank 1:</b></A> ([src.storage_tank_1.reagents.total_volume]/[src.storage_tank_1.reagents.maximum_volume]) <A href='?src=\ref[src];flush=\ref[src.storage_tank_1]'>(Flush All)</A><br>"
			if(src.storage_tank_1.reagents.reagent_list.len)
				for(var/current_id in storage_tank_1.reagents.reagent_list)
					var/datum/reagent/current_reagent = storage_tank_1.reagents.reagent_list[current_id]
					dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i> <A href='?src=\ref[src];flush=\ref[src.storage_tank_1];flush_reagent=[current_id]'>(X)</A><br>"
			else dat += "Empty<BR>"

			dat += "<br>"
			dat += "<A href='?src=\ref[src];chemtransfer=\ref[src.storage_tank_2]'><b>Storage Tank 2:</b></A> ([src.storage_tank_2.reagents.total_volume]/[src.storage_tank_2.reagents.maximum_volume]) <A href='?src=\ref[src];flush=\ref[src.storage_tank_2]'>(Flush All)</A><br>"
			if(src.storage_tank_2.reagents.reagent_list.len)
				for(var/current_id in storage_tank_2.reagents.reagent_list)
					var/datum/reagent/current_reagent = storage_tank_2.reagents.reagent_list[current_id]
					dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i> <A href='?src=\ref[src];flush=\ref[src.storage_tank_2];flush_reagent=[current_id]'>(X)</A><br>"
			else dat += "Empty<BR>"

		else
			dat += {"<b>Software Error.</b><br>
			<A href='?src=\ref[src];page=1'>Please click here to return to the Overview.</A>"}

		dat += "<HR>"
		dat += "<b><u>Mode:</u></b> <A href='?src=\ref[src];page=1'>(Overview)</A> <A href='?src=\ref[src];page=2'>(Extraction)</A> <A href='?src=\ref[src];page=3'>(Transference)</A>"

		user.Browse(dat.Join(), "window=rextractor;size=370x500")
		onclose(user, "rextractor")

	handle_event(var/event, var/sender)
		if (event == "reagent_holder_update")
			src.updateUsrDialog()

	Topic(href, href_list)
		if(get_dist(usr,src) > 1 && !issilicon(usr) && !isAI(usr) )
			boutput(usr, "<span class='alert'>You need to be closer to the extractor to do that!</span>")
			return
		if(href_list["page"])
			var/ops = text2num(href_list["page"])
			switch(ops)
				if(2) src.mode = "extraction"
				if(3) src.mode = "transference"
				else src.mode = "overview"
			src.update_icon()
			src.updateUsrDialog()

		else if(href_list["ejectbeaker"])
			if (!src.inserted) boutput(usr, "<span class='alert'>No receptacle found to eject.</span>")
			else
				if (src.inserted == src.extract_to) src.extract_to = null
				src.inserted.set_loc(src.output_target)
				usr.put_in_hand_or_eject(inserted)
				src.inserted = null
			src.updateUsrDialog()

		else if(href_list["ejectingred"])
			var/obj/item/I = locate(href_list["ejectingred"]) in src
			if (istype(I))
				src.ingredients.Remove(I)
				I.set_loc(src.output_target)
				boutput(usr, "<span class='notice'>You eject [I] from the machine!</span>")
				src.update_icon()
			src.updateUsrDialog()

		else if (href_list["autoextract"])
			src.autoextract = !src.autoextract
			src.update_icon()
			src.updateUsrDialog()

		else if (href_list["flush_reagent"])
			var/id = href_list["flush_reagent"]
			var/obj/item/reagent_containers/T = locate(href_list["flush"]) in src
			if (istype(T, /obj/item/reagent_containers/food/drinks) || istype(T, /obj/item/reagent_containers/glass) && T.reagents)
				T.reagents.remove_reagent(id, 500)
			src.updateUsrDialog()

		else if (href_list["flush"])
			var/obj/item/reagent_containers/T = locate(href_list["flush"]) in src
			if (istype(T, /obj/item/reagent_containers/food/drinks) || istype(T, /obj/item/reagent_containers/glass) && T.reagents)
				T.reagents.clear_reagents()
			src.updateUsrDialog()

		else if(href_list["extracttarget"])
			var/list/ext_targets = list(src.storage_tank_1,src.storage_tank_2)
			if (src.inserted) ext_targets.Add(src.inserted)
			var/target = input(usr, "Extract to which target?", "Reagent Extractor", 0) in ext_targets
			if(get_dist(usr, src) > 1) return
			src.extract_to = target
			src.update_icon()
			src.updateUsrDialog()

		else if(href_list["extractingred"])
			if (!src.extract_to)
				boutput(usr, "<span class='alert'>You must first select an extraction target.</span>")
			else
				if (src.extract_to.reagents.total_volume == src.extract_to.reagents.maximum_volume)
					boutput(usr, "<span class='alert'>The extraction target is already full.</span>")
				else
					var/obj/item/I = locate(href_list["extractingred"]) in src
					if (!istype(I) || !I.reagents)
						return

					src.doExtract(I)
					src.ingredients -= I
					qdel(I)
			src.update_icon()
			src.updateUsrDialog()

		else if(href_list["chemtransfer"])
			var/obj/item/reagent_containers/glass/G = locate(href_list["chemtransfer"]) in src
			if (!G)
				boutput(usr, "<span class='alert'>Transfer target not found.</span>")
				src.updateUsrDialog()
				return
			else if (!G.reagents.total_volume)
				boutput(usr, "<span class='alert'>Nothing in container to transfer.</span>")
				src.updateUsrDialog()
				return

			var/list/ext_targets = list(src.storage_tank_1,src.storage_tank_2)
			if (src.inserted) ext_targets.Add(src.inserted)
			ext_targets.Remove(G)
			var/target = input(usr, "Transfer to which target?", "Reagent Extractor", 0) in ext_targets
			if(get_dist(usr, src) > 1) return
			var/obj/item/reagent_containers/glass/T = target

			if (!T) boutput(usr, "<span class='alert'>Transfer target not found.</span>")
			else if (G == T) boutput(usr, "<span class='alert'>Cannot transfer a container's contents to itself.</span>")
			else
				var/amt = input(usr, "Transfer how many units?", "Chemical Transfer", 0) as null|num
				if(get_dist(usr, src) > 1) return
				if (amt < 1) boutput(usr, "<span class='alert'>Invalid transfer quantity.</span>")
				else G.reagents.trans_to(T,amt)

			src.updateUsrDialog()

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if (isrobot(user))
			boutput(user, "This machine is not compatible with mechanical users.")
			return

		if(istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if(src.inserted)
				boutput(user, "<span class='alert'>A container is already loaded into the machine.</span>")
				return
			src.inserted =  W
			user.drop_item()
			W.set_loc(src)
			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
			src.updateUsrDialog()

		else if (istype(W,/obj/item/satchel/hydro))
			var/obj/item/satchel/S = W

			var/loadcount = 0
			for (var/obj/item/I in S.contents)
				for(var/check_path in src.allowed)
					if(istype(I, check_path))
						I.set_loc(src)
						src.ingredients += I
						loadcount++
						break

			if (loadcount)
				boutput(user, "<span class='notice'>[loadcount] items were loaded from the satchel!</span>")
			else
				boutput(user, "<span class='alert'>No items were loaded from the satchel!</span>")
			S.satchel_updateicon()
			src.update_icon()
			src.updateUsrDialog()

		else
			var/proceed = 0
			for(var/check_path in src.allowed)
				if(istype(W, check_path))
					proceed = 1
					break
			if (!proceed)
				boutput(user, "<span class='alert'>The extractor cannot accept that!</span>")
				return

			if (src.autoextract)
				if (!src.extract_to)
					boutput(user, "<span class='alert'>You must first select an extraction target if you want items to be automatically extracted.</span>")
					return
				if (src.extract_to.reagents.total_volume == src.extract_to.reagents.maximum_volume)
					boutput(user, "<span class='alert'>The extraction target is full.</span>")
					return

			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
			user.u_equip(W)
			W.dropped()

			if (src.autoextract)
				src.doExtract(W)
				qdel(W)
			else
				W.set_loc(src)
				src.ingredients += W
			src.update_icon()
			src.updateUsrDialog()
			return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (istype(O, /obj/item/reagent_containers/glass/) || istype(O, /obj/item/reagent_containers/food/drinks/) || istype(O, /obj/item/satchel/hydro))
			return src.attackby(O, user)
		var/proceed = 0
		for (var/check_path in src.allowed)
			if (istype(O, check_path))
				proceed = 1
				break
		if (!proceed) ..()
		else
			user.visible_message("<span class='notice'>[user] begins quickly stuffing [O.name] into [src]!</span>")
			var/staystill = user.loc
			for (var/obj/item/P in view(1,user))
				sleep(0.2 SECONDS)
				if (user.loc != staystill) break
				if (P.type == O.type)
					src.ingredients.Add(P)
					P.set_loc(src)
				else continue
			boutput(user, "<span class='notice'>You finish stuffing items into [src]!</span>")
		src.update_icon()

	MouseDrop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the extractor's output target.</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>The extractor is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set the extractor to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

/obj/submachine/chem_extractor/proc/update_icon()
	if (src.ingredients.len)
		src.icon_state = "reex-on"
	else
		src.icon_state = "reex-off"

/obj/submachine/chem_extractor/proc/doExtract(var/obj/item/I)
	// Welp -- we don't want anyone extracting these. They'll probably
	// feed them to monkeys and then exsanguinate them trying to get at the chemicals.
	if (istype(I, /obj/item/reagent_containers/food/snacks/candy/jellybean/everyflavor))
		src.extract_to.reagents.add_reagent("sugar", 50)
		return

	I.reagents.trans_to(src.extract_to, I.reagents.total_volume)
	src.update_icon()

/obj/submachine/seed_manipulator/kudzu
	name = "KudzuMaster V1"
	desc = "A strange \"machine\" that seems to function via fluids and plant fibers."
	mats = 0
	deconstruct_flags = null
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "seed-gene-console"
	_health = 1

	disposing()
		var/turf/T = get_turf(src)
		for (var/obj/O in seeds)
			O.set_loc(T)
		src.visible_message("<span class='alert'>All the seeds spill out of [src]!</span>")
		..()
	attack_ai(var/mob/user as mob)
		return 0

	attack_hand(var/mob/user as mob)
		if (iskudzuman(user))
			..()
		else
			boutput(user, "<span class='notice'>You stare at the bit that looks most like a screen, but you can't make heads or tails of what it's saying.!</span>")

	//only kudzumen can understand it.
	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if (!W) return
		if (!user) return

		if (destroys_kudzu_object(src, W, user))
			//Takes at least 2 hits to kill.
			if (_health)
				_health = 0
				return

			if (prob(40))
				user.visible_message("<span class='alert'>[user] savagely attacks [src] with [W]!</span>")
			else
				user.visible_message("<span class='alert'>[user] savagely attacks [src] with [W], destroying it!</span>")
				qdel(src)
				return
		..()

/obj/item/hydro_ticket
	name = "ticket"
	desc = "a reward for growing plants!"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "ticket-1"
	inventory_counter_enabled = 1
	var/value = 1

	New()
		..()
		inventory_counter.update_number(value)

	proc/update_sprite()
		if(value >= 30)
			icon_state = "ticket-3"
		else if(value >= 15)
			icon_state = "ticket-2"
		else if(value >= 1)
			icon_state = "ticket-1"
		if(value > 1)
			name = "stack of tickets"
			desc = "a reward for growing plants! There are [value] tickets in this stack!"
		else if(value <= 1)
			name = "ticket"
			desc = "a reward for growing plants!"
			if(value < 1)
				value = 1
		inventory_counter.update_number(value)

	attackby(var/obj/item/W,var/mob/user)
		if(istype(W,/obj/item/hydro_ticket))
			var/obj/item/hydro_ticket/TICKET = W
			user.u_equip(TICKET)
			value += TICKET.value
			update_sprite()
			qdel(TICKET)
		else
			..()

	attack_hand(var/mob/user)
		if(loc == user)
			var/amount = round(input("How many tickets would you like to take from the [name]?") as null|num)
			if(!amount)
				return
			if(amount > value)
				amount = value
			if(amount && loc == user && !user.equipped())
				var/obj/item/hydro_ticket/TICKET = new /obj/item/hydro_ticket
				src.value -= amount
				TICKET.value = amount
				TICKET.update_sprite()
				user.put_in_hand_or_drop(TICKET)

				if(!value)
					user.u_equip(src)
					qdel(src)
				else
					update_sprite()
		else
			..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		SPAWN_DBG(0.2 SECONDS)
			if(istype(O,/obj/item/hydro_ticket))
				for(var/obj/item/hydro_ticket/TICKET in range(1,user))
					if(TICKET == src)
						continue
					value += TICKET.value
					qdel(TICKET)
					update_sprite()
					sleep(0.2 SECONDS)

/obj/submachine/seed_vendor
	name = "seed market"
	desc = "A vending....gachapon....ticket machine....Someone had waaay too much fun making this thing."
	mats = 6
	flags = TGUI_INTERACTIVE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_MULTITOOL
	icon = 'icons/obj/vending.dmi'
	icon_state = "seed_market"
	density = TRUE
	anchored = TRUE
	var/tickets = 0
	var/tab = 1
	var/list/crop = list()
	var/list/fruit = list()
	var/list/vegetable = list()
	var/list/herb = list()
	var/list/flower = list()
	var/list/weed = list()
	var/list/alien = list()
	var/list/to_ui = list()
	var/target_path
	var/gacha_cost = 10

	proc/sort_plant_list(var/list/L)
		for(var/i = 1; i <= L.len; i++)
			for(var/j = i+1; j <= L.len; j++)
				if(sorttext(L[i]["name"], L[j]["name"]) == -1)
					L.Swap(i, j)

	New()
		..()
		for(var/plant in concrete_typesof(/datum/plant/crop))
			var/datum/plant/PLANT = new plant
			crop += list(list("name"=PLANT.name,"path"=PLANT.type,"desc"=PLANT.vending_details,"cost"=PLANT.ticket_cost))

		for(var/plant in concrete_typesof(/datum/plant/fruit))
			var/datum/plant/PLANT = new plant
			fruit += list(list("name"=PLANT.name,"path"=PLANT.type,"desc"=PLANT.vending_details,"cost"=PLANT.ticket_cost))

		for(var/plant in concrete_typesof(/datum/plant/veg))
			var/datum/plant/PLANT = new plant
			vegetable += list(list("name"=PLANT.name,"path"=PLANT.type,"desc"=PLANT.vending_details,"cost"=PLANT.ticket_cost))

		for(var/plant in concrete_typesof(/datum/plant/herb))
			var/datum/plant/PLANT = new plant
			herb += list(list("name"=PLANT.name,"path"=PLANT.type,"desc"=PLANT.vending_details,"cost"=PLANT.ticket_cost))

		for(var/plant in concrete_typesof(/datum/plant/flower))
			var/datum/plant/PLANT = new plant
			flower += list(list("name"=PLANT.name,"path"=PLANT.type,"desc"=PLANT.vending_details,"cost"=PLANT.ticket_cost))

		for(var/plant in concrete_typesof(/datum/plant/weed))
			var/datum/plant/PLANT = new plant
			weed += list(list("name"=PLANT.name,"path"=PLANT.type,"desc"=PLANT.vending_details,"cost"=PLANT.ticket_cost))

		for(var/plant in concrete_typesof(/datum/plant/artifact))
			var/datum/plant/PLANT = new plant
			alien += list(list("name"=PLANT.name,"path"=PLANT.type,"desc"=PLANT.vending_details,"cost"=PLANT.ticket_cost))

		sort_plant_list(crop)
		sort_plant_list(fruit)
		sort_plant_list(vegetable)
		sort_plant_list(herb)
		sort_plant_list(flower)
		sort_plant_list(weed)
		sort_plant_list(alien)

		to_ui += list(list("category"="Crops","plant_list"=crop))
		to_ui += list(list("category"="Fruit","plant_list"=fruit))
		to_ui += list(list("category"="Vegetables","plant_list"=vegetable))
		to_ui += list(list("category"="Herbs","plant_list"=herb))
		to_ui += list(list("category"="Flowers","plant_list"=flower))
		to_ui += list(list("category"="Weeds","plant_list"=weed))
		to_ui += list(list("category"="Experimental","plant_list"=alien))

	attack_hand(var/mob/user as mob)
		if(!ishuman(user))
			return
		ui_interact(user)

	attackby(var/obj/item/W,var/mob/user)
		if(istype(W,/obj/item/hydro_ticket))
			var/obj/item/hydro_ticket/TICKET = W
			user.u_equip(TICKET)
			tickets += TICKET.value
			qdel(W)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "SeedMarket", "Seed Market")
			ui.open()

	ui_data(mob/user)
		. = list(
			"tickets" = tickets,
			"gacha_cost" = gacha_cost,
			"tab" = tab,
			"plant_lists" = to_ui
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		switch(action)
			if("spawn_item")
				if((tickets - params["cost"]) < 0)
					return
				target_path = params["target_path"]
				tickets -= params["cost"]
				vend_item(ui.user)
			if("gachapon")
				gachapon(ui.user)
			if("eject")
				eject(ui.user)
				

	proc/vend_item(var/mob/user)
		var/path = text2path(target_path)
		var/datum/plant/PLANT = new path
		var/obj/item/seed/SEED = Hydro_seed_setup(PLANT,TRUE)
		user.put_in_hand_or_drop(SEED)
		user.playsound_local(src.loc, "keyboard", 50, 1)

	proc/gachapon(var/mob/user)
		if((tickets - gacha_cost) < 0)
			return
		tickets -= gacha_cost
		user.put_in_hand_or_drop(new /obj/item/seed_gachapon)
		user.playsound_local(user.loc, 'sound/machines/capsulebuy.ogg', 50, 1)

	proc/eject(var/mob/user)
		var/obj/item/hydro_ticket/TICKET = new /obj/item/hydro_ticket
		TICKET.value = tickets
		tickets = 0
		TICKET.update_sprite()
		user.put_in_hand_or_drop(TICKET)
		playsound(user.loc, 'sound/machines/ping.ogg', 20, 1)

/obj/item/seed_gachapon
	name = "NaNo Gacha! Capsule"
	desc = "NanoTrasen's failed attempt at making hydroponics more attractive to new recruits."
	icon = 'icons/obj/items/figures.dmi'
	w_class = 1.0
	var/obj/item/stored_seed
	var/image/underlay
	var/image/underlay_color
	var/open = FALSE

	New()
		..()
		icon_state = "[pick("cap-g","cap-b")]"
		UpdateOverlays(image('icons/obj/items/figures.dmi',"cap-cap1"),"cap")
		var/target_list = rand(1,7)
		var/path
		switch(target_list)
			if(1)
				path = pick(concrete_typesof(/datum/plant/crop))
			if(2)
				path = pick(concrete_typesof(/datum/plant/fruit))
			if(3)
				path = pick(concrete_typesof(/datum/plant/veg))
			if(4)
				path = pick(concrete_typesof(/datum/plant/herb))
			if(5)
				path = pick(concrete_typesof(/datum/plant/flower))
			if(6)
				path = pick(concrete_typesof(/datum/plant/weed))
			if(7)
				if(prob(30))
					path = pick(concrete_typesof(/datum/plant/artifact))
				else
					path = pick(concrete_typesof(/datum/plant/weed))

		var/datum/plant/PLANT = new path
		var/obj/item/seed/SEED = Hydro_seed_setup(PLANT,TRUE)
		if(PLANT.unique_seed)
			SEED = unpool(PLANT.unique_seed)
		else
			SEED = unpool(/obj/item/seed)
			SEED.removecolor()

		SEED.name = "NaNo Gacha! Mystery Seed"
		SEED.set_loc(src)
		stored_seed = SEED
		
		underlay_color = SEED.GetOverlayImage("color")
		if(underlay_color)
			underlay_color.pixel_y = 3
		underlay = image(SEED.icon,SEED.icon_state)
		underlay.pixel_y = 3

	attack_self(var/mob/user)
		if(!open)
			ClearSpecificOverlays("cap")
			if(underlay_color)
				underlays += underlay_color
			underlays += underlay
			open = TRUE
		else
			if(stored_seed)
				if(underlay_color)
					underlays -= underlay_color
				underlays -= underlay
				UpdateOverlays(image('icons/obj/items/figures.dmi',"cap-cap1"),"cap")
				open = FALSE

	attack_hand(var/mob/user)
		if(src.loc != user)
			..()
		else if(stored_seed && open)
			user.put_in_hand_or_drop(stored_seed)
			stored_seed = null
			underlays -= underlay_color
			underlays -= underlay