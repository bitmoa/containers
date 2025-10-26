#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Redmine environment
. /opt/bitmoa/scripts/redmine-env.sh

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/redmine/run.sh" ]]; then
    /opt/bitmoa/scripts/mysql-client/setup.sh
    /opt/bitmoa/scripts/postgresql-client/setup.sh
    /opt/bitmoa/scripts/redmine/setup.sh
    /post-init.sh
    info "** Redmine setup finished! **"
fi

echo ""
exec "$@"
