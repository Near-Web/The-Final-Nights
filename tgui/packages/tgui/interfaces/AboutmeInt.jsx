import { useBackend, useLocalState } from '../backend';
import { Section, Tabs, Box, Button, Table } from 'tgui-core/components';
import { Window } from '../layouts';

const OverviewSection = ({ overview = {}, status, alignment }) => {
  const {
    name,
    species,
    role,
    special_role,
    clan,
    generation,
    regnant,
    regnant_clan,
    masquerade,
    humanity,
    stats = {},
    disciplines = [],
  } = overview;

  return (
    <Section fill title="Overview">
      <Box><b>Name:</b> {name}</Box>
      <Box><b>Species:</b> {species}</Box>
      <Box><b>Role:</b> {role} {special_role && `(${special_role})`}</Box>
      <Box><b>Clan:</b> {clan}</Box>
      <Box><b>Generation:</b> {generation}</Box>
      <Box><b>Regnant:</b> {regnant}</Box>
      <Box><b>Regnant Clan:</b> {regnant_clan}</Box>
      <Box><b>Masquerade:</b> {masquerade}</Box>
      <Box><b>Humanity:</b> {humanity}</Box>

      <br />
      <Box bold>Stats</Box>
      <Table>
        {Object.entries(stats).map(([key, val], i) => (
          <Table.Row key={i}>
            <Table.Cell>{key}</Table.Cell>
            <Table.Cell>{val}</Table.Cell>
          </Table.Row>
        ))}
      </Table>

      <Box bold mt={1}>Disciplines</Box>
      {disciplines.length > 0 ? (
        <Table>
          {disciplines.map((d, i) => (
            <Table.Row key={i}>
              <Table.Cell bold>{d.name}</Table.Cell>
              <Table.Cell>Lv. {d.level}</Table.Cell>
              <Table.Cell>{d.desc}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <Box italic>No disciplines known.</Box>
      )}

      <br />
      <Box><b>Status:</b> {status}</Box>
      <Box><b>Alignment:</b> {alignment}</Box>
    </Section>
  );
};


const GroupsSection = ({ groups = {} }) => (
  <Section title="Groups">
    {['sect_text', 'organization_text', 'party_text'].map(key => (
      <Box key={key}>
        <b>{key.replace('_text', '').toUpperCase()}:</b> {groups[key] || 'None'}
      </Box>
    ))}
  </Section>
);

const RelationshipsSection = ({ group_affiliations = [], act, actModal }) => (
  <Section title="Relationships">
    <Button icon="plus" content="New Relationship" onClick={() => act('create_relationship')} mb={1} />
    {group_affiliations.length ? (
      <Table>
        {group_affiliations.map((rel, i) => (
          <Table.Row key={i}>
            <Table.Cell bold>{rel.name}</Table.Cell>
            <Table.Cell>{rel.relationship_type}</Table.Cell>
            <Table.Cell>{rel.strength}</Table.Cell>
            <Table.Cell>
              <Button icon="edit" tooltip="Edit" onClick={() =>
                actModal('edit_relationship', {
                  title: 'Edit Relationship',
                  fields: [
                    { name: 'id', type: 'hidden', value: rel.id },
                    { name: 'name', label: 'Name', type: 'text', defaultValue: rel.name },
                    { name: 'desc', label: 'Description', type: 'textarea', defaultValue: rel.desc },
                    { name: 'relationship_type', label: 'Type', type: 'text', defaultValue: rel.relationship_type },
                    { name: 'strength', label: 'Strength', type: 'number', defaultValue: rel.strength },
                  ],
                })} />
              <Button icon="trash" color="bad" tooltip="Delete" onClick={() => act('delete_relationship', { id: rel.id })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    ) : <Box italic>No relationships defined.</Box>}
  </Section>
);

const ChronicleSection = ({ chronicleEvents = [], act, actModal }) => (
  <Section title="Chronicle">
    <Button icon="plus" content="Create Chronicle" onClick={() => act('create_chronicle')} mb={1} />
    {chronicleEvents.length ? (
      <Table>
        {chronicleEvents.map((entry, i) => (
          <Table.Row key={i}>
            <Table.Cell bold>{entry.title}</Table.Cell>
            <Table.Cell>{entry.details}</Table.Cell>
            <Table.Cell>{entry.time || entry.timestamp}</Table.Cell>
            <Table.Cell>
              <Button icon="edit" tooltip="Edit" onClick={() =>
                actModal('edit_chronicle', {
                  title: 'Edit Chronicle',
                  fields: [
                    { name: 'id', type: 'hidden', value: entry.id },
                    { name: 'title', label: 'Title', type: 'text', defaultValue: entry.title },
                    { name: 'details', label: 'Details', type: 'textarea', defaultValue: entry.details },
                  ],
                })} />
              <Button icon="trash" tooltip="Delete" color="bad" onClick={() => act('delete_chronicle', { id: entry.id })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    ) : <Box italic>No chronicle entries yet.</Box>}
  </Section>
);

const MemoriesTabsSection = ({ memories = {}, act, actModal }) => {
  const [memTab, setMemTab] = useLocalState('aboutme_memtab', 'all');
  const categories = ['all', 'background', 'current', 'recent', 'goal', 'secret', 'reputation'];
  const tagFiltered = memTab === 'all' ? memories.memories_all : (memories[memTab] || []);
  return (
    <Section title="Memories">
      <Tabs>
        {categories.map(tag => (
          <Tabs.Tab key={tag} selected={memTab === tag} onClick={() => setMemTab(tag)}>
            {tag.charAt(0).toUpperCase() + tag.slice(1)}
          </Tabs.Tab>
        ))}
      </Tabs>
      <Box mb={1}>
        <Button icon="plus" content="Add Memory" onClick={() => act('create_memory')} />
        <Button icon="tag" content="Tag Memory" ml={1} onClick={() => act('tag_memory')} />
      </Box>
      <Table>
        {tagFiltered.length ? tagFiltered.map((mem, i) => (
          <Table.Row key={i}>
            <Table.Cell bold>{mem.title}</Table.Cell>
            <Table.Cell>{mem.details}</Table.Cell>
            <Table.Cell>{mem.tags?.join(', ')}</Table.Cell>
            <Table.Cell>{mem.status}</Table.Cell>
            <Table.Cell>{mem.time}</Table.Cell>
            <Table.Cell>
              <Button icon="edit" tooltip="Edit" onClick={() =>
                actModal('edit_memory', {
                  title: 'Edit Memory',
                  fields: [
                    { name: 'id', type: 'hidden', value: mem.id },
                    { name: 'title', label: 'Title', type: 'text', defaultValue: mem.title },
                    { name: 'details', label: 'Details', type: 'textarea', defaultValue: mem.details },
                    { name: 'tags', label: 'Tags', type: 'text', defaultValue: mem.tags?.join(', ') },
                    { name: 'status', label: 'Status', type: 'text', defaultValue: mem.status },
                  ],
                })} />
              <Button icon="trash" color="bad" tooltip="Delete" onClick={() => act('delete_memory', { id: mem.id })} />
            </Table.Cell>
          </Table.Row>
        )) : (
          <Table.Row><Table.Cell colSpan="6" italic>No memories in this category</Table.Cell></Table.Row>
        )}
      </Table>
    </Section>
  );
};

export const AboutmeInt = (props, context) => {
  const { data = {}, act, actModal } = useBackend(context);
  const {
    overview = {},
    groups = {},
    relationships: { group_affiliations = [] } = {},
    chronicle: { events: chronicleEvents = [] } = {},
    memories_all = [],
    background = [],
    current = [],
    recent = [],
    goal = [],
    secret = [],
    reputation = [],
    status = '',
    alignment = '',
  } = data;

  const [tab, setTab] = useLocalState('aboutme_tab', 'overview');
  const memories = { memories_all, background, current, recent, goal, secret, reputation };

  return (
    <Window width={720} height={540} title="About Me">
      <Window.Content scrollable>
        <Box italic mb={1}>
          This window shows your character's profile, memories, affiliations, and history.
        </Box>
        <Tabs>
          <Tabs.Tab selected={tab === 'overview'} onClick={() => setTab('overview')}>Overview</Tabs.Tab>
          <Tabs.Tab selected={tab === 'groups'} onClick={() => setTab('groups')}>Groups</Tabs.Tab>
          <Tabs.Tab selected={tab === 'relationships'} onClick={() => setTab('relationships')}>Relationships</Tabs.Tab>
          <Tabs.Tab selected={tab === 'chronicle'} onClick={() => setTab('chronicle')}>Chronicle</Tabs.Tab>
          <Tabs.Tab selected={tab === 'memories'} onClick={() => setTab('memories')}>Memories</Tabs.Tab>
        </Tabs>

        {tab === 'overview' && <OverviewSection overview={overview} status={status} alignment={alignment} />}
        {tab === 'groups' && <GroupsSection groups={groups} />}
        {tab === 'relationships' && <RelationshipsSection group_affiliations={group_affiliations} act={act} actModal={actModal} />}
        {tab === 'chronicle' && <ChronicleSection chronicleEvents={chronicleEvents} act={act} actModal={actModal} />}
        {tab === 'memories' && <MemoriesTabsSection memories={memories} act={act} actModal={actModal} />}

        {/* Debug payload dump for dev */}
        <Box mt={2}>
          <details>
            <summary>Debug: Full Payload</summary>
            <pre style={{
              maxHeight: 160,
              overflowY: 'auto',
              fontSize: 12,
              background: '#111',
              color: '#eee',
              borderRadius: 4,
              padding: 8
            }}>
              {JSON.stringify(data, null, 2)}
            </pre>
          </details>
        </Box>
      </Window.Content>
    </Window>
  );
};

AboutmeInt.displayName = 'AboutmeInt';
AboutmeInt.defaultProps = {
  id: 'AboutmeInt',
  title: 'About Me',
};
