#!/bin/bash
# receive.sh — check inbox, process incoming messages, propose temporal links
# Usage: ./receive.sh
# Processes all messages in inbox/, logs receipt, creates pending links.

ROOM_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOM_NAME=$(basename "$ROOM_DIR")

INBOX_COUNT=$(ls "$ROOM_DIR/inbox/"*.json 2>/dev/null | wc -l)
if [ "$INBOX_COUNT" -eq 0 ]; then
  echo "Inbox empty."
  exit 0
fi

for MSG in "$ROOM_DIR/inbox/"*.json; do
  FROM_ROOM=$(python3 -c "import json; print(json.load(open('$MSG'))['from_room'])")
  FROM_SEQ=$(python3 -c "import json; print(json.load(open('$MSG'))['from_seq'])")
  CONTENT=$(python3 -c "import json; print(json.load(open('$MSG'))['content'])")
  PROPOSED_U=$(python3 -c "import json; print(json.load(open('$MSG'))['proposed_universe_time'])")
  MSG_ID=$(basename "$MSG" .json)

  # Log the receipt (this increments our seq)
  "$ROOM_DIR/say.sh" "heard" "from:$FROM_ROOM seq:$FROM_SEQ content:$CONTENT" > /dev/null
  MY_SEQ=$(cat "$ROOM_DIR/seq")

  # Check if we agree with proposed universe time
  # Simple rule: if we already have that U time, propose U+1
  EXISTING=$(ls "$ROOM_DIR/ledger/u-$(printf "%06d" $PROPOSED_U).json" 2>/dev/null)
  if [ -n "$EXISTING" ]; then
    MY_PROPOSAL=$((PROPOSED_U + 1))
    ACCEPT="false"
  else
    MY_PROPOSAL=$PROPOSED_U
    ACCEPT="true"
  fi

  # Write pending link
  cat > "$ROOM_DIR/pending/${MSG_ID}.json" <<EOF
{
  "from_room": "$FROM_ROOM",
  "from_seq": $FROM_SEQ,
  "to_room": "$ROOM_NAME",
  "to_seq": $MY_SEQ,
  "proposed_universe_time": $MY_PROPOSAL,
  "their_proposal": $PROPOSED_U,
  "accept": $ACCEPT,
  "proposed_by": "$ROOM_NAME",
  "status": "proposed"
}
EOF

  # Move from inbox to processed
  mkdir -p "$ROOM_DIR/inbox/processed"
  mv "$MSG" "$ROOM_DIR/inbox/processed/"

  echo "Received from $FROM_ROOM (their seq $FROM_SEQ, my seq $MY_SEQ)"
  echo "  Proposed U:$MY_PROPOSAL (theirs was $PROPOSED_U, accept=$ACCEPT)"
done
