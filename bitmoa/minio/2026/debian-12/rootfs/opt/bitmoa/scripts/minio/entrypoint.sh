#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh

print_welcome_page

if [[ "$*" = *"/opt/bitmoa/scripts/minio/run.sh"* ]]; then
    info "** Starting MinIO setup **"
    /opt/bitmoa/scripts/minio/setup.sh
    info "** MinIO setup finished! **"
fi

echo ""

# Necessary for compatibility for minio-operator, if the first argument is "server" then prepend "minio"
if [[ "$1" = "server" ]]; then
    exec minio "$@"
else
    exec "$@"
fi