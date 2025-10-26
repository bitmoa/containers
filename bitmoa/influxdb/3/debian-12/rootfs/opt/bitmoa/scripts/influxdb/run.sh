#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libinfluxdb.sh

# Load InfluxDB environment variables
. /opt/bitmoa/scripts/influxdb-env.sh

info "** Starting InfluxDB **"
start_command=("$(influxdb_binary)")
if is_influxdb_3; then
    start_command+=("serve" "--node-id" "$INFLUXDB_NODE_ID" "--object-store" "$INFLUXDB_OBJECT_STORE")
    ! is_boolean_yes "$INFLUXDB_HTTP_AUTH_ENABLED" && start_command+=("--without-auth")
else
    export HOME="/bitmoa/influxdb"
fi
if am_i_root; then
    exec_as_user "$INFLUXDB_DAEMON_USER" "${start_command[@]}" "$@"
else
    exec "${start_command[@]}" "$@"
fi
