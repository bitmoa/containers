#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Ghost environment
. /opt/bitmoa/scripts/ghost-env.sh

# Load libraries
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libghost.sh

# Constants
declare -a args=("run" "$@")

info "** Starting Ghost **"
cd "$GHOST_BASE_DIR" || false
if am_i_root; then
    exec_as_user "$GHOST_DAEMON_USER" ghost "${args[@]}"
else
    exec ghost "${args[@]}"
fi
