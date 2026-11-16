#!/bin/sh
# Windows: перевыкачать сабмодули с LF-переводами строк (иначе shell-скрипты в Linux-контейнерах не запускаются).
# Внимание: незакоммиченные изменения внутри сабмодулей будут потеряны.
set -e
cd "$(dirname "$0")/.."
git config core.autocrlf false
git submodule foreach --quiet 'git config core.autocrlf false && git rm -q --cached -r . && git reset -q --hard && echo "$sm_path: ok"'
