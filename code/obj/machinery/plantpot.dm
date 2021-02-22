// This file is arguably the "main" file where all of the central hydroponics shit goes down.
// Most of the actual content itself is found in other files, but the plantpot does just about
// all of the actual work, so if you're looking to see how Hydro works at the very base level
// this is the file you want to be looking in.
//
// Other files you'll want if you're looking up on Hydroponics stuff:
// obj/item/plants_food_etc.dm: Most of the seed and produce items are in here.
// obj/item/hydroponics.dm: The tools players use to do hydro work are here.
// datums/plants.dm: The plant species, mutations and genetics are kept here.
// obj/submachine/seed.dm: The splicer and reagent extractor are in here.

/obj/machinery/plantpot
	// The central object for Hydroponics. All plant growing and most of everything goes on in
	// this object - that said you don't want to have too many of them on the map because they
	// get kind of resource intensive past a certain point.
	name = "hydroponics tray"
	desc = "A tray filled with nutrient solution capable of sustaining plantlife."
	icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
	icon_state = "tray"
	anchored = 0
	density = 1
	mats = 2
	flags = NOSPLASH
	processing_tier = PROCESSING_SIXTEENTH
	machine_registry_idx = MACHINES_PLANTPOTS

	var/datum/plant/growing = null			// What is growingly growing in the plant pot
	var/datum/plantgenes/DNA = null 		// Set this up in New
	var/datum/plantmutation/MUT = null		// Also set up in New
	var/tickcount = 0  						// Automatic. Tracks how many ticks have elapsed, for CPU efficiency things.
	var/dead = 0       						// Automatic. If the plant is dead.
	var/growth = 0     						// Automatic. How developed the plant is.
	var/health = 0     						// Set this when you plant a seed. Plant dies when this hits 0.
	var/harvests = 0  						// Set this when you plant a seed. How many times you can harvest it before it dies. Plant dies when it hits 0.
	var/recently_harvested = 0 				// Automatic. A time delay between harvests.
	var/generation = 0 						// Automatic. Just a fun thing to track how many generations a plant has been bred.
	var/weedproof = 0  						// Does this tray block weeds from appearing in it? (Won't stop deliberately planted weeds)

	var/report_freq = 1433 					//Radio channel to report plant status/death/whatever.
	var/net_id = null

	var/water_level = 4 					// Used for efficiency in the update_tray_overlays proc with water level changing
	var/grow_level = 1 						// Same as the above except for growing plant growth
	var/total_volume = 4 					// How much volume total is actually in the tray because why the fuck was water the only reagent being counted towards the level

	var/health_warning = 0
	var/harvest_warning = 0
	var/image/water_sprite = null
	var/image/water_meter = null
	var/image/plant_sprite = null
											// We have these here as a check for whether or not the plant needs to update its sprite.
	var/do_update_overlays = FALSE 					// this is now a var on the pot itself so you can actually call it outside of process()
	var/do_update_water_icon = 1 			// this handles the water overlays specifically (water and water level) It's set to 1 by default so it'll update on spawn
	var/growth_rate = 2

	var/list/contributors = list() // Who helped grow this plant? Mainly used for critters.

	var/action_bar_status //holds defines for action bar harvesting yay :D
	
	New()
		..()
		DNA = new /datum/plantgenes(src)
		if(DNA.mutation)
			MUT = DNA.mutation

		src.create_reagents(400)			// The plantpot can store 400 reagents in total, we want a bit more than the max water for other reagents
		reagents.add_reagent("water", 200)	// 200 is the exact maximum amount of WATER a plantpot can hold before it is considered full
		src.water_meter = image('icons/obj/hydroponics/machines_hydroponics.dmi', "wat-[src.water_level]")
		src.plant_sprite = image('icons/obj/hydroponics/plants_weed.dmi', "")
		update_tray_overlays()

		SPAWN_DBG(0.5 SECONDS)
			radio_controller?.add_object(src, "[report_freq]")

			if(!net_id)
				net_id = generate_net_id(src)

	disposing()
		radio_controller.remove_object(src, "[report_freq]")
		..()

	on_reagent_change()
		src.do_update_water_icon = 1
		src.update_water_level()

	process()
		..()
		if(do_update_overlays)	// We skip every other tick. Another cpu-conserving measure.
			update_tray_overlays()
			update_name()
		if(!src.growing || src.dead)	// If the plantpot is empty or contains a dead plant, we don't need to do anything
			return

		if(growing.required_reagents)	//Checks to see if the plant requires a reagent to grow, and compares to to the reagents present in the pot.
			for(var/i in 1 to length(growing.required_reagents))
				if(src.reagents.get_reagent_amount(growing.required_reagents[i]["id"]) < growing.required_reagents[i]["amount"])
					return

		// REAGENT PROCESSING
		var/drink_rate = 1	// drink_rate is how much reagent is consumed per tick.
		if(has_plant_flag(growing,SIMPLE_GROWTH))	// Simplegrowth essentially skips all simulation whatsoever and just adds one growth point per tick
			src.growth++
		else
			var/compared_water = water_preferred_vs_growing()

			if(compared_water != "no water")
				var/is_slow_metabolism = Hydro_check_strain(DNA,/datum/plant_gene_strain/metabolism_slow)
				var/is_fast_metabolism = Hydro_check_strain(DNA,/datum/plant_gene_strain/metabolism_fast)
				switch(compared_water)
					if(0)
						if(is_slow_metabolism)
							if(prob(50))
								growth++
						else if(is_fast_metabolism)
							growth += 4
						else
							growth += 2
						if(prob(15))	// extra bonus for taking care of your plants <3
							growth++
					if(1)
						if(is_slow_metabolism)
							if(prob(50))
								growth++
						else if(is_fast_metabolism)
							growth += 2
						else
							growth++
					if(2)
						if(is_slow_metabolism)
							if(prob(25))
								growth++
						else if(is_fast_metabolism)
							if(prob(20))
								growth++
						else
							if(prob(10))
								growth++
				if(is_slow_metabolism)	// If our plant has a slow metabolism, it will only gain growth 50% of the time compared to usual and consume reagents a lot slower though.
					if(drink_rate)
						drink_rate /= 2
				else if(is_fast_metabolism) // The "growth rate on crack" mutation and causes it to consume reagents a lot faster
					if(drink_rate)
						drink_rate *= 2
			else	// If there's no water in the plant pot, we slowly damage the plant unless the plant doesn't require water to grow
				if(!has_plant_flag(growing,NO_THIRST))
					damage_plant("drought",1)
				else
					src.growth++

			// Now we look through every reagent growingly in the plantpot and call the reagent's
			// on_plant_life proc. These are defined in the chemistry reagents file on each reagent
			// for the sake of efficiency.
			if(src.reagents)
				for(var/growing_id in src.reagents.reagent_list)
					var/datum/reagent/growing_reagent = src.reagents.reagent_list[growing_id]
					if(growing_reagent)
						growing_reagent.on_plant_life(src)

			/* DEPRECATED, IN COMMENTS FOR THE MOMENT FOR TESTING
			// Now we do a similar thing for gene strains, except with these we do a hard-coded
			// thing right here since the gene strains themselves are just text strings.
			for (var/X in DNA.gene_strains)
				switch(X)
					if("Unstable")
						if(prob(18))
							mutate_plant(1)
						// Unstable causes the plant to mutate on its own every so often.
						// Players might want this or might not, so it's neither good nor bad.
					if("Accelerator")
						if(prob(10))
							DNA.growtime--
							DNA.harvtime--
						// This gene strain should be kept rare. It boosts the growth rate genes
						// which makes the plant grow faster permanently. As of the time of writing
						// I don't think anyone's discovered it so if it needs a downside, we can
						// figure it out later.
					if("Poor Health")
						if(prob(24))
							damage_plant("frailty",1)
						// Poor Health is a bad strain to have that causes the plant to slowly take
						// damage for sod all reason. It's basically a weak wuss plant strain.
					if("Rapid Growth")
						src.growth += 2
						// Basically like rapid metabolism with no downsides.
					if("Stunted Growth")
						if(src.growth > 1)
							src.growth--
						// Slow down growth. We don't want this to reduce src.growth to zero in
						// any case, because that means the plant would die.
			*/

			if(DNA.gene_strains)
				for (var/datum/plant_gene_strain/X in DNA.gene_strains)
					X.on_process(src)

		src.reagents?.remove_any_except(drink_rate, "nectar")
		// This is where drink_rate does its thing. It will remove a bit of all reagents to meet
		// it's quota, except nectar because that's supposed to stay in the plant pot.

		if(growing.nectarlevel)	// If the plant produces nectar, add nectar gradually until the target nectar level is reached
			var/growing_level = src.reagents.get_reagent_amount("nectar")
			if(growing_level < growing.nectarlevel)
				src.reagents.add_reagent("nectar", rand(growing.nectarlevel * 0.2, growing.nectarlevel * 0.5) )

		if(has_plant_flag(growing,USE_SPECIAL_PROC))	// Handling special procs :  These trigger on the process loop of the pot
			if(MUT)		// If we've got a mutation, check if the mutation has its own special proc that overrides the regular one.
				switch (MUT.special_proc_override)
					if(0) // There's no special proc for this mutation, so just use the regular one.
						growing.HYPspecial_proc(src)
					if(1) // The mutation overrides the base proc to use its own.
						MUT.HYPspecial_proc_M(src)
					else // Any other value means we use BOTH procs.
						growing.HYPspecial_proc(src)
						MUT.HYPspecial_proc_M(src)
			else
				growing.HYPspecial_proc(src)	// If there's no mutation we just use the base special proc, obviously!

		var/growing_growth_level = 0	// This is entirely for updating the icon.

		if(src.growth >= growing.harvtime - DNA.harvtime)	// is the plant fully grown?
			growing_growth_level = 4
		else if(src.growth >= growing.growtime - DNA.growtime)	// is the plant past the halfway point of growing?
			growing_growth_level = 3
		else if(src.growth >= (growing.growtime - DNA.growtime) / 2) // is the plant at half or higher?
			growing_growth_level = 2
		else
			growing_growth_level = 1

		if(growing_growth_level != src.grow_level)	// sanity check update in case of variable editing
			src.grow_level = growing_growth_level
			do_update_overlays = TRUE

		if(!harvest_warning && is_harvestable())	// The plant want's to be harvested and it will let everyone know!
			src.harvest_warning = 1
			do_update_overlays = TRUE
		else if(harvest_warning && !is_harvestable())	// If the plant can't be harvested, do not display an indicator
			src.harvest_warning = 0
			do_update_overlays = TRUE

		if(!health_warning && src.health <= growing.starthealth / 2)	// Does the plant need to be sent to medbay?
			src.health_warning = 1
			do_update_overlays = TRUE
		else if(health_warning && src.health > growing.starthealth / 2)
			src.health_warning = 0
			do_update_overlays = TRUE

		// Have we lost all health or growth, or used up all available harvests? If so, this plant
		// should now die. Sorry, that's just life! Didn't they teach you the curds and the peas?
		if((src.health < 1 || src.growth < 0) || (!has_plant_flag(growing,NO_HARVEST) && src.harvests < 1))
			kill_plant()
			return

		if(do_update_overlays)
			update_tray_overlays()
			update_name()

		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(src.growing)
			if(istype(src.growing,/datum/plant/maneater))	// We want to be able to feed stuff to maneaters, such as meat, people, etc.
				handle_maneater_interaction(W,user)
			if(src.growing.harvest_tools)	// Checks to see if the plant requires a specific tool to harvest, rather than an empty hand.
				var/passed
				for(var/i in 1 to length(growing.harvest_tools))
					if(ispath(growing.harvest_tools[i]))
						if(istype(W,growing.harvest_tools[i]))
							passed = TRUE
							break
					else if(istool(W,growing.harvest_tools[i]))
						passed = TRUE
						break
				if(passed)
					if(growing.harvest_tool_message)
						user.show_text(growing.harvest_tool_message)
					harvest(user,null)
					return

		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))	// These allow you to unanchor the plantpots to move them around, or re-anchor them.
			if(src.anchored)
				user.visible_message("<b>[user]</b> unbolts the [src] from the floor.")
				playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
				src.anchored = 0
			else
				user.visible_message("<b>[user]</b> secures the [src] to the floor.")
				playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
				src.anchored = 1

		else if(W.firesource)	// These are for burning down plants with.
			if(isweldingtool(W) && !W:try_weld(usr, 3, noisy = 0, burn_eyes = 1))
				return
			else if(istype(W, /obj/item/device/light/zippo) && !W:on)
				boutput(user, "<span class='alert'>It would help if you lit it first, dumbass!</span>")
				return
			if(src.growing)
				if(trigger_attacked_proc(W,user))
					return
				if(src.dead)
					src.visible_message("<span class='alert'>[src] goes up in flames!</span>")
					src.reagents.add_reagent("ash", src.growth)	// Ashes in the plantpot I guess.
					destroy_plant()
				else
					if(!damage_plant("fire",150)) src.visible_message("<span class='alert'>[src] resists the fire!</span>")

		else if(istype(W,/obj/item/saw))	// Allows you to cut down plants.
			if(src.growing)
				if(trigger_attacked_proc(W,user))
					return
				if(src.dead)
					src.visible_message("<span class='alert'>[src] is is destroyed by [user.name]'s [W]!</span>")
					destroy_plant()
					return
				else
					damage_plant("physical",150,1)
					src.visible_message("<span class='alert'>[user.name] cuts at [src] with [W]!</span>")

		else if(istype(W, /obj/item/seed/))	// Planting a seed in the tray.
			var/obj/item/seed/SEED = W
			if(src.growing)
				user.show_text("Something is already in that tray.","red")
				return
			user.visible_message("<span class='notice'>[user] plants a seed in the [src].</span>")
			user.u_equip(SEED)
			SEED.set_loc(src)
			if(SEED.planttype)
				src.create_plant(SEED)
				if(SEED && istype(SEED.planttype,/datum/plant/maneater)) // Logging for man-eaters, since they can't be harvested (Convair880).
					logTheThing("combat", user, null, "plants a [SEED.planttype] seed at [log_loc(src)].")
				if(!(user in src.contributors))
					src.contributors += user
			else
				user.show_text("You plant the seed, but nothing happens.","red")
				pool (SEED)
			return

		else if(istype(W, /obj/item/seedplanter/))
			var/obj/item/seedplanter/SP = W
			if(src.growing)
				user.show_text("Something is already in that tray.","red")
				return
			if(!SP.selected)
				user.show_text("You need to select something to plant first.","red")
				return
			user.visible_message("<span class='notice'>[user] plants a seed in the [src].</span>")
			var/obj/item/seed/SEED
			if(SP.selected.unique_seed)
				SEED = unpool(SP.selected.unique_seed)
			else
				SEED = unpool(/obj/item/seed)
			SEED.generic_seed_setup(SP.selected)
			SEED.set_loc(src)
			if(SEED.planttype)
				src.create_plant(SEED)
				if(SEED && istype(SEED.planttype,/datum/plant/maneater)) // Logging for man-eaters, since they can't be harvested (Convair880).
					logTheThing("combat", user, null, "plants a [SEED.planttype] seed at [log_loc(src)].")
				if(!(user in src.contributors))
					src.contributors += user
			else
				user.show_text("You plant the seed, but nothing happens.","red")
				pool (SEED)

		else if(istype(W, /obj/item/reagent_containers/glass/))	// Not just watering cans - any kind of glass can be used to pour stuff in.
			if(!W.reagents.total_volume)
				user.show_text("There is nothing in [W] to pour!","red")
				return
			else
				user.visible_message("<span class='notice'>[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src].</span>")
				playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 100, 1)
				W.reagents.trans_to(src, W:amount_per_transfer_from_this)
				if(!(user in src.contributors))
					src.contributors += user
				if(!W.reagents.total_volume)
					user.show_text("<b>[W] is now empty.</b>","red")
				update_tray_overlays()
				return


		else if(istype(W, /obj/item/raw_material/shard/plasmacrystal) && !growing)	// Planting a crystal shard simply puts a crystal seed inside the plant pot.
			user.visible_message("<span class='notice'>[user] plants [W] in the tray.</span>")
			var/obj/item/seed/crystal/WS = unpool(/obj/item/seed/crystal)
			WS.set_loc(src)
			create_plant(WS)
			pool(W)
			sleep(0.5 SECONDS)
			pool(WS)
			if(!(user in src.contributors))
				src.contributors += user

		else if(istype(W, /obj/item/satchel/hydro))	// Harvesting directly into a satchel.
			if(!src.growing)
				user.show_text("There's no plant here to harvest!","red")
				return
			if(src.dead)
				user.show_text("The plant is dead and cannot be harvested!","red")
				return
			if (src.growing.harvest_tools)
				return
			if(has_plant_flag(growing,NO_HARVEST))
				user.show_text("You doubt this plant is going to grow anything worth harvesting...","red")
				return

			if(is_harvestable())
				harvest(user,W)
			else
				user.show_text("The plant isn't ready to be harvested yet!","red")
				return

		else ..()

	attack_ai(mob/user as mob)
		if(isrobot(user) && get_dist(src, user) <= 1)
			return src.attack_hand(user)

	attack_hand(var/mob/user as mob)
		if(isAI(user) || isobserver(user))
			return
		src.add_fingerprint(user)
		if(src.growing)
			if(src.dead)
				user.show_text("You clear the dead plant out of the tray.","blue")
				destroy_plant()
				return

			if(is_harvestable())
				if(!growing.harvest_tools) //if the plant needs a specific tool or set of tools to harvest
					harvest(user,null)
				else
					if(!growing.harvest_tool_fail_message)
						user.show_text("<b>You don't have the right tool to harvest this plant!</b>","red")
					else
						user.show_text(growing.harvest_tool_fail_message)
			else
				user.show_text("You check [name] and the tray.")

				if(src.recently_harvested)
					user.show_text("This plant has been harvested recently. It needs some time to regenerate.")
				if(!src.reagents.has_reagent("water"))
					user.show_text("The tray is completely dry.","red")
				else
					if(src.reagents.get_reagent_amount("water") > 200)
						user.show_text("The tray has too much water.","red")
					if(src.reagents.get_reagent_amount("water") < 40)
						user.show_text("The tray's water level looks a little low.","red")
				if(src.health >= growing.starthealth * 4)
					user.show_text("The plant is flourishing!","green")
				else if(src.health >= growing.starthealth * 2)
					user.show_text("The plant looks very healthy.","green")
				else if(src.health <= growing.starthealth / 2)
					user.show_text("The plant is in poor condition.","red")
				if(MUT)
					user.show_text("The plant looks strange...","red")

				var/reag_list = ""
				for(var/growing_id in src.reagents.reagent_list)
					var/datum/reagent/growing_reagent = src.reagents.reagent_list[growing_id]
					reag_list += "[reag_list ? ", " : " "][growing_reagent.name]"

				user.show_text("There is a total of [src.reagents.total_volume] units of solution.")
				user.show_text("The solution seems to contain [reag_list].")
		else	// If there's no plant, just check what reagents are in there.
			user.show_text("You check the solution in [src.name].")
			var/reag_list = ""
			for(var/growing_id in src.reagents.reagent_list)
				var/datum/reagent/growing_reagent = src.reagents.reagent_list[growing_id]
				reag_list += "[reag_list ? ", " : " "][growing_reagent.name]"

			user.show_text("There is a total of [src.reagents.total_volume] units of solution.")
			user.show_text("The solution seems to contain [reag_list].")
		return

	MouseDrop(over_object, src_location, over_location)
		..()
		if(!isliving(usr))
			return
		if(get_dist(src, usr) > 1)
			usr.show_text("You need to be closer to empty the tray out!","red")
			return

		if(src.growing)
			trigger_attacked_proc(usr)

			if(has_plant_flag(growing,GROWTHMODE_WEED))	// Use weedkiller to get rid of the weeds since you can't clear them out by hand.
				if(alert("Clear this tray?",,"Yes","No") == "Yes")
					usr.visible_message("<b>[usr.name]</b> dumps out the tray's contents.")
					usr.show_text("Weeds still infest the tray. You'll need something a bit more thorough to get rid of them.","red")
					src.growth = 0
					src.reagents.clear_reagents()
			else
				if(alert("Clear this tray?",,"Yes","No") == "Yes")
					usr.visible_message("<b>[usr.name]</b> dumps out the tray's contents.")
					src.reagents.clear_reagents()
					src.do_update_overlays = TRUE
					destroy_plant()
		else
			if(alert("Clear this tray?",,"Yes","No") == "Yes")
				usr.visible_message("<b>[usr.name]</b> dumps out the tray's contents.")
				src.reagents.clear_reagents()
				src.do_update_overlays = TRUE
		return

	MouseDrop_T(atom/over_object as obj, mob/user as mob) // ty to Razage for the initial code
		if(!in_interact_range(src,user) || !in_interact_range(src,over_object) || is_incapacitated(user) || isAI(user))
			return
		if(istype(over_object, /obj/item/seed))  // Checks to make sure it's a seed being dragged onto the tray.
			if(get_dist(user, src) > 1)
				user.show_text("You need to be closer to the tray!","red")
				return
			if(get_dist(user, over_object) > 1)
				user.show_text("[over_object] is too far away!","red")
				return
			src.attackby(over_object, user)  // Activates the same command as would be used with a seed in hand on the tray.
			return
		else // if it's not a seed...
			return ..() // call our parents and ask what to do.

	temperature_expose(null, temp, volume)
		if(reagents)
			reagents.temperature_reagents(temp, volume)
		if((temp >= 360) && growing)
			if(src.dead)
				src.reagents.add_reagent("saltpetre", src.growth)
				destroy_plant()
			else
				damage_plant("fire",temp - 360)

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN))
			return

		if(!signal || signal.encryption)
			return

		if((signal.data["address_1"] == "ping") && signal.data["sender"])
			var/datum/signal/pingsignal = get_free_signal()
			pingsignal.source = src
			pingsignal.data["device"] = "WNET_[pick("GENERIC", "PACKETSPY", "DETECTOR", "SYN%%^#FF")]" //Todo: Set this as something appropriate when complete.
			pingsignal.data["netid"] = src.net_id
			pingsignal.data["address_1"] = signal.data["sender"]
			pingsignal.data["command"] = "ping_reply"
			pingsignal.transmission_method = TRANSMISSION_RADIO

			var/datum/radio_frequency/frequency = radio_controller.return_frequency("[report_freq]")
			if(!frequency)
				return
			SPAWN_DBG(0.5 SECONDS) //Send a reply for those curious jerks
				frequency.post_signal(src, pingsignal)

		return //Just toss out the rest of the signal then I guess

	proc/update_water_icon()
		var/datum/color/average
		src.water_sprite = image('icons/obj/hydroponics/machines_hydroponics.dmi',"wat-[src.total_volume]")
		src.water_sprite.layer = 3
		src.water_meter = image('icons/obj/hydroponics/machines_hydroponics.dmi',"ind-wat-[src.water_level]")
		if(src.reagents.total_volume)
			average = src.reagents.get_average_color()
			src.water_sprite.color = average.to_rgba()

		UpdateOverlays(src.water_sprite, "water_fluid")
		UpdateOverlays(src.water_meter, "water_meter")

	proc/update_tray_overlays() //plant icon stuffs
		src.water_meter = image('icons/obj/hydroponics/machines_hydroponics.dmi',"ind-wat-[src.water_level]")
		UpdateOverlays(water_meter, "water_meter")
		if(!src.growing)
			UpdateOverlays(null, "harvest_display")
			UpdateOverlays(null, "health_display")
			UpdateOverlays(null, "plant")
			UpdateOverlays(null, "plantdeath")
			return

		var/iconname = 'icons/obj/hydroponics/plants_weed.dmi'
		if(growing.plant_icon)
			iconname = growing.plant_icon
		else if(MUT?.iconmod)
			if(MUT.plant_icon)
				iconname = MUT.plant_icon
			else
				iconname = growing.plant_icon

		if(src.dead)
			UpdateOverlays(hydro_controls.pot_death_display, "plantdeath")
			UpdateOverlays(null, "harvest_display")
			UpdateOverlays(null, "health_display")
		else
			UpdateOverlays(null, "plantdeath")
			if(src.harvest_warning)
				UpdateOverlays(hydro_controls.pot_harvest_display, "harvest_display")
			else
				UpdateOverlays(null, "harvest_display")

			if(src.health_warning)
				UpdateOverlays(hydro_controls.pot_health_display, "health_display")
			else
				UpdateOverlays(null, "health_display")

		var/planticon = null
		if(MUT?.iconmod)
			planticon = "[MUT.iconmod]-G[src.grow_level]"
		else if(growing.sprite)
			planticon = "[growing.sprite]-G[src.grow_level]"
		else if(growing.override_icon_state)
			planticon = "[growing.override_icon_state]-G[src.grow_level]"
		else
			planticon = "[growing.name]-G[src.grow_level]"

		src.plant_sprite.icon = iconname
		src.plant_sprite.icon_state = planticon
		src.plant_sprite.layer = 4
		UpdateOverlays(plant_sprite, "plant")

	proc/update_name()
		if(!src.growing)
			src.name = "hydroponics tray"
			return
		if(growing && has_plant_flag(growing,NO_SCAN))
			src.name = "\improper strange plant"
		else
			if(istype(MUT,/datum/plantmutation/))
				if(!MUT.name_prefix && !MUT.name_prefix && MUT.name)
					src.name = "\improper [MUT.name] plant"
				else if(MUT.name_prefix || MUT.name_suffix)
					src.name = "\improper [MUT.name_prefix][growing.name][MUT.name_suffix] plant"
			else
				src.name = "\improper [growing.name] plant" //TODO: add optional suffix eg. "tree"
		if(src.dead)
			src.name = "dead " + src.name

	proc/is_harvestable()
		if(!growing || !DNA || health < 1 || harvests < 1 || recently_harvested) return 0
		if(MUT && MUT.harvest_override && MUT.crop)
			if(src.growth >= growing.harvtime - DNA.harvtime) 
				return TRUE
			else 
				return FALSE
		if(!growing.crop || has_plant_flag(growing,NO_HARVEST))
			return FALSE

		if(src.growth >= growing.harvtime - DNA.harvtime)
			return TRUE
		else
			return FALSE

	proc/harvest(var/mob/living/user,var/obj/item/satchel/SA)
		if(!user)
			return
		var/satchelpick = 0
		if(SA)
			if(SA.contents.len >= SA.maxitems)
				user.show_text("Your satchel is already full! Free some space up first.","red")
				return
			else
				satchelpick = input(user, "What do you want to harvest into the satchel?", "[src.name]", 0) in list("Everything","Produce Only","Seeds Only","Never Mind")
				if(!is_harvestable() || satchelpick == "Never Mind")
					return
				if(satchelpick == "Everything")
					satchelpick = null
		// it's okay if we don't have a satchel at all since it'll just harvest by hand instead
		if(!growing)
			logTheThing("debug", null, null, "<b>Hydro Controls</b>: Plant pot at \[[x],[y],[z]] used by ([user]) attempted a harvest without having a growing plant.")
			return

		// Does this plant react to being harvested? If so, do it - it also functions as
		// a check since harvesting will stop here if this returns anything other than 0.
		if(has_plant_flag(growing,USE_HARVESTED_PROC) && (growing.HYPharvested_proc(src,user) || MUT?.HYPharvested_proc_M(src,user)))
			return

		if(hydro_controls)
			src.recently_harvested = 1
			src.harvest_warning = 0
			SPAWN_DBG(hydro_controls.delay_between_harvests)
				src.recently_harvested = 0
		else
			logTheThing("debug", null, null, "<b>Hydro Controls</b>: Could not access Hydroponics Controller to get Delay cap.")

		var/base_quality_score = 1	// This is a modular thing suggested by Cogwerks that can affect the final quality of produce such as making fruit make you sick or herbs have less reagents.
		var/harvest_cap = 10

		if(hydro_controls)
			harvest_cap = hydro_controls.max_harvest_cap
		else
			logTheThing("debug", null, null, "<b>Hydro Controls</b>: Could not access Hydroponics Controller to get Harvest cap.")

		src.growth = growing.growtime - DNA.growtime	// Reset the growth back to the beginning of maturation so we can wait out the harvest time again.
		var/getamount = growing.cropsize + DNA.cropsize	//dictates the number of crops that are harvested
		var/extra_harvest_chance = 0

		if(src.health >= growing.starthealth * 2 && prob(30))
			user.show_text("This looks like a good harvest!","green")
			base_quality_score += 5
			var/bonus = rand(1,3)
			getamount += bonus
			harvest_cap += bonus	// Good health levels bump the harvest amount up a bit and increase jumbo chances.
		if(src.health >= growing.starthealth * 4 && prob(30))	// This is if the plant health is absolutely excellent.
			user.show_text("It's a bumper crop!","green")
			base_quality_score += 10
			var/bonus = rand(2,5)
			getamount += bonus
			harvest_cap += bonus
		if(src.health <= growing.starthealth / 2 && prob(70))	// And this is if you've neglected the plant!
			user.show_text("This is kind of a crappy harvest...","red")
			base_quality_score -= 12

		if(DNA.gene_strains)
			for(var/datum/plant_gene_strain/quality/Q in DNA.gene_strains)
				if(Q.negative)
					base_quality_score -= Q.quality_mod
				else
					base_quality_score += Q.quality_mod

			for(var/datum/plant_gene_strain/yield/Y in DNA.gene_strains)	// Gene strains that boost or penalize the cap.
				if(Y.negative)
					if(harvest_cap == 0 || Y.yield_mult == 0)
						continue
					else
						harvest_cap /= Y.yield_mult
						harvest_cap -= Y.yield_mod
				else
					harvest_cap *= Y.yield_mult
					harvest_cap += Y.yield_mod

		if(getamount > harvest_cap)	// Max harvest amount for all plants is capped. The cap is defined in hydro_controls and can be edited by coders on the fly.
			getamount = harvest_cap
			extra_harvest_chance += getamount - harvest_cap

		var/getitem = null
		var/dont_rename_crop = FALSE
		if(growing.crop || MUT?.crop)
			if(MUT)
				if(MUT.crop)
					getitem = MUT.crop
				else
					logTheThing("debug", null, null, "<b>I Said No/Hydroponics:</b> Plant mutation [MUT] crop is not properly configured")
					getitem = growing.crop
			else
				getitem = growing.crop
			if(has_plant_flag(growing,NO_RENAME_HARVEST))
				dont_rename_crop = TRUE

		getamount = max(getamount, 0) 
		if(getamount < 1)
			user.show_text("You aren't able to harvest anything worth salvaging.","red")
		else if(!getitem)
			user.show_text("You can't seem to find anything that looks harvestable.","red")
		else
			var/seedcount = 0
			while (getamount > 0)
				// Start up the loop of grabbing all our produce. Remember, each iteration of
				// this loop is for one item each.
				var/quality_score = base_quality_score
				quality_score += rand(-2,2)	// Just a bit of natural variance to make it interesting
				if(DNA.potency)
					quality_score += round(DNA.potency / 6)
				if(DNA.endurance)
					quality_score += round(DNA.endurance / 6)
				if(Hydro_check_strain(DNA,/datum/plant_gene_strain/unstable))
					quality_score += rand(-7,7)
				var/quality_status = null

				var/itemtype = null
				if(istype(getitem, /list))
					itemtype = pick(getitem)
				else
					itemtype = getitem

				var/obj/CROP = unpool(itemtype)
				CROP.set_loc(src)
				
				if(!dont_rename_crop)
					CROP.name = growing.name
				/*
				if(istype(MUT,/datum/plantmutation/))
					if(!MUT.name_prefix && !MUT.name_prefix && MUT.name)
						CROP.name = "[MUT.name]"
					else if(MUT.name_prefix || MUT.name_suffix)
						CROP.name = "[MUT.name_prefix][growing.name][MUT.name_suffix]"
				*/
				if(istype(CROP, /obj/item/plant/))
					var/obj/item/plant/PLANT = CROP
					CROP.name = "[PLANT.crop_prefix][CROP.name][PLANT.crop_suffix]"

				else if(istype(CROP, /obj/item/reagent_containers/food/snacks/plant))
					var/obj/item/reagent_containers/food/snacks/plant/SNACK = CROP
					CROP.name = "[SNACK.crop_prefix][CROP.name][SNACK.crop_suffix]"

				CROP.name = lowertext(CROP.name)

				switch(quality_score)
					if(25 to INFINITY)	// as quality approaches 115, rate of getting jumbo increases
						if(prob(min(100, quality_score - 15)))
							CROP.name = "jumbo [CROP.name]"
							quality_status = "jumbo"
						else
							CROP.name = "[pick("perfect","amazing","incredible","supreme")] [CROP.name]"
					if(20 to 24)
						if(prob(4))
							CROP.name = "jumbo [CROP.name]"
							quality_status = "jumbo"
						else
							CROP.name = "[pick("superior","excellent","exceptional","wonderful")] [CROP.name]"
					if(15 to 19)
						CROP.name = "[pick("quality","prime","grand","great")] [CROP.name]"
					if(10 to 14)
						CROP.name = "[pick("fine","large","good","nice")] [CROP.name]"
					if(-10 to -5)
						CROP.name = "[pick("feeble","poor","small","shrivelled")] [CROP.name]"
					if(-14 to -11)
						CROP.name = "[pick("bad","sickly","terrible","awful")] [CROP.name]"
						quality_status = "rotten"
					if(-99 to -15)
						CROP.name = "[pick("putrid","moldy","rotten","spoiled")] [CROP.name]"
						quality_status = "rotten"
					if(-9999 to -100)	// this will never happen. but why not!
						CROP.name = "[pick("horrific","hideous","disgusting","abominable")] [CROP.name]"
						quality_status = "rotten"

				switch(quality_status)
					if("jumbo")
						CROP.quality = quality_score * 2
					if("rotten")
						CROP.quality = quality_score - 20
					else
						CROP.quality = quality_score

				if(!has_plant_flag(growing,NO_SIZE_SCALE)) //Keeps plant sprite from scaling if variable is enabled.
					CROP.transform = matrix() * clamp((quality_score + 100) / 100, 0.35, 2)

				if(istype(CROP,/obj/item/reagent_containers/food/snacks/plant/))	// If we've got a piece of fruit or veg that contains seeds.
					var/obj/item/reagent_containers/food/snacks/plant/F = CROP
					var/datum/plantgenes/FDNA = F.plantgenes

					Hydro_pass_DNA(DNA,FDNA)
					F.generation = src.generation
					F.planttype = setup_hybrid(F)

					// Now we calculate the final quality of the item!
					if(Hydro_check_strain(DNA,/datum/plant_gene_strain/unstable) && prob(33))	// The unstable gene can do weird shit to your produce.
						F.name = "[pick("awkward","irregular","crooked","lumpy","misshapen","abnormal","malformed")] [F.name]"
						F.heal_amt += rand(-2,2)
						F.amount += rand(-2,2)

					if(quality_status == "jumbo")
						F.heal_amt *= 2
						F.amount *= 2
					else if(quality_status == "rotten")
						F.heal_amt = 0

					add_harvest_reagents(F,quality_status)	// Put any reagents the plant produces into the new item.

				else if(istype(CROP,/obj/item/plant/) || istype(CROP,/obj/item/reagent_containers))	// If the plant is not a fruit or vegetable
					add_harvest_reagents(CROP,quality_status)

				else if(istype(CROP,/obj/item/seed/))	// Passing genes to seeds
					var/obj/item/seed/S = CROP
					if(growing.unique_seed)
						S = unpool(growing.unique_seed)
						S.set_loc(src)
					else
						S = unpool(/obj/item/seed)
						S.set_loc(src)
						S.removecolor()

					var/datum/plantgenes/seed_DNA = S.plantgenes
					if(!growing.unique_seed && !growing.hybrid)
						S.generic_seed_setup(growing)
					Hydro_pass_DNA(DNA,seed_DNA)
					S.generation = src.generation
					S.planttype = setup_hybrid(S)

				else if(istype(CROP,/obj/item/reagent_containers/food/snacks/mushroom/))	// Mushrooms mostly act the same as herbs, except you can eat them.
					var/obj/item/reagent_containers/food/snacks/mushroom/M = CROP

					if(Hydro_check_strain(DNA,/datum/plant_gene_strain/unstable) && prob(33))
						M.name = "[pick("awkward","irregular","crooked","lumpy","misshapen","abnormal","malformed")] [M.name]"
						M.heal_amt += rand(-2,2)
						M.amount += rand(-2,2)

					if(quality_status == "jumbo")
						M.heal_amt *= 2
						M.amount *= 2
					else if(quality_status == "rotten")
						M.heal_amt = 0

					add_harvest_reagents(CROP,quality_status)

				else if(istype(CROP,/obj/critter/))	// If the plant is a critter, add the people that grew it as a friend so they aren't attacked.
					var/obj/critter/C = CROP
					C.friends = C.friends | src.contributors

				else if(istype(CROP,/obj/item/organ/heart))
					var/obj/item/organ/heart/H = CROP
					H.quality = quality_score

				else if(istype(CROP,/obj/item/reagent_containers/balloon))
					var/obj/item/reagent_containers/balloon/B = CROP
					B.reagents.maximum_volume = B.reagents.maximum_volume + DNA.endurance // more endurance = larger and more sturdy balloons!
					add_harvest_reagents(CROP,quality_status)

				else if(istype(CROP,/obj/item/spacecash))
					var/obj/item/spacecash/S = CROP
					S.amount = max(1, DNA.potency * rand(2,4))
					S.update_stack_appearance()

				if(((has_plant_flag(growing,SINGLE_HARVEST) || has_plant_flag(growing,FORCE_SEED_ON_HARVEST)) && prob(80)) && !istype(CROP,/obj/item/seed/) && !Hydro_check_strain(DNA,/datum/plant_gene_strain/seedless))
					var/obj/item/seed/S
					if(growing.unique_seed)
						S = unpool(growing.unique_seed)
						S.set_loc(src)
					else
						S = unpool(/obj/item/seed)
						S.set_loc(src)
						S.removecolor()
					var/datum/plantgenes/seed_DNA = S.plantgenes
					if(!growing.unique_seed && !growing.hybrid)
						S.generic_seed_setup(growing)

					var/seedname = "[growing.name]"
					if(istype(MUT,/datum/plantmutation/))
						if(!MUT.name_prefix && !MUT.name_suffix && MUT.name)
							seedname = "[MUT.name]"
						else if(MUT.name_prefix || MUT.name_suffix)
							seedname = "[MUT.name_prefix][growing.name][MUT.name_suffix]"

					S.name = "[seedname] seed"
					Hydro_pass_DNA(DNA,seed_DNA)
					S.generation = src.generation
					S.planttype = setup_hybrid(S)

					seedcount++
				getamount--


			// Give XP based on base quality of crop harvest. Will make better later, like so more plants harvasted and stuff, this is just for testing.
			// This is only reached if you actually got anything harvested.
			// (tmp_crop here was causing runtimes in a lot of cases, so changing to just use it like this)
			// Base quality score:
			//   1: base
			// -12: if HP <=  50% w/ 70% chance
			// + 5: if HP >= 200% w/ 30% chance
			// +10: if HP >= 400% w/ 30% chance
			// Mutations can add or remove this, of course
			// @TODO adjust this later, this is just to fix runtimes and make it slightly consistent
			if (base_quality_score >= 1 && prob(10))
				if(base_quality_score > 20)
					JOB_XP(user, "Botanist", 3)
				if(base_quality_score > 11)
					JOB_XP(user, "Botanist", 2)
				else
					JOB_XP(user, "Botanist", 1)

			var/list/harvest_string = list("You harvest [getamount] item")
			if(getamount > 1)
				harvest_string += "s"
			if(seedcount)
				harvest_string += " and [seedcount] seed"
				if(seedcount > 1)
					harvest_string += "s"
			user.show_text("[harvest_string.Join()].","blue")

			if(istype(MUT,/datum/plantmutation/))	// Mostly for dangerous produce (explosive tomatoes etc) that should show up somewhere in the logs (Convair880).
				logTheThing("combat", user, null, "harvests [getamount] items from a [MUT.name] plant ([MUT.type]) at [log_loc(src)].")
			else
				logTheThing("combat", user, null, "harvests [getamount] items from a [growing.name] plant ([growing.type]) at [log_loc(src)].")

			// At this point all the harvested items are inside the plant pot, and this is the part where we decide where they're going and get them out.
			if(SA)	// If we're putting stuff in a satchel, this is where we do it.
				for(var/obj/item/I in src.contents)
					if(SA.contents.len >= SA.maxitems)
						user.show_text("Your satchel is full! You dump the rest on the floor.","red")
						break
					if(istype(I,/obj/item/seed/))
						if(!satchelpick || satchelpick == "Seeds Only")
							I.set_loc(SA)
					else
						if(!satchelpick || satchelpick == "Produce Only")
							I.set_loc(SA)
				SA.satchel_updateicon()

			// if the satchel got filled up this will dump any unharvested items on the floor
			// if we're harvesting by hand it'll just default to this anyway! truly magical~
			for(var/obj/I in src.contents)
				I.set_loc(user.loc)

		// Now we determine the harvests remaining or grant extra ones.
		if(!Hydro_check_strain(DNA,/datum/plant_gene_strain/immortal))	// Immortal is a gene strain that means infinite harvests as long as the plant is kept alive.
			if(src.health >= growing.starthealth * 4)
				// If we have excellent health, its a +20% chance for an extra harvest.
				extra_harvest_chance += 20
				extra_harvest_chance = max(0,min(100,extra_harvest_chance))
				if(prob(extra_harvest_chance))	// We got the bonus so don't reduce harvests.
					user.show_text("The plant glistens with good health!","green")
				else
					src.harvests--
			else
				src.harvests--

		//do we have to run the next life tick manually? maybe
		playsound(src.loc, "rustle", 50, 1, -5, 2)
		update_tray_overlays()
		update_name()

		if(has_plant_flag(growing,SINGLE_HARVEST))	// These plants always die after one harvest
			kill_plant()

	proc/mutate_plant(var/severity = 1)	// This proc is for mutating the plant - gene strains, mutant variants and plain old genetic bonuses and penalties are handled here.
		if(severity < 1 || !severity)	// Severity is a multiplier to odds and amounts.
			severity = 1
			
		if(!istype(growing) || !istype(DNA))
			return

		Hydro_mutate_DNA(DNA,severity)
		Hydro_new_strain_check(growing,DNA)
		Hydro_new_mutation_check(growing,DNA,src)

	proc/create_plant(var/obj/item/seed/SEED)
		// This proc is triggered on the plantpot when we want to grow a new plant. Usually by
		// planting a seed - even weed growth briefly spawns a seed, uses it for this proc, then
		// deletes the seed.
		src.growing = SEED.planttype
		var/datum/plantgenes/seed_DNA = SEED.plantgenes

		src.health = growing.starthealth	// Now we deal with various health bonuses and penalties for the plant.

		if(has_plant_flag(growing,SINGLE_HARVEST))
			src.health += src.DNA.harvests * 2
			// If we have a single-harvest vegetable plant, the harvests gene (which is otherwise
			// useless) adds 2 health for every point. This works negatively also!

		if(growing.cropsize + seed_DNA.cropsize > 30)
			src.health += (growing.cropsize + seed_DNA.cropsize) - 30
			// If we have a total crop yield above the maximum harvest size, we add it to the
			// plant's starting health.

		src.health += SEED.planttype.endurance + seed_DNA.endurance	// Add the plant's total endurance score to the health.

		if(SEED.seeddamage > 0)
			src.health -= round(SEED.seeddamage / 5)
			// If the seed was damaged by infusions, knock off 5 health points for each point of damage to the seed.

		if(src.health < 1)
			src.health = 1
			// And finally, if health has fallen below zero, set it back to 1 so the plant doesn't instantly die.

		src.generation = SEED.generation + 1
		DNA.growtime = seed_DNA.growtime
		DNA.harvtime = seed_DNA.harvtime
		DNA.cropsize = seed_DNA.cropsize
		DNA.harvests = seed_DNA.harvests
		DNA.potency = seed_DNA.potency
		DNA.endurance = seed_DNA.endurance
		// we use the same list as the seed here, as new lists are created only on mutation to avoid making way more lists than we need
		DNA.gene_strains = seed_DNA.gene_strains
		if(seed_DNA.mutation)
			DNA.mutation = HY_get_mutation_from_path(seed_DNA.mutation.type)
		// Copy over all genes, strains and mutations from the seed.

		// Finally set the harvests, make sure we always have at least one harvest,
		// then get rid of the seed, mutate the genes a little and update the pot sprite.
		if(!has_plant_flag(growing,NO_HARVEST)) src.harvests = growing.harvests + DNA.harvests
		if(src.harvests < 1) src.harvests = 1
		pool (SEED)

		mutate_plant(1)
		post_alert("event_new")
		src.recently_harvested = 0
		update_tray_overlays()
		update_name()

		/*if(usr && ishellbanned(usr)) //Haw haw
			growth_rate = 1
		else
			growth_rate = 2*/

	proc/kill_plant()	// Simple proc to kill the plant without clearing the plantpot out altogether.
		src.health = 0
		src.harvests = 0
		src.dead = 1
		src.recently_harvested = 0
		src.grow_level = 0
		post_alert("event_death")
		src.health_warning = 0
		src.harvest_warning = 0
		update_tray_overlays()
		update_name()

	proc/destroy_plant()	// This resets the plantpot back to it's base state, apart from reagents.
		src.name = "hydroponics tray"
		src.growing = null
		src.growth = 0
		src.grow_level = 1
		src.dead = 0
		src.harvests = 0
		src.recently_harvested = 0
		src.health_warning = 0
		src.harvest_warning = 0
		src.contributors = list()

		DNA.growtime = 0
		DNA.harvtime = 0
		DNA.cropsize = 0
		DNA.harvests = 0
		DNA.potency = 0
		DNA.endurance = 0
		DNA.gene_strains = null
		DNA.mutation = null

		src.generation = 0
		update_tray_overlays()
		post_alert("event_cleared")

	proc/damage_plant(var/damage_source, var/damage_amount, var/bypass_resistance = 0)
		if(!damage_source || damage_amount < 1 || !damage_amount)
			return 0
		if(!growing || !DNA)
			return 0
		var/damage_prob = 100

		if(!bypass_resistance)
			switch(damage_source)
				if("poison")
					if(Hydro_check_strain(DNA,/datum/plant_gene_strain/immunity_toxin)) return 0
				if("radiation")
					if(Hydro_check_strain(DNA,/datum/plant_gene_strain/immunity_radiation)) return 0
				if("drought")
					if(Hydro_check_strain(DNA,/datum/plant_gene_strain/resistance_drought) && damage_prob > 0) damage_prob /= 2
					if(Hydro_check_strain(DNA,/datum/plant_gene_strain/metabolism_fast)) damage_amount *= 2
					if(Hydro_check_strain(DNA,/datum/plant_gene_strain/metabolism_slow) && damage_amount > 0) damage_amount /= 2
			// Various gene strains will eliminate or reduce damage from various sources.
			// In some cases damage is increased, like a fast metabolism plant dying faster
			// from lack of water.

			if(DNA.gene_strains)
				for(var/datum/plant_gene_strain/damage_res/D in DNA.gene_strains)
					if(D.negative)
						damage_amount += D.damage_mod
						damage_amount *= D.damage_mult
					else
						damage_amount -= D.damage_mod
						if(damage_amount && D.damage_mult)
							damage_amount /= D.damage_mult

			damage_prob -= growing.endurance + DNA.endurance
			if(damage_prob < 1) return 0
			if(damage_prob > 100) damage_prob = 100

		if(growing.endurance + DNA.endurance < 0) damage_amount -= growing.endurance + DNA.endurance
		if(prob(damage_prob))
			src.health -= damage_amount
			return 1
		else return 0

	proc/add_harvest_reagents(var/obj/item/I,var/special_condition = null)
		// This is called during harvest to add reagents from the plant to a new piece of produce.
		if(!I || !DNA || !I.reagents)
			return

		// First we decide how much reagents to begin with certain items should hold.
		var/basecapacity = 8
		if(istype(I,/obj/item/plant/))
			basecapacity = 15
		else if(istype(I,/obj/item/reagent_containers/food/snacks/mushroom))
			basecapacity = 5
		else if(istype(I,/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat))
			basecapacity = 2	//I foresee a growing if tree here, should probably break these values out.

		if(DNA.gene_strains)
			for(var/datum/plant_gene_strain/quality/Q in DNA.gene_strains)
				if(Q.negative)
					if(basecapacity && Q.quality_mult)
						basecapacity /= Q.quality_mult
				else
					basecapacity *= Q.quality_mult

		if(special_condition == "jumbo")
			basecapacity *= 2

		// Now we add the plant's potency to their max reagent capacity.
		var/to_add = basecapacity + DNA.potency
		I.reagents.maximum_volume = max(basecapacity + DNA.potency, I.reagents.maximum_volume)
		if(I.reagents.maximum_volume < 1)
			I.reagents.maximum_volume = 1

		// Build the list of all what reagents need to go into the new item.
		var/list/putreagents = list()
		putreagents = growing.assoc_reagents
		if(MUT)
			putreagents = putreagents | MUT.assoc_reagents

		if(special_condition == "rotten")
			putreagents += "yuck"

		if(DNA.gene_strains)
			for(var/datum/plant_gene_strain/reagent_adder/R in DNA.gene_strains)
				putreagents |= R.reagents_to_add

		if(putreagents.len && I.reagents.maximum_volume)
			var/putamount = round(to_add / putreagents.len)
			for(var/X in putreagents)
				I.reagents.add_reagent(X,putamount,,, 1)

	proc/handle_maneater_interaction(var/obj/item/W,var/mob/user) //used to interact with the maneater in attackby
		if(istype(W, /obj/item/grab) && iscarbon(W:affecting) && istype(src.growing,/datum/plant/maneater))
			if(src.growth < 60)
				user.show_text("It's not big enough to eat that yet.","red")
				return	// It doesn't make much sense to feed a full man to a dinky little plant.
			var/mob/living/carbon/C = W:affecting
			user.visible_message("<span class='alert'>[user] starts to feed [C] to the plant!</span>")
			logTheThing("combat", user, (C), "attempts to feed [constructTarget(C,"combat")] to a man-eater at [log_loc(src)].") // Some logging would be nice (Convair880).
			message_admins("[key_name(user)] attempts to feed [key_name(C, 1)] ([isdead(C) ? "dead" : "alive"]) to a man-eater at [log_loc(src)].")
			src.add_fingerprint(user)
			if(!(user in src.contributors))
				src.contributors += user
			if(do_after(user, 3 SECONDS)) // Same as the gibber and reclaimer. Was 20 (Convair880).
				if(src && W && W.loc == user && C)
					user.visible_message("<span class='alert'>[src.name] grabs [C] and devours them ravenously!</span>")
					logTheThing("combat", user, (C), "feeds [constructTarget(C,"combat")] to a man-eater at [log_loc(src)].")
					message_admins("[key_name(user)] feeds [key_name(C, 1)] ([isdead(C) ? "dead" : "alive"]) to a man-eater at [log_loc(src)].")
					if(C.mind)
						C.ghostize()
						qdel(C)
					else
						qdel(C)
					playsound(src.loc, "sound/items/eatfood.ogg", 30, 1, -2)
					src.reagents.add_reagent("blood", 120)
					SPAWN_DBG(2.5 SECONDS)
						if(src)
							playsound(src.loc, pick("sound/voice/burp_alien.ogg"), 50, 0)
					return
				else
					user.show_text("You were interrupted!", "red")
					return
			else
				user.show_text("You were interrupted!", "red")
				return
		else if(istype(W, /obj/item/reagent_containers/food/snacks/ingredient/meat))
			if(src.growth > 60)
				user.show_text("It's going to need something more substantial than that now...","red")
			else
				src.reagents.add_reagent("blood", 5)
				user.show_text("You toss the [W] to the plant.","red")
				qdel (W)
				if(!(user in src.contributors))
					src.contributors += user
		else if(istype(W, /obj/item/organ/brain) || istype(W, /obj/item/clothing/head/butt))
			src.reagents.add_reagent("blood", 20)
			user.show_text("You toss the [W] to the plant.","red")
			qdel (W)
			if(!(user in src.contributors))
				src.contributors += user

	proc/trigger_attacked_proc(var/obj/W,var/mob/user)
		if(has_plant_flag(growing,USE_ATTACKED_PROC))	// Does the plant do anything special when smacked?
			if(MUT)
				// If we've got a mutation, we want to check if the mutation has its own special
				// proc that overrides the regular one.
				switch (MUT.attacked_proc_override)	// See special proc for values
					if(0)
						if(growing.HYPattacked_proc(src,user,W))
							return
					if(1)
						if(MUT.HYPattacked_proc_M(src,user,W)) 
							return
					else
						if(growing.HYPattacked_proc(src,user,W) || MUT.HYPattacked_proc_M(src,user,W))
							return
			else
				if(growing.HYPattacked_proc(src,user,W))
					return

	proc/setup_hybrid(var/datum/plant/P)
		if(growing.hybrid)	// Copy the genes from the plant we're harvesting to the new piece of produce.
			var/datum/plant/hybrid = new /datum/plant(P)
			for(var/V in growing.vars)
				if(issaved(growing.vars[V]) && V != "holder")
					hybrid.vars[V] = growing.vars[V]
			. = hybrid

	proc/add_gene_strain_pot(var/strain) //for varediting! : requires a gene strain path
		if(!growing)
			return
		Hydro_add_strain(DNA,strain)

	proc/post_alert(var/alert_msg)
		var/datum/radio_frequency/frequency = radio_controller.return_frequency("[report_freq]")
		if(!frequency || !alert_msg) 
			return
		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = 1
		signal.data["data"] = alert_msg
		signal.data["netid"] = net_id

		frequency.post_signal(src, signal)

	proc/update_water_level() //checks reagent contents of the pot, then returns the curent water level
		var/growing_total_volume = (src.reagents ? src.reagents.total_volume : 0)
		var/growing_water_level = (src.reagents ? src.reagents.get_reagent_amount("water") : 0)
		switch(growing_water_level)
			if(0 to 0) growing_water_level = 1
			if(1 to 40) growing_water_level = 2
			if(41 to 100) growing_water_level = 3
			if(101 to 200) growing_water_level = 4
			if(201 to INFINITY) growing_water_level = 5
		if(growing_water_level != src.water_level)
			src.water_level = growing_water_level
			src.do_update_water_icon = 1
		if(!growing)
			switch(growing_total_volume)
				if(0 to 0) growing_total_volume = 1
				if(1 to 40) growing_total_volume = 2
				if(41 to 100) growing_total_volume = 3
				if(101 to 200) growing_total_volume = 4
				if(201 to INFINITY) growing_total_volume = 5
			if(growing_total_volume != src.total_volume)
				src.total_volume = growing_total_volume
				src.do_update_water_icon = 1

		if(src.do_update_water_icon)
			src.update_water_icon()
			src.do_update_water_icon = 0

		return growing_water_level

	proc/water_preferred_vs_growing()
		var/growing_water_level = (src.reagents ? src.reagents.get_reagent_amount("water") : 0)
		switch(growing_water_level)
			if(0 to 0)
				return "no water"
			if(1 to 40) growing_water_level = 1
			if(40 to 100) growing_water_level = 2
			if(100 to 200) growing_water_level = 3
			if(200 to INFINITY) growing_water_level = 4

		. = abs(growing.preferred_water_level-growing_water_level)

//children of plantpots
/obj/machinery/plantpot/hightech
	name = "high-tech hydroponics tray"
	desc = "A mostly debug-only plant tray that is capable of revealing more information about your plants."

	New()
		..()

	proc/update_maptext()
		if(!src.growing)
			src.maptext = "<span class='pixel ol c vb'>--</span>"
		maptext_width = 96
		maptext_y = 32
		maptext_x = -32
		var/growth_pct = round(src.growth / (growing.harvtime - (DNA ? DNA.harvtime : 0)) * 100)
		var/hp_pct = round(health / growing.starthealth * 100)
		var/hp_col = "#ffffff"
		switch (hp_pct)
			if(400 to INFINITY)
				hp_col = "#88ffff"
			if(200 to 400)
				hp_col = "#88ff88"
			if(100 to 200)
				hp_col = "#ffffff"
			if(50 to 100)
				hp_col = "#ffff00"
			if(25 to 50)
				hp_col = "#ff8000"
			else
				hp_col = "#ff0000"

		src.maptext = "<span class='ps2p sh c vt'>GR [growth_pct]%\n<span style='color: [hp_col];'>HP [hp_pct]%</span></span>"

	get_desc()
		if(!src.growing)
			return

		var/growthlimit = growing.harvtime - DNA.harvtime
		return "Generation: [src.generation] - Health: [src.health] / [growing.starthealth] - Growth: [src.growth] / [growthlimit] - Harvests: [src.harvests] left."

	process()
		..()
		update_maptext()

/obj/machinery/plantpot/kudzu
	name = "hydroponics tray"
	desc = "A tray filled with nutrient solution capable of sustaining plantlife... Made of plants."
	icon_state = "kudzutray"

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		//Can only attempt to destroy the plant pot if the plant in it is dead or empty.
		if(!src.growing || src.dead)
			if (destroys_kudzu_object(src, W, user))
				if (prob(40))
					user.visible_message("<span class='alert'>[user] savagely attacks [src] with [W]!</span>")
				else
					user.visible_message("<span class='alert'>[user] savagely attacks [src] with [W], destroying it!</span>")
					qdel(src)
					return
			else
				return ..()
		..()

// Machines created specifically to interact with plantpots, kind of abandoned experimental
// shit for the time being for the most part.
/obj/machinery/hydro_growlamp
	name = "\improper UV Grow Lamp"
	desc = "A special lamp that emits ultraviolet light to help plants grow quicker."
	icon = 'icons/obj/hydroponics/machines_hydroponics.dmi'
	icon_state = "growlamp0" // sprites by Clarks
	density = 1
	anchored = 0
	mats = 6
	var/active = 0
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(1)
		light.set_height(1)
		light.set_color(0.7, 0.2, 1)
		if(src.active)
			light.enable()
		else
			light.disable()


	process()
		..()
		if(src.active)
			for (var/obj/machinery/plantpot/P in view(2,src))
				if(!P.growing || P.dead)
					continue
				P.growth += 2
				if(istype(P.DNA,/datum/plantgenes/))
					var/datum/plantgenes/DNA = P.DNA
					if(Hydro_check_strain(DNA,/datum/plant_gene_strain/photosynthesis))
						P.growth += 4

	attack_hand(var/mob/user as mob)
		src.add_fingerprint(user)
		src.active = !src.active
		user.visible_message("<b>[user]</b> switches [src.name] [src.active ? "on" : "off"].")
		src.icon_state = "growlamp[src.active]"
		if(src.active)
			light.enable()
		else
			light.disable()

	attackby(obj/item/W as obj, mob/user as mob)
		if(isscrewingtool(W) || iswrenchingtool(W))
			if(!src.anchored)
				user.visible_message("<b>[user]</b> secures the [src] to the floor!")
			else
				user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
			playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
			src.anchored = !src.anchored

/obj/machinery/hydro_mister
	name = "\improper Botanical Mister"
	desc = "A device that constantly sprays small amounts of chemical onto nearby plants."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "fogmachine0"
	density = 1
	anchored = 0
	mats = 6
	var/active = 0
	var/mode = 1

	New()
		..()
		src.create_reagents(5000)
		reagents.add_reagent("water", 1000)

	get_desc()
		var/reag_list = ""
		for(var/growing_id in src.reagents.reagent_list)
			var/datum/reagent/growing_reagent = src.reagents.reagent_list[growing_id]
			reag_list += "[reag_list ? ", " : " "][growing_reagent.name]"
		return "<br>It's [!src.active ? "off" : (!src.mode ? "on low" : "on high")]. It's about [round(src.reagents.total_volume / src.reagents.maximum_volume * 100, 1)]% full. It seems to contain [reag_list]."

	process()
		..()
		if(src.active)
			for (var/obj/machinery/plantpot/P in view(2,src))
				if(P.reagents.get_reagent_amount("water") >= 195)
					continue
				src.reagents.trans_to(P, 1 + (mode * 4))
			if(src.reagents.total_volume < 10)
				src.visible_message("\The [src] sputters and runs out of liquid.")
				src.active = 0
				src.mode = 0

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/reagent_containers/glass/))
			// Not just watering cans - any kind of glass can be used to pour stuff in.
			if(!W.reagents.total_volume)
				boutput(user, "<span class='alert'>There is nothing in [W] to pour!</span>")
				return
			else
				user.visible_message("<span class='notice'>[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src].</span>")
				playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 100, 1)
				W.reagents.trans_to(src, W:amount_per_transfer_from_this)
				if(!W.reagents.total_volume) boutput(user, "<span class='alert'><b>[W] is now empty.</b></span>")


	attack_hand(var/mob/user as mob)
		src.add_fingerprint(user)
		if(!src.active)
			src.active = 1
			src.mode = 0
			user.visible_message("<b>[user]</b> switches [src.name] on to low power mode.")
			src.visible_message("\The [src] starts to hum, emitting a fine mist.")
		else
			if(!src.mode)
				src.mode = 1
				user.visible_message("<b>[user]</b> switches [src.name] to high power mode.")
				src.visible_message("\The [src] starts to <em>really</em> emit a fine mist!")
			else
				src.active = 0
				src.mode = 0
				user.visible_message("<b>[user]</b> switches [src.name] off.")
				src.visible_message("\The [src] goes quiet.")

		src.icon_state = "fogmachine[src.active]"
		playsound(get_turf(src), "sound/misc/lightswitch.ogg", 50, 1)

	is_open_container()
		return 1 // :I
