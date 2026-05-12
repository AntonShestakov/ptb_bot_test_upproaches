#!/bin/bash
RETRIES=5
DELAY=5

for i in $(seq 1 $RETRIES); do
  STATUS=$(docker inspect --format='{{.State.Running}}' telegram-bot-prod 2>/dev/null || echo "false")
  if [ "$STATUS" = "true" ]; then
    echo "✅ Bot container is running"
    exit 0
  fi
  echo "⏳ Attempt $i/$RETRIES — waiting..."
  sleep $DELAY
done

echo "❌ Bot did not start in time"
exit 1