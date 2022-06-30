FROM python:3.7.4-slim-buster

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

ENTRYPOINT gunicorn --log-level debug api:app -b 0.0.0.0:5000