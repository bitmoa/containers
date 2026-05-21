#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libksql.sh
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh

# Load KSQL environment variables
. /opt/bitmoa/scripts/ksql-env.sh

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/ksql/run.sh" ]]; then
    info "** Starting KSQL setup **"
    /opt/bitmoa/scripts/ksql/setup.sh
    info "** KSQL setup finished! **"
fi

echo ""
exec "$@"
