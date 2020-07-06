/obj/kotatsu
    name = "kotatsu"
    desc = "a heated table with a futon cover on top for maximum warm!"
    icon = 'icons/obj/furniture/table.dmi'
    icon_state = "0"

/obj/machinery/space_heater/table
    name = "heated table"
    desc = "a table. that is a heater. that is also a table."
    icon = 'icons/obj/furniture/table.dmi'
    icon_state = "0"
    layer = OBJ_LAYER-0.1
    anchored = 1
    var/oldpath

    New()
        ..()
        UpdateOverlays(image('icons/obj/furniture/table.dmi',"heater-0"),"heater")

    proc/cell_transfer(var/obj/machinery/space_heater/TO,var/obj/machinery/space_heater/FROM)
        if(TO.cell)
            qdel(TO.cell)
        if(FROM.cell)
            var/obj/item/cell/new_cell = new FROM.cell.type
            new_cell.charge = FROM.cell.charge
            new_cell.maxcharge = FROM.cell.maxcharge
            new_cell.set_loc(TO)
            TO.cell = new_cell

    attackby(obj/item/I, mob/user,params)
        if(istype(I, /obj/item/cell))
            ..()
        else if(istype(I,/obj/item/card/emag))
            ..()
        else if(isscrewingtool(I))
            open = !open
            user.visible_message("<span class='notice'>[user] [open ? "opens" : "closes"] the hatch on the [src].</span>", "<span class='notice'>You [open ? "open" : "close"] the hatch on the [src].</span>")
            if(open)
                UpdateOverlays(image('icons/obj/furniture/table.dmi',"heater-open"),"heater-open")
            else
                ClearSpecificOverlays("heater-open")
        else if(iswrenchingtool(I))
            if(oldpath)
                new oldpath(src.loc)
            else
                new /obj/table/auto(src.loc)
            var/obj/machinery/space_heater/H = new /obj/machinery/space_heater
            cell_transfer(H,src)
            H.set_loc(src.loc)
            qdel(src)
        else
            src.place_on(I, user, params)

    update_icon()
        if(on)
            if(heating)
                UpdateOverlays(image('icons/obj/furniture/table.dmi',"heater-1"),"heater")
            else
                UpdateOverlays(image('icons/obj/furniture/table.dmi',"heater-2"),"heater")
        else
            UpdateOverlays(image('icons/obj/furniture/table.dmi',"heater-0"),"heater")

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
        table_ref = table

    onUpdate()
        ..()
        if(!table_ref || !(heater_ref in range(1,owner.loc)))
            interrupt(INTERRUPT_ALWAYS)
            return

    onEnd()
        ..()
        var/obj/machinery/space_heater/table/T = new /obj/machinery/space_heater/table
        T.icon = table_ref.icon
        T.icon_state = "0"
        T.oldpath = table_ref.type
        T.cell_transfer(T,heater_ref)
        qdel(heater_ref)
        T.set_loc(table_ref.loc)
        qdel(table_ref)
