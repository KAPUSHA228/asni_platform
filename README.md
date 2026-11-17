# ASNI Platform

Umbrella repository for **ASNI** (Automated System for Scientific Research, UNN Faculty of Social Sciences).

Each subsystem lives in its own repository and is included here as a **git submodule**.
This repository contains only what is needed to run them together: a single Docker Compose
stack, build overrides, helper scripts and integration docs. **Subsystem code is never edited here.**

## Subsystems

Submodules point to forks under [KAPUSHA228](https://github.com/KAPUSHA228); the original
repositories are listed as *upstream*.

| Subsystem | Path | Submodule (fork) | Upstream | Stack |
|---|---|---|---|---|
| Academic risk monitoring (ML) | `subsystems/ml-risk` | [diplom](https://github.com/KAPUSHA228/diplom) | — (original) | FastAPI, Ray, React |
| Creativity analysis | `subsystems/creativity` | [creativity-analysis-subsystem](https://github.com/KAPUSHA228/creativity-analysis-subsystem) | [ermilovad](https://github.com/ermilovad/creativity-analysis-subsystem) | Django, Celery, spaCy, sentence-transformers |
| Survey constructor | `subsystems/survey-constructor` | [survey-constructor-service](https://github.com/KAPUSHA228/survey-constructor-service) | [sanya2905](https://github.com/sanya2905/survey-constructor-service) | FastAPI, React, SurveyJS |
| Data loading (desktop) | `subsystems/data-loading` | [DataLoadingSubsystemFX](https://github.com/KAPUSHA228/DataLoadingSubsystemFX) | [KaterinaKaraseva](https://github.com/KaterinaKaraseva/DataLoadingSubsystemFX) | JavaFX 17, Maven |
| ASNI auth | `subsystems/asni/auth-service` | [auth-service](https://github.com/KAPUSHA228/auth-service) | [ASNI-UNN](https://github.com/ASNI-UNN/auth-service) | Java 21, Spring Boot |
| ASNI API gateway | `subsystems/asni/gateway-service` | [gateway-service](https://github.com/KAPUSHA228/gateway-service) | [ASNI-UNN](https://github.com/ASNI-UNN/gateway-service) | Spring Cloud Gateway |
| ASNI surveys | `subsystems/asni/survey-service` | [survey-service](https://github.com/KAPUSHA228/survey-service) | [ASNI-UNN](https://github.com/ASNI-UNN/survey-service) | Java 21, Spring Boot |
| ASNI data storage | `subsystems/asni/data-storage-service` | [data-storage-service](https://github.com/KAPUSHA228/data-storage-service) | [ASNI-UNN](https://github.com/ASNI-UNN/data-storage-service) | Java 21, Spring Boot |
| ASNI analytics | `subsystems/asni/analytics-service` | [analytics-service](https://github.com/KAPUSHA228/analytics-service) | [ASNI-UNN](https://github.com/ASNI-UNN/analytics-service) | Java 21, Spring Boot |

## Requirements

- Git
- Docker Desktop (Docker Compose v2.20+)
- ~16 GB RAM, ~20 GB free disk space
- For the desktop client only: JDK 17+ and Maven 3.9+

## Quick start

```bash
git clone --recurse-submodules https://github.com/KAPUSHA228/asni_platform.git
cd asni_platform
cp .env.example .env
sh scripts/build.sh          # build all images (retries on network errors)
docker compose up -d
sh scripts/smoke-test.sh     # check that every entry point responds
```

The first build downloads several GB of dependencies and can take from ~20 minutes
to a few hours depending on your connection. Subsequent builds use the cache.

> **Windows users:** clone with `core.autocrlf=false`, otherwise Git converts `gradlew`
> and `entrypoint.sh` to CRLF line endings and the build fails with `./gradlew: not found`:
> ```bash
> git -c core.autocrlf=false clone --recurse-submodules https://github.com/KAPUSHA228/asni_platform.git
> ```
> Already cloned? Run `sh scripts/fix-line-endings.sh` (Git Bash).

Cloned without `--recurse-submodules`? Run:

```bash
git submodule update --init --recursive
```

## Entry points

| Service | URL |
|---|---|
| Landing page (links to everything) | http://localhost |
| ASNI API gateway | http://localhost:8080/api/v1/… |
| Academic risk monitoring (ML) | http://localhost:8101 |
| Creativity analysis | http://localhost:8102 |
| Survey constructor | http://localhost:8103 |
| Ray dashboard | http://localhost:8265 |

Default ASNI admin: `admin` / `Admin@1234!` (change in `.env`).

Ports, secrets and Ray CPU count are configured in `.env` (see `.env.example`).

To run only part of the stack, name the services, dependencies start automatically:

```bash
docker compose up -d survey-frontend      # survey constructor only
docker compose up -d gateway-service      # Java backend only
```

### Data loading (JavaFX desktop client)

Not containerized, it is a desktop application:

```bash
cd subsystems/data-loading
mvn clean javafx:run
```

## Useful commands

```bash
docker compose ps                    # status of all containers
docker compose logs -f survey-api    # follow logs of one service
docker compose logs -f --tail 50     # follow logs of everything
docker compose down                  # stop the stack (data is kept in volumes)
docker compose down -v               # stop and DELETE all databases
```

## Repository layout

```
asni_platform/
├── subsystems/                 # git submodules (subsystem source code)
│   ├── ml-risk/
│   ├── creativity/
│   ├── survey-constructor/
│   ├── data-loading/
│   └── asni/{auth,gateway,survey,data-storage,analytics}-service/
├── docker/                     # build overrides for this stack
│   ├── creativity.Dockerfile
│   └── ml-api.Dockerfile
├── landing/                    # landing page served on :80
├── scripts/
│   ├── build.sh                # build with automatic retries
│   ├── smoke-test.sh           # check all entry points
│   ├── update-submodules.sh    # bump subsystems to their latest commits
│   └── fix-line-endings.sh     # Windows CRLF fix for submodules
├── docker-compose.yml
└── .env.example
```

## Working with submodules

Every submodule is pinned to a specific commit, so a push to a subsystem repository
never breaks this stack by itself.

- **Update all subsystems to their latest version:**
  ```bash
  sh scripts/update-submodules.sh
  sh scripts/build.sh && docker compose up -d && sh scripts/smoke-test.sh
  git add subsystems && git commit -m "chore: bump subsystems"
  ```
- **Change a subsystem's code:** commit and push in *that subsystem's* fork
  (`cd subsystems/<name>`, regular git workflow), then bump the pointer here as above.
  To get the change into the original repository, open a pull request from the fork to upstream.
- **Pull new changes from the original authors into a fork:** on GitHub, open the fork and click
  **Sync fork → Update branch**, then run `sh scripts/update-submodules.sh` here. Or from the command line:
  ```bash
  cd subsystems/creativity
  git remote add upstream https://github.com/ermilovad/creativity-analysis-subsystem.git  # once
  git fetch upstream && git merge upstream/main && git push origin main
  ```
- **Don't patch subsystem code from this repository.** Anything needed for the subsystems
  to run together (service names, ports, env vars) is overridden in `docker-compose.yml`.

## How the integration works

- All services share one Docker network. Only entry points are published to the host.
- Each subsystem keeps its own database and Redis. Name clashes between the original
  compose files are resolved by renaming (`ml-redis`, `creativity-db`, `constructor-db`, …).
  Service names that subsystem configs depend on (`ml-api`, `ray-head`, `survey-api`) are kept.
- The survey constructor reaches creativity analysis at `http://creative-mfe:8000`
  (network alias of `creativity-web`), as its code expects.
- Java ASNI services share a single `JWT_SECRET`.
- Build overrides in `docker/` (subsystem Dockerfiles are not modified):
  - **creativity**: installs CPU-only PyTorch (~200 MB instead of 3–4 GB of CUDA libraries;
    no GPU is used), caches pip downloads between builds, and pins `kombu<5.5`. The upstream
    `requirements.txt` pins `redis==5.0`, but the latest kombu requires `redis>=6.1`, which makes
    the Celery worker crash on startup.
  - **ml-api**: same as upstream `Dockerfile.api` plus a pip cache and longer timeouts, so a
    retry after a network failure does not re-download everything.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `./gradlew: not found` or `entrypoint.sh: not found` during build | CRLF line endings on Windows → `sh scripts/fix-line-endings.sh` |
| Build fails with a timeout or `connection reset` | Network issue → re-run `sh scripts/build.sh`; downloads are cached, it resumes |
| `port is already allocated` | Change the port in `.env` |
| A container keeps restarting | `docker compose logs <service>` |

## Roadmap

1. ✅ Umbrella repository with submodules, one-command `docker compose up`.
2. ⬜ Single entry point: one reverse proxy, subsystems under `/ml/`, `/creativity/`, `/surveys/`.
   Requires `base` in Vite configs and `FORCE_SCRIPT_NAME` in Django (PRs to subsystem repos).
3. ⬜ Single sign-on via `auth-service` (JWT). The survey constructor already supports
   `PROXY_AUTH_ENABLED` for running behind a trusted proxy.
4. ⬜ Resolve overlaps: Java `survey-service` vs survey constructor; `data-storage-service` vs
   the data loading client (replace its `ApiClient` stub with `/api/v1/datasets`).
5. ⬜ Data flows: survey responses → ML analysis and creativity analysis.
6. ⬜ CI: build the whole stack and run the smoke test on every PR; publish images to GHCR
   so users can `docker compose pull` instead of building.
