#!/bin/sh
# Подтянуть свежие коммиты всех подсистем (ветки по умолчанию) и показать, что изменилось.
# После проверки: git add subsystems && git commit -m "chore: bump subsystems"
set -e
cd "$(dirname "$0")/.."
git submodule update --init --recursive
git submodule update --remote --recursive
git submodule status
git status --short subsystems
