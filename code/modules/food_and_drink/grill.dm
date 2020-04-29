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

	New()
		..()

		contextActions = list()
		contextLayout = new /datum/contextLayout/flexdefault(2, 32, 32, 32)

		for(var/i=1,i<=4,i++)
			quadrants.Add(list(list("food"=null,"side"=1,"grease"=0)))

	/*process() //DEV make sure power consumption is working properly
		..()
		for(var/i=1,i<=4,i++) //in order for cooking to take about 40 seconds, each milestone is in 20s i.e. 40 = done, 60 = burnt
			if(quadrants[i]["food"])
				switch(quadrants[i]["side"])
					if(1)
						quadrants[i]["food"].side_1_grill++
					if(2)
						quadrants[i]["food"].side_2_grill++
				//check mess stuffs
	*/

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/reagent_containers/food/snacks) && W:grillable)
			//add food to grill
			var/targetquadrant = open_quadrant()
			if(!targetquadrant)
				boutput(user, "<span style=\"color:red\">There is no more room on the grill!</span>")
				return
			user.u_equip(W)
			W.set_loc(src)
			quadrants[targetquadrant]["food"] = W
			quadrants[targetquadrant]["side"] = 1
			var/image/foodoverlay = image('icons/obj/foodNdrink/grill.dmi',"[W.icon_state]-[targetquadrant]")
			foodoverlay.layer = 4
			UpdateOverlays(foodoverlay,"[targetquadrant]")
			//grillsound
		else if(istype(W,/obj/item/kitchen/utensil/spatula))
			if(empty_check("all"))
				return
			//cleanup
			reset_to_quadrants()
			//popup menu
			user.showContextActions(src.contextActions,src)
		else
			..()

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
			addContextAction(/datum/contextAction/grill/peek)
			addContextAction(/datum/contextAction/grill/press)
			addContextAction(/datum/contextAction/grill/flip)
			addContextAction(/datum/contextAction/grill/pull)
		else if(type == 2)
			addContextAction(/datum/contextAction/grill/clean)

	proc/peek_food()
	proc/press_food()
	proc/flip_food()
	proc/pull_food()
	proc/clean_quadrant()
