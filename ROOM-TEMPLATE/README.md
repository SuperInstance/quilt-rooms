# Room Template

A minimal quilt room. Copy this directory to create a new room.

## Setup

```bash
cp -r ROOM-TEMPLATE my-room
cd my-room
echo "my-room" > ROOM.md  # or write a proper identity
echo "0" > seq
chmod +x *.sh
./say.sh note "Room created."
```

## Scripts

- `say.sh <type> "<content>"` — log an internal event
- `send.sh <to_room_path> "<content>" [universe_time]` — send to another room
- `receive.sh` — process inbox, create pending temporal links
- `agree.sh <other_room_path>` — finalize agreements into ledger

## Directory layout

```
my-room/
  ROOM.md       # identity
  seq           # current sequence number
  log/          # active log (internal events)
  inbox/        # incoming messages
  outbox/       # outgoing messages
  ledger/       # agreed inter-room links
  pending/      # proposed links awaiting agreement
  *.sh          # the four scripts
```

## Example session

```bash
# Room A says something internally
./say.sh think "I wonder what's north."

# Room A sends to Room B
./send.sh ../room-b "Should we go north?" 101

# Room B receives
cd ../room-b
./receive.sh

# Room B agrees (or Room A runs agree.sh)
./agree.sh ../room-a
# Or from room-a:
cd ../room-a
./agree.sh ../room-b
```
