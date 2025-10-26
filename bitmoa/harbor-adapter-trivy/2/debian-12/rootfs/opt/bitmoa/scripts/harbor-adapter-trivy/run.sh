#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libos.sh

# Load harbor-adapter-trivy environment
. /opt/bitmoa/scripts/harbor-adapter-trivy-env.sh

CMD="$(command -v scanner-trivy)"

info "** Starting harbor-adapter-trivy **"
if am_i_root; then
    exec_as_user "$SCANNER_TRIVY_DAEMON_USER" "$CMD" "$@"
else
    exec "$CMD" "$@"
fi
