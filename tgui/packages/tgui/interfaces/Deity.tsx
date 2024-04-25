import { GameIcon } from "../components/GameIcon";
import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Icon,
  LabeledList,
  Section,
  Tabs,
  Stack,
  Table,
  NoticeBox,
  Divider,
} from "../components";
import { Window } from "../layouts";
import { capitalize } from "common/string";

export const Stat2Text = {
  0: "Conscious",
  1: "Unconscious",
  2: "Dead",
};

enum Page {
  Forms,
  Evolution,
  Compendium,
  List,
}

interface Follower {
  name: string;
  stat: number;
  ref: string;
}

interface Building {
  name: string;
}

interface User {
  form?: string | null;
  name: string;
}

interface Item {
  name: string;
  desc: string;
  icon: string;
  owned: boolean;
  cost: number;
  expected_type: string;
  power_path: string;
}

interface Form {
  name: string;
  desc: string;
  icon: string;
}

interface EvolutionPackage {
  name: string;
  desc: string;
  tier: number;
  icon: string;
  unlocked: boolean;
}

interface EvolutionCategory {
  name: string;
  desc: string;
  icon: string;
  packages: EvolutionPackage[];
}

interface InputData {
  page: number;
  forms: Form[];
  user: User;
  items: Item[];
  evolutionItems: EvolutionCategory[];
  followers: Follower[];
  buildings: Building[];
}

export const Deity = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  const [currentPage, setCurrentPage] = useLocalState(
    context,
    "pageName",
    Page.Forms
  );

  return (
    <Window width={425} height={520}>
      <Window.Content scrollable>
        <Section textAlign="center" align="center">
          <Tabs>
            {data.user.form ? (
              <>
                <Tabs.Tab onClick={() => setCurrentPage(Page.Evolution)}>
                  Evolution Menu
                </Tabs.Tab>
                <Tabs.Tab onClick={() => setCurrentPage(Page.Compendium)}>
                  Compendium
                </Tabs.Tab>
                <Tabs.Tab onClick={() => setCurrentPage(Page.List)}>
                  List
                </Tabs.Tab>
              </>
            ) : (
              <Tabs.Tab onClick={() => setCurrentPage(Page.Forms)}>
                Forms
              </Tabs.Tab>
            )}
          </Tabs>
        </Section>
        <Section>
          {(currentPage === Page.Forms && <Forms />) ||
            (currentPage === Page.Evolution && <EvolutionMenu />) ||
            (currentPage === Page.Compendium && <Compendium />) ||
            (currentPage === Page.List && <List />)}
        </Section>
      </Window.Content>
    </Window>
  );
};

const Forms = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Stack vertical>
      <Stack.Item>
        {data.forms?.map((form) => (
          <Section>
            <Button
              onClick={() => {
                act("choose_form", { path: form.name });
              }}
            >
              Choose
            </Button>
            <GameIcon html={form.icon} />
          </Section>
        ))}
      </Stack.Item>
    </Stack>
  );
};

const EvolutionMenu = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <>
      {data.evolutionItems?.map((category: EvolutionCategory) => (
        <Section title={category.name}>
          <Stack fill vertical>
            {category.packages?.map((evoPack: EvolutionPackage) =>
              EvolutionCard(evoPack, context)
            )}
          </Stack>
        </Section>
      ))}
    </>
  );
};

const Compendium = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return <Stack>I'm a stub for compendium. More content later.</Stack>;
};

const EvolutionCard = (props: any, context: any) => {
  const { data, act } = useBackend<InputData>(context);

  return (
    <Stack direction="column">
      <Stack.Item align="left">
        <span className="PowerName">{props.name}</span>
      </Stack.Item>
      <p>
        <b>Cost:</b> {props.cost === 0 ? "Free" : props.cost}
      </p>
      <p>{props.description}</p>
      {props.help_text ? <p className="HelpText">{props.help_text}</p> : ""}
    </Stack>
  );
};

const List = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Stack>
      {data.followers?.length ? (
        <Table>
          <Table.Row className="candystripe" collapsing>
            <Table.Cell bold fontSize={1.2} textAlign="left">
              Name
            </Table.Cell>
            <Table.Cell bold fontSize={1.2} textAlign="left">
              Required
            </Table.Cell>
            <Table.Cell bold fontSize={1.2} textAlign="left">
              Actions
            </Table.Cell>
          </Table.Row>
          {data.followers?.map((follower, i) => (
            <Table.Row className="candystripe" collapsing key={i}>
              <Table.Cell bold>{follower.name}</Table.Cell>
              <Table.Cell bold>{Stat2Text[follower.stat]}</Table.Cell>
              <Table.Cell collapsing textAlign="left">
                <Button.Confirm
                  color="good"
                  content="reward"
                  onClick={() => act("reward_follower", { ref: follower.ref })}
                />
                <Button.Confirm
                  color="bad"
                  content="punish"
                  onClick={() => act("punish_follower", { ref: follower.ref })}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <Stack.Item grow>
          <NoticeBox textAlign="center">You have no followers!</NoticeBox>
        </Stack.Item>
      )}
    </Stack>
  );
};
