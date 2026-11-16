#!/bin/sh
# Сборка стенда с повторами: при обрыве сети пробует снова.
# Скачанные pip-пакеты и слои кэшируются, поэтому каждая попытка продолжает с места падения.
#   sh scripts/build.sh            — собрать всё
#   sh scripts/build.sh ml-api     — собрать конкретные сервисы
cd "$(dirname "$0")/.."
TRIES=${TRIES:-10}
i=1
while [ $i -le $TRIES ]; do
  echo "=== Попытка $i/$TRIES: $(date '+%H:%M:%S')"
  docker compose pull --ignore-buildable --ignore-pull-failures -q 2>/dev/null
  if docker compose build "$@"; then
    echo "=== Сборка завершена: $(date '+%H:%M:%S')"
    exit 0
  fi
  i=$((i + 1))
  sleep 15
done
echo "=== Не удалось собрать за $TRIES попыток"
exit 1
