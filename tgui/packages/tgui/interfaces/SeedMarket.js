import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Divider, BlockQuote, Icon, Tabs } from '../components';
import { Window } from '../layouts';

export const SeedMarket = (props, context) => {
    const { data } = useBackend(context);
    const { tickets, products } = data;
    return(
        <Window
            title = "Seed Market"
            width={730}
            height={415}>
            <Window.Content scrollable>
            <Box mb="0.5em">
                <strong>Stored Tickets:</strong>{tickets}
             </Box>
                <Box ml="1em">
                    <Tabs>
                        <Tabs.Tab
                            icon="plus-square"
                            onClick={() => setMenu("all")}>
                            All
                        </Tabs.Tab>
                        <Tabs.Tab
                            icon="pagelines"
                            onClick={() => setMenu("crop")}>
                            Crop
                        </Tabs.Tab>
                        <Tabs.Tab
                            icon="apple-alt"
                            onClick={() => setMenu("fruit")}>
                            Fruit
                        </Tabs.Tab>
                        <Tabs.Tab
                            icon="carrot"
                            onClick={() => setMenu("vegetable")}>
                            Vegetable
                        </Tabs.Tab>
                        <Tabs.Tab
                            icon="leaf"
                            onClick={() => setMenu("herb")}>
                            Herb
                        </Tabs.Tab>
                        <Tabs.Tab
                            icon="sun"
                            onClick={() => setMenu("flower")}>
                            Flower
                        </Tabs.Tab>
                        <Tabs.Tab
                            icon="seedling"
                            onClick={() => setMenu("weed")}>
                            Weed
                        </Tabs.Tab>
                        <Tabs.Tab
                            icon="flask"
                            onClick={() => setMenu("alien")}>
                            Alien
                        </Tabs.Tab>
                    </Tabs>
                </Box>
            </Window.Content>
        </Window>
    );
};