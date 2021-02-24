import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';
import { Description } from "./GeneTek/BioEffect";

var TAB = 0

function build_list(list, tickets, context){
    const { act } = useBackend(context);
    return(
        <Box>
            <NoticeBox>
                {list.category}
            </NoticeBox>
            {list.plant_list.map(l => (
                <Section 
                title={l.name} 
                buttons={
                    <Button
                        icon="dollar-sign"
                        disabled={tickets-l.cost < 0}
                        onClick={() => act("spawn_item", {target_path: l.path, cost: l.cost})}>
                        Tickets: {l.cost}
                    </Button>
                }>
                <Description text={l.desc}/>
                </Section>
            ))}
        </Box>
    )
}


function check_tab(plant_lists, tickets, context){
    if(TAB == 0){
        return(
            plant_lists.map(l => build_list(l,tickets, context))
        )
    }else{
        return(
            build_list(plant_lists[TAB-1], tickets, context)
        )
    }
}

export const SeedMarket = (props, context) => {
    const { data, act } = useBackend(context);
    const { tickets, plant_lists, gacha_cost} = data;
    return(
        <Window
            title = "Seed Market"
            width={620}
            height={700}>
            <Window.Content scrollable>
            <NoticeBox success>
                <strong>Stored Tickets:</strong> {tickets}
            </NoticeBox>
            <Button
                icon="eject"
                disabled={tickets < 1}
                onClick={() => act("eject")}>
                Eject Tickets
            </Button>
            <Button
                icon="heart"
                disabled={tickets < gacha_cost}
                onClick={() => act("gachapon")}>
                Gachapon! : {gacha_cost}
            </Button>
            <Setup/>
            {check_tab(plant_lists, tickets, context)}
            </Window.Content>
        </Window>
    );
};

const Setup = (props, context) => {
    const { act } = useBackend(context);
    return (
        <Box>
            <Tabs>
                <Tabs.Tab
                    icon="plus-square"
                    onClick={() => TAB=0}>
                    All
                </Tabs.Tab>
                <Tabs.Tab
                    icon="bread-slice"
                    onClick={() => TAB=1}>
                    Crops
                </Tabs.Tab>
                <Tabs.Tab
                    icon="apple-alt"
                    onClick={() => TAB=2}>
                    Fruit
                </Tabs.Tab>
                <Tabs.Tab
                    icon="carrot"
                    onClick={() => TAB=3}>
                    Vegetables
                </Tabs.Tab>
                <Tabs.Tab
                    icon="leaf"
                    onClick={() => TAB=4}>
                    Herbs
                </Tabs.Tab>
                <Tabs.Tab
                    icon="sun"
                    onClick={() => TAB=5}>
                    Flowers
                </Tabs.Tab>
                <Tabs.Tab
                    icon="seedling"
                    onClick={() => TAB=6}>
                    Weeds
                </Tabs.Tab>
                <Tabs.Tab
                    icon="flask"
                    onClick={() => TAB=7}>
                    Experimental
                </Tabs.Tab>
            </Tabs>
        </Box>
    );
};