import os
from flask import Flask, request
import telebot

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
bot = telebot.TeleBot(TOKEN)
app = Flask(__name__)

WEBHOOK_PATH = "/webhook"
WEBHOOK_URL = f"https://isticharabot-isticharachat.koyeb.app{WEBHOOK_PATH}"

@app.route("/")
def home():
    return "Bot actif! ✅"

@app.route("/webhook", methods=["POST"])  # ✅ Assurez-vous que "methods" est bien écrit
def receive_update():
    if request.headers.get("content-type") == "application/json":
        update = telebot.types.Update.de_json(request.get_json())
        bot.process_new_updates([update])
        return "OK", 200
    return "Unsupported Media Type", 415

@app.route("/set_webhook", methods=["GET"])
def set_webhook():
    success = bot.set_webhook(url=WEBHOOK_URL)
    if success:
        return f"Webhook configuré avec succès sur : {WEBHOOK_URL}", 200
    else:
        return "Échec de la configuration du webhook", 500

@bot.message_handler(commands=["start"])
def send_welcome(message):
    bot.reply_to(message, "Salut ! Je suis hébergé sur Koyeb 🚀")

@bot.message_handler(func=lambda msg: True)
def echo_all(message):
    bot.reply_to(message, f"Tu as dit : {message.text}")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)


