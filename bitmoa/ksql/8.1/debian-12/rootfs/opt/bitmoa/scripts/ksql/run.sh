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

# Load KSQL environment variables
. /opt/bitmoa/scripts/ksql-env.sh

info "** Starting KSQL **"

__run_cmd="${KSQL_BIN_DIR}/ksql-server-start"
__run_flags=("$KSQL_CONF_FILE" "$@")

if am_i_root; then
    exec_as_user "$KSQL_DAEMON_USER" "$__run_cmd" "${__run_flags[@]}"
else
    exec "$__run_cmd" "${__run_flags[@]}"
fi
