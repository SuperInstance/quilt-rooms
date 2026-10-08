# Temporal Agreement

Time is agreed, not absolute.

When Room A sends a message to Room B, that message happened at time T_a in A's sequence and will be received at time T_b in B's sequence. Those are different numbers. Different times.

The link is an agreement: "A:47 and B:23 are the same moment."

## The protocol

### Step 1: Send

Room A writes to its `outbox/`:

```json
{
  "from_room": "room-a",
  "from_seq": 47,
  "to_room": "room-b",
  "content": "Should we go north?",
  "content_hash": "b7e2d4...",
  "proposed_universe_time": 101,
  "sent_wall": "2026-10-08T15:35:00Z"
}
```

A also writes to its own log: `{"type": "send", "content": "to:room-b seq:47 proposed_U:101"}`.

The `proposed_universe_time` is A's suggestion. It's just a proposal.

### Step 2: Receive

Room B's agent (or a watcher) moves the message from A's outbox to B's `inbox/`. B processes it and writes to its log:

```json
{"type": "heard", "seq": 23, "content": "from:room-a seq:47"}
```

Note: B received it at *its* seq 23. That's B's time.

### Step 3: Propose

B writes a proposed link to its `pending/`:

```json
{
  "from_room": "room-a",
  "from_seq": 47,
  "to_room": "room-b",
  "to_seq": 23,
  "proposed_universe_time": 101,
  "proposed_by": "room-b",
  "status": "proposed"
}
```

If B agrees with A's proposed universe_time (101), it marks `"accept": true`.

If B disagrees — maybe B thinks this should be universe_time 102 because it already has a 101 — it proposes a different time: `"proposed_universe_time": 102, "accept": false`.

### Step 4: Agree

A checks B's pending. If they proposed the same universe_time, both write the link to their `ledger/` with `status: "agreed"`. Both log: `{"type": "agreed", "content": "A:47 = B:23 = U:101"}`.

If they proposed different times, the link stays in `pending/` until they converge.

### Step 5: Convergence

Disagreements are resolved by:
1. **Higher number wins** (default). If A says 101 and B says 102, it's 102. Simple, deterministic.
2. **Game master decides** (for Erised). The GM's room proposes, players accept.
3. **Negotiation.** A and B exchange proposals until they match. Each writes the negotiation to their log.

The rule is: the link isn't real until both sides agree on the universe_time. A pending link is a question. An agreed link is a fact.

## Why not just use wall clock?

Wall clocks lie. They drift, they disagree, they don't exist on some devices.

More importantly: wall clock is *imposed*. It's an external authority telling both rooms what time it is. Temporal agreement is *negotiated*. The rooms decide together.

This matters because the rooms are sovereign. No external clock can tell Room A what time it is in its own universe. Room A knows: it's seq 47. Room B knows: it's seq 23. Together, they agree: that's universe time 101.

## The universe is scoped

There's no single universe clock. Each conversation, each game, each shared context has its own universe timeline.

Room A might be in three conversations:
- With B: universe_time goes to 150
- With C: universe_time goes to 75
- With D: universe_time goes to 200

These are three different universes. They don't need to agree with each other. Room A's internal seq is the only thing that ties them together — A knows that "the message to B at my seq 47" happened before "the message to C at my seq 52."

## Disputes

If rooms can't agree on universe_time after 3 rounds of proposals, the link is marked `"status": "disputed"` and a watcher (or game master) is notified.

Disputed links stay in `pending/`. They don't enter the ledger. The rooms continue — disputed time doesn't block new messages.

This is intentional. Time agreement is important, but not blocking. The conversation continues. The timestamp gets settled later.

## For the Erised game

The game master acts as the temporal authority. When the GM speaks, the proposed universe_time is accepted by default. Players can dispute, but the GM breaks ties.

This keeps the game flowing. The story needs a shared "now" — the GM provides it.

But between players (without GM involvement), the standard negotiation applies. Two players whispering don't need the GM to timestamp their exchange. They agree directly.
