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
. /opt/bitmoa/scripts/libkong.sh

. /opt/bitmoa/scripts/kong-env.sh

print_welcome_page

# We add the copy from default config in the entrypoint to not break users 
# bypassing the setup.sh logic. If the file already exists do not overwrite (in
# case someone mounts a configuration file in /opt/bitmoa/kong/conf)
debug "Copying files from $KONG_DEFAULT_CONF_DIR to $KONG_CONF_DIR"
cp -nr "$KONG_DEFAULT_CONF_DIR"/. "$KONG_CONF_DIR"

if ! is_dir_empty "$KONG_DEFAULT_SERVER_DIR"; then
    cp -nr "$KONG_DEFAULT_SERVER_DIR"/. "$KONG_SERVER_DIR"
fi
if [[ "$*" = *"/opt/bitmoa/scripts/kong/run.sh"* ]]; then
    info "** Starting Kong setup **"
    /opt/bitmoa/scripts/kong/setup.sh
    info "** Kong setup finished! **"
fi

echo ""
exec "$@"
