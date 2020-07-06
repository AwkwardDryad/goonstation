/obj/kotatsu
    name = "kotatsu"
    desc = "a heated table with a futon cover on top for maximum warm!"
    icon = 'icons/obj/furniture/table.dmi' //DEV - replace with target table sprite
    icon_state = "0"

/obj/machinery/space_heater/table
    name = "heated table"
    desc = "a table. that is a heater. that is also a table."
    icon = 'icons/obj/furniture/table.dmi' //DEV - replace with target table sprite
    icon_state = "0"

		New()
			UpdateOverlays(image('icons/obj/furniture/table.dmi',"heater-0"),"heater")

		attackby(obj/item/I, mob/user,params)
			//put item on table
            src.place_on(I, user, params)

/datum/action/bar/icon/table_heater_install
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "railing_deconstruct"
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
    var/obj/heater_ref
    var/obj/table_ref

    New(user,heater,table)
        owner = user
        heater_ref = heater

    onUpdate()
	    ..()
        //if the heater moves away from the player or the table no longer exists, interrupt_always

    onEnd()
	    ..()
        qdel(heater_ref)
        var/obj/machinery/space_heater/table/T = new /obj/machinery/space_heater/table
        T.icon = table_ref.icon
        T.icon_state = table_ref.icon_state
        T.set_loc(table_ref.loc)
        qdel(table_ref)
