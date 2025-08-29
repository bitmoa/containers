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

# Load Cilium environment variables
. /opt/bitmoa/scripts/cilium-env.sh

declare -a cmd=("cilium-dbg")
cmd+=("$@")

info "** Starting Cilium **"
if am_i_root; then
    exec_as_user "$CILIUM_DAEMON_USER" "${cmd[@]}"
else
    exec "${cmd[@]}"
fi
