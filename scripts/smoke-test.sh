#!/bin/sh
# Проверка, что после `docker compose up` все точки входа отвечают.
[ -f .env ] && . ./.env
check() { code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$2"); printf '%-28s %s  %s\n' "$1" "$code" "$2"; }
check "landing"            "http://localhost:${LANDING_PORT:-80}/"
check "gateway (login)"    "http://localhost:${GATEWAY_PORT:-8080}/api/v1/auth/login"
check "ml frontend"        "http://localhost:${ML_PORT:-8101}/"
check "ml api health"      "http://localhost:${ML_PORT:-8101}/health"
check "creativity"         "http://localhost:${CREATIVITY_PORT:-8102}/"
check "survey constructor" "http://localhost:${SURVEY_PORT:-8103}/"
check "survey api health"  "http://localhost:${SURVEY_PORT:-8103}/healthz"
