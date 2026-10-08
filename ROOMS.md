# Quilt Rooms

Each room is its own universe.

A room has its own internal happenings, its own sequence, its own time. It doesn't need anyone else to exist. If a room never talks to another room, it's still a complete universe — just a quiet one.

Rooms can talk to each other. When they do, each maintains its own sequence. The conversation between them is recorded separately from what happens inside each one.

## The three records

Every room keeps three things:

1. **Active log** (`log/`) — what's happening *in* the room. The room's private timeline. Sequenced, hash-chained, append-only. See ACTIVE-LOG.md.

2. **Active ledger** (`ledger/`) — what's happening *between* rooms. Every cross-room message, with both rooms' local times and the agreed universe time. See ACTIVE-LEDGER.md.

3. **Pending** (`pending/`) — messages sent but not yet agreed on. The temporal negotiation zone. See TEMPORAL-AGREEMENT.md.

## The room as a directory

```
my-room/
  ROOM.md          # identity: name, purpose, who runs it
  log/             # active log: internal events, sequenced
  inbox/           # incoming messages from other rooms (not yet processed)
  outbox/          # outgoing messages to other rooms (sent, awaiting receipt)
  ledger/          # agreed inter-room links (the settled history)
  pending/         # proposed links awaiting temporal agreement
  seq              # the room's current sequence number (local time)
```

## How rooms find each other

A room doesn't need a registry. It needs a path.

To send to another room, you need to know where its directory is. That's it. The `outbox/` holds your sent messages. The other room's agent (or a shared watcher) moves them to its `inbox/`.

For the Erised game nights: the game master knows all room paths. Players know the game master's room. That's enough.

## The room is sovereign

No room can write to another room's log. No room can dictate another room's time. No room can force agreement.

A room can:
- Write to its own log (always)
- Send messages to another room's inbox (via outbox)
- Propose a universe time for a link
- Accept or dispute a proposed universe time

A room cannot:
- Modify another room's log
- Set another room's sequence number
- Unilaterally declare a universe time

## Silence is valid

A room that never sends is not broken. A room that never receives is not empty. The active log keeps going — internal events, thoughts, state changes. The universe doesn't require communication to exist.

This matters for the game: a player who sits quietly is still playing. Their room has a timeline. When they finally speak, the temporal agreement places that speech correctly in both timelines.
