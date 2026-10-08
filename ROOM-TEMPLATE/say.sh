#!/bin/bash
# say.sh — log an internal event to this room's active log
# Usage: ./say.sh <type> "<content>"
# Example: ./say.sh think "I think we should go north."

ROOM_DIR="$(cd "$(dirname "$0")" && pwd)"
TYPE="$1"
CONTENT="$2"

if [ -z "$TYPE" ] || [ -z "$CONTENT" ]; then
  echo "Usage: ./say.sh <type> \"<content>\""
  exit 1
fi

SEQ=$(cat "$ROOM_DIR/seq")
NEXT=$((SEQ + 1))
SEQ_PADDED=$(printf "%06d" $NEXT)
WALL=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ "$SEQ" -eq 0 ]; then
  PREV="genesis"
else
  PREV_PADDED=$(printf "%06d" $SEQ)
  PREV=$(python3 -c "import json; print(json.load(open('$ROOM_DIR/log/$PREV_PADDED.json'))['hash'])" 2>/dev/null || echo "genesis")
fi

HASH=$(echo -n "${NEXT}${WALL}${TYPE}${CONTENT}${PREV}" | sha256sum | cut -d' ' -f1 | cut -c1-12)

cat > "$ROOM_DIR/log/$SEQ_PADDED.json" <<EOF
{
  "seq": $NEXT,
  "wall": "$WALL",
  "type": "$TYPE",
  "content": "$CONTENT",
  "prev": "$PREV",
  "hash": "$HASH"
}
EOF

echo "$NEXT" > "$ROOM_DIR/seq"
echo "Logged seq $NEXT ($TYPE)"
