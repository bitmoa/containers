#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Discourse environment
. /opt/bitmoa/scripts/discourse-env.sh

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/discourse/run.sh" ]]; then
    /opt/bitmoa/scripts/postgresql-client/setup.sh
    /opt/bitmoa/scripts/discourse/setup.sh
    /post-init.sh
    info "** Discourse setup finished! **"
elif [[ "$1" = "/opt/bitmoa/scripts/discourse-sidekiq/run.sh" ]]; then
    /opt/bitmoa/scripts/discourse-sidekiq/setup.sh
    /post-init.sh
    info "** Sidekiq setup finished! **"
fi

echo ""
exec "$@"
