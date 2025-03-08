#!/bin/bash
echo "Starting entrypoint.sh"
cat <<EOF > /app/credentials_temp.yml
telegram:
  access_token: "$TELEGRAM_BOT_TOKEN"
  verify: "$TELEGRAM_BOT_NAME"
  webhook_url: "https://isticharabot-isticharachat.koyeb.app/webhooks/telegram/webhook"
EOF
exec rasa run --enable-api --cors "*" --port 5005 --connector telegram --credentials /app/credentials_temp.yml --model models/model.tar.gz
