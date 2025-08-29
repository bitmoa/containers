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
. /opt/bitmoa/scripts/libcouchdb.sh

# Load environment
. /opt/bitmoa/scripts/couchdb-env.sh

info "** Starting CouchDB **"
if am_i_root; then
    exec_as_user "$COUCHDB_DAEMON_USER" "${COUCHDB_BIN_DIR}/couchdb"
else
    exec "${COUCHDB_BIN_DIR}/couchdb"
fi
