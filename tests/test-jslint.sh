#!/bin/bash -e

# shellcheck disable=SC1090
source "$(dirname "$0")"/../scripts/resources.sh

if find . -name '*.js' -print0 | xargs -0 jslint --color --node --version=latest; then
    test_passed "$0"
else
    test_failed "$0"
fi
