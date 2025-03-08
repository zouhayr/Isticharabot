#!/bin/bash
# Afficher les variables pour le débogage (visible dans les logs Koyeb)
echo "TELEGRAM_BOT_TOKEN: $TELEGRAM_BOT_TOKEN"
echo "TELEGRAM_BOT_NAME: $TELEGRAM_BOT_NAME"
echo "Listing files in /app/models:"
ls -la /app/models/

# Créer un credentials.yml temporaire avec les valeurs substituées
cat <<EOF > /app/credentials_temp.yml
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "https://isticharabot-isticharachat.koyeb.app/webhooks/telegram/webhook"
EOF

# Lancer Rasa avec le modèle et le fichier temporaire
exec rasa run --enable-api --cors "*" --port 5005 --connector telegram --credentials /app/credentials_temp.yml --model models/model.tar.gz
