#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libsolr.sh

# Load solr environment variables
. /opt/bitmoa/scripts/solr-env.sh

print_welcome_page

if [[ "$*" = *"/opt/bitmoa/scripts/solr/run.sh"* ]]; then
    info "** Starting solr setup **"
    /opt/bitmoa/scripts/solr/setup.sh
    info "** solr setup finished! **"
fi

echo ""
exec "$@"
