#!/bin/bash -e

# shellcheck disable=SC1090
source "$(dirname "$0")"/../scripts/resources.sh

pushd "$(dirname "$0")"/../nodeApp

main(){
    if ! docker build -t test .; then
        popd
        test_failed "$0"
    elif ! docker run -d -p 8080:8080 test; then
        test_failed "$0"
    elif ! sleep 1 && curl -sS localhost:8080; then
        test_failed "$0"
    else
        test_passed "$0"
    fi
}

main "$@"
