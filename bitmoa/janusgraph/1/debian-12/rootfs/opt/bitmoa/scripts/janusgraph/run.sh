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

# Load JanusGraph environment variables
. /opt/bitmoa/scripts/janusgraph-env.sh

info "** Starting JanusGraph **"

EXEC="${JANUSGRAPH_BIN_DIR}/janusgraph-server.sh"
args=("$JANUSGRAPH_GREMLIN_CONF_FILE")

if am_i_root; then
    exec_as_user "$JANUSGRAPH_DAEMON_USER" "$EXEC" "${args[@]}"
else
    exec "$EXEC" "${args[@]}"
fi
