#!/bin/bash

echo "Starting entrypoint.sh"
LOG_DIR=/tmp/rasa_logs
mkdir -p $LOG_DIR

# Vérifier l'existence du modèle
echo "Vérification du chemin du modèle..."
if [ -f "/app/models/model.tar.gz" ]; then
    echo "Fichier /app/models/model.tar.gz trouvé."
    tar -tzf /app/models/model.tar.gz > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Archive /app/models/model.tar.gz est valide."
    else
        echo "Erreur : /app/models/model.tar.gz est corrompu ou invalide."
    fi
else
    echo "Erreur : /app/models/model.tar.gz n'existe pas."
    ls -l /app/models/ || echo "Dossier /app/models/ introuvable."
    find / -name model.tar.gz 2>/dev/null || echo "Fichier model.tar.gz introuvable dans le conteneur."
    exit 1
fi

# Écrire les identifiants Telegram
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_BOT_NAME" ]; then
    echo "Erreur : Variables d'environnement TELEGRAM_BOT_TOKEN ou TELEGRAM_BOT_NAME manquantes"
    exit 1
fi
cat << EOF > $LOG_DIR/credentials_temp.yml
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "https://isticharabot-isticharachat.koyeb.app/webhooks/telegram/webhook"
EOF
echo "Credentials written to $LOG_DIR/credentials_temp.yml:"
cat $LOG_DIR/credentials_temp.yml

# Lancer Rasa avec redirection des logs
echo "Launching Rasa in background"
rasa run --log-level DEBUG --enable-api --cors '*' --port 5005 --connector telegram --credentials $LOG_DIR/credentials_temp.yml --model /app/models/model.tar.gz > $LOG_DIR/rasa_output.log 2>&1 &
RASA_PID=$!
echo "Rasa PID: $RASA_PID"

# Attendre que Rasa soit prêt
echo "Waiting for Rasa to be ready on port 5005..."
sleep 10

# Vérifier la disponibilité avec un nombre limité de tentatives
MAX_RETRIES=36
RETRY_COUNT=0
until curl -s -f http://localhost:5005/ || [ $RETRY_COUNT -ge $MAX_RETRIES ]; do
    echo "Still waiting for Rasa... (attempt $((RETRY_COUNT+1)))"
    sleep 5
    ((RETRY_COUNT++))
done

if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Erreur : Rasa n'est pas prêt après $MAX_RETRIES tentatives"
    cat $LOG_DIR/rasa_output.log
    exit 1
fi

echo "Rasa is running!"
tail -f $LOG_DIR/rasa_output.log
