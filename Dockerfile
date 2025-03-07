FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir torch==2.0.0+cpu -f https://download.pytorch.org/whl/torch_stable.html \
    && pip install --no-cache-dir -r requirements.txt
COPY . .
ENV TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
ENV TELEGRAM_BOT_NAME=$TELEGRAM_BOT_NAME
RUN chmod +x entrypoint.sh
CMD ["./entrypoint.sh"]
