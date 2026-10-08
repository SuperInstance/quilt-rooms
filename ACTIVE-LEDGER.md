# Active Ledger

What's happening *between* rooms. The inter-room record.

The ledger is the set of agreed links. Each link says: "This event in Room A and this event in Room B happened at the same time in our shared universe."

## Format

Each agreed link is a file in `ledger/`, named by universe time:

```
ledger/u-000101.json
ledger/u-000102.json
```

Each file:

```json
{
  "universe_time": 101,
  "links": [
    {"room": "room-a", "seq": 47},
    {"room": "room-b", "seq": 23}
  ],
  "type": "message",
  "summary": "room-a asked about the north passage",
  "content_hash": "b7e2d4...",
  "agreed_by": ["room-a", "room-b"],
  "agreed_at_wall": "2026-10-08T15:36:00Z"
}
```

Fields:
- `universe_time` — the agreed time. Monotonic within the ledger's scope.
- `links` — the room-local times being linked. Each is a (room, seq) pair.
- `type` — what kind of link: `message`, `action`, `sync`, `witness`.
- `summary` — human-readable. Not the full content — just enough to know what happened.
- `content_hash` — hash of the full message content (stored in the rooms' outbox/inbox).
- `agreed_by` — which rooms have recorded this agreement in their own logs.
- `agreed_at_wall` — when the agreement was finalized. Advisory.

## Rules

1. **Both sides record.** A link isn't in the ledger until both rooms have it. Each room keeps its own copy of the ledger — they should match, but each is sovereign.
2. **Links are bilateral (usually).** Most links connect two rooms. Multi-room links are allowed for broadcasts — all rooms record the same universe_time.
3. **Universe time is scoped.** There's no global universe clock. The "universe" is the set of rooms that have agreed to share time. Two separate conversations have two separate universe timelines.
4. **The ledger is append-only.** Like the log. Corrections are new entries.

## Ledger vs Log

| | Active Log | Active Ledger |
|---|---|---|
| Where | `log/` in each room | `ledger/` in each room |
| What | Internal events | Cross-room links |
| Time | Room-local seq | Agreed universe_time |
| Writer | Room's own agent | Both rooms (by agreement) |
| Scope | One room's universe | The shared universe |

## Reading the ledger

To reconstruct what happened between rooms, read the ledger in universe_time order. Each entry tells you which rooms participated and what their local times were.

To reconstruct what happened *inside* a room, read its log in seq order. The log will reference ledger entries where cross-room events occurred.

Together, they give you the full picture: each room's private timeline, and the agreed points where those timelines touched.
