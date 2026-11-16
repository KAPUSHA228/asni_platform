# syntax=docker/dockerfile:1
# Сборка ML API (KAPUSHA228/diplom) для объединённого стенда.
# Повторяет subsystems/ml-risk/Dockerfile.api, но с кэшем pip между сборками
# и увеличенными таймаутами — чтобы повтор после обрыва сети не качал всё заново.
FROM python:3.11-slim AS builder
ENV PIP_DEFAULT_TIMEOUT=120 PIP_RETRIES=10 PIP_DISABLE_PIP_VERSION_CHECK=1
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ make cmake curl && \
    rm -rf /var/lib/apt/lists/*
COPY requirements_base.txt requirements_api.txt ./
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --user --no-warn-script-location -r requirements_api.txt

FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /root/.local /root/.local
COPY . .
RUN mkdir -p models logs/drift_reports experiments analysis_data/synthetic analysis_data/monitoring /app/ray_temp
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONPATH=/app
EXPOSE 8000
CMD ["uvicorn", "api.gateway.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
