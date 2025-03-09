#!/bin/bash

set -e  # Arrêter sur erreur
set -x  # Activer le mode débogage pour voir les commandes

echo "Starting entrypoint.sh"

# Utiliser /tmp/rasa_logs pour éviter les problèmes de permissions
LOG_DIR=/tmp/rasa_logs
mkdir -p "$LOG_DIR"

# Vérifier si les variables d'environnement sont définies
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_BOT_NAME" ]; then
  echo "Erreur : TELEGRAM_BOT_TOKEN ou TELEGRAM_BOT_NAME non défini."
  exit 1
fi

# Écriture des credentials
cat <<EOF > "$LOG_DIR/credentials_temp.yml"
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "https://isticharabot-isticharachat.koyeb.app/webhooks/telegram/webhook"
EOF

echo "Credentials written to $LOG_DIR/credentials_temp.yml:"
cat "$LOG_DIR/credentials_temp.yml"

echo "Launching Rasa in background"

# Démarrer Rasa avec logging
rasa run \
  --enable-api \
  --cors "*" \
  --port 8080 \
  --connector telegram \
  --credentials "$LOG_DIR/credentials_temp.yml" \
  --model models/model.tar.gz \
  > "$LOG_DIR/rasa.log" 2>&1 &

RASA_PID=$!
echo "Rasa PID: $RASA_PID"

echo "Waiting for Rasa to be ready on port 8080..."

# Délai initial pour laisser Rasa démarrer
sleep 10

# Vérification améliorée avec timeout aligné sur Koyeb (180s)
MAX_RETRIES=36  # 36 x 5s = 180s
RETRY_COUNT=0

until curl -s -f http://localhost:8080/ > "$LOG_DIR/rasa_response.log" 2>"$LOG_DIR/curl_debug.log"
do
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Timeout: Rasa n'a pas démarré après $((MAX_RETRIES * 5)) secondes"
    echo "Derniers logs Rasa :"
    tail -n 100 "$LOG_DIR/rasa.log" 2>/dev/null || echo "Aucun log disponible"
    exit 1
  fi

  echo "Still waiting for Rasa... (attempt $((RETRY_COUNT+1)))"
  ((RETRY_COUNT++))

  # Afficher les logs si disponibles
  if [ -f "$LOG_DIR/rasa.log" ]; then
    tail -n 20 "$LOG_DIR/rasa.log"
  else
    echo "Aucun log Rasa disponible pour l'instant"
  fi
  sleep 5
done

echo "Rasa is running now - Response from curl:"
curl -s http://localhost:8080/

wait $RASA_PID
