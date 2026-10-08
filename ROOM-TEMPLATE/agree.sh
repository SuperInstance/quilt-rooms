#!/bin/bash
# agree.sh — check pending links, finalize agreements into the ledger
# Usage: ./agree.sh <other_room_path>
# Compares our pending with theirs, agrees where proposals match.

ROOM_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOM_NAME=$(basename "$ROOM_DIR")
OTHER_ROOM="$1"

if [ -z "$OTHER_ROOM" ]; then
  echo "Usage: ./agree.sh <other_room_path>"
  exit 1
fi

OTHER_NAME=$(basename "$OTHER_ROOM")
AGREED=0

for PENDING in "$ROOM_DIR/pending/"*.json; do
  [ -e "$PENDING" ] || continue
  MSG_ID=$(basename "$PENDING" .json)

  MY_U=$(python3 -c "import json; print(json.load(open('$PENDING'))['proposed_universe_time'])")
  FROM_ROOM=$(python3 -c "import json; print(json.load(open('$PENDING'))['from_room'])")
  FROM_SEQ=$(python3 -c "import json; print(json.load(open('$PENDING'))['from_seq'])")
  TO_ROOM_P=$(python3 -c "import json; print(json.load(open('$PENDING'))['to_room'])")
  # to_seq may be null on sender side — get it from the other room's pending
  TO_SEQ_RAW=$(python3 -c "import json; v=json.load(open('$PENDING'))['to_seq']; print(v if v else '')")

  # Check if the other room has a matching pending
  THEIR_PENDING="$OTHER_ROOM/pending/${MSG_ID}.json"
  if [ -f "$THEIR_PENDING" ]; then
    THEIR_U=$(python3 -c "import json; print(json.load(open('$THEIR_PENDING'))['proposed_universe_time'])")
    # Fill in to_seq from whichever side has it
    THEIR_TO_SEQ=$(python3 -c "import json; v=json.load(open('$THEIR_PENDING'))['to_seq']; print(v if v else '')")
    if [ -z "$TO_SEQ_RAW" ]; then TO_SEQ="$THEIR_TO_SEQ"; else TO_SEQ="$TO_SEQ_RAW"; fi
    # Determine the actual recipient room name for the ledger
    if [ "$FROM_ROOM" = "$ROOM_NAME" ]; then ACTUAL_TO="$TO_ROOM_P"; else ACTUAL_TO="$ROOM_NAME"; fi

    if [ "$MY_U" -eq "$THEIR_U" ]; then
      # Agreement! Write to both ledgers.
      U_PADDED=$(printf "%06d" $MY_U)
      CONTENT_HASH=$(python3 -c "import json; d=json.load(open('$PENDING')); print(d.get('content_hash',''))" 2>/dev/null || echo "")

      for LEDGER_DIR in "$ROOM_DIR/ledger" "$OTHER_ROOM/ledger"; do
        cat > "$LEDGER_DIR/u-$U_PADDED.json" <<EOF
{
  "universe_time": $MY_U,
  "links": [
    {"room": "$FROM_ROOM", "seq": $FROM_SEQ},
    {"room": "$ACTUAL_TO", "seq": $TO_SEQ}
  ],
  "type": "message",
  "summary": "$MSG_ID",
  "content_hash": "$CONTENT_HASH",
  "agreed_by": ["$FROM_ROOM", "$ACTUAL_TO"],
  "agreed_at_wall": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
      done

      # Log agreement in both rooms
      "$ROOM_DIR/say.sh" "agreed" "$FROM_ROOM:$FROM_SEQ = $ACTUAL_TO:$TO_SEQ = U:$MY_U" > /dev/null

      # Remove from pending
      rm "$PENDING" "$THEIR_PENDING"
      AGREED=$((AGREED + 1))
      echo "Agreed: $FROM_ROOM:$FROM_SEQ = $ACTUAL_TO:$TO_SEQ = U:$MY_U"
    else
      # Disagreement — higher number wins (default rule)
      if [ "$MY_U" -gt "$THEIR_U" ]; then
        WINNER=$MY_U
      else
        WINNER=$THEIR_U
      fi
      echo "Disagreement on $MSG_ID (mine:$MY_U theirs:$THEIR_U). Higher wins: U:$WINNER"
      echo "  Run agree.sh again after updating proposals."
    fi
  else
    echo "Waiting for $OTHER_NAME on $MSG_ID (my proposal U:$MY_U)"
  fi
done

if [ "$AGREED" -eq 0 ]; then
  echo "No new agreements."
fi
