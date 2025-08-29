#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

# Load libraries
. /opt/bitmoa/scripts/libopensearchdashboards.sh
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/liblog.sh

# Load environment
. /opt/bitmoa/scripts/opensearch-dashboards-env.sh

info "** Starting Opensearch Dashboards **"
start_command=("${SERVER_BIN_DIR}/opensearch-dashboards" "serve")
if am_i_root; then
    exec_as_user "$SERVER_DAEMON_USER" "${start_command[@]}"
else
    exec "${start_command[@]}"
fi
