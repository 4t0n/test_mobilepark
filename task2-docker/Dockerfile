# Исходный файл:
#   FROM python
#   WORKDIR /app
#   COPY . .
#   RUN pip install -r requirements.txt
#   EXPOSE 5000
#   CMD ["python", "app.py"]

FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --upgrade pip --no-cache-dir && \
    pip install --user --no-cache-dir -r requirements.txt


FROM python:3.12-slim

RUN groupadd --gid 1100 appgroup && \
    useradd --uid 1100 --gid appgroup --no-create-home --shell /bin/false appuser

WORKDIR /app

COPY --from=builder --chown=appuser:appgroup /root/.local /home/appuser/.local

COPY . .

RUN chown -R appuser:appgroup /app

USER appuser

ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

EXPOSE 5000

HEALTHCHECK --interval=30s \
            --timeout=5s \
            --start-period=10s \
            --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

CMD ["python", "app.py"]
