#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/libnginx.sh

# Load NGINX environment variables
. /opt/bitmoa/scripts/nginx-env.sh

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/nginx/run.sh" ]]; then
    info "** Starting harbor-portal setup **"
    /opt/bitmoa/scripts/nginx/setup.sh
    /opt/bitmoa/scripts/harbor-portal/setup.sh
    info "** harbor-portal setup finished! **"
fi

echo ""
exec "$@"
