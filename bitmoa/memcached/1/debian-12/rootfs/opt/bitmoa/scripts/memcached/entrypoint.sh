#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libmemcached.sh

# Load Memcached environment variables
. /opt/bitmoa/scripts/memcached-env.sh

print_welcome_page

# We add the copy from default config in the entrypoint to not break users 
# bypassing the setup.sh logic. If the file already exists do not overwrite (in
# case someone mounts a configuration file in /opt/bitmoa/memcached/conf)
debug "Copying files from $MEMCACHED_DEFAULT_CONF_DIR to $MEMCACHED_CONF_DIR"
cp -nfr "$MEMCACHED_DEFAULT_CONF_DIR"/. "$MEMCACHED_CONF_DIR"

if [[ "$*" = *"/opt/bitmoa/scripts/memcached/run.sh"* || "$*" = *"/run.sh"* ]]; then
    info "** Starting Memcached setup **"
    /opt/bitmoa/scripts/memcached/setup.sh
    info "** Memcached setup finished! **"
fi

echo ""
exec "$@"
