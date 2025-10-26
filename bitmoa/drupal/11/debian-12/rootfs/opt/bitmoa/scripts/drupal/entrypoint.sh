#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Drupal environment
. /opt/bitmoa/scripts/drupal-env.sh

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libwebserver.sh

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/$(web_server_type)/run.sh" ]]; then
    info "** Starting Drupal setup **"
    /opt/bitmoa/scripts/"$(web_server_type)"/setup.sh
    /opt/bitmoa/scripts/php/setup.sh
    /opt/bitmoa/scripts/mysql-client/setup.sh
    /opt/bitmoa/scripts/drupal/setup.sh
    /post-init.sh
    info "** Drupal setup finished! **"
fi

echo ""
exec "$@"
