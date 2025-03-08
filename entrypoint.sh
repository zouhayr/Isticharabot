#!/bin/bash
echo "Starting entrypoint.sh"
cat <<EOF > /app/credentials_temp.yml
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "https://isticharabot-isticharachat.koyeb.app/webhooks/telegram/webhook"
EOF
echo "Credentials written to /app/credentials_temp.yml:"
cat /app/credentials_temp.yml
echo "Launching Rasa in background"
rasa run --enable-api --cors "*" --port 5005 --connector telegram --credentials /app/credentials_temp.yml --model models/model.tar.gz &
RASA_PID=$!
echo "Rasa PID: $RASA_PID"
echo "Waiting for Rasa to be ready on port 5005..."
until curl -s -v http://localhost:5005/ > /dev/null 2>/app/curl_debug.log; do
  echo "Still waiting for Rasa..."
  echo "Current curl debug output:"
  cat /app/curl_debug.log
  sleep 5
done
echo "Rasa is running now - Response from curl:"
curl -s http://localhost:5005/
wait $RASA_PID
