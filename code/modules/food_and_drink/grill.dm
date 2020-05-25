/obj/item/kitchen/utensil/spatula
    name = "spatula"
    desc = "Thyme to fleep."
    icon = 'icons/obj/kitchen.dmi'
    icon_state = "spatula"

/obj/machinery/grill
	name = "grill"
	desc = "A grill of the non-shitty variety."
	icon = 'icons/obj/foodNdrink/grill.dmi'
	icon_state = "grill"
	anchored = 1
	density = 1
	mats = 18
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	flags = NOSPLASH
	power_usage = 50
	var/active_quadrant //used to relay information from buttons to grill procs
	var/peeking //used to stop peek spam
	var/list/quadrants = list()

	//path,icon_state,peek_state : list of explicit grill overlays
	//icon_state: the icon that is rendered on the grill
	//peek_state: meat only, rendered when a player peeks on the other side of the item while grilling and the side is fully cooked
	//i.e. meat will show steak on the cooked side
	var/list/grill_overlays = list(
	list("path"=/obj/item/reagent_containers/food/snacks/meatball,"icon_state"="meatball"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat,"icon_state"="meat-mystery","peek_state"="meatball"),
	list("path"=/obj/item/reagent_containers/food/snacks/steak_h,"icon_state"="steak"),
	list("path"=/obj/item/reagent_containers/food/snacks/steak_m,"icon_state"="steak"),
	list("path"=/obj/item/reagent_containers/food/snacks/steak_s,"icon_state"="steak"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw,"icon_state"="bacon-raw","peek_state"="bacon"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon,"icon_state"="bacon"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat,"icon_state"="meat","peek_state"="steak"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat,"icon_state"="meat","peek_state"="steak"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat,"icon_state"="meat","peek_state"="steak"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat,"icon_state"="meat","peek_state"="steak")
	)

	New()
		..()

		contextActions = list()
		contextLayout = new /datum/contextLayout/flexdefault(2, 32, 32, 32)

		for(var/i=1,i<=4,i++)
			quadrants.Add(list(list("food"=null,"side"=1,"grease"=0,"aux_cook"=0))) //aux_cook functions as both a burn timer and a non-meat cook timer

	process()
		..()

		//check if thing is on grill
		if(status & NOPOWER)
			return

		for(var/i=1,i<=4,i++) //in order for cooking to take about 40 seconds, each milestone is in 20s i.e. 40 = done, 60 = burnt
			if(quadrants[i]["food"])
				//var/aux_cook = quadrants[i]["auxcook"]
				if(istype(quadrants[i]["food"],/obj/item/reagent_containers/food/snacks/ingredient/meat))
					//world.log << ("MEAT GRILL EVENT")
					if(!quadrants[i]["aux_cook"])
						//40 seconds on grill = done
						switch(quadrants[i]["food"].grill(quadrants[i]["side"]))
							if(2)
								world.log << ("RARE MEAT PLACEHOLDER")
							if(3)
								world.log << ("RECIPE COMPLETION PLACEHOLDER")
								//complete recipe
								//produce product
								//set aux_cook to 41 //starts burn timer
					else
						if(quadrants[i]["aux_cook"] < 50)
							quadrants[i]["aux_cook"]++
				else
					world.log << ("NON-MEAT GRILL EVENT")
					//40 seconds on grill = done
					if(quadrants[i]["aux_cook"] < 50)
						quadrants[i]["aux_cook"]++

					/*if(quadrants[i]["aux_cook"] < 40)
						if(quadrants[i]["food"].use_grill_proc)
							quadrants[i]["food"].grill()*/

					if(quadrants[i]["aux_cook"] == 40)
						//recipe check
						//produce product
						//start burn timer
						world.log << ("NON-MEAT RECIPE COMPLETION PLACEHOLDER")

				if(quadrants[i]["aux_cook"] == 50) //using aux_cook as a sort of burn timer as well
					//burn
					//DEV - set aux_cook to 0 after pulling
					world.log << ("BURN PLACEHOLDER")
				else //stops generation of infinite grease
					//random grease tick
					//world.log << ("RANDOM GREASE TICK")
					if(quadrants[i]["food"].reagents.has_reagent("grillgrease"))
						//world.log << ("CONTAINS GREASE")
						if(prob(10))
							//world.log << ("PASSED RANDOM CHANCE")
							quadrants[i]["food"].reagents.remove_reagent("grillgrease",1)
							add_grease(i,1)

				//check grease effects

	attackby(obj/item/W as obj, mob/user as mob)
		world.log << ("ATTACKBY")
		if(istype(W,/obj/item/kitchen/utensil/spatula))
			world.log << ("WAS SPATULA")
			if(empty_check("all"))
				world.log << ("ALL EMPTY")
				return
			//cleanup
			reset_to_quadrants(user) //DEV - user temp
			//popup menu
			user.showContextActions(src.contextActions,src)
		else
			//add food to grill
			var/targetquadrant = open_quadrant()
			if(!targetquadrant)
				boutput(user, "<span style=\"color:red\">There is no more room on the grill!</span>")
				return
			user.u_equip(W)
			W.set_loc(src)
			quadrants[targetquadrant]["food"] = W
			quadrants[targetquadrant]["side"] = 1

			var/image/foodoverlay
			foodoverlay = find_overlay(W,targetquadrant)
			foodoverlay.layer = 4
			UpdateOverlays(foodoverlay,"[targetquadrant]")
			//grillsound

	//grill food overlays
	proc/find_overlay(var/obj/item/I,var/targetquadrant)
		for(var/i=1,i<=grill_overlays.len,i++)
			if(I.type == grill_overlays[i]["path"])
				return image('icons/obj/foodNdrink/grill.dmi',"[grill_overlays[i]["icon_state"]]-[targetquadrant]")
		return build_overlay(I,targetquadrant)

	proc/build_overlay(var/obj/item/I,var/targetquadrant)
		var/image/newimage = image(I.icon,I.icon_state)
		newimage.transform *= 0.30

		switch(src.dir)
			if(NORTH)
				switch(targetquadrant)
					if(1)
						newimage.pixel_x=4
						newimage.pixel_y=2
					if(2)
						newimage.pixel_x=-5
						newimage.pixel_y=3
					if(3)
						newimage.pixel_x=4
						newimage.pixel_y=7
					if(4)
						newimage.pixel_x=-5
						newimage.pixel_y=8
			if(SOUTH)
				switch(targetquadrant)
					if(1)
						newimage.pixel_x=-5
						newimage.pixel_y=8
					if(2)
						newimage.pixel_x=4
						newimage.pixel_y=7
					if(3)
						newimage.pixel_x=-5
						newimage.pixel_y=3
					if(4)
						newimage.pixel_x=4
						newimage.pixel_y=2
			if(EAST)
				switch(targetquadrant)
					if(1)
						newimage.pixel_x=-6
						newimage.pixel_y=4
					if(2)
						newimage.pixel_x=-6
						newimage.pixel_y=11
					if(3)
						newimage.pixel_x=2
						newimage.pixel_y=1
					if(4)
						newimage.pixel_x=2
						newimage.pixel_y=8
			if(WEST)
				switch(targetquadrant)
					if(1)
						newimage.pixel_x=6
						newimage.pixel_y=8
					if(2)
						newimage.pixel_x=6
						newimage.pixel_y=1
					if(3)
						newimage.pixel_x=-2
						newimage.pixel_y=11
					if(4)
						newimage.pixel_x=-2
						newimage.pixel_y=4
		return newimage

	//grease management
	proc/add_grease(var/quadrant,var/amount)
		if(!quadrants[quadrant]["grease"])
			add_grease_overlay(quadrant)
		quadrants[quadrant]["grease"] += amount

	proc/remove_grease(var/quadrant,var/amount)
		if((amount == "all") || amount > quadrants[quadrant]["grease"])
			amount = quadrants[quadrant]["grease"]
		quadrants[quadrant]["grease"] -= amount
		if(!quadrants[quadrant]["grease"])
			//remove grill overlay
			ClearSpecificOverlays("grease-[quadrant]")

	proc/add_grease_overlay(var/quadrant)
		var/image/greaseimage = image('icons/obj/foodNdrink/grill.dmi',"grease-[quadrant]")
		greaseimage.layer = 3
		src.UpdateOverlays(greaseimage,"grease-[quadrant]")

	//supporting list management
	proc/open_quadrant() //returns the closest open quadrant number or returns 0 if there is none
		for(var/i=1,i<=4,i++)
			if(quadrants[i]["food"] == null)
				return i
		return 0

	proc/empty_check(var/food_or_grease) //returns 1 if that category is empty
		world.log << ("EMPTY CHECK")
		var/nofood = 1
		var/nogrease = 1
		for(var/i=1,i<=4,i++)
			if(quadrants[i]["food"])
				nofood = 0
			if(quadrants[i]["grease"])
				nogrease = 0
		switch(food_or_grease)
			if("food")
				if(nofood)
					return 1
			if("grease")
				if(nogrease)
					return 1
			if("all")
				if(nofood && nogrease)
					return 1
		return 0

	proc/greasecheck(var/quadrant) //checks for grease on a given quadrant
		if(quadrants[quadrant]["grease"])
			return 1
		else
			return 0

	//ui handling stuffs
	/*proc/update_quadrants() //calculates the items on top of the grill and assigns the context actions accordingly
		removeContextAction(/*thing*/)*/ //duplicate for all quadrants

	proc/reset_to_quadrants(var/mob/user) //resets the interface to the quadrant state
		user.closeContextActions() //DEV - temp
		for(var/datum/contextAction/grill/action in src.contextActions)
			removeContextAction(action.type)

		/*for(var/i=1,i<=src.contextActions.len,i++)
			if(istype(src.contextActions[i],/datum/contextAction/grill))
				world.log << ("FOUND GRILL ACTION")
				world.log << ("src.contextActions[i].type")
				removeContextAction(src.contextActions[i].type)
				world.log << ("REMOVED")*/

		addContextAction(/datum/contextAction/grill/quadrant/quad_1)
		addContextAction(/datum/contextAction/grill/quadrant/quad_2)
		addContextAction(/datum/contextAction/grill/quadrant/quad_3)
		addContextAction(/datum/contextAction/grill/quadrant/quad_4)

	contextActionOverlayRelay(var/datum/contextAction/A)
		var/datum/contextAction/grill/quadrant/GA = A
		var/image/food
		var/image/grease
		var/list/returnlist = list()
		if(quadrants[GA.target_quadrant]["grease"])
			grease = image('icons/obj/decals.dmi',"[pick("dirt","dirt2","dirt3","dirt4","dirt5")]")
			grease.color = "#D6AFAB"
		if(quadrants[GA.target_quadrant]["food"])
			var/obj/item/holder = quadrants[GA.target_quadrant]["food"]
			food = image(holder.icon,holder.icon_state)
			food.color = holder.color
		if(grease)
			returnlist.Add(grease)
		returnlist.Add(food)
		return returnlist

	proc/quadrant_check(var/quadrant)
		return

	proc/setup_grill_actions(var/quadrant) //checks what is in a quadrant and assigns context actions accordingly
		if(!quadrant)
			return
		var/type
		if(quadrants[quadrant]["food"])
			type = 1
		else if(quadrants[quadrant]["grease"])
			type = 2
		if(!type)
			return

		for(var/datum/contextAction/grill/action in src.contextActions)
			removeContextAction(action.type)

		if(type == 1)
			if(!istype(quadrants[quadrant]["food"],/obj/item/reagent_containers/food/snacks/ingredient/meat))
				addContextAction(/datum/contextAction/grill/pull)
			else
				addContextAction(/datum/contextAction/grill/peek)
				addContextAction(/datum/contextAction/grill/press)
				addContextAction(/datum/contextAction/grill/flip)
				addContextAction(/datum/contextAction/grill/pull)
		else if(type == 2)
			addContextAction(/datum/contextAction/grill/clean)

	proc/render_reverse_sprite(var/obj/item/reagent_containers/food/snacks/ingredient/meat/M,var/cookstate,var/active_quadrant/*,var/permanent*/)
	//item, cookstate: 1=raw,2=rare,3=cooked, permanent: 1 or 0 (Does the overlay revert after a certain amount of time?)
	// : renders the cook sprite of the reverse side of a meat item
	//DEV - update

		/*var/image/overlayflash
		switch(cookstate)
			if(1)
				world.log << ("RAW OVERLAY PLACEHOLDER")
				//set non-raw overlays to a different layer and stack them on top of the raw overlay for reference?
			if(2)
				overlayflash = image(overlaybuffer.icon,overlaybuffer.icon_state)
				overlayflash.color = "#7F4100"
				overlayflash.layer = 4
				UpdateOverlays(overlayflash,"[active_quadrant]")
			if(3)
				world.log << ("COOKED OVERLAY PLACEHOLDER")
		if(overlayflash)
			return overlayflash*/

	proc/peek_food(var/mob/user)
		if(peeking)
			return
		if(!quadrants[active_quadrant]["food"])
			return
		if(istype(quadrants[active_quadrant]["food"],/obj/item/reagent_containers/food/snacks/ingredient/meat))
			var/targetside = quadrants[active_quadrant]["side"]
			var/cookvalue
			//view reverse side
			switch(targetside)
				if(1)
					cookvalue = quadrants[active_quadrant]["food"].side_1_grill
				if(2)
					cookvalue = quadrants[active_quadrant]["food"].side_2_grill
			var/image/overlaybuffer = GetOverlayImage("[active_quadrant]")
			peeking = 1
			switch(cookvalue)
				if(0 to 9)
					//do nothing, but still give feedback
					boutput(user,"<span style=\"color:green\"><b>The [quadrants[active_quadrant]["food"].name] is raw on it's reverse side!</b></span>")
				if(10 to 19)
					//flash rare sprite
					UpdateOverlays(render_reverse_sprite(quadrants[active_quadrant]["food"],2,active_quadrant),"[active_quadrant]")
					sleep(1.5 SECONDS)
					UpdateOverlays(overlaybuffer,"[active_quadrant]")
					boutput(user,"<span style=\"color:green\"><b>The [quadrants[active_quadrant]["food"].name] is rare on it's reverse side!</b></span>")
				if(20 to INFINITY) //DEV - goes up to 50, modify grill proc to only go up to a certain amount?
					//flash cooked sprite
					boutput(user,"<span style=\"color:green\"><b>The [quadrants[active_quadrant]["food"].name] is cooked on it's reverse side!</b></span>")
			peeking = 0

	proc/press_food()
		//check if food has grease in it
		//set a relay variable equal to half the current amount of grease
		//remove relay amount from food and add relay amount to the quadrant
		//play sound
	proc/flip_food()
		//update grill overlay based on cook amount
	proc/pull_food()
		//remove overlay, place the food item in hand, and update quadrants list
	proc/clean_quadrant()
		//remove grease and transfer to tray
