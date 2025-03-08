#!/bin/bash
echo "Starting entrypoint.sh"
cat <<EOF > /app/credentials_temp.yml
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "https://isticharabot-isticharachat.koyeb.app/webhooks/telegram/webhook"
EOF
echo "Launching Rasa in background"
rasa run --enable-api --cors "*" --port 5005 --connector telegram --credentials /app/credentials_temp.yml --model models/model.tar.gz &
echo "Waiting for Rasa to be ready on port 5005..."
until curl -s http://localhost:5005/ > /dev/null; do
  echo "Still waiting for Rasa..."
  sleep 5
done
echo "Rasa is running now"
wait
