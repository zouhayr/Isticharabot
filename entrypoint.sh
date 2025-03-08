#!/bin/bash
set -x  # Affiche chaque commande avant exécution pour débogage
echo "Starting entrypoint.sh"
echo "Current directory: $(/bin/pwd)"
echo "TELEGRAM_BOT_TOKEN: $TELEGRAM_BOT_TOKEN"
echo "TELEGRAM_BOT_NAME: $TELEGRAM_BOT_NAME"
echo "Listing files in /app:"
/bin/ls -la /app
echo "Listing files in /app/models:"
/bin/ls -la /app/models || echo "Error: /app/models not found"
echo "Creating credentials_temp.yml"
/bin/cat <<EOF > /app/credentials_temp.yml
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "https://isticharabot-isticharachat.koyeb.app/webhooks/telegram/webhook"
EOF
echo "Credentials file created, content:"
/bin/cat /app/credentials_temp.yml
echo "Launching Rasa"
/usr/local/bin/rasa run --enable-api --cors "*" --port 5005 --connector telegram --credentials /app/credentials_temp.yml --model models/model.tar.gz
