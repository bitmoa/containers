#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libwebserver.sh

# Load phpMyAdmin environment
. /opt/bitmoa/scripts/phpmyadmin-env.sh

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/$(web_server_type)/run.sh" || "$1" = "/opt/bitmoa/scripts/nginx-php-fpm/run.sh" ]]; then
    info "** Starting phpMyAdmin setup **"
    /opt/bitmoa/scripts/"$(web_server_type)"/setup.sh
    /opt/bitmoa/scripts/php/setup.sh
    /opt/bitmoa/scripts/phpmyadmin/setup.sh
    /post-init.sh
    info "** phpMyAdmin setup finished! **"
fi

echo ""
exec "$@"
