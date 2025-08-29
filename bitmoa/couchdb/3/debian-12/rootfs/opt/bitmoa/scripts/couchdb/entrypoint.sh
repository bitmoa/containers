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
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/libcouchdb.sh

# Load environment
. /opt/bitmoa/scripts/couchdb-env.sh

print_welcome_page

if [[ "$*" = *"/opt/bitmoa/scripts/couchdb/run.sh"* ]]; then
    info "** Starting CouchDB setup **"
    /opt/bitmoa/scripts/couchdb/setup.sh
    info "** CouchDB setup finished! **"
fi

echo ""
exec "$@"
