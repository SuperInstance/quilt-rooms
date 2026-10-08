# Quilt Rooms

Each room is its own universe. Rooms talk, but each keeps its own time.

## The three documents

- **ROOMS.md** — the protocol. How rooms work, sovereignty, silence.
- **ACTIVE-LOG.md** — the intra-room log. Every internal event, sequenced, hash-chained.
- **ACTIVE-LEDGER.md** — the inter-room ledger. Agreed links with dual timestamps.
- **TEMPORAL-AGREEMENT.md** — how rooms agree on time. Negotiated, not dictated.

## The core idea

When Room A sends to Room B:
- It happened at A's seq 47 (A's time)
- It was received at B's seq 23 (B's time)
- The link records: **A:47 = B:23 = U:101** (agreed universe time)

Time is agreed, not absolute. If A and B propose different universe times, the link stays pending until they converge. Higher number wins by default. The game master breaks ties.

## ROOM-TEMPLATE/

A working room. Four scripts:
- `say.sh` — log internal events
- `send.sh` — send to another room
- `receive.sh` — process inbox, propose temporal links
- `agree.sh` — finalize agreements into the ledger

Tested end-to-end: send → receive → agree produces matching ledger entries in both rooms. Disagreement detection works.

## For Erised

Each room is a player. The game master nudges. The active log is what happened in the room. The active ledger is what happened between rooms. Temporal agreement is how the story stays coherent across independent timelines.
