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

# Load Laravel environment
. /opt/bitmoa/scripts/laravel-env.sh

print_welcome_page

if [[ "$*" = *"/opt/bitmoa/scripts/laravel/run.sh"* ]]; then
    info "** Running Laravel setup **"
    /opt/bitmoa/scripts/php/setup.sh
    /opt/bitmoa/scripts/laravel/setup.sh
    /post-init.sh
    info "** Laravel setup finished! **"
fi

echo ""
exec "$@"
