#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libcilium.sh
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh

# Load Cilium environment variables
. /opt/bitmoa/scripts/cilium-env.sh

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/cilium/run.sh" ]]; then
    info "** Starting Cilium setup **"
    /opt/bitmoa/scripts/cilium/setup.sh
    info "** Cilium setup finished! **"
fi

echo ""
exec "$@"
