# syntax=docker/dockerfile:1
# Сборка подсистемы креативности для объединённого стенда.
# Отличия от subsystems/creativity/Dockerfile:
#   - PyTorch ставится CPU-версией (~200 МБ вместо 3–4 ГБ CUDA-библиотек), GPU здесь не используется;
#   - кэш pip сохраняется между сборками, повтор после обрыва сети не качает всё заново.
FROM python:3.11-slim
ENV PIP_DEFAULT_TIMEOUT=120 PIP_RETRIES=10 PIP_DISABLE_PIP_VERSION_CHECK=1
WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install torch --index-url https://download.pytorch.org/whl/cpu
COPY requirements.txt .
# kombu не закреплён в requirements.txt, а свежий kombu требует redis-py >= 6.1,
# тогда как там закреплён redis==5.0 → celery-worker падает с VersionMismatch.
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt "kombu>=5.3,<5.5"
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install https://github.com/explosion/spacy-models/releases/download/ru_core_news_sm-3.7.0/ru_core_news_sm-3.7.0-py3-none-any.whl
COPY . .
