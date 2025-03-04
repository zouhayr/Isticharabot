# Utiliser une image Python officielle comme base
FROM python:3.10

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers du projet dans le conteneur
COPY . .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Exposer le port utilisé par Flask
EXPOSE 8080

# Lancer le bot
CMD ["python", "bot.py"]
