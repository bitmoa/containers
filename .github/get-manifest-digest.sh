#!/bin/sh

set -ex

docker manifest inspect "$1" | tee /dev/stderr | jq -r '.manifests.[] | select(.platform.architecture == "'$2'") | .digest'

