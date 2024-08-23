#!/bin/bash
set -e

# Загрузка переменных из файла .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Файл .env не найден"
    exit 1
fi

docker login -u $DOCKER_LOGIN -p $DOCKER_PASSWORD

if [ "$DOCKER_SYSTEM_PRUNE" = 'true' ] ; then
    docker system prune -af
fi

last_arg='.'
if [ "$NO_CACHE" = 'true' ] ; then
    last_arg='--no-cache .'
fi

max_version="0.0.0"

# Функция для сравнения версий
version_gt() { 
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; 
}

# Цикл по всем переданным версиям
for version in "$@"
do
    echo "Building and pushing for version: $version"
    docker build \
        --pull \
        --build-arg SERVER_VERSION=$version \
        -t segateekb/pg_pro:$version \
        -f ./Dockerfile \
        $last_arg

    docker push segateekb/pg_pro:$version

    # Обновляем max_version, если текущая версия больше
    if version_gt $version $max_version; then
        max_version=$version
    fi
done

# Пушим тег 'latest' для максимальной версии
echo "Pushing 'latest' tag for max version: $max_version"
docker build \
    --pull \
    --build-arg SERVER_VERSION=$max_version \
    -t segateekb/pg_pro:latest \
    -f ./Dockerfile \
    $last_arg

docker push segateekb/pg_pro:latest
