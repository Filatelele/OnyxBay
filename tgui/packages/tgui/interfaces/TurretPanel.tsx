import { useBackend } from "../backend";
import {
  Button,
  Section,
  Stack,
  ProgressBar,
  LabeledList,
} from "../components";
import { Window } from "../layouts";

const PAGE_MAIN = 0;
const PAGE_TURRETS = 1;

type Turret = {
  gun: string;
  status: boolean;
  ammo: number;
  integrity: number;
};

type InputData = {
  turrets: Turret[];
  access: boolean;
  locked: boolean;
  enabled: boolean;
  is_lethal: boolean;
  lethal: boolean;
  check_arrest: boolean;
  check_records: boolean;
  check_weapon: boolean;
  check_access: boolean;
  check_anomalies: boolean;
  check_synth: boolean;
  page: 0;
};

const mainPage = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Section>
      <Stack.Item>
        <Stack>
          <Stack.Item align="right">
            <Button
              fluid
              content={"Lethal Mode"}
              icon={data.lethal ? "circle-check" : "circle"}
              color={data.lethal ? "red" : "green"}
              onClick={() => act("lethal_mode", {})}
            />
            <Button
              fluid
              content={"Neutralize ALL Non-Synthetics"}
              icon={data.check_synth ? "circle-check" : "circle"}
              color={data.check_synth ? "red" : "green"}
              onClick={() => act("check_synth", {})}
            />
            <Button
              fluid
              content={"Check Weapon Authorization"}
              icon={data.check_weapon ? "circle-check" : "circle"}
              color={data.check_weapon ? "red" : "green"}
              onClick={() => act("check_weapon", {})}
            />
            <Button
              fluid
              content={"Check Security Records"}
              icon={data.check_records ? "circle-check" : "circle"}
              color={data.check_records ? "red" : "green"}
              onClick={() => act("check_records", {})}
            />
            <Button
              fluid
              content={"Check Arrest Status"}
              icon={data.check_arrest ? "circle-check" : "circle"}
              color={data.check_arrest ? "red" : "green"}
              onClick={() => act("check_arrest", {})}
            />
            <Button
              fluid
              content={"Check Access Authorization"}
              icon={data.check_access ? "circle-check" : "circle"}
              color={data.check_access ? "red" : "green"}
              onClick={() => act("check_access", {})}
            />
            <Button
              fluid
              content={"Check misc. Lifeforms"}
              icon={data.check_anomalies ? "circle-check" : "circle"}
              color={data.check_anomalies ? "red" : "green"}
              onClick={() => act("check_anomalies", {})}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Section>
  );
};
const turretPage = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Stack vertical>
      {data.turrets.map((turret) => (
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Installed gun">
              {turret.gun}
            </LabeledList.Item>
            <LabeledList.Item label="Integrity">
              <ProgressBar
                value={turret.integrity}
                minValue={0}
                maxValue={100}
                ranges={{
                  bad: [-Infinity, 0.7],
                  average: [0.7, 0.9],
                  good: [0.9, Infinity],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Ammo">
              <ProgressBar
                value={turret.ammo}
                minValue={0}
                maxValue={100}
                ranges={{
                  bad: [-Infinity, 0.7],
                  average: [0.7, 0.9],
                  good: [0.9, Infinity],
                }}
              />
            </LabeledList.Item>
          </LabeledList>
          <LabeledList.Divider size={1} />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const PAGES = {
  0: {
    render: mainPage,
  },
  1: {
    render: turretPage,
  },
};

export const TurretPanel = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window title="Turret Control Panel" width={240} height={280}>
      <Window.Content scrollable>
        <Section
          title="Turret Control Panel"
          buttons={
            <Button
              icon={"screwdriver-wrench"}
              onClick={() => act("change_page", {})}
            />
          }
        >
          Conntected turrets:{" "}
          {data.turrets?.length > 0 ? data.turrets?.length : 0}
        </Section>
        <Section>{PAGES[data.page].render(props, context)}</Section>
      </Window.Content>
    </Window>
  );
};
