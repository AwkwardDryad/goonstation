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
	var/list/quadrants = list()
	var/testthing = 1

	var/list/grill_overlays = list(
	list("path"=/obj/item/reagent_containers/food/snacks/meatball,"icon_state"="meatball"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat,"icon_state"="meat-mystery"),
	list("path"=/obj/item/reagent_containers/food/snacks/steak_h,"icon_state"="steak"),
	list("path"=/obj/item/reagent_containers/food/snacks/steak_m,"icon_state"="steak"),
	list("path"=/obj/item/reagent_containers/food/snacks/steak_s,"icon_state"="steak"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw,"icon_state"="bacon-raw"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon,"icon_state"="bacon"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat,"icon_state"="meat"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat,"icon_state"="meat"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat,"icon_state"="meat"),
	list("path"=/obj/item/reagent_containers/food/snacks/ingredient/meat,"icon_state"="meat")
	)

	New()
		..()

		contextActions = list()
		contextLayout = new /datum/contextLayout/flexdefault(2, 32, 32, 32)

		for(var/i=1,i<=4,i++)
			quadrants.Add(list(list("food"=null,"side"=1,"grease"=0)))

	process()
		..()

		//check if thing is on grill
		if(status & NOPOWER)
			return

		world.log << ("[testthing]")
		testthing++
		for(var/i=1,i<=4,i++) //in order for cooking to take about 40 seconds, each milestone is in 20s i.e. 40 = done, 60 = burnt
			if(quadrants[i]["food"])
				world.log << ("GRILL EVENT PLACEHOLDER")
				//quadrants[i]["food"].grill(quadrants[i]["side"])
				//check overall cook value
				//check mess stuffs

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/kitchen/utensil/spatula))
			if(empty_check("all"))
				return
			//cleanup
			reset_to_quadrants()
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

	//grill overlays
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

	//supporting list management
	proc/open_quadrant() //returns the closest open quadrant number or returns 0 if there is none
		for(var/i=1,i<=4,i++)
			if(quadrants[i]["food"] == null)
				return i
		return 0

	proc/empty_check(var/food_or_grease) //returns 1 if that category is empty
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

	proc/reset_to_quadrants() //resets the interface to the quadrant state
		for(var/datum/contextAction/grill/action in src.contextActions)
			removeContextAction(action.type)

		addContextAction(/datum/contextAction/grill/quadrant/quad_1)
		addContextAction(/datum/contextAction/grill/quadrant/quad_2)
		addContextAction(/datum/contextAction/grill/quadrant/quad_3)
		addContextAction(/datum/contextAction/grill/quadrant/quad_4)

	contextActionOverlayRelay(var/datum/contextAction/A)
		var/datum/contextAction/grill/GA = A
		var/image/overlay
		if(quadrants[GA.quadrant]["food"])
			var/obj/item/holder = quadrants[GA.quadrant]["food"]
			overlay = image(holder.icon,holder.icon_state)
			overlay.color = holder.color
		return overlay

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

	proc/peek_food()
		//visually represent how done the other side is
			//briefly flash the other side of the patty
			//make sure this cant be spammed
	proc/press_food()
		//squeeze grease out onto grill quadrant
	proc/flip_food()
		//update grill overlay based on cook amount
	proc/pull_food()
		//remove overlay, place the food item in hand, and update quadrants list
	proc/clean_quadrant()
		//remove grease and transfer to tray
