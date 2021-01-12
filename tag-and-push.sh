#!/bin/bash

echo todo

source .env 

APP=${1:-GIVEME_AN_ARG}
VER=${2:-GIVEME_AN_VER}
APPVER="$APP:v$VER"

function _docker() {
    # change docker with echo docker for atomic debug purposes :)
    docker "$@"
}

echo "1. Taking for granted local tag exists: $APPVER"
_docker tag "${APPVER}" "gcr.io/$PROJECT_ID/${APPVER}" &&
           _docker push "gcr.io/$PROJECT_ID/${APPVER}"
echo "2. Building also LATEST version"

_docker tag "${APPVER}" "${APP}" &&
_docker tag "${APP}" "gcr.io/$PROJECT_ID/${APP}" &&
           _docker push "gcr.io/$PROJECT_ID/${APP}"
