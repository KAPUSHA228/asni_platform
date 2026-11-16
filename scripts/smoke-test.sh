#!/bin/sh
# Проверка, что после `docker compose up` все точки входа отвечают.
cd "$(dirname "$0")/.."
[ -f .env ] && . ./.env
check() { code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$2"); printf '%-28s %s  %s\n' "$1" "$code" "$2"; }
login() {
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -H 'Content-Type: application/json' \
    -d "{\"username\":\"${ADMIN_DEFAULT_USERNAME:-admin}\",\"password\":\"${ADMIN_DEFAULT_PASSWORD:-Admin@1234!}\"}" "$1")
  printf '%-28s %s  POST %s\n' "gateway (admin login)" "$code" "$1"
}
check "landing"            "http://localhost:${LANDING_PORT:-80}/"
login                      "http://localhost:${GATEWAY_PORT:-8080}/api/v1/auth/login"
check "ml frontend"        "http://localhost:${ML_PORT:-8101}/"
check "ml api health"      "http://localhost:${ML_PORT:-8101}/health"
check "creativity"         "http://localhost:${CREATIVITY_PORT:-8102}/"
check "survey constructor" "http://localhost:${SURVEY_PORT:-8103}/"
check "survey api health"  "http://localhost:${SURVEY_PORT:-8103}/healthz"
