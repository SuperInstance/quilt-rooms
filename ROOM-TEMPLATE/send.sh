#!/bin/bash
# send.sh — send a message to another room
# Usage: ./send.sh <to_room_path> "<content>" [proposed_universe_time]
# Example: ./send.sh ../room-b "Should we go north?" 101

ROOM_DIR="$(cd "$(dirname "$0")" && pwd)"
TO_ROOM="$1"
CONTENT="$2"
PROPOSED_U="${3:-}"

if [ -z "$TO_ROOM" ] || [ -z "$CONTENT" ]; then
  echo "Usage: ./send.sh <to_room_path> \"<content>\" [proposed_universe_time]"
  exit 1
fi

ROOM_NAME=$(basename "$ROOM_DIR")
TO_NAME=$(basename "$TO_ROOM")
SEQ=$(cat "$ROOM_DIR/seq")
CONTENT_HASH=$(echo -n "$CONTENT" | sha256sum | cut -d' ' -f1 | cut -c1-12)
WALL=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MSG_ID="${ROOM_NAME}-${SEQ}-to-${TO_NAME}"

if [ -z "$PROPOSED_U" ]; then
  # Default: propose next universe time based on our ledger
  LAST_U=$(ls "$ROOM_DIR/ledger/" 2>/dev/null | sort | tail -1 | sed 's/u-0*//' | sed 's/.json//')
  if [ -z "$LAST_U" ]; then LAST_U=0; fi
  PROPOSED_U=$((LAST_U + 1))
fi

cat > "$ROOM_DIR/outbox/${MSG_ID}.json" <<EOF
{
  "from_room": "$ROOM_NAME",
  "from_seq": $SEQ,
  "to_room": "$TO_NAME",
  "content": "$CONTENT",
  "content_hash": "$CONTENT_HASH",
  "proposed_universe_time": $PROPOSED_U,
  "sent_wall": "$WALL"
}
EOF

# Also copy to recipient's inbox if path is accessible
if [ -d "$TO_ROOM/inbox" ]; then
  cp "$ROOM_DIR/outbox/${MSG_ID}.json" "$TO_ROOM/inbox/"
  echo "Sent to $TO_NAME inbox (seq $SEQ, proposed U:$PROPOSED_U)"
else
  echo "Written to outbox (seq $SEQ, proposed U:$PROPOSED_U). Recipient inbox not accessible."
fi

# Create our own pending entry
cat > "$ROOM_DIR/pending/${MSG_ID}.json" <<EOF
{
  "from_room": "$ROOM_NAME",
  "from_seq": $SEQ,
  "to_room": "$TO_NAME",
  "to_seq": null,
  "proposed_universe_time": $PROPOSED_U,
  "their_proposal": null,
  "accept": true,
  "proposed_by": "$ROOM_NAME",
  "status": "proposed"
}
EOF

# Log the send
"$ROOM_DIR/say.sh" "send" "to:$TO_NAME seq:$SEQ proposed_U:$PROPOSED_U" > /dev/null
