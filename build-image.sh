#!/bin/bash
set -e

docker login -u $DOCKER_LOGIN -p $DOCKER_PASSWORD

if [ "$DOCKER_SYSTEM_PRUNE" = 'true' ] ; then
    docker system prune -af
fi

last_arg='.'
if [ "$NO_CACHE" = 'true' ] ; then
    last_arg='--no-cache .'
fi

max_version="0.0.0"

# Function to compare version numbers
version_gt() { 
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; 
}

# Loop through each argument
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

    # Update max_version if this version is greater
    if version_gt $version $max_version; then
        max_version=$version
    fi
done

# Push the 'latest' tag with the max version
echo "Pushing 'latest' tag for max version: $max_version"
docker build \
    --pull \
    --build-arg SERVER_VERSION=$max_version \
    -t segateekb/pg_pro:latest \
    -f ./Dockerfile \
    $last_arg

docker push segateekb/pg_pro:latest
