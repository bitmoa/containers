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
. /opt/bitmoa/scripts/libopenresty.sh

# Load OpenResty environment variables
. /opt/bitmoa/scripts/openresty-env.sh

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/openresty/run.sh" ]]; then
    info "** Starting OpenResty setup **"
    /opt/bitmoa/scripts/openresty/setup.sh
    info "** OpenResty setup finished! **"
fi

echo ""
exec "$@"
