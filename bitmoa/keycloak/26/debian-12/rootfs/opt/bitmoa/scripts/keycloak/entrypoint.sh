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
. /opt/bitmoa/scripts/libkeycloak.sh

# Load Keycloak environment variables
. /opt/bitmoa/scripts/keycloak-env.sh

print_welcome_page

# We add the copy from default config in the entrypoint to not break users
# bypassing the setup.sh logic. If the file already exists do not overwrite (in
# case someone mounts a configuration file in /opt/bitmoa/keycloak/conf)
debug "Copying files from $KEYCLOAK_DEFAULT_CONF_DIR to $KEYCLOAK_CONF_DIR"
cp -nr "$KEYCLOAK_DEFAULT_CONF_DIR"/. "$KEYCLOAK_CONF_DIR"

if [[ "$*" = *"/opt/bitmoa/scripts/keycloak/run.sh"* ]]; then
    info "** Starting keycloak setup **"
    /opt/bitmoa/scripts/keycloak/setup.sh
    info "** keycloak setup finished! **"
fi

echo ""
exec "$@"
