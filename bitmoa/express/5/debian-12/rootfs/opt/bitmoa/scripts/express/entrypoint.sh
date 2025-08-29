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
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libos.sh

# Load Express environment
. /opt/bitmoa/scripts/express-env.sh

print_welcome_page

if [[ "$1" = "npm" ]] && [[ "$2" = "run" || "$2" = "start" ]]; then
    info "** Running Express setup **"
    /opt/bitmoa/scripts/express/setup.sh
    info "** Express setup finished! **"
fi

echo ""
exec "$@"
