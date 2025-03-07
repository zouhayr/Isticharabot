#!/bin/bash
# Écrire les variables dans un fichier de débogage
echo "TELEGRAM_BOT_TOKEN: $TELEGRAM_BOT_TOKEN" > /tmp/debug.log
echo "TELEGRAM_BOT_NAME: $TELEGRAM_BOT_NAME" >> /tmp/debug.log

# Créer un credentials.yml temporaire avec les valeurs substituées
cat <<EOF > /app/credentials_temp.yml
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "TEMPORAIRE"  # À remplacer par l’URL finale
EOF

# Lancer Rasa avec le fichier temporaire
exec rasa run --enable-api --cors "*" --port 5005 --connector telegram --credentials /app/credentials_temp.yml
