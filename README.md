# АСНИ — объединённая платформа

Зонтичный репозиторий **Автоматизированной системы научных исследований** (ФСН ННГУ).
Каждая подсистема живёт в своём репозитории и подключена сюда как git-сабмодуль;
здесь — только общий запуск, конфигурация и документация по интеграции.

## Состав

| Подсистема | Путь | Репозиторий | Стек |
|---|---|---|---|
| Мониторинг академических рисков (ML) | `subsystems/ml-risk` | [KAPUSHA228/diplom](https://github.com/KAPUSHA228/diplom) | FastAPI, Ray, React |
| Анализ креативности | `subsystems/creativity` | [ermilovad/creativity-analysis-subsystem](https://github.com/ermilovad/creativity-analysis-subsystem) | Django, Celery, spaCy |
| Конструктор анкет | `subsystems/survey-constructor` | [sanya2905/survey-constructor-service](https://github.com/sanya2905/survey-constructor-service) | FastAPI, React, SurveyJS |
| Загрузка данных (десктоп) | `subsystems/data-loading` | [KaterinaKaraseva/DataLoadingSubsystemFX](https://github.com/KaterinaKaraseva/DataLoadingSubsystemFX) | JavaFX 17, Maven |
| АСНИ backend: auth, gateway, survey, data-storage, analytics | `subsystems/asni/*` | [ASNI-UNN](https://github.com/ASNI-UNN) | Java 21, Spring Boot |

## Быстрый старт

Нужны Git и Docker Desktop (Compose v2). Для полной сборки — ~16 ГБ RAM и ~20 ГБ диска
(Ray, sentence-transformers и Java-сборки тяжёлые).

```bash
git clone --recurse-submodules https://github.com/KAPUSHA228/asni-platform.git
cd asni-platform
cp .env.example .env
docker compose up -d --build
sh scripts/smoke-test.sh
```

> **Windows:** клонируйте с `-c core.autocrlf=false`, иначе Git переведёт `gradlew` и
> `entrypoint.sh` в CRLF и сборка упадёт с `./gradlew: not found`:
> ```bash
> git -c core.autocrlf=false clone --recurse-submodules https://github.com/KAPUSHA228/asni-platform.git
> ```
> Если уже склонировано: `sh scripts/fix-line-endings.sh`.

Если репозиторий склонирован без `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

| Что | Адрес |
|---|---|
| Стартовая страница | http://localhost |
| API АСНИ (gateway) | http://localhost:8080/api/v1/… |
| Мониторинг рисков (ML) | http://localhost:8101 |
| Анализ креативности | http://localhost:8102 |
| Конструктор анкет | http://localhost:8103 |
| Ray dashboard | http://localhost:8265 |

Порты меняются в `.env`. Запуск части стенда: `docker compose up -d survey-frontend`
(зависимости поднимутся сами).

### Загрузка данных (JavaFX)

Десктоп-клиент, в Docker не запускается:

```bash
cd subsystems/data-loading
mvn clean javafx:run
```

## Работа с сабмодулями

Каждый сабмодуль зафиксирован на конкретном коммите — стенд не сломается от
случайного пуша в репозиторий подсистемы.

- **Обновить все подсистемы до свежих версий:** `sh scripts/update-submodules.sh`,
  проверить, затем `git add subsystems && git commit -m "chore: bump subsystems"`.
- **Изменить код подсистемы:** коммит и пуш делаются в *её* репозиторий
  (`cd subsystems/<name>`, обычный git), а здесь потом обновляется ссылка на коммит.
- **Код подсистем в этом репозитории не правится.** Всё, что нужно для совместной
  работы (имена, порты, переменные), переопределяется в `docker-compose.yml`.

## Как устроено объединение

- Все сервисы в одной Docker-сети, наружу опубликованы только точки входа.
- У каждой подсистемы своя БД и свой Redis. Конфликты имён исходных compose-файлов
  разрешены переименованием (`ml-redis`, `creativity-db`, `constructor-db`, …).
- Конструктор анкет обращается к анализу креативности по `http://creative-mfe:8000`
  (сетевой алиас `creativity-web`).
- Java-сервисы АСНИ используют общий `JWT_SECRET`.

## Дорожная карта интеграции

1. ✅ Зонтичный репозиторий с сабмодулями, общий `docker compose up`.
2. ⬜ Единая точка входа (один nginx, подсистемы по путям `/ml/`, `/creativity/`, `/surveys/`).
   Требует `base` во vite-конфигах и `FORCE_SCRIPT_NAME` в Django — PR в репозитории подсистем.
3. ⬜ Единая авторизация через `auth-service` (JWT); у конструктора уже есть
   `PROXY_AUTH_ENABLED` для работы за доверенным прокси.
4. ⬜ Решить дублирование: Java `survey-service` ↔ конструктор анкет,
   `data-storage-service` ↔ загрузка данных (заменить заглушку `ApiClient` на `/api/v1/datasets`).
5. ⬜ Потоки данных: ответы анкет → ML-анализ и анализ креативности.
6. ⬜ CI: сборка всего стенда и smoke-тест на каждый PR.
