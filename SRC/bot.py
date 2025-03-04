import os
import telebot
from flask import Flask, request

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
bot = telebot.TeleBot(TOKEN)
app = Flask(__name__)

@app.route("/")
def home():
    return "Le bot fonctionne ! 🚀"

@app.route(f"/{TOKEN}", methods=["POST"])
def receive_update():
    update = request.get_json()
    if update:
        bot.process_new_updates([telebot.types.Update.de_json(update)])
    return "OK", 200

@bot.message_handler(commands=["start"])
def send_welcome(message):
    bot.reply_to(message, "Bienvenue ! Je suis un bot Telegram hébergé sur Koyeb.")

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    bot.reply_to(message, message.text)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
