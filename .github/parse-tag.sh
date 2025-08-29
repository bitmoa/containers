#!/bin/bash

set -euo pipefail
REF="${GITHUB_REF:-}"
if [[ "${REF}" != refs/tags/* ]]; then
  echo "Not a tag event (REF=${REF}) — exiting."
  exit 78
fi
TAG="${REF#refs/tags/}"
echo "Tag: ${TAG}"

# Expected format: NAME-VERSION-OSTYPE-OSVER-rREV
# NAME may contain hyphens. Use regex with greedy NAME capture.
if [[ "${TAG}" =~ ^(.+)-([0-9]+(\.[0-9]+)*)-([^-]+)-([^-]+)-([^-]+)$ ]]; then
  NAME="${BASH_REMATCH[1]}"
  VERSION="${BASH_REMATCH[2]}"
  OSTYPE="${BASH_REMATCH[4]}"
  OSVER="${BASH_REMATCH[5]}"
  REV="r${BASH_REMATCH[6]}"
else
  echo "ERROR: tag does not match required format NAME-VERSION-OSTYPE-OSVER-rREV"
  exit 1
fi

# Build list of version-prefix candidates: full, then drop last component, etc.
IFS='.' read -ra parts <<< "${VERSION}"
candidates=()
for ((i=${#parts[@]}; i>=1; i--)); do
  prefix="${parts[0]}"
  for ((j=1;j<i;j++)); do
    prefix="${prefix}.${parts[j]}"
  done
  candidates+=("${prefix}")
done

DOCKERFILE=""
for prefix in "${candidates[@]}"; do
  candidate="bitmoa/${NAME}/${prefix}/${OSTYPE}-${OSVER}/Dockerfile"
  if [ -f "${candidate}" ]; then
    DOCKERFILE="${candidate}"
    VERSION_PREFIX="${prefix}"
    break
  fi
done

if [ -z "${DOCKERFILE}" ]; then
  echo "ERROR: no Dockerfile found for any version-prefix candidates."
  echo "Checked candidates:"
  for prefix in "${candidates[@]}"; do
    echo "  bitmoa/${NAME}/${prefix}/${OSTYPE}-${OSVER}/Dockerfile"
  done
  exit 1
fi

IMAGE_TAG="${DOCKER_REGISTRY}/${ORG}/${NAME}:${VERSION}-${OSTYPE}-${OSVER}-${REV}"

echo "name=${NAME}" >> "$GITHUB_OUTPUT"
echo "version=${VERSION}" >> "$GITHUB_OUTPUT"
echo "version_prefix=${VERSION_PREFIX}" >> "$GITHUB_OUTPUT"
echo "ostype=${OSTYPE}" >> "$GITHUB_OUTPUT"
echo "osver=${OSVER}" >> "$GITHUB_OUTPUT"
echo "rev=${REV}" >> "$GITHUB_OUTPUT"
echo "dockerfile=${DOCKERFILE}" >> "$GITHUB_OUTPUT"
echo "image_tag=${IMAGE_TAG}" >> "$GITHUB_OUTPUT"
