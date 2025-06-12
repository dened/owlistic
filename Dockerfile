FROM dart:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart run build_runner build --delete-conflicting-outputs \
    && dart compile exe bin/lookup_service.dart -o lookup_service.run \
    && dart compile exe bin/owlistic.dart -o owlistic.run 

FROM ubuntu:noble AS runtime

WORKDIR /app

ENV LOOKUP_SERVICE_PATH="/app/lookup_service.run"

COPY --from=build /app/owlistic.run /app/
COPY --from=build /app/lookup_service.run /app/
COPY docker/entrypoint.sh /app/
COPY docker/crontab /app/

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends cron libssl-dev libsqlite3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && chmod +x /app/entrypoint.sh  \
    && crontab /app/crontab

CMD ["/app/entrypoint.sh"]
