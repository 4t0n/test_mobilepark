#!/usr/bin/env bash
# Демонстрация подключения к PostgreSQL и Redis из ubuntu-worker.
# Скрипт должен запускаться на ноде, где работает контейнер.

set -euo pipefail

STACK_NAME="${1:-mp-stack}"
POSTGRES_HOST="${2:-postgres}"
REDIS_HOST="${3:-redis}"

CONTAINER_ID=$(docker ps --filter "name=${STACK_NAME}_ubuntu-worker" --format "{{.ID}}" | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Контейнер ${STACK_NAME}_ubuntu-worker не найден. Проверьте: docker stack ps ${STACK_NAME}"
    exit 1
fi

echo "Контейнер: ${CONTAINER_ID}"
echo ""

echo "=== Установка пакетов ==="
docker exec "$CONTAINER_ID" bash -c "
    apt-get update -qq &&
    apt-get install -y --no-install-recommends postgresql-client redis-tools &&
    echo 'Пакеты установлены'
"

echo ""

echo "=== PostgreSQL ==="
docker exec -e PGPASSWORD=mppassword "$CONTAINER_ID" \
    psql -h "$POSTGRES_HOST" -U mpuser -d mpdb -c "SELECT version();"

echo ""

echo "=== Redis ==="
docker exec "$CONTAINER_ID" redis-cli -h "$REDIS_HOST" PING

echo ""
echo "Для интерактивного подключения:"
echo "  docker exec -it ${CONTAINER_ID} bash"
