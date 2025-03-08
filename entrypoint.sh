#!/bin/bash
echo "Starting entrypoint.sh"
cat <<EOF > /app/credentials_temp.yml
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "https://isticharabot-isticharachat.koyeb.app/webhooks/telegram/webhook"
EOF
# Lancer Rasa en arrière-plan
rasa run --enable-api --cors "*" --port 5005 --connector telegram --credentials /app/credentials_temp.yml --model models/model.tar.gz &
# Attendre que Rasa soit prêt
echo "Waiting for Rasa to start on port 5005..."
sleep 15  # Attend 15 secondes pour le chargement complet
echo "Rasa should be running now"
# Maintenir le processus en vie
wait
