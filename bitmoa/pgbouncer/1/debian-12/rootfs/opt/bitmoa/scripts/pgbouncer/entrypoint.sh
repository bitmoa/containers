#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load pgbouncer environment
. /opt/bitmoa/scripts/pgbouncer-env.sh

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libpgbouncer.sh

print_welcome_page

# Enable the nss_wrapper settings
pgbouncer_enable_nss_wrapper

if [[ "$1" = "/opt/bitmoa/scripts/pgbouncer/run.sh" ]]; then
    info "** Starting PgBouncer setup **"
    /opt/bitmoa/scripts/pgbouncer/setup.sh
    info "** PgBouncer setup finished! **"
fi

echo ""
exec "$@"
