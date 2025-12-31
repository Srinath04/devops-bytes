# Dockerfile (inside guess-game-amd64)
FROM --platform=linux/amd64 python:3.11

WORKDIR /app

COPY app.py .

RUN pip install flask

EXPOSE 5000

CMD ["python", "app.py"]
