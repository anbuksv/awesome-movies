#!/bin/bash

set -e
WHITE='\033[0;37m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ "" = "$VERSION" ]
then
  echo -e "${RED}VERSION not found in environment variables.${NC}"
  exit
fi
rm -rf dist
mkdir dist

for ENV in $( go tool dist list | grep -v 'android' | grep -v 'darwin/arm' | grep -v 's390x' | grep -v 'plan9/arm' | grep -v 'js/wasm' | grep -v 'linux/riscv64'); do
    eval $( echo $ENV | tr '/' ' ' | xargs printf 'export GOOS=%s; export GOARCH=%s\n' )

    GOOS=${GOOS:-linux}
    GOARCH=${GOARCH:-amd64}

    BIN="movies"
    if [ ${GOOS} = "windows" ]; then
        BIN="movies.exe"
    fi

    mkdir -p dist

    echo -e "Building for GOOS=$GREEN$GOOS$NC GOARCH=$YELLOW$GOARCH$NC"

    sudo docker run \
        --rm -v ${PWD}:/usr/build \
        -w /usr/build \
        -e GOPATH=/usr/build/workspace \
        -e GOOS=${GOOS} \
        -e GOARCH=${GOARCH} \
        golang \
        go build -v -a -o ./dist/${BIN}

	zip dist/awesome_movies_v${VERSION}_${GOOS}_${GOARCH}.zip -j dist/${BIN}
    rm -f dist/${BIN}
done
