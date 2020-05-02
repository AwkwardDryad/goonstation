/datum/food_recipe //move later
    var/meat // 1 or 0 : meat functions off of icon state changes, so exempts it from product
    var/product //path or direct item reference (direct references need to use custom product) : what comes out when the cooking process finishes
    var/custom_product //1 or 0: if 1, acts as a check variable for when you need a specific instance of a product

    proc/create_custom_product(var/obj/item/reagent_containers/food/snacks/F) //food item : fill-in proc for calling and modifying elsewhere
        return

/datum/food_recipe/grill
    var/overlay_icon = 'icons/obj/foodNdrink/grill.dmi'//icon path
    var/overlay_icon_state //sprite that is shown on the grill's surface while an item cooks

    proc/create_icon_state(var/obj/item/reagent_containers/food/snacks/F) //dynamic icon_states
        return

/datum/food_recipe/grill/basicmeat
    overlay_icon_state = "meat"
