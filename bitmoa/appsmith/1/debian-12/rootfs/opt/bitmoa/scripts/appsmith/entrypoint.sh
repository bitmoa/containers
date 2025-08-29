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

# Load Appsmith environment variables
. /opt/bitmoa/scripts/appsmith-env.sh

print_welcome_page

# We add the copy from default config in the entrypoint to not break users
# bypassing the setup.sh logic. If the file already exists do not overwrite (in
# case someone mounts a configuration file in /opt/bitmoa/appsmith/conf)
debug "Copying files from $APPSMITH_DEFAULT_CONF_DIR to $APPSMITH_CONF_DIR"
cp -nr "$APPSMITH_DEFAULT_CONF_DIR"/. "$APPSMITH_CONF_DIR" || true

if [[ "$1" = "/opt/bitmoa/scripts/appsmith/run.sh" ]]; then
    info "** Starting Appsmith ${APPSMITH_MODE} setup **"
    /opt/bitmoa/scripts/appsmith/setup.sh
    if [[ "$APPSMITH_MODE" == "client" ]]; then
        # In the case of the frontend, we need to configure nginx too
        /opt/bitmoa/scripts/nginx/setup.sh
    fi
    info "** Appsmith ${APPSMITH_MODE} setup finished! **"
fi

echo ""
exec "$@"
