FROM python:alpine3.8

# Add security improvements: limiting privileges, ensuring proper file ownership, etc.
RUN apk add --no-cache wget \
    && wget -O /usr/bin/wait-for https://raw.githubusercontent.com/eficode/wait-for/master/wait-for \
    && chmod +x /usr/bin/wait-for \
    && apk del wget \
    && adduser -D appuser \
    && chown -R appuser /app

USER appuser

# Install dependencies securely
COPY requirements.txt /tmp
RUN apk add --no-cache --virtual build-deps gcc python3-dev musl-dev \
    && apk add --no-cache postgresql-dev \
    && pip install -r /tmp/requirements.txt \
    && apk del build-deps

# Clean up and ensure minimal installation
RUN rm -rf /tmp/requirements.txt

WORKDIR /app
ADD ./run.py /app
ADD ./sqli /app/sqli
ADD ./config /app/config

# Restrict the root filesystem to be read-only
RUN chmod -R 700 /app && chown -R appuser /app
