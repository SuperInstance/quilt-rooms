# Active Log

What's happening *in* the room. The room's private timeline.

## Format

Each event is a file in `log/`, named by sequence number:

```
log/000001.json
log/000002.json
log/000003.json
```

Each file:

```json
{
  "seq": 1,
  "wall": "2026-10-08T15:35:00Z",
  "type": "say",
  "content": "I think we should go north.",
  "prev": "genesis",
  "hash": "a3f8c1..."
}
```

Fields:
- `seq` — the room's local sequence number. Monotonic. This is the room's time.
- `wall` — wall-clock timestamp. Informational only. Not authoritative.
- `type` — event type. Free-form: `say`, `think`, `act`, `note`, `join`, `leave`, anything.
- `content` — the event. Text, or a reference to a larger payload.
- `prev` — hash of the previous log entry. Hash chain for integrity.
- `hash` — hash of this entry (excluding the hash field itself).

The first entry has `"prev": "genesis"`.

## Rules

1. **Append-only.** Never edit, never delete. If you got it wrong, write a correction as a new event.
2. **One writer.** Only the room's agent writes to its log. No exceptions.
3. **Sequence is time.** The seq number *is* the room's local time. There is no other clock that matters inside the room.
4. **Wall clock is advisory.** It's there for humans reading the log. The room doesn't use it for ordering.
5. **Hash chain is the seal.** If the chain breaks, the log was tampered with. Start over or fork.

## What goes in the log

Everything the room does, thinks, or decides — that stays inside the room.

- Internal reasoning: `{"type": "think", "content": "..."}`
- Actions taken: `{"type": "act", "content": "moved the piece"}`
- Speech (before sending): `{"type": "say", "content": "..."}` then a `send` event
- Received messages (after processing): `{"type": "heard", "content": "from:room-b seq:12"}`
- Temporal agreements: `{"type": "agreed", "content": "A:47 = B:23 = U:101"}`

The log is the room's memory. If the room forgets everything else, the log rebuilds it.

## What doesn't go in the log

Cross-room messages themselves. Those go in the ledger (once agreed) or pending (while negotiating). The log records *that* a message was sent or received, not the full content — just a pointer.

This keeps the log readable. The ledger holds the links.
