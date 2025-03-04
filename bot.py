import os
from flask import Flask, request
import telebot

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
bot = telebot.TeleBot(TOKEN)
app = Flask(__name__)

# Chemin d'écoute standard pour le webhook (au lieu d'utiliser le token dans l'URL)
WEBHOOK_PATH = "/webhook"

@app.route("/")
def home():
    return "Bot actif! ✅"

# Point d'entrée unique pour le webhook
@app.route(WEBHOOK_PATH, methods=["POST"])
def receive_update():
    if request.headers.get("content-type") == "application/json":
        update = telebot.types.Update.de_json(request.get_json())
        bot.process_new_updates([update])
        return "OK", 200
    return "Unsupported Media Type", 415

@bot.message_handler(commands=["start"])
def send_welcome(message):
    bot.reply_to(message, "Salut ! Je suis hébergé sur Koyeb 🚀")

@bot.message_handler(func=lambda msg: True)
def echo_all(message):
    bot.reply_to(message, f"Tu as dit : {message.text}")

def set_webhook():
    # URL du webhook = domaine Koyeb + chemin d'écoute
    webhook_url = f"https://isticharabot-[ORG].koyeb.app{WEBHOOK_PATH}"
    bot.remove_webhook()
    bot.set_webhook(url=webhook_url)
    print(f"Webhook configuré sur : {webhook_url}")

if __name__ == "__main__":
    set_webhook()
    app.run(host="0.0.0.0", port=8080)

