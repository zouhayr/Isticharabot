#!/bin/bash

set -e  # Arrêter sur erreur
set -x  # Activer le mode débogage pour voir les commandes

echo "Starting entrypoint.sh"

# Écriture des credentials
cat <<EOF > /app/credentials_temp.yml
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "https://isticharabot-isticharachat.koyeb.app/webhooks/telegram/webhook"
EOF

echo "Credentials written to /app/credentials_temp.yml:"
cat /app/credentials_temp.yml

echo "Launching Rasa in background"

# Démarrer Rasa avec logging
rasa run \
  --enable-api \
  --cors "*" \
  --port 8080 \
  --connector telegram \
  --credentials /app/credentials_temp.yml \
  --model models/model.tar.gz \
  > /app/rasa.log 2>&1 &

RASA_PID=$!
echo "Rasa PID: $RASA_PID"

echo "Waiting for Rasa to be ready on port 8080..."

# Délai initial pour laisser Rasa démarrer
sleep 10  # Ajuster selon les besoins du modèle

# Vérification améliorée avec timeout aligné sur Koyeb (120s)
MAX_RETRIES=24  # 24 x 5s = 120s
RETRY_COUNT=0

until curl -s -f http://localhost:8080/ > /app/rasa_response.log 2>/app/curl_debug.log
do
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Timeout: Rasa n'a pas démarré après $((MAX_RETRIES * 5)) secondes"
    echo "Derniers logs Rasa :"
    tail -n 100 /app/rasa.log 2>/dev/null || echo "Aucun log disponible"
    exit 1
  fi

  echo "Still waiting for Rasa... (attempt $((RETRY_COUNT+1)))"
  ((RETRY_COUNT++))

  # Afficher les logs si disponibles
  if [ -f /app/rasa.log ]; then
    tail -n 20 /app/rasa.log
  else
    echo "Aucun log Rasa disponible pour l'instant"
  fi
  sleep 5
done

echo "Rasa is running now - Response from curl:"
curl -s http://localhost:8080/

wait $RASA_PID
