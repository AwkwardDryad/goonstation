/datum/food_recipe //DEV - move later
    var/id //recipe id
    var/list/ingredients //direct reference, custom reference, or list of references
    //examples
    //ingredients = list(list("ingredient"=/obj/item/carrot,"pseudo"=list(/obj/item/choppedcarrot,/obj/item/friedcarrot),"custom"=0))
    var/list/products //path or direct item reference (direct references need to use custom product) : what comes out when the cooking process finishes
    //examples
    //products = list(list("product"=/obj/item/product,"amount"=3,"custom"=0))
    //var/require_dynamic_product //1 or 0 : compiles product item on recipe completion based on variables passed

    New()
        ..()
        ingredients = list()
        create_ingredients()
        products = list()
        create_products()
        if(!products.len)
            products = null

    //Internal procs: procs that are usually called within the datum itself without modification
    proc/add_ingredient(var/obj/item/ingredient,var/list/pseudo,var/custom) //item,list of items,1 or 0 : adds an ingredient to the ingredients list
        if(!ingredient)
            return
        var/list/package = list("ingredient"=ingredient)
        if(pseudo && pseudo.len)
            package.Add(list("pseudo"=pseudo)) //DEV - might cause issues
        if(custom)
            package.Add(list("custom"=custom))
        ingredients.Add(list(package))
        return

    proc/add_product(var/obj/item/product,var/amount,var/custom) //item,amount of item, 1 or 0 : adds a product to the products list
        if(!product)
            return
        var/list/package = list("product"=product)
        if(amount)
            package.Add(list("amount"=amount))
        if(custom)
            package.Add(list("custom"=custom))
        products.Add(list(package))
        return

    proc/ingredient_check(var/obj/item/I) //takes an ingredient and an element number in the ingredients list : against the ingredients list
        var/passed
        for(var/i=1,i<=ingredients.len,i++)
            if(I.type == ingredients[i]["ingredient"].type)
                if(ingredients[i]["custom"]==1) //check variables
                    if(variable_check(I)) //checks unique variables, then if the proc returns 1, ingredient_check passes
                        passed = i
                        break
                else
                    passed = i
                    break
            else
                //check pseudos, if not, return
                passed = 0
            //if it got to this point, it failed, check pseudos, if theres a match, set passed to 1 and break
            if(ingredients[i]["pseudo"])
                var/pseudobreak
                for(var/j=1,j<=ingredients[i]["pseudo"].len)
                    if(I.type == ingredients[i]["pseudo"][j])
                        pseudobreak = i
                        break
                if(pseudobreak)
                    passed = i
                    break
        return passed //return 0 if failed, 1 if passed

    //External procs: procs that are typically called from outside the datum and modified per recipe
    proc/variable_check(var/obj/item/I)
        return

    //example : modified
    /*variable_check(var/obj/item/I) //would work, but less coder friendly
        switch(I.type)
            if(/obj/item/test1)
                var/obj/item/test1 = I
                if(test1.variable==thing && test1.variable2==thing)
                    return 1 //if passed
                else return
        return*/

    proc/add_dynamic_product(var/obj/item/I) //takes an item and compiles a product based on dynamic information
        return //product override

    proc/create_ingredients() //basically a proc to neatly compile all of your ingredients
        return

    proc/create_products() //same, but for products
        return

    proc/create_dynamic_products(var/list/L) //list of things : similar to the other create procs, but ususally fired from recipe_completion()
        return

    proc/recipe_completion(var/list/L) //list of things : proc that triggers before a recipe is complete
        return

/datum/food_recipe/grill
    //note: grill recipes only support one ingredient
    //var/meat //1 or 0 : meat is assumed to be a food item that uses rarity rules

    //DEV - store icon paths on grill for user friendliness, if one doesn't exist, downscale sprite
    //var/overlay_icon = 'icons/obj/foodNdrink/grill.dmi'//icon path
    //var/overlay_icon_state //sprite that is shown on the grill's surface while an item cooks

    /*proc/create_icon_state(var/obj/item/reagent_containers/food/snacks/F) //dynamic icon_states
        return*/

/datum/food_recipe/grill/basicmeat
    id = "basicmeat"

    create_ingredients()
        var/list/pseudolist = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat,
        /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)

        add_ingredient(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat,pseudolist)
        return

    create_dynamic_products(var/list/L)
        if(!L)
            return
        if(istype(L[1],/obj/item/reagent_containers/food/snacks))
            switch(L[1].type)
                if(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat)
                    var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/H = L[1]
                    var/obj/item/reagent_containers/food/snacks/steak_h/S
                    S.hname = H.subjectname
                    S.job = H.subjectjob
                    return S
                if(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat)
                    var/obj/item/reagent_containers/food/snacks/steak_m/S
                    return S
                if(/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)
                    var/obj/item/reagent_containers/food/snacks/steak_s/S
                    return S
        return

    recipe_completion(var/list/L) //DEV - make a proc for calling dynamic products
        if(!L)
            return
        return create_dynamic_products(L)

/datum/food_recipe/grill/test //clown mask into cluwne mask
    id = "cluwnemask"

    create_ingredients()
        add_ingredient(/obj/item/clothing/mask/clown_hat)
        return

    create_products()
        var/obj/item/clothing/mask/cursedclown_hat/product
        product.name = "HONK HONK HONK!!!"
        add_product(product,1,0)
        return
