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

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/harbor-jobservice/run.sh" ]]; then
    info "** Starting harbor-jobservice setup **"
    /opt/bitmoa/scripts/harbor-jobservice/setup.sh
    info "** harbor-jobservice setup finished! **"
fi

echo ""
exec "$@"
