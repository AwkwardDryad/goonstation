
// Bad food

/obj/item/reagent_containers/food/snacks/yuck
	name = "?????"
	desc = "How the hell did they manage to cook this abomination..?!"
	icon = 'icons/obj/foodNdrink/food_yuck.dmi'
	icon_state = "yuck"
	amount = 1
	heal_amt = 0
	food_color = "#d6d6d8"
	initial_volume = 25
	initial_reagents = "yuck"

/obj/item/reagent_containers/food/snacks/yuckburn
	name = "smoldering mess"
	desc = "This looks more like charcoal than food..."
	icon = 'icons/obj/foodNdrink/food_yuck.dmi'
	icon_state = "burnt"
	amount = 1
	heal_amt = 0
	food_color = "#33302b"
	initial_volume = 25
	initial_reagents = "yuck"

/obj/item/reagent_containers/food/snacks/shell
	name = "incinerated embodiment of culinary disaster"
	desc = "Oh, the might of cooking."
	heal_amt = 10
	icon = 'icons/obj/foodNdrink/food_yuck.dmi'
	icon_state = "fried"
	food_effects = list("food_warm")
	use_bite_mask = 0
	var/charcoaliness = 0 // how long it cooked - can be used to quickly check grill level

	on_finish(mob/eater)
		..()
		if(iscarbon(eater))
			var/mob/living/carbon/C = eater
			for(var/atom/movable/MO as mob|obj in src)
				MO.set_loc(C)
				C.stomach_contents += MO

	disposing()
		for (var/mob/M in src)
			M.ghostize()
			for (var/obj/item/I in M)
				I.dispose()
		..()

/obj/item/reagent_containers/food/snacks/shell/deepfry
	name = "physical manifestation of the very concept of fried foods"
	desc = "Oh, the power of the deep fryer."
	icon = 'icons/obj/foodNdrink/food_yuck.dmi'
	icon_state = "fried"

/obj/item/reagent_containers/food/snacks/shell/grill
	name = "the charcoal singed essence of grilling itself"
	desc = "Oh, the magic of a hot grill."
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = "fried" // fix this

/obj/item/reagent_containers/food/snacks/pizza
	name = "pizza"
	desc = "A plain cheese and tomato pizza."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "pizza_p"
	amount = 6
	heal_amt = 3
	var/topping_color = "#ff0000"
	var/sharpened = FALSE
	var/sliced = FALSE
	var/topping = FALSE
	var/num = 0
	var/list/topping_colors = list()
	var/list/topping_holder = list()
	custom_food = 0

	mat_changeappearance = 0
	mat_changename = 0
	mat_changedesc = 0

	food_effects = list("food_deep_burp", "food_all")

	New()
		..()
		src.setMaterial(getMaterial("pizza"), appearance = 0, setname = 0)
		if (prob(1))
			SPAWN_DBG( rand(300, 900) )
				src.visible_message("<b>[src]</b> <i>says, \"I'm pizza.\"</i>")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/kitchen/utensil/knife/pizza_cutter/traitor))
			var/obj/item/kitchen/utensil/knife/pizza_cutter/traitor/cutter = W
			if (cutter.sharpener_mode)
				if (src.sharpened)
					boutput(user, "<span class='alert'>This has already been sharpened.</span>")
					return
				src.sharpened = TRUE
				if(src.sliced)
					boutput(user, "<span class='notice'>You sharpen the pizza slice. Somehow.</span>")
					return
				else
					boutput(user, "<span class='notice'>You sharpen the pizza, and start slicing it.</span>")
		if (istool(W, TOOL_CUTTING | TOOL_SAWING))
			if (src.sliced)
				boutput(user, "<span class='alert'>This has already been sliced.</span>")
				return
			boutput(user, "<span class='notice'>You cut the pizza into slices.</span>")
			if (src.name == "cheese keyzza")
				boutput(user, "<i>You feel as though something of value has been lost...</i>")
			src.make_slices()

	proc/make_slices()
		var/makeslices = src.amount
		. = list()
		while (makeslices > 0)
			var/obj/item/reagent_containers/food/snacks/pizza/P = new src.type(get_turf(src))
			P.topping_holder += src.topping_colors
			P.overlays.len = 0
			P.sharpened = src.sharpened
			P.sliced = TRUE
			P.amount = 1
			P.icon_state = "pslice"
			P.quality = src.quality
			P.heal_amt += round((src.heal_amt/makeslices))
			P.topping_color = src.topping_color
			if(src.sharpened)
				src.throw_spin = 0
			if(topping)
				P.name = src.name
				P.desc = src.desc
				P.topping = TRUE
				P.num = src.num
				P.add_topping(num)
			src.reagents.trans_to(P, src.reagents.total_volume/makeslices)
			P.pixel_x = rand(-6, 6)
			P.pixel_y = rand(-6, 6)
			. += P
			makeslices--
		qdel(src)


	attack(mob/M as mob, mob/user as mob, def_zone)
		if (sharpened && prob(15))
			boutput(M, "<span class='alert'>That pizza was sharp!</span>")
			take_bleeding_damage(user, null, 15, DAMAGE_CUT)
		if (!src.sliced)
			if (user == M)
				boutput(user, "<span class='alert'>You can't just cram that in your mouth, you greedy beast!</span>")
				user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
				return
			else
				user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
				return
		else
			if (sharpened)
				boutput(M, "<span class='alert'>The pizza was too pointy!</span>")
				take_bleeding_damage(M, user, 50, DAMAGE_CUT)
			..()

	attack_self(var/mob/user as mob)
		if (sharpened && prob(15))
			boutput(user, "<span class='alert'>The pizza was sharp!</span>")
			take_bleeding_damage(user, null, 15, DAMAGE_CUT)
		if (!src.sliced)
			boutput(user, "<span class='alert'>You can't just cram that in your mouth, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			if (sharpened)
				boutput(user, "<span class='alert'>The pizza was too pointy!</span>")
				take_bleeding_damage(user, user, 50, DAMAGE_CUT)
			..()

	throw_impact(M)
		..()
		if (!sharpened || isnull(M))
			return
		if (sliced)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				H.implant.Add(src)
				src.visible_message("<span class='alert'>[src] gets embedded in [M]!</span>")
				playsound(src.loc, "sound/weapons/slashcut.ogg", 100, 1)
				H.changeStatus("weakened", 2 SECONDS)
				src.set_loc(M)
				src.transfer_all_reagents(M)
			random_brute_damage(M, 11)
			take_bleeding_damage(M, null, 25, DAMAGE_STAB)

	proc/add_topping(var/num)
		var/icon/I
		if (!sliced)
			I = new /icon('icons/obj/foodNdrink/food_meals.dmi',"pizza_topping_1")
			I.Blend(topping_color, ICON_ADD)
			src.overlays += I
		else if (num == 0 && sliced == 1) // Bad, I know, sorry!
			I = new /icon('icons/obj/foodNdrink/food_meals.dmi',"pizza_topping_s1")
			I.Blend(topping_color, ICON_ADD)
			src.overlays += I
		else
			var/x = 0
			while(x++ < num)
				I = new /icon('icons/obj/foodNdrink/food_meals.dmi',"pizza_topping_s[x]")
				topping_color = pick(src.topping_holder)
				src.topping_holder -= topping_color
				I.Blend(topping_color, ICON_ADD)
				src.overlays += I

/obj/item/reagent_containers/food/snacks/pizza/pepperoni
	name = "pepperoni pizza"
	desc = "A typical pepperoni pizza."
	topping = TRUE
	topping_color = "#C90E0E"

	New()
		..()
		src.add_topping(0)

/obj/item/reagent_containers/food/snacks/pizza/meatball
	name = "meatball pizza"
	desc = "A typical meatball pizza."
	topping = TRUE
	topping_color = "#663300"

	New()
		..()
		src.add_topping(0)

/obj/item/reagent_containers/food/snacks/pizza/mushroom
	name = "mushroom pizza"
	desc = "A typical mushroom pizza."
	topping = TRUE
	topping_color = "#CFCFCF"
	food_effects = list("food_disease_resist")

	New()
		..()
		src.add_topping(0)

/obj/item/reagent_containers/food/snacks/pizza/xmas
	name = "\improper Spacemas pizza"
	desc = "A traditional Spacemas pizza! It has ham, mashed potatoes, gingerbread and candy canes on it, with eggnog sauce and a fruitcake crust! Yum!"
	topping = TRUE
	topping_color = "#3CFF00"

	New()
		..()
		src.add_topping(0)

/obj/item/reagent_containers/food/snacks/stroopwafel
	name = "stroopwafel"
	desc = "A traditional cookie from Holland. Doesn't this need to go into the microwave?"
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "stroopwafel"
	amount = 2
	heal_amt = 2
	food_effects = list("food_refreshed")

/obj/item/reagent_containers/food/snacks/cookie
	name = "sugar cookie"
	desc = "Outside of North America, the Earth's Moon, and certain regions of Europa, these are referred to as biscuits."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "cookie-sugar"
	amount = 1
	heal_amt = 1
	var/frosted = 0
	food_color = "#CC9966"
	festivity = 1
	food_effects = list("food_refreshed")

	New()
		..()
		src.pixel_x = rand(-6, 6)
		src.pixel_y = rand(-6, 6)

	attackby(obj/item/W as obj, mob/user as mob)
		if (!frosted && istype(W, /obj/item/reagent_containers/food/snacks/condiment/cream))
			src.frosted = 1

			var/list/frosting_colors = list(rgb(0,0,255),rgb(204,0,102),rgb(255,255,0),rgb(51,153,0))
			var/icon/frosticon = icon('icons/obj/foodNdrink/food_snacks.dmi', "frosting-cookie", src.dir, 1)
			frosticon.Blend( pick(frosting_colors) )
			src.overlays += frosticon

		else
			..()
		return

	metal
		name = "iron cookie"
		desc = "A cookie made out of iron. You could probably use this as a coaster or something."
		heal_amt = 0
		icon_state = "cookie-metal"
		food_effects = list("food_hp_up")

	chocolate_chip
		name = "chocolate-chip cookie"
		desc = "Invented during the Great Depression, this chocolate-laced cookie was a key element of FDR's New Deal policies."
		icon_state = "cookie-chips"
		heal_amt = 2
		initial_volume = 15
		initial_reagents = list("chocolate"=10)

	oatmeal
		name = "oatmeal cookie"
		desc = "This cookie has been designed specifically to evoke memories of one's grandparents."
		icon_state = "cookie-medium"
		heal_amt = 2

	bacon
		name = "bacon cookie"
		desc = "A cookie made out of bacon. Is this intended to be savory or a sweet candied bacon sort of thing? Whatever it is, it's pretty dumb."
		icon_state = "cookie-bacon"
		initial_volume = 50
		initial_reagents = list("porktonium"=25)
		food_effects = list("food_sweaty")

	jaffa
		name = "jaffa cake"
		desc = "Legally a cake, this edible consists of precision layers of chocolate, sponge cake, and orange jelly."
		icon_state = "cookie-jaffa"

	spooky
		name = "spookie"
		desc = "Two ounces of pure terror."
		icon_state = "cookie-spooky"
		frosted = 1
		initial_volume = 25
		initial_reagents = list("ectoplasm"=10)

	butter
		name = "butter cookie"
		desc = "Little bite-sized heart attacks." //no kidding
		icon_state = "cookie-butter"
		frosted = 1
		initial_volume = 25
		initial_reagents = list("butter"=10)

/obj/item/reagent_containers/food/snacks/moon_pie
	name = "sugar moon pie"
	desc = "A confection consisting of a creamy filling sandwiched between two cookies."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "moonpie-sugar"
	amount = 1
	heal_amt = 6
	var/frosted = 0
	food_effects = list("food_refreshed")

	New()
		..()
		src.pixel_x = rand(-6, 6)
		src.pixel_y = rand(-6, 6)

	attackby(obj/item/W as obj, mob/user as mob)
		if (!frosted && istype(W, /obj/item/reagent_containers/food/snacks/condiment/cream))
			src.frosted = 1

			var/list/frosting_colors = list(rgb(0,0,255),rgb(204,0,102),rgb(255,255,0),rgb(51,153,0))
			var/icon/frosticon = icon('icons/obj/foodNdrink/food_snacks.dmi', "frosting-moonpie", src.dir, 1)
			frosticon.Blend(pick(frosting_colors) )
			src.overlays += frosticon

		else
			..()
		return

	metal
		name = "iron moon pie"
		desc = "Definitely not food.  Not even a good coaster anymore, what with all the cream."
		icon_state = "moonpie-metal"
		heal_amt = 0
		food_effects = list("food_hp_up_big")

	chocolate_chip
		name = "chocolate-chip moon pie"
		desc = "The confection commonly credited with winning the Korean, Gulf, and Unfolder wars."
		icon_state = "moonpie-chips"
		heal_amt = 7
		food_effects = list("food_refreshed_big")

	oatmeal
		name = "oatmeal moon pie"
		desc = "The official pie of the moon.  This one.  This specific sandwich cookie right here."
		icon_state = "moonpie-oatmeal"
		heal_amt = 7
		food_effects = list("food_refreshed_big")

	bacon
		name = "bacon moon pie"
		desc = "How is this even food?"
		icon_state = "moonpie-bacon"
		heal_amt = 5
		initial_volume = 50
		initial_reagents = "porktonium"
		food_effects = list("food_sweaty_big")

	jaffa
		name = "jaffa moon cobbler"
		desc = "This dish was named in an attempt to dodge sales taxes on pie production. However, it is actually legally considered a form of crumble."
		icon_state = "moonpie-jaffa"
		heal_amt = 8
		food_effects = list("food_refreshed_big")

	chocolate
		name = "whoopie pie"
		desc = "A confection infamous for being especially terrible for you, in a culture noted for having nothing but foods that are terrible for you."
		icon_state = "moonpie-chocolate"
		heal_amt = 250 //oh jesus
		food_effects = list("food_refreshed_big")

	spooky
		name = "full moon pie"
		desc = "Caution: Do not serve confection within sight of a werewolf, wolfman, or particularly-hairy crew members."
		icon_state = "moonpie-spooky"
		heal_amt = 6
		frosted = 1
		initial_volume = 25
		initial_reagents = list("ectoplasm"=10)
		food_effects = list("food_refreshed_big")

/obj/item/reagent_containers/food/snacks/soup
	name = "soup"
	desc = "A soup of indeterminable type."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "gruel"
	needspoon = 1
	amount = 6
	heal_amt = 1
	w_class = 2
	initial_volume = 100
	food_effects = list("food_warm")
	dropped_item = /obj/item/reagent_containers/food/drinks/bowl

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/tortilla_chip))
			if (amount <= 1)
				boutput(user, "You scoop up the last of [src] with the [W.name].")
			else
				boutput(user, "You scoop some of [src] with the [W.name].")

			if (src.reagents)
				src.reagents.trans_to(W, src.reagents.total_volume/amount)

			src.amount--
			if (!amount)
				qdel(src)
		else
			..()

/obj/item/reagent_containers/food/snacks/soup/tomato
	name = "tomato soup"
	desc = "A rich and creamy soup made from tomatoes."
	icon_state = "tomsoup"
	needspoon = 1
	amount = 6
	heal_amt = 2
	food_effects = list("food_warm","food_refreshed")

/obj/item/reagent_containers/food/snacks/soup/guacamole
	name = "guacamole"
	desc = "A spiced paste made of smashed avocados."
	icon_state = "guacamole"
	needspoon = 1
	amount = 6
	heal_amt = 2
	food_color = "#007B1C"
	initial_reagents = list("guacamole"=90)
	food_effects = list("food_refreshed")

/obj/item/reagent_containers/food/snacks/soup/mint_chutney
	name = "mint chutney"
	desc = "A flavorful paste that smells strongly of mint."
	icon_state = "mintchutney"
	needspoon = 1
	amount = 6
	heal_amt = 2
	food_color = "#2DAB1F"
	initial_reagents = list("mint"=20,"capsaicin"=10)
	food_effects = list("food_refreshed", "food_energized")

/obj/item/reagent_containers/food/snacks/soup/refried_beans
	name = "refried beans"
	desc = "A dish made of mashed beans cooked with lard. It has bits of bacon in it."
	icon_state = "refriedbeans"
	needspoon = 1
	amount = 6
	heal_amt = 2
	food_color = "#AA7777"
	initial_reagents = list("refried_beans"=30)
	food_effects = list("food_deep_fart", "food_space_farts")

/obj/item/reagent_containers/food/snacks/soup/chili
	name = "chili con carne"
	desc = "Meat pieces in a spicy pepper sauce. Delicious."
	icon_state = "tomsoup"
	needspoon = 1
	amount = 6
	heal_amt = 2
	initial_reagents = list("capsaicin"=20)
	food_effects = list("food_warm","food_sweaty")

/obj/item/reagent_containers/food/snacks/soup/queso
	name = "chili con queso"
	desc = "Spicy mexican cheese stuff."
	icon_state = "custard"
	needspoon = 1
	amount = 6
	heal_amt = 2
	food_color = "#FF8C00"
	initial_reagents = list("capsaicin"=10)
	food_effects = list("food_warm","food_space_farts")

/obj/item/reagent_containers/food/snacks/soup/superchili
	name = "chili con flagration"
	desc = "God damn. This stuff smells strong."
	icon_state = "tomsoup"
	needspoon = 1
	amount = 6
	heal_amt = 2
	initial_reagents = list("capsaicin"=50)
	food_effects = list("food_warm", "food_fireburp")

/obj/item/reagent_containers/food/snacks/soup/ultrachili
	name = "El Diablo"
	desc = "You feel overheated just looking at this dish."
	icon_state = "hotchili"
	needspoon = 1
	amount = 2
	heal_amt = 6
	initial_reagents = list("el_diablo"=90)
	food_effects = list("food_warm", "food_fireburp_big")

/obj/item/reagent_containers/food/snacks/soup/gruel
	name = "gruel"
	desc = "Asking if you can have more is probably ill-advised."
	icon_state = "gruel"
	needspoon = 1
	amount = 6
	heal_amt = 0
	food_color = "#808080"
	food_effects = list("food_sweaty")

	heal(var/mob/M)
		if (prob(15)) boutput(M, "<span class='alert'>You feel depressed.</span>")

/obj/item/reagent_containers/food/snacks/soup/porridge
	name = "porridge"
	desc = "Mushy rice. Basically."
	icon_state = "porridge"
	needspoon = 1
	amount = 6
	heal_amt = 1
	food_color = "#E1E1E1"
	food_effects = list("food_brute")

/obj/item/reagent_containers/food/snacks/soup/oatmeal
	name = "oatmeal"
	desc = "Sometimes the station gets the fun kind with the little candy dinosaur eggs. This isn't the fun kind."
	icon_state = "oatmeal-plain"
	needspoon = 1
	amount = 6
	heal_amt = 2
	var/randomized = 1
	food_effects = list("food_brute")

	New()
		..()
		if (randomized)
			src.name = "[pick("cranberry", "apple cinnamon", "maple", "cran-apple";5, "blueberry-maple";5, "peaches and cream", "bananas and cream", "strawberries and cream", "plain", "cinnamon", "raisins, dates, and walnuts";5)] oatmeal"
		return

	fun
		desc = "The fun kind of oatmeal with the little candy dinosaur eggs.  HECK YES!"
		icon_state = "oatmeal-fun"
		randomized = 0

		heal(var/mob/M)
			var/dinosaur = pick("Ohmdenosaurus","Velafrons","Saurophaganax","Bissektipelta","Aardonyx","Tsintaosaurus","Barapasaurus","Rahonavis")
			boutput(M, "<span class='notice'>You found a marshmallow [dinosaur] in this bite!</span>")
			..()

/obj/item/reagent_containers/food/snacks/soup/creamofmushroom
	name= "cream of mushroom"
	desc = "A thick soup that can be made from various mushrooms."
	icon_state = "gruel"
	needspoon = 1
	amount = 6
	heal_amt = 2
	food_effects = list("food_tox", "food_disease_resist")

/obj/item/reagent_containers/food/snacks/soup/creamofmushroom/amanita
	name= "cream of mushroom"
	desc = "A thick soup that can be made from various mushrooms."
	icon_state = "gruel"
	needspoon = 1
	amount = 6
	heal_amt = 2
	initial_volume = 30
	initial_reagents = list("amanitin"=30)
	food_effects = list("food_disease_resist", "food_rad_resist")

/obj/item/reagent_containers/food/snacks/soup/creamofmushroom/psilocybin
	name= "cream of mushroom"
	desc = "A thick soup that can be made from various mushrooms."
	icon_state = "gruel"
	needspoon = 1
	amount = 6
	heal_amt = 2
	initial_volume = 60
	initial_reagents = list("psilocybin"=20,"LSD"=20,"space_drugs"=20)
	food_effects = list("food_tox", "food_disease_resist", "food_rad_resist")

/obj/item/reagent_containers/food/snacks/salad
	name = "salad"
	desc = "A meal of mostly plants. Good for healthy eating."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "salad"
	needfork = 1
	amount = 4
	heal_amt = 2
	food_effects = list("food_energized", "food_refreshed")

/obj/item/reagent_containers/food/snacks/cereal_box
	name = "cereal box -'Pope Crunch'"
	desc = "A sugary breakfast cereal with a papal mascot. Each 1/8 cup serving is an important part of a balanced breakfast!"
	icon_state = "cereal_box"
	amount = 11
	real_name = "cereal"
	w_class = 2
	var/prize = 10 //Chance of a rad prize inside!

	New()
		..()
		if (prize > 0)
			prize = prob(prize)

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (user == M)
			user.visible_message("<b>[user]</b> pours [src] directly into their mouth!", "You eat straight from the box!")
		else
			user.visible_message("<span class='alert'><b>[user]</b> pours [src] into [M]'s mouth!</span>")

		//Hello, here is a dumb hack to get around "you take a bite of cerealbox-'Pope Crunch'!"
		// apparently there was a runtime error here, i'm guessing someone edited a cereal box's name?
		var/name_len = length(src.name)
		if (name_len > 14)
			var/tempname = src.name
			src.name = copytext(src.name, 14, name_len)
			..()
			src.name = tempname
		else
			..()

		return

/obj/item/reagent_containers/food/snacks/cereal_box/honey
	name = "cereal box -'Honey Wonks'"
	desc = "A honey-sweetened breakfast cereal. A total sugarbomb, but it probably contains some vitamins or something."
	icon_state = "cereal_box2"
	prize = 0

/obj/item/reagent_containers/food/snacks/cereal_box/tanhony
	name = "cereal box -'Tanh-O-Nys'"
	desc = "An artificially sweetened breakfast cereal with a monkey mascot. It probably tastes like bananas or something."
	icon_state = "cereal_box3"
	prize = 0

/obj/item/reagent_containers/food/snacks/cereal_box/roach
	name = "cereal box -'Roach Puffs'"
	desc = "A puffy, chocolately breakfast cereal. Probably."
	icon_state = "cereal_box4"
	prize = 0

/obj/item/reagent_containers/food/snacks/cereal_box/syndie
	name = "cereal box -'Shredded Syndies'"
	desc = "A fortified breakfast cereal, packed chock full of half grains and magnesium."
	icon_state = "cereal_box5"
	initial_volume = 20
	initial_reagents = list("atropine"=10,"space_drugs"=10)
	prize = 0

/obj/item/reagent_containers/food/snacks/cereal_box/cirrial
	name = "cereal box -'Flocked-Flakes Cirrial'"
	desc = "A bluey-green cereal that beeps gently at you, they're grrrrowing out of the box oh fuck!"
	icon_state = "cereal_box5"
	initial_volume = 20
	initial_reagents = list("feather_fluid"=10)
	prize = 0

/obj/item/reagent_containers/food/snacks/soup/cereal
	name = "dry cereal"
	desc = "A bowl of colorful breakfast cereal, each piece sharp enough to slice the roof of your mouth into meat confetti."
	icon_state = "cereal_bowl"
	amount = 5
	heal_amt = 1
	var/dry = 1
	var/hasPrize = 0
	food_effects = list("food_refreshed")

	New(loc, prize_inside)
		..()
		hasPrize = (prize_inside == 1)

	on_reagent_change()
		if (src.reagents && src.reagents.total_volume)
			src.name = "cereal"
			src.dry = 0
		else
			src.name = "[src.dry ? "dry" : "soggy"] cereal"

	heal(var/mob/M)
		M.reagents.add_reagent("sugar",15)
		if(src.dry)
			boutput(M, "<span class='alert'>It cuts the roof of your mouth! WHY DID YOU TRY EATING THIS DRY?!</span>")
			random_brute_damage(M, 3)
			take_bleeding_damage(M, null, 0, DAMAGE_STAB, 0)
			bleed(M, 3, 1)
			M.emote("scream")

		if(src.hasPrize && ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/affecting = H.organs["head"]
			boutput(H, "<span class='alert'>You slash your mouth and tongue open on a piece of jagged rusty metal! Looks like you found the prize inside!</span>")
			H.changeStatus("weakened", 3 SECONDS)
			affecting.take_damage(10, 0)
			take_bleeding_damage(H, null, 0, DAMAGE_STAB, 0)
			bleed(H, rand(10,30), rand(1,3))
			H.UpdateDamageIcon()
			src.hasPrize = 0
			new /obj/item/razor_blade( get_turf(src) )
		..()

	disposing()
		if (src.amount < 1)
			new /obj/item/reagent_containers/food/drinks/bowl(get_turf(src))
		..()

	is_open_container()
		return 1

/obj/item/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	icon_state = "waffles"
	amount = 5
	heal_amt = 2
	food_effects = list("food_energized")

/obj/item/reagent_containers/food/snacks/donkpocket
	name = "donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	heal_amt = 4
	amount = 1
	doants = 0
	var/warm = 0

	warm
		name = "warm donk-pocket"
		warm = 1

		New()
			..()
			src.cooltime()
			return

	heal(var/mob/M)
		if(src.warm && M.reagents)
			M.reagents.add_reagent("omnizine",15)
		else
			boutput(M, "<span class='alert'>It's just not good enough cold..</span>")
		..()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if (!warm && exposed_temperature >= T0C+176.7) //Roughly 350 C
			src.warm = 1
			name = "warm [initial(src.name)]"
			src.cooltime()
		return ..()

	proc/cooltime()
		if (src.warm)
			SPAWN_DBG( 4200 )
				src.warm = 0
				src.name = "donk-pocket"
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/condiment/)) src.amount += 1

/obj/item/reagent_containers/food/snacks/donkpocket_w
	name = "donk-pocket"
	desc = "This donk-pocket is emitting a small amount of heat."
	icon_state = "donkpocket"
	heal_amt = 25
	amount = 1
	heal(var/mob/M)
		if(M.reagents)
			M.reagents.add_reagent("omnizine",15)
			M.reagents.add_reagent("teporone", 15)
			M.reagents.add_reagent("synaptizine", 15)
			M.reagents.add_reagent("saline", 15)
			M.reagents.add_reagent("salbutamol", 15)
			M.reagents.add_reagent("methamphetamine", 15)
		..()

/obj/item/reagent_containers/food/snacks/donkpocket/honk
	name = "honk-pocket"
	desc = "The food of choice for the seasoned t-- wait, what?"

	warm
		name = "warm honk-pocket"
		warm = 1

	heal(var/mob/M)
		if(src.warm && M.reagents)
			M.reagents.add_reagent("honk_fart",15)
		else
			boutput(M, "<span class='alert'>It's just not good enough cold...</span>")
			M.reagents.add_reagent("simethicone",15)
		..()

	cooltime()
		if (src.warm)
			SPAWN_DBG( 4200 )
				src.warm = 0
				src.name = "honk-pocket"
		return

/obj/item/reagent_containers/food/snacks/breakfast
	name = "bacon and eggs"
	desc = "A plate containing a breakfast meal of both bacon AND eggs. Together!"
	icon_state = "breakfast"
	amount = 4
	heal_amt = 4
	needfork = 1
	food_effects = list("food_energized_big")

/obj/item/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	amount = 1
	heal_amt = 2
	food_color ="#663300"

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/condiment/))
			src.amount += 1
		else return ..()

/obj/item/reagent_containers/food/snacks/swedishmeatball
	name = "swedish meatballs"
	desc = "It's even got a little rice-paper swedish flag in it. How cute."
	icon_state = "swede_mball"
	needfork = 1
	amount = 6
	heal_amt = 2
	food_color ="#663300"
	initial_volume = 30
	initial_reagents = list("swedium"=25)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/condiment/))
			src.amount += 1
		else return ..()

/obj/item/reagent_containers/food/snacks/surstromming
	name = "funny-looking can"
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "surs" //todo: get real sprite
	heal_amt = 0
	amount = 5
	desc = ""
	food_effects = list("food_bad_breath")

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (src.icon_state == "surs")
			if (user == M)
				boutput(user, "<span class='alert'>You need to take the lid off first, you greedy beast!</span>")
				user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
				return
			else
				user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
				return
		else
			..()

	New()
		..()
		processing_items |= src

	process()
		if (prob(30) && src.icon_state == "surs-open")
			for(var/mob/living/carbon/H in viewers(src, null))
				if (H.bioHolder.HasEffect("accent_swedish"))
					return
				boutput(H, "<span class='alert'>[stinkString()]</span>")
				if(prob(30))
					H.changeStatus("stunned", 2 SECONDS)
					boutput(H, "<span class='alert'>[stinkString()]</span>")
					H.visible_message("<span class='alert'>[H] vomits, unable to handle the fishy stank!</span>")
					H.vomit()

	disposing()
		processing_items.Remove(src)
		..()


	heal(var/mob/M)
		if (M.bioHolder.HasEffect("accent_swedish"))
			boutput(M, "<span class='notice'>It tastes just like the old country!</span>")
			M.reagents.add_reagent("love", 5)
			..()
		else
			var/effect = rand(1,21)
			switch(effect)
				if(1 to 5)
					boutput(M, "<span class='alert'>aaaaaAAAAA<b>AAAAAAAA</b></span>")
					M.visible_message("<span class='alert'>[M] suddenly and violently vomits!</span>")
					M.vomit()
					M.changeStatus("weakened", 4 SECONDS)
				if(6 to 10)
					boutput(M, "<span class='alert'>A squirt of some foul-smelling juice gets in your sinuses!!!</span>")
					M.emote("scream")
					M.emote("sneeze")
					M.changeStatus("weakened", 4 SECONDS)
					SPAWN_DBG(0)
						while(prob(75))
							sleep(rand(50,75))
							boutput(M, "<span class='alert'>Some of the horrible juice in your nose drips into the back of your throat!!</span>")
							M.emote("sneeze")
							M.vomit()
							M.changeStatus("stunned", 2 SECONDS)
				if(11 to 15)
					boutput(M, "<span class='notice'>Huh. That wasn't so bad. <span class='alert'>WAIT NEVERMIND THERE'S THE AFTERTASTE</span></span>")
					M.emote ("cry")
					M.changeStatus("weakened", 4 SECONDS)
				if(16 to 20)
					boutput(M, "<span class='alert'>AGHBGLBLGHLGBGLHGHBLGH</span>")
					M.visible_message("<span class='alert'>[M] pukes their guts out!</span>")
					playsound(M.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
					M.changeStatus("weakened", 4 SECONDS)
					if (ishuman(M))
						var/mob/living/carbon/human/H = M

						var/obj/decal/cleanable/blood/gibs/G = null // For forensics (Convair880).
						G = make_cleanable( /obj/decal/cleanable/blood/gibs,M.loc)
						if (H.bioHolder.Uid && H.bioHolder.bloodType)
							G.blood_DNA = H.bioHolder.Uid
							G.blood_type = H.bioHolder.bloodType

						if (prob(5) && H.organHolder && H.organHolder.heart)
							H.organHolder.drop_organ("heart")

							H.visible_message("<span class='alert'><b>Wait, is that their heart!?</b></span>")
				if(21)
					if (!M.bioHolder.HasEffect("stinky"))
						boutput(M, "<span class='alert'>Oh God, the stink is <b>inside</b> you now!</span>")
						M.bioHolder.AddEffect("stinky")
						M.changeStatus("stunned", 2 SECONDS)
						return
					else
						boutput(M, "<span class='alert'>The stink of the surströmming combines with your inherent body funk to create a stench of BIBLICAL PROPORTIONS!</span>")
						M.name_suffix("the Stinky")
						M.UpdateName()
		..()


	examine(mob/user)
		. = ..()
		if (user.bioHolder.HasEffect("accent_swedish"))
			if (src.icon_state == "surs")
				. += "Oooh, a can of surströmming! It's been a while since you've seen one of these. It looks like it's ready to eat."
			else
				. += "Oooh, a can of surströmming! It's been a while since you've seen one of these. It smells heavenly!"
			return
		else
			if (src.icon_state == "surs")
				. += "The fuck is this? The label's written in some sort of gibberish, and you're pretty sure cans aren't supposed to bulge like that."
			else
				. += "<b>AAAAAAAAAAAAAAAAUGH AAAAAAAAAAAUGH IT SMELLS LIKE FERMENTED SKUNK EGG BUTTS MAKE IT STOP</b>"

	attack_self(var/mob/user as mob)
		if (src.icon_state == "surs")
			boutput(user, "<span class='notice'>You pop the lid off the [src].</span>")
			src.icon_state = "surs-open" //todo: get real sprite
			for(var/mob/living/carbon/M in viewers(user, null))
				if (M == user)
					if (user.bioHolder.HasEffect("accent_swedish"))
						boutput(user, "<span class='notice'>Ahhh, that smells wonderful!</span>")
					else
						boutput(user, "<span class='alert'><font size=4><B>HOLY FUCK THAT REEKS!!!!!</b></font></span>")
						user.changeStatus("weakened", 8 SECONDS)
						user.visible_message("<span class='alert'>[user] suddenly and violently vomits!</span>")
						user.vomit()
				else
					if(M.bioHolder.HasEffect("accent_swedish"))
						boutput(M, "<span class='notice'>Hey, something smells good!</span>")
					else
						boutput(M, "<span class='alert'><font size=4><B>WHAT THE FUCK IS THAT SMELL!?</b></font></span>")
						M.changeStatus("weakened", 4 SECONDS)
						M.visible_message("<span class='alert'>[M] suddenly and violently vomits!</span>")
						M.vomit()

/obj/item/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "chips"
	heal_amt = 1
	doants = 0
	food_effects = list("food_explosion_resist")

/obj/item/reagent_containers/food/snacks/popcorn
	name = "popcorn"
	desc = "Pop that corn!"
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state =  "popcorn1"
	amount = 4
	heal_amt = 1
	food_effects = list("food_cateyes")

/obj/item/reagent_containers/food/snacks/spaghetti/
	name = "spaghetti noodles"
	desc = "Just noodles on their own."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "spag-plain"
	needfork = 1
	heal_amt = 1
	amount = 3
	food_effects = list("food_brute","food_burn")


	New()
		. = ..()
		name = "[random_spaghetti_name()] noodles"

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/reagent_containers/food/snacks/condiment/ketchup) && icon_state == "spag_plain" )// don't forget, other shit inherits this too!
			boutput(user, "<span class='notice'>You create [random_spaghetti_name()] with tomato sauce...</span>")
			var/obj/item/reagent_containers/food/snacks/spaghetti/sauce/D
			if (user.mob_flags & IS_BONER)
				D = new/obj/item/reagent_containers/food/snacks/spaghetti/sauce/skeletal(W.loc)
				boutput(user, "<span class='alert'>... whoa, that felt good. Like really good.</span>")
				user.reagents.add_reagent("bonerjuice",20)
			else
				D = new/obj/item/reagent_containers/food/snacks/spaghetti/sauce(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)

		// Muppet show EP 111
		if (istype(W, /obj/item/kitchen/utensil/spoon))
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.a_intent == INTENT_HARM && (H.job == "Chef" || H.job == "Sous-Chef") && H.bioHolder?.HasEffect("accent_swedish"))
					src.visible_message("<span class='alert'><b>[H] hits the [src] with [W]!<b></span>")
					src.visible_message("<span class='alert'>The [src] barks at [H]!</span>")
					playsound(get_turf(src), "sound/voice/animal/dogbark.ogg", 40, 1)
					SPAWN_DBG(0.75 SECONDS)
						if (src && H)
							src.visible_message("<span class='alert'>The [src] takes a bite out of [H]!</span>")
							random_brute_damage(H, 10)

		else
			return ..()

	heal(var/mob/M) // ditto goddammit - arrabiata is not fuckin bland you dorks
		if (icon_state == "spag_plain")
			boutput(M, "<span class='alert'>This is really bland.</span>")
		. = ..()

/obj/item/reagent_containers/food/snacks/spaghetti/sauce/skeletal
	name = "boneless spaghetti"
	desc = "Eh, this isn't very good at all..."
	icon_state = "spag-dish"
	needfork = 1
	heal_amt = 1
	amount = 5
	initial_volume = 60
	food_effects = list("food_energized","food_explosion_resist")
	initial_reagents = list("milk"=50)

	New()
		. = ..()
		name = "boneless [random_spaghetti_name()]"

	process()
		if(prob(1))
			playsound(src,'sound/musical_instruments/Bikehorn_1.ogg',50)

/obj/item/reagent_containers/food/snacks/spaghetti/sauce
	name = "spaghetti with tomato sauce"
	desc = "Eh, the sauce tastes pretty bland..."
	icon_state = "spag-dish"
	needfork = 1
	heal_amt = 3
	amount = 5
	food_effects = list("food_energized","food_brute","food_burn")

	New()
		. = ..()
		name = "[random_spaghetti_name()] with tomato sauce"

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/reagent_containers/food/snacks/condiment/hotsauce))
			boutput(user, "<span class='notice'>You create [random_spaghetti_name()] arrabbiata!</span>")
			var/obj/item/reagent_containers/food/snacks/spaghetti/spicy/D = new/obj/item/reagent_containers/food/snacks/spaghetti/spicy(W.loc)
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)
		else if(istype(W,/obj/item/reagent_containers/food/snacks/pizza))
			var/obj/item/reagent_containers/food/snacks/pizza/P = W
			boutput(user, "<span class='notice'>You create pizza-ghetti!</span>")
			var/obj/item/reagent_containers/food/snacks/spaghetti/spicy/D = new/obj/item/reagent_containers/food/snacks/spaghetti/pizzaghetti(W.loc)
			D.food_effects += P.food_effects
			D.food_effects += src.food_effects
			user.u_equip(W)
			user.put_in_hand_or_drop(D)
			qdel(W)
			qdel(src)
		else return ..()

/obj/item/reagent_containers/food/snacks/spaghetti/spicy
	name = "spaghetti arrabbiata"
	desc = "Quite spicy!"
	icon_state = "spag-dish-spicy"
	needfork = 1
	heal_amt = 1
	amount = 5
	initial_volume = 60
	initial_reagents = list("capsaicin"=50,"omnizine"=5,"synaptizine"=5)
	food_effects = list("food_energized","food_brute","food_burn")

	New()
		. = ..()
		name = "[random_spaghetti_name()] arrabbiata"

/obj/item/reagent_containers/food/snacks/spaghetti/meatball
	name = "spaghetti and meatballs"
	desc = "That's better!"
	icon_state = "spag-meatball"
	needfork = 1
	heal_amt = 2
	amount = 5
	initial_volume = 10
	initial_reagents = "synaptizine"
	food_effects = list("food_energized","food_hp_up","food_brute","food_burn")

	New()
		. = ..()
		name = "[random_spaghetti_name()] and meatballs"

/obj/item/reagent_containers/food/snacks/spaghetti/pizzaghetti
	name = "pizza-ghetti"
	desc = "This is just- It's pizza and spaghetti on a plate? They're not even touching. What gives?"
	icon_state = "pizzaghetti"
	needfork = 1
	heal_amt = 1
	amount = 5
	initial_volume = 50
	initial_reagents = list("quebon"=25,"nicotine"=5,"gravy"=5,"pizza"=5) // staples of french canadian life
	food_effects = list("food_sweaty")

	New()
		. = ..()
		name = "pizza-ghetti"

	heal(var/mob/M)
		boutput(M, "<span class='alert'>Tastes like pizza and spaghetti, but way less convenient.</span>")
		. = ..()

/obj/item/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "donut1"
	heal_amt = 1
	initial_volume = 20
	initial_reagents = "sugar"
	food_effects = list("food_energized")

	heal(var/mob/M)
		if(ishuman(M) && (M.job in list("Security Officer", "Head of Security", "Detective")))
			src.heal_amt *= 2
			..()
			src.heal_amt /= 2
		else
			..()

	frosted
		name = "frosted donut"
		icon_state = "donut2"
		heal_amt = 2

	cinnamon
		name = "cinnamon sugar donut"
		desc = "One of Delectable Dan's seasonal bestsellers."
		icon_state = "donut3"
		heal_amt = 3

	robust
		name = "robust donut"
		desc = "It's like an energy bar, but in donut form! Contains some chemicals known for partial stun time reduction and boosted stamina regeneration."
		icon_state = "donut4"
		amount = 6
		initial_volume = 36
		initial_reagents = list("sugar"=12,"synaptizine"=12,"epinephrine"=12)

	random
		New()
			if(rand(1,3) == 1)
				src.icon_state = "donut2"
				src.name = "frosted donut"
				src.heal_amt = 2
			..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			user.suiciding = 0
			return 0
		user.u_equip(src)
		user.visible_message("<span class='alert'><b>[user] accidentally inhales part of a [src], blocking their windpipe!</b></span>")
		user.take_oxygen_deprivation(123)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/reagent_containers/food/snacks/bagel
	name = "bagel"
	desc = "A lovely bread torus to snack on."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "bagel"
	heal_amt = 1
	food_effects = list("food_explosion_resist")

	New()
		..()
		if(rand(1,3) == 1)
			src.icon_state = "seedbagel"
			src.name = "seed bagel"
			src.desc = "A bagel. But with seeds on it!"

/obj/item/reagent_containers/food/snacks/crumpet
	name = "crumpet"
	desc = "Fresh from England! Goes best with tea."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "crumpet"
	heal_amt = 1
	food_effects = list("food_brute")

/obj/item/reagent_containers/food/snacks/mushroom
	name = "space mushroom"
	desc = "A mushroom cap of Space Fungus. Probably tastes pretty bad."
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	icon_state = "mushroom"
	food_color = "#89533C"
	amount = 1
	heal_amt = 0
	food_effects = list("food_disease_resist")

/obj/item/reagent_containers/food/snacks/mushroom/amanita
	name = "space mushroom"
	desc = "A mushroom cap of Space Fungus. This one is quite different."
	icon_state = "mushroom-poison"
	food_color = "#AF2B2B"
	amount = 1
	heal_amt = 3

/obj/item/reagent_containers/food/snacks/mushroom/psilocybin
	name = "space mushroom"
	desc = "A mushroom cap of Space Fungus. It's slightly more vibrant than usual."
	icon_state = "mushroom-magic"
	food_color = "#A76933"
	amount = 1
	heal_amt = 1

/obj/item/reagent_containers/food/snacks/mushroom/cloak
	name = "space mushroom"
	desc = "A mushroom cap of Space Fungus. It doesn't smell of anything."
	icon_state = "mushroom-M3"
	amount = 1
	heal_amt = 0


// Foods

/obj/item/reagent_containers/food/snacks/ectoplasm
	name = "ectoplasm"
	desc = "A luminescent blob of what scientists refer to as \"ghost goo.\""
	icon = 'icons/misc/halloween.dmi'
	icon_state = "ectoplasm"
	real_name = "ectoplasm"
	heal_amt = 0
	amount = 2
	doants = 0
	food_color = "#B3E197"
	initial_volume = 15
	initial_reagents = list("ectoplasm" = 10)
	food_effects = list("food_hp_up_small", "food_damage_tox")

	New()
		..()
		flick("ectoplasm-a", src)
		src.setMaterial(getMaterial("ectoplasm"), appearance = 0, setname = 0)

	heal(mob/M)
		..()
		var/ughmessage = pick("Your mouth feels haunted. Haunted with bad flavors.","It tastes like flavor died.", "It tastes like a ghost fart.", "It has the texture of ham aspic.  From the 1950s.  Left out in the sun.")
		boutput(M, "<span class='alert'>Ugh, why did you eat that? [ughmessage]</span>")

/obj/item/reagent_containers/food/snacks/corndog
	name = "corndog"
	desc = "A hotdog inside a fried cornmeal shell.  On a stick."
	icon = 'icons/obj/foodNdrink/food_hotdog.dmi'
	icon_state = "corndog"
	amount = 3
	heal_amt = 4
	initial_volume = 30
	initial_reagents = list("porktonium"=10)
	food_effects = list("food_sweaty")

	banana
		name = "banana-corndog"
		desc = "A hotdog inside a fried banana bread shell.  Is that even possible?"
		icon_state = "corndogb"
		heal_amt = 20
		food_effects = list("food_sweaty_big")

	brain
		name = "brain-corndog"
		desc = "A hotdog inside a fried shell of...what."
		icon_state = "corndogbr"
		heal_amt = 5
		food_effects = list("food_hp_up_big")

	elvis
		name = "hounddog-on-a-stick"
		desc = "It ain't never caught a rabbit and it ain't no friend of mine."
		icon_state = "elviscorndog"
		heal_amt = 10
		initial_reagents = list("porktonium"=10,"essenceofelvis"=15)
		food_effects = list("food_energized_big")

	spooky
		name = "corndog of the damned"
		desc = "A very haunted hotdog in a very haunted shell. Probably the most haunted hotdog ever, honestly."
		icon_state = "hauntedcorndog"
		heal_amt = 5
		food_effects = list("food_all")

	on_reagent_change()
		src.update_icon()

	proc/update_icon()
		src.overlays.len = 0
		if (src.reagents.has_reagent("juice_tomato"))
			src.overlays += image(src.icon, "corndog-k")
			//to-do: mustard
		return

/obj/item/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "A plain hotdog."
	icon = 'icons/obj/foodNdrink/food_hotdog.dmi'
	icon_state = "hotdog"
	amount = 3
	heal_amt = 2
	var/bun = 0
	var/herb = 0
	initial_volume = 30
	initial_reagents = list("porktonium"=10)

	on_reagent_change()
		src.update_icon()

	heal(var/mob/M)
		if (src.bun == 4) M.bioHolder.AddEffect("accent_elvis", timeleft = 180)
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/breadslice))
			if(src.bun)
				boutput(user, "<span class='alert'>It already has a bun!</span>")
				return

			if(istype(W, /obj/item/reagent_containers/food/snacks/breadslice/banana))
				src.bun = 2
				src.desc = "A hotdog...in a banana bread bun.  What."
				src.heal_amt += 8
				src.name = "bananadog"
				food_effects = list("food_sweaty_big","food_all")
				if(src.herb)
					src.name = "herbal " + src.name
			else if (istype(W, /obj/item/reagent_containers/food/snacks/breadslice/brain))
				src.bun = 3
				src.desc = "A hotdog in some manner of meat-bread bun."
				src.heal_amt += 2
				src.name = "braindog"
				food_effects = list("food_hp_up_big","food_all")
				if(src.herb)
					src.name = "herbal " + src.name
			else if (istype(W, /obj/item/reagent_containers/food/snacks/breadslice/elvis))
				src.bun = 4
				src.desc = "It ain't never caught a rabbit and it ain't no friend of mine."
				src.heal_amt += 4
				src.name = "hounddog"
				food_effects = list("food_energized_big","food_all")
				if(src.herb)
					src.name = "herbal " + src.name

			else if (istype(W, /obj/item/reagent_containers/food/snacks/breadslice/spooky))
				var/wowspooky = 0
#ifdef HALLOWEEN
				wowspooky = 1
#endif
				if (user.mob_flags & IS_BONER)
					wowspooky = 1
				if (wowspooky)
					user.visible_message("[user] adds a bun to [src].","You add a bun to [src].")
					src.visible_message("The hot dog comes to life!")
					new /obj/critter/hauntdog(get_turf(src))
					user.u_equip(src)
					user.u_equip(W)
					var/area/getarea = get_area(src)
					getarea.john_talk = list("It smells sausagey here... too sausagey","I know the smell of hauntdog. We need to move. FAST.","Get my grill. Don't ask questions.")
					qdel(W)
					qdel(src)
					return
				else
					src.bun = 5
					src.desc = "A very haunted hotdog. A hauntdog, perhaps."
					src.heal_amt += 1
					src.name = "frankenstein's beef frank" // why not beef frankenstein?
					food_effects = list("food_all","food_brute")
					if (src.reagents)
						src.reagents.add_reagent("ectoplasm", 10)
					if(src.herb)
						src.name = "herbal " + src.name

			else
				src.bun = 1
				src.desc = "A hotdog! A staple of both sporting events and space stations."
				food_effects = list("food_all")

			qdel(W)
			user.visible_message("[user] adds a bun to [src].","You add a bun to [src].")
			src.update_icon()

		else if (istype(W,/obj/item/rods) || istype(W,/obj/item/stick))
			if(!src.bun)
				boutput(user, "<span class='alert'>You need to bread it first!</span>")
				return

			// Check for broken sticks
			if(istype(W,/obj/item/stick))
				var/obj/item/stick/S = W
				if(S.broken)
					boutput(user, __red("You can't use a broken stick!"))
					return

			boutput(user, "<span class='notice'>You create a corndog...</span>")
			var/obj/item/reagent_containers/food/snacks/corndog/newdog = null
			switch(src.bun)
				if(2)
					newdog = new /obj/item/reagent_containers/food/snacks/corndog/banana(get_turf(src))
				if(3)
					newdog = new /obj/item/reagent_containers/food/snacks/corndog/brain(get_turf(src))
				if (4)
					newdog = new /obj/item/reagent_containers/food/snacks/corndog/elvis(get_turf(src))
				if (5)
					newdog = new /obj/item/reagent_containers/food/snacks/corndog/spooky(get_turf(src))
				else
					newdog = new /obj/item/reagent_containers/food/snacks/corndog(get_turf(src))

			// Consume a rod or stick
			if(istype(W,/obj/item/rods)) W.change_stack_amount(-1)
			if(istype(W,/obj/item/stick)) W.amount--

			// If no rods or sticks left, delete item
			if(!W:amount) qdel(W)

			if(newdog?.reagents && src.reagents)
				src.reagents.trans_to(newdog, 100)

			if(src.herb)
				newdog.name = replacetext(newdog.name, "corn","herb")
				newdog.desc = replacetext(newdog.desc, "hotdog","sausage")

			qdel(src)

		else if (istype(W,/obj/item/plant/herb) && !src.herb)
			if(src.bun)
				boutput(user, "<span class='alert'>It's too late! This hotdog is already in a bun, you see.</span>")
				return

			boutput(user, "<span class='notice'>You create a herbal sausage...</span>")
			src.herb = 1
			src.icon_state = "sausage"
			src.name = "herbal sausage"
			desc = "A fancy herbal sausage! Spices really make the sausage."
			W.reagents.trans_to(src,W.reagents.total_volume)
			pool(W)

		else if (istype(W,/obj/item/kitchen/utensil/knife))
			if(src.GetOverlayImage("bun"))
				return
			var/hotloc = get_turf(src)
			var/obj/item/reagent_containers/food/snacks/hotdog_half/l = new /obj/item/reagent_containers/food/snacks/hotdog_half
			var/obj/item/reagent_containers/food/snacks/hotdog_half/r = new /obj/item/reagent_containers/food/snacks/hotdog_half
			l.icon_state = "hotdogl"
			r.icon_state = "hotdogr"
			if(src in user.contents)
				user.u_equip(src)
				src.set_loc(user)
				l.set_loc(get_turf(user))
				r.set_loc(get_turf(user))
			else
				src.set_loc(user)
				l.set_loc(hotloc)
				r.set_loc(hotloc)
			qdel(src)

		else
			..()
		return

	proc/update_icon()
		if(!(src.GetOverlayImage("bun")))
			switch(src.bun)
				if(1)
					src.UpdateOverlays(new /image(src.icon,"hotdog-bun"),"bun")
				if(2)
					src.UpdateOverlays(new /image(src.icon,"hotdog-bunb"),"bun")
				if(3)
					src.UpdateOverlays(new /image(src.icon,"hotdog-bunbr"),"bun")
				if(4)
					src.UpdateOverlays(new /image(src.icon,"elvisdog"),"bun")
				if(5)
					src.icon_state = "hauntdog"
		if ((src.reagents.has_reagent("ketchup")))
			if(!(src.GetOverlayImage("ketchup")))
				if(!src.GetOverlayImage("mustard"))
					src.UpdateOverlays(new /image(src.icon,"hotdog-k1"),"ketchup")
				else
					src.UpdateOverlays(new /image(src.icon,"hotdog-k2"),"ketchup")
		if (src.reagents.has_reagent("mustard"))
			if(!(src.GetOverlayImage("mustard")))
				if(!src.GetOverlayImage("ketchup"))
					src.UpdateOverlays(new /image(src.icon,"hotdog-m1"),"mustard")
				else
					src.UpdateOverlays(new /image(src.icon,"hotdog-m2"),"mustard")
		return

/obj/item/reagent_containers/food/snacks/hotdog_half
	name = "half hotdog"
	desc = "A hot dog chopped in half!"
	icon = 'icons/obj/foodNdrink/food_hotdog.dmi'
	icon_state = "hotdog"
	amount = 1
	heal_amt = 1
	initial_volume = 15
	//initial_reagents = list("porktonium"=5)
	var/list/cuts = list("chunks","octopus")

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/kitchen/utensil/knife))
			var/inp
			inp = input("Which cut would you like?", "Yay chopping a hotdog", null) as null|anything in cuts
			var/inplayer
			var/halfloc = get_turf(src)
			if(src in user.contents)
				inplayer = 1
			else
				inplayer = 0
			if(inp && (user in range(1,src)))
				switch(inp)
					if("chunks")
						if(inplayer)
							user.u_equip(src)
						src.set_loc(user)
						for(var/i=1,i<=4,i++)
							var/obj/item/reagent_containers/food/snacks/hotdog_chunk/c = new /obj/item/reagent_containers/food/snacks/hotdog_chunk
							c.pixel_y = rand(-8,8)
							c.pixel_x = rand(-8,8)
							if(inplayer)
								c.set_loc(get_turf(user))
							else
								c.set_loc(halfloc)
						qdel(src)
					if("octopus")
						var/obj/item/reagent_containers/food/snacks/hotdog_octo/o = new /obj/item/reagent_containers/food/snacks/hotdog_octo
						if(inplayer)
							user.u_equip(src)
							src.set_loc(user)
							user.put_in_hand_or_drop(o)
						else
							o.set_loc(halfloc)
						qdel(src)
			else
				..()
		else
			..()

/obj/item/reagent_containers/food/snacks/hotdog_chunk
	name = "chunk of hotdog"
	desc = "A hot dog chopped in half!"
	icon = 'icons/obj/foodNdrink/food_hotdog.dmi'
	icon_state = "hotdog-chunk"
	amount = 1
	heal_amt = 1
	initial_volume = 5
	//initial_reagents = list("porktonium"=1)

/obj/item/reagent_containers/food/snacks/hotdog_octo
	name = "hotdog octopus"
	desc = "A hot dog chopped into the shape of an octopus! How cute!"
	icon = 'icons/obj/foodNdrink/food_hotdog.dmi'
	icon_state = "hotdog-octo"
	amount = 1
	heal_amt = 1
	initial_volume = 5
	initial_reagents = list("love"=1)

	/*New()
		..()
		src.reagents.add_reagent("love", 1)*/

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/kitchen/utensil/knife) && (src.icon_state == "hotdog-octo"))
			src.visible_message("<span class='success'>[user.name] carves a cute little face on the [src]!</span>")
			src.icon_state = "hotdog-octo2"
			src.reagents.add_reagent("love", 1)
		else
			..()



/obj/item/reagent_containers/food/snacks/hotdog/syndicate
	var/mob/living/carbon/cube/meat/victim = null

	disposing()
		if((victim)&&(victim.client))
			victim.ghostize()
		..()

/obj/item/reagent_containers/food/snacks/taco
	name = "empty taco shell"
	desc = "A lone taco shell, devoid of any filling."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	amount = 3
	heal_amt = 1
	icon_state = "taco0"
	var/stage = 0
	var/salsa = 0
	food_color = "#FFFF33"
	initial_volume = 100

	heal(var/mob/M)
		if(!src.salsa)
			boutput(M, "<span class='alert'>Could use sauce...</span>")
		..()
		return

	attack_self(mob/user as mob)
		if (!src.stage)
			boutput(user, "You crunch up the tortilla shell into tortilla chips.")
			new /obj/item/reagent_containers/food/snacks/tortilla_chip_spawner(user.loc)
			user.u_equip(src)
			qdel(src)
		else
			..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/meat))
			if(src.stage)
				boutput(user, "<span class='alert'>It can't hold any more!</span>")
				return
			src.stage++
			src.icon_state = "taco1"
			src.name = "[W.name] taco"
			src.heal_amt++
			desc = "A meat taco. Pretty plain, really."
			boutput(user, "<span class='notice'>You add [W] to [src]!</span>")
			food_effects += W:food_effects
			qdel (W)

		else if(istype(W,/obj/item/reagent_containers/food/snacks/condiment/hotsauce) || istype(W,/obj/item/reagent_containers/food/snacks/condiment/coldsauce))
			boutput(user, "<span class='notice'>You add [W] to [src]!</span>")
			if(!src.salsa)
				src.heal_amt++
				src.salsa = 1

			return

		else if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/cheese))
			switch(src.stage)
				if(0)
					boutput(user, "<span class='alert'>You really should add the meat first.</span>")
				if(1)
					boutput(user, "<span class='notice'>You add [W] to [src]!</span>")
					qdel (W)
					src.stage++
					src.heal_amt++
					src.icon_state = "taco2"
					src.desc = "A complete taco. Looks pretty good."
					food_effects += "food_energized_big"
				if(2)
					boutput(user, "<span class='alert'>It can't hold any more!</span>")
			return
		else return ..()

/obj/item/reagent_containers/food/snacks/taco/complete
	name = "taco carnitas"
	icon_state = "taco2"
	desc = "A taco filled with tender shredded pork. Looks pretty rippin' good."
	salsa = 1
	heal_amt = 4
	stage = 2
	food_effects = list("food_energized_big", "food_warm")

/obj/item/reagent_containers/food/snacks/steak_h
	name = "steak"
	desc = "Made of people."
	icon_state = "meat-grilled"
	amount = 2
	heal_amt = 3
	var/hname = null
	var/job = null
	food_color = "#999966"
	initial_volume = 50
	initial_reagents = list("cholesterol"=3)
	food_effects = list("food_hp_up_big", "food_brute")

/obj/item/reagent_containers/food/snacks/steak_m
	name = "monkey steak"
	desc = "You'll go bananas for it."
	icon_state = "meat-grilled"
	amount = 2
	heal_amt = 3
	food_color = "#999966"
	initial_volume = 50
	initial_reagents = list("cholesterol"=3)
	food_effects = list("food_hp_up", "food_brute")

/obj/item/reagent_containers/food/snacks/steak_s
	name = "synth-steak"
	desc = "And they thought processed food was artificial..."
	icon_state = "meat-plant-grilled"
	amount = 2
	heal_amt = 3
	food_color = "#999966"
	initial_volume = 50
	initial_reagents = list("cholesterol"=2)
	food_effects = list("food_hp_up", "food_brute")

/obj/item/reagent_containers/food/snacks/fish_fingers
	name = "fish fingers"
	desc = "What kind of fish did it start out as? Who knows!"
	icon_state = "fish_fingers"
	amount = 3
	heal_amt = 2
	food_color = "#FFCC33"
	food_effects = list("food_burn", "food_sweaty", "food_tox")

/obj/item/reagent_containers/food/snacks/bakedpotato
	name = "baked potato"
	desc = "Would go good with some cheese or steak."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "potato-baked"
	amount = 6
	heal_amt = 1
	food_color = "#FFFF99"
	food_effects = list("food_explosion_resist")

/obj/item/reagent_containers/food/snacks/omelette
	name = "omelette"
	desc = "A delicious breakfast food."
	icon_state = "omelette"
	amount = 3
	heal_amt = 4
	needfork = 1
	food_color = "#FFCC00"
	initial_volume = 10
	initial_reagents = list("cholesterol"=1)
	food_effects = list("food_energized", "food_deep_burp")

/obj/item/reagent_containers/food/snacks/omelette/bee
	name = "deep-space hell omelette"
	desc = "<tt>BEE EGGS</tt> make this a delightful breakfast food."

/obj/item/reagent_containers/food/snacks/pancake
	name = "pancakes"
	desc = "They seem to be lacking something"
	icon_state = "pancake"
	amount = 3
	heal_amt = 1
	var/syrup = 0
	food_color = "#FFFF99"
	food_effects = list("food_deep_fart", "food_energized")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/condiment/syrup))
			boutput(user, "<span class='notice'>You add [W] to [src].</span>")
			icon_state = "pancake_s"
			syrup = 1
			heal_amt = 5
			desc = "They look delicious!"
			user.u_equip(W)
			qdel (W)
		else return ..()

	heal(var/mob/M)
		..()
		if(!syrup)
			boutput(M, "<span class='alert'>[src] seem a bit dry.</span>")

/obj/item/reagent_containers/food/snacks/mashedpotatoes
	name ="mashed potatoes"
	desc = "A classic dish."
	icon_state = "mashedpotatoes"
	amount = 5
	heal_amt = 1
	needfork = 1
	food_color = "#FFFFFF"
	initial_volume = 50
	initial_reagents = list("mashedpotatoes"=25)
	food_effects = list("food_explosion_resist", "food_hp_up")

/obj/item/reagent_containers/food/snacks/mashedbrains
	name = "mashed brains"
	desc = "Rumored to be a good brain food"
	icon_state = "mashedbrains"
	amount = 5
	heal_amt = 1
	needfork = 1
	food_color = "#FF6699"
	food_effects = list("food_hp_up_big")

	heal(var/mob/M as mob)
		..()
		if(quality >= 1)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(1))
					boutput(M, "<span class='alert'>You feel dumber.</span>")
					H:bioHolder:RandomEffect("bad")
				else if(prob(1))
					boutput(M, "<span class='notice'>You feel smarter.</span>")
					H:bioHolder:RandomEffect("good")

/obj/item/reagent_containers/food/snacks/meatloaf
	name = "meatloaf"
	desc = "A loaf of meat"
	icon_state = "meatloaf"
	amount = 5
	heal_amt = 1
	needfork = 1
	initial_volume = 50
	initial_reagents = list("cholesterol"=2)
	food_effects = list("food_hp_up_big")

/obj/item/reagent_containers/food/snacks/tortilla_chip_spawner
	name = "INVISIBLE GHOST OF PANCHO VILLA'S BAKER BROTHER, GARY VILLA"
	desc = "IGNORE ME"

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			if (isturf(src.loc))
				for (var/x = 1, x <= 4, x++)
					new /obj/item/reagent_containers/food/snacks/tortilla_chip(src.loc)

			qdel(src)

/obj/item/reagent_containers/food/snacks/tortilla_chip
	name = "tortilla chip"
	desc = "A crispy little tortilla disk."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "tortilla-chip"
	amount = 1
	heal_amt = 1
	food_effects = list("food_energized")

	New()
		..()
		src.pixel_x = rand(-6, 6)
		src.pixel_y = rand(-6, 6)

	on_reagent_change()
		if (src.reagents && src.reagents.total_volume)
			var/image/dip = image('icons/obj/foodNdrink/food_snacks.dmi', "tortilla-chip-overlay")
			dip.color = src.reagents.get_average_color().to_rgba()
			src.UpdateOverlays(dip, "dip")
		else
			src.UpdateOverlays(null, "dip")

/obj/item/reagent_containers/food/snacks/wonton_spawner
	name = "wonton spawner"
	desc = "You shouldn't see this."

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			if (isturf(src.loc))
				for (var/x = 1, x <= 4, x++)
					new /obj/item/reagent_containers/food/snacks/wonton_wrapper(src.loc)

			qdel(src)

/obj/item/reagent_containers/food/snacks/wonton_wrapper
	name = "wonton wrapper"
	desc = "An egg dough wrapper typically employed in the creation of dumplings."
	icon_state = "wrapper"
	amount = 1
	heal_amt = 1
	var/obj/item/wrapped = null
	var/maximum_wrapped_size = 2
	food_effects = list("food_energized")

	attackby(obj/item/W as obj, mob/user as mob)
		if (wrapped)
			if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/saw) || istype(W,/obj/item/knife/butcher))
				user.visible_message("<span class='alert'>[user] performs an act of wonton destruction!</span>","You slice open the wrapper.")
				wrapped.set_loc(get_turf(src))
				src.reagents = null
				qdel(src)
			else
				boutput(user, "<span class='alert'>That wrapper is already full!</span>")
			return
		else
			if (istype(W, /obj/item/reagent_containers/food/snacks/wonton_wrapper))
				boutput(user, "<span class='alert'>A wrapped wrapper? That's ridiculous.</span>")
				return

			else if (W.w_class > src.maximum_wrapped_size || istype(W, /obj/item/storage) || istype(W, /obj/item/storage/secure))
				boutput(user, "<span class='alert'>There is no way that could fit!</span>")
				return

			boutput(user, "You wrap \the [W] into a dumpling.")
			user.u_equip(W)
			W.set_loc(src)
			src.wrapped = W
			W.dropped()

			if (W.w_class > (src.maximum_wrapped_size / 2))
				src.name = "[W.name] eggroll"
				src.desc = "A rolled appetizer with a wonton wrapper skin. It really should be fried before you eat it."
				icon_state = "eggroll"
			else
				src.name = "[W.name] rangoon"
				src.desc = "A dumpling made from a wonton wrapper wrapped in a flower configuration. It really should be fried before you eat it."
				icon_state = "rangoon"

			src.reagents = W.reagents
			return

	New()
		..()
		src.pixel_x = rand(-6, 6)
		src.pixel_y = rand(-6, 6)

	heal(var/mob/M)
		boutput(M, "<span class='alert'>Ugh, you really should've cooked that first.</span>")
		if(prob(25))
			M.reagents.add_reagent("salmonella",15)
		..()

/obj/item/reagent_containers/food/snacks/agar_block
	name = "Agar Block"
	desc = "A gel derived from algae with multiple culinary and scientific uses.  Ingestion of plain agar is not advised."
	icon_state = "agar"
	amount = 1
	heal_amt = 0
	food_color = "#9D3811"
	food_effects = list("food_disease_resist")

/obj/item/reagent_containers/food/snacks/granola_bar
	name = "granola bar"
	desc = "A crisp bar of oats bonded together by honey.  A big indicator of either space hikers or space hippies."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "granola-bar"
	amount = 2
	heal_amt = 2
	food_color = "#6A532D"
	food_effects = list("food_refreshed_big")

/obj/item/reagent_containers/food/snacks/biscuit
	name = "biscuit"
	desc = "A big ol' biscuit."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "biscuit"
	amount = 2
	heal_amt = 1
	food_color = "#6A532D"
	food_effects = list("food_brute")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/saw) || istype(W,/obj/item/knife/butcher))
			boutput(user, "<span class='notice'>You cut [src] into halves</span>")
			new /obj/item/reagent_containers/food/snacks/emuffin(get_turf(src))
			new /obj/item/reagent_containers/food/snacks/emuffin(get_turf(src))
			qdel(src)
		else ..()

/obj/item/reagent_containers/food/snacks/emuffin
	name = "english muffin"
	desc = "Like a muffin, but with a funny accent."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "emuffin"
	amount = 1
	heal_amt = 1
	food_color = "#6A532D"
	food_effects = list("food_warm")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/butter))
			boutput(user, "<span class='notice'>You butter up the english muffin</span>")
			new /obj/item/reagent_containers/food/snacks/emuffin/butter(get_turf(src))
			qdel(W)
			qdel(src)
		else ..()

/obj/item/reagent_containers/food/snacks/emuffin/butter
	name = "buttered english muffin"
	desc = "Just like the Queen intended it."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "emuffin-butter"
	heal_amt = 2
	food_color = "#6A532D"
	initial_reagents = list("butter"=3)
	food_effects = list("food_energized")

/obj/item/reagent_containers/food/snacks/hardtack
	name = "Hardtack"
	desc = "The brick of the food world."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "hardtack"
	amount = 2
	heal_amt = 0
	food_color = "#6A532D"

	heal(var/mob/M)
		boutput(M, "<span class='alert'>OH GOD! You bite down and break a few teeth!</span>")
		random_brute_damage(M, 2)
		M.emote("scream")

/obj/item/reagent_containers/food/snacks/pickle
	name = "pickle"
	desc = "Crunchy, sour, and a bit savory; perfect for sandwiches or as a standalone snack."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "pickle"
	amount = 2
	heal_amt = 1
	initial_reagents = list("juice_pickle"=5)

	trash
		name = "trash pickle"
		quality = -99
		desc = "Ooh, free pickle!"
		initial_reagents = list("juice_pickle"=5, "yuck"=5, "space_fungus"=5, "spiders"=5)

/obj/item/reagent_containers/food/snacks/onionchips
	name = "onion chips"
	desc = "Scrumpdillyicious."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "chips-onion"
	item_state = "chips" // TODO: unique inhand sprite?
	amount = 3
	heal_amt = 2
	food_effects = list("food_bad_breath")

/obj/item/reagent_containers/food/snacks/goldfish_cracker
	name = "goldfish cracker"
	desc = "Wow! It's almost like eating a real goldfish!"
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "goldfish-cracker"
	amount = 1
	heal_amt = 6
	initial_reagents = list("enriched_msg"=1)

/obj/item/reagent_containers/food/snacks/deviledegg
	name = "deviled egg"
	desc = "For when you want the taste of egg, but the feeling of luxury."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "egg-deviled"
	amount = 1
	heal_amt = 1
	food_color = "#6A532D"
	food_effects = list("food_energized")

/obj/item/reagent_containers/food/snacks/eggsalad
	name = "egg salad"
	desc = "A meal of mostly egg. Good for eating eggs."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "eggsalad"
	needfork = 1
	amount = 4
	heal_amt = 2
	food_effects = list("food_energized", "food_bad_breath")

// Haggis and Scotch Eggs by Cirrial, 2017
/obj/item/reagent_containers/food/snacks/haggis
	name = "haggis"
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "haggis"
	needfork = 1
	var/isbutt = 0
	amount = 6
	heal_amt = 1
	food_color ="#663300"
	initial_volume = 30
	food_effects = list("food_burn","food_tox")

	New()
		..()
		reagents.add_reagent("caledonium",20)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/condiment/)) src.amount += 1
		else ..()

	examine(mob/user)
		. = list("This is a [src.name].")

		if(isbutt)
			. += "A dire misunderstanding of how haggis works."
		else
			if (user.bioHolder.HasEffect("accent_scots"))
				. += "Fair fa' your honest, sonsie face, great chieftain o the puddin'-race!"
			else
				. += "A big ol' meat pudding, wrapped up in a synthetic stomach stuffed nearly to bursting. Gusty!"

	heal(var/mob/M)
		if (M.bioHolder.HasEffect("accent_scots"))
			heal_amt *= 2
			boutput(M, "<span class='notice'>Och aye! That's th' stuff!</span>")
			..()
			heal_amt /= 2

/obj/item/reagent_containers/food/snacks/haggis/ass
	name = "haggass"
	isbutt = 1

	New()
		..()
		reagents.add_reagent("fartonium",10)


/obj/item/reagent_containers/food/snacks/scotch_egg
	name = "scotch egg"
	desc = "A boiled egg inside a breaded meat shell. Staple of picnics in Great Britain and some parts of Europe. Yum!"
	icon_state = "scotchegg"
	amount = 1
	heal_amt = 2
	food_effects = list("food_burn", "food_tox")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/snacks/condiment/)) src.amount += 1

/obj/item/reagent_containers/food/snacks/rice_ball
	name = "rice ball"
	desc = "A ball of sticky rice. Looks a bit plain."
	icon = 'icons/obj/foodNdrink/food_sushi.dmi'
	icon_state = "rice_ball"
	amount = 2
	heal_amt = 1
	food_effects = list("food_warm")

	rand_pos = 1

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/reagent_containers/food/snacks/ingredient/seaweed))
			boutput(user, "You wrap the seaweed around the rice ball. A good decision.")
			new /obj/item/reagent_containers/food/snacks/rice_ball/onigiri(get_turf(user))
			qdel(src)
		else if(istype(W, /obj/item/reagent_containers/food/snacks/ingredient/meat/fish))
			var/spawnloc = get_turf(src)
			var/handspawn
			if(istype(src.loc,/mob))
				user.u_equip(src)
				handspawn = 1
			src.set_loc(user)
			var/obj/item/reagent_containers/food/snacks/nigiri_roll/nigiri = new /obj/item/reagent_containers/food/snacks/nigiri_roll
			switch(W.icon_state)
				if("fillet-orange")
					nigiri.icon_state = "nigiri1"
				if("fillet-pink")
					nigiri.icon_state = "nigiri2"
				if("fillet-white")
					nigiri.icon_state = "nigiri3"
			user.u_equip(W)
			qdel(W)
			if(handspawn)
				user.put_in_hand_or_drop(nigiri)
			else
				nigiri.set_loc(spawnloc)
			qdel(src)

/obj/item/reagent_containers/food/snacks/rice_ball/onigiri
	name = "onigiri"
	desc = "A strip of salty seaweed wrapped around a ball of sticky rice. Looks pretty good."
	icon = 'icons/obj/foodNdrink/food_sushi.dmi'
	icon_state = "onigiri"

/obj/item/reagent_containers/food/snacks/sushi_roll
	name = "sushi roll"
	desc = "A roll of seaweed, sticky rice, and freshly caught fish of unknown origin."
	icon = 'icons/obj/foodNdrink/food_sushi.dmi'
	icon_state = "sushi_roll"
	amount = 4
	heal_amt = 2
	food_effects = list("food_hp_up_big")
	var/cut = 0

	attackby(obj/item/W as obj, mob/user as mob)
		if (istool(W, TOOL_CUTTING | TOOL_SAWING))
			if (src.cut == 1)
				boutput(user, "<span class='alert'>This has already been cut.</span>")
				return
			boutput(user, "<span class='notice'>You cut the sushi roll into pieces.</span>")
			var/makepieces = src.amount
			while (makepieces > 0)
				var/obj/item/reagent_containers/food/snacks/sushi_roll/S = new src.type(get_turf(src))
				S.cut = 1
				S.amount = 1
				S.icon_state = "sushi_rolls"
				S.quality = src.quality
				src.reagents.trans_to(S, src.reagents.total_volume/makepieces)
				S.pixel_x = rand(-6, 6)
				S.pixel_y = rand(-6, 6)
				makepieces--
			qdel (src)

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (!src.cut)
			if (user == M)
				boutput(user, "<span class='alert'>You can't just cram that in your mouth, you greedy beast!</span>")
				user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
				return
			else
				user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
				return
		else
			..()

/obj/item/reagent_containers/food/snacks/sushi_roll/custom
	icon = 'icons/obj/foodNdrink/food_sushi.dmi'
	icon_state = "sushiroll"
	food_color = "#5E6351"

	attackby(obj/item/W as obj, mob/user as mob)
		if(istool(W, TOOL_CUTTING | TOOL_SAWING))
			if(src.cut == 1)
				boutput(user, "<span class='alert'>This has already been cut.</span>")
				return
			if(istype(src.loc,/mob))
				user.u_equip(src)
				src.set_loc(user)
			boutput(user, "<span class='notice'>You cut the sushi roll into pieces.</span>")
			var/makepieces = src.amount
			var/spawnloc = get_turf(src)
			while (makepieces > 0)
				var/obj/item/reagent_containers/food/snacks/sushi_roll/S = new src.type//src.type(get_turf(src))
				S.cut = 1
				S.amount = 1
				S.icon_state = "chopped_sushiroll"
				S.quality = src.quality
				src.reagents.trans_to(S, src.reagents.total_volume/makepieces)
				S.pixel_x = rand(-6, 6)
				S.pixel_y = rand(-6, 6)
				for(var/i=1,i<=src.overlays.len,i++) //transferring any overlays to the cut form
					var/image/buffer = src.GetOverlayImage("[src.overlay_refs[i]]")
					var/image/overlay = new /image('icons/obj/foodNdrink/food_sushi.dmi',"chopped_[src.overlay_refs[i]]")
					overlay.color = buffer.color
					S.UpdateOverlays(overlay,"[src.overlay_refs[i]]")
				for(var/b=1,b<=src.food_effects.len,b++)
					if(src.food_effects[b] in S.food_effects)
						continue
					S.food_effects += src.food_effects[b]
				S.set_loc(spawnloc)
				makepieces--
			qdel(src)
		else if(istype(W,/obj/item/kitchen/utensil/fork))
			src.Eat(user,user)
		else
			..()

/obj/item/reagent_containers/food/snacks/nigiri_roll
	name = "nigiri roll"
	desc = "A ball of sticky rice with a slice of freshly caught fish on top."
	icon = 'icons/obj/foodNdrink/food_sushi.dmi'
	icon_state = "nigiri"
	amount = 2
	heal_amt = 2
	food_effects = list("food_energized_big")

	New()
		..()
		src.icon_state = "nigiri[rand(1,3)]"

/obj/item/reagent_containers/food/snacks/riceandbeans
	name = "rice and beans"
	desc = "A filling plate of rice and beans."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "riceandbeans"
	needspoon = 1
	amount = 6
	heal_amt = 2
	food_effects = list("food_deep_fart", "food_space_farts")

/obj/item/reagent_containers/food/snacks/friedrice
	name = "fried rice"
	desc = "A plate of fried rice. There's even an egg!"
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "friedrice"
	needspoon = 1
	amount = 6
	heal_amt = 3
	food_effects = list("food_brute", "food_all")

/obj/item/reagent_containers/food/snacks/omurice
	name = "omurice"
	desc = "The ketchup drawing looks like George."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "omurice"
	needspoon = 1
	amount = 4
	heal_amt = 2
	food_effects = list("food_warm", "food_hp_up_big")

/obj/item/reagent_containers/food/snacks/risotto
	name = "risotto"
	desc = "Not a sandwich."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "risotto"
	needspoon = 1
	amount = 6
	heal_amt = 2
	food_effects = list("food_all", "food_energized_big")

/obj/item/reagent_containers/food/snacks/zongzi
	name = "zongzi"
	desc = "A glutinous rice snack wrapped in bamboo leaves."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "zongzi-wrapped"
	amount = 3
	heal_amt = 2
	var/unwrapped = 0
	food_effects = list("food_all", "food_energized_big")


	attack(mob/M as mob, mob/user as mob, def_zone)
		if (unwrapped)
			..()
		else if (user == M)
			boutput(user, "<span class='alert'>You need to unwrap it first, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

	attack_self(mob/user as mob)
		if (unwrapped)
			return

		unwrapped = 1
		user.visible_message("[user] unwraps the zongzi!", "You unwrap the zongzi.")
		icon_state = "zongzi"
		desc = "A glutinous rice snack. The distinctive bamboo leaf wrapper seems to be missing."

/obj/item/reagent_containers/food/snacks/fortune_cookie
	name = "fortune cookie"
	desc = "A cookie that heralds your future."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "fortune-cookie"
	amount = 1
	heal_amt = 1
	food_color = "#f6ad58"
	var/open = 0
	var/fortune = 0

	attack_self(mob/user as mob)
		if (!open)
			var/obj/item/reagent_containers/food/snacks/fortune_cookie/B = new(user)
			user.put_in_hand_or_drop(B)
			name = "fortune cookie half"
			B.name = "fortune cookie half"
			desc = "Half of a fortune cookie. It has a fortune in it."
			B.desc = "Half of a fortune cookie."
			icon_state = "fortune-open"
			B.icon_state = "fortune-top"
			open = 1
			B.open = 1
			fortune = 1

	attack_hand(mob/user as mob, unused, flag)
		if (fortune)
			desc = "Half of a fortune cookie."
			icon_state = "fortune-bottom"
			var/obj/item/paper/fortune/B = unpool(/obj/item/paper/fortune)
			B.set_loc(user)

			user.put_in_hand_or_drop(B)
			fortune = 0
		else
			..()

/obj/item/reagent_containers/food/snacks/healgoo
	name = "weird goo"
	desc = "This goop is released from a dead hallucigenia. It is known for its beneficial anti-radiation and healing properties."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "healgoo"
	heal_amt = 2
	amount = 3
	initial_volume = 28
	food_effects = list("food_rad_resist")

	New()
		..()
		reagents.add_reagent("saline",7)
		reagents.add_reagent("charcoal",7)
		reagents.add_reagent("anti_rad",7)
		reagents.add_reagent("omnnizine",7)


/obj/item/reagent_containers/food/snacks/greengoo
	name = "green goo"
	desc = "This goop is released from a dead pikaia. It acts as a mild stimulant."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "greengoo"
	heal_amt = 1
	amount = 2
	initial_volume = 16
	food_effects = list("food_energized_big")

	New()
		..()
		reagents.add_reagent("epinephrine",8)
		reagents.add_reagent("synaptizine",8)

/obj/item/reagent_containers/food/snacks/mandrake
	name = "mandrake root"
	desc = "SCREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	icon_state = "mandrake-fresh"
	w_class = 1
	//brewable = 1
	//brew_result = "mandrake_tea?"
	var/list/bound_blood = list() //list of mobs bound to the mandrake (MAX: 2)
	var/is_bloody
	var/is_segment
	var/list/limbs = list("left arm","right arm","left leg","right leg","hair")
	var/severing

	New()
		..()
		processing_items.Remove(src)

	proc/bloody_mandrake(var/mob/user) //handling the bloodying of a mandrake
		name = "blood-soaked mandrake"
		desc = "the mandrake is soaked in blood! My god there's blood everywhere!"
		icon_state = "mandrake-base"
		UpdateOverlays(image('icons/obj/foodNdrink/food_produce.dmi',"mandrake-head"),"head")
		UpdateOverlays(image('icons/obj/foodNdrink/food_produce.dmi',"mandrake-l_arm"),"l_arm")
		UpdateOverlays(image('icons/obj/foodNdrink/food_produce.dmi',"mandrake-r_arm"),"r_arm")
		UpdateOverlays(image('icons/obj/foodNdrink/food_produce.dmi',"mandrake-l_leg"),"l_leg")
		UpdateOverlays(image('icons/obj/foodNdrink/food_produce.dmi',"mandrake-r_leg"),"r_leg")

		if(open_binding_slot()) //if two players aren't bound, don't bloody the leaves
			UpdateOverlays(image('icons/obj/foodNdrink/food_produce.dmi',"mandrake-hair"),"hair")
			user.visible_message("<span class='alert'><b>[user]</b> wraps the [name] in [his_or_her(user)] blood-soaked hands, letting the red fluid soak into the root.")
		else //if both slots are filled, add the bloody leaves overlay
			UpdateOverlays(image('icons/obj/foodNdrink/food_produce.dmi',"mandrake-hair_blood"),"hair")
			user.visible_message("<span class='alert'><b>[user]</b> smears blood all over the [name]'s leaves. It begins to glow with an ominous power!")
			for(var/mob/living/carbon/human/H in bound_blood)
				H.show_text("You feel like you're not alone...at all...","red")

		user.clean_forensic() //clean up the user because the blood has been transferred to the mandrake
		is_bloody = TRUE

	proc/mandrake_delimb(var/limb,var/name)
		if(!limb)
			return
		if(src.GetOverlayImage(limb))
			src.ClearSpecificOverlays(limb)
		else 
			var/find_limb
			switch(limb)
				if("l_arm")
					find_limb = "left arm"
				if("r_arm")
					find_limb = "right arm"
				if("l_leg")
					find_limb = "left leg"
				if("r_leg")
					find_limb = "right leg"
			if(find_limb in src.limbs)
				src.limbs -= find_limb
			return 0
		var/obj/item/reagent_containers/food/snacks/mandrake/M = new /obj/item/reagent_containers/food/snacks/mandrake
		M.is_segment = 1
		M.name = "chunk of mandrake root"
		if(limb == "hair")
			M.icon_state = "mandrake-hair_blood"
		else
			M.icon_state = "mandrake-[limb]"
		
		if(reagents)//add reagents to mandrake limb
			var/transferamount
			var/remaininglimbs = (length(limbs) + 2) //+2 because bodies are separated into two segments
			if((length(limbs) == 1) && (src.limbs[1] == "head"))
				remaininglimbs--
			transferamount = src.reagents.total_volume / remaininglimbs
			src.reagents.trans_to(M,transferamount)
		src.visible_message("<span style='alert'><b>[name]</b> dramatically severs a chunk from the [src]!</span>")
		M.set_loc(get_turf(src))
		var/list/throw_target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))
		M.throw_at(throw_target, 5, 1)
		. = 1

	proc/open_binding_slot()
		if(!length(bound_blood))
			. = 2
		else if(length(bound_blood) == 1)
			. = 1

	proc/player_bound(var/mob/user)
		if(!length(bound_blood))
			return
		if(bound_blood[1] && (bound_blood[1] == user))
			. = 1
		if(length(bound_blood) == 2 && bound_blood[2] == user)
			. = 1

	proc/cleanup_bound_blood(var/balance)
		if(!length(bound_blood))
			return
		var/gibbed
		for(var/mob/living/carbon/human/H in bound_blood)
			if(!H.bioHolder)
				bound_blood -= H
				bound_blood += "GIBBED"
		if(bound_blood[1] == "GIBBED")
			gibbed = TRUE
		else if(length(bound_blood) == 2 && bound_blood[2] == "GIBBED")
			gibbed = TRUE
		if(gibbed && balance)
			for(var/mob/living/carbon/human/H in bound_blood)
				H.visible_message("<span style='alert'><b>The [name]</b> grabs the [H.equipped()] and rips [H.name] to shreds!</span>","<b>The [name]</b> says, \"Your fate must be balanced.\"")
				H.gib(1)

	proc/burn_mandrake()
		src.visible_message("<span style='alert'>The [name] is consumed by flamed and poofs into a pile of ash!</span>")
		make_cleanable( /obj/decal/cleanable/ash,get_turf(src))
		qdel(src)

	proc/addUid(Uid)
		if(!src.blood_DNA)
			src.blood_DNA = Uid
		else
			var/list/dna_list = params2list(src.blood_DNA)
			dna_list += Uid
			src.blood_DNA = list2params(dna_list)

	attack_self(mob/user as mob)
		if(is_segment) //is the mandrake in question just a chunk of the original mandrake?
			..()
			return
		if(!user.blood_DNA) //is the user covered in blood?
			return
		cleanup_bound_blood()
		var/list/dna_list = params2list(user:blood_DNA)
		var/player_added
		for(var/i in 1 to length(dna_list))
			if(!open_binding_slot())
				break
			if(dna_list[i] == user.bioHolder.Uid) //checking for the user specifically to prioritize their blood
				if(player_bound(user))
					continue
				bound_blood += user
				addUid(user.bioHolder.Uid)
				player_added = TRUE
			else
				for(var/mob/living/carbon/human/H in mobs) //search for the human it corresponds to
					if(H.bioHolder.Uid == dna_list[i]) //if there's a match
						if(player_bound(H)) //link the mob if they aren't already linked
							continue
						bound_blood += H
						addUid(H.bioHolder.Uid)
						player_added = TRUE

		if(player_added) //if a player was added, soak the mandrake in blood!
			bloody_mandrake(user)

	attackby(obj/item/W as obj,mob/user as mob)
		if(istool(W, TOOL_CUTTING | TOOL_SAWING) && in_interact_range(src,user) && !is_segment)
			if(open_binding_slot() && !player_bound(user))
				user.show_text("The [name] hungers for your blood!","red")
				return
			if(!open_binding_slot() && !player_bound(user))
				user.show_text("You attempt to cut at the [src], but it resists all attempts! Perhaps your fates are not bound...","red")
				return
			cleanup_bound_blood(1)
			var/selection = input("Which limb would you like to cut?", "Being a Terrible Person", null) as null|anything in limbs
			if(selection && in_interact_range(src,user))
				severing = TRUE
				var/mandrake_limb
				switch(selection)
					if("left arm")
						mandrake_limb = "l_arm"
					if("right arm")
						mandrake_limb = "r_arm"
					if("left leg")
						mandrake_limb = "l_leg"
					if("right leg")
						mandrake_limb = "r_leg"
				severing = FALSE
				if((selection != "head") && (selection != "hair"))
					for(var/mob/living/carbon/human/H in bound_blood)
						mandrake_delimb(mandrake_limb,user.name)
						H.sever_limb(mandrake_limb)
					limbs -= "[selection]"
				else
					if(selection == "hair")
						for(var/mob/living/carbon/human/H in bound_blood)
							mandrake_delimb("hair",user.name)
							var/obj/item/wig = H.create_wig()
							H.visible_message("<span style='alert'>[H.name]'s hair flies off!</span>")
							H.bioHolder.mobAppearance.customization_first = "None"
							H.bioHolder.mobAppearance.customization_second = "None"
							H.bioHolder.mobAppearance.customization_third = "None"
							wig.set_loc(H.loc)
						limbs -= "hair"
					else
						mandrake_delimb("head",user.name)
						for(var/mob/living/carbon/human/H in bound_blood)
							H.organHolder.drop_organ("head")
							H.visible_message("<span style='alert'><b>[H.name] IS DECAPITATED BY A MYSTERIOUS FORCE! OH GOD NO!</b>")
						limbs -= "head"
						is_segment = TRUE

				for(var/mob/living/carbon/human/H in bound_blood)
					random_brute_damage(H, 20)

				if(!length(limbs))
					limbs += "head"
		else if(W.firesource)
			if(src.loc == user)
				user.u_equip(src)
			burn_mandrake()
		else
			..()

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		..()
		burn_mandrake()


	clean_forensic()
		..()
		if(!length(bound_blood))
			return
		for(var/mob/living/carbon/human/H in bound_blood)
			H.show_text("You feel free...","green")
		if("hair" in limbs)
			src.UpdateOverlays(image('icons/obj/foodNdrink/food_produce.dmi',"mandrake-hair"),"hair")
		src.name = "inert mandrake"
		src.visible_message("<span style='green'>The energy emanating from the [name] fades slowly into nothingness...")

	disposing()
		for(var/mob/living/carbon/human/H in bound_blood)
			H.show_text("You feel free...","green")
		..()