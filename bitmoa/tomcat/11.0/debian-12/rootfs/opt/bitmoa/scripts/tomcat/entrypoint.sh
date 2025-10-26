#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libtomcat.sh
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh

# Load Tomcat environment variables
. /opt/bitmoa/scripts/tomcat-env.sh

print_welcome_page

# We add the copy from default config in the entrypoint to not break users
# bypassing the setup.sh logic. If the file already exists do not overwrite (in
# case someone mounts a configuration file in /opt/bitmoa/tomcat/conf)
debug "Copying files from $TOMCAT_DEFAULT_CONF_DIR to $TOMCAT_CONF_DIR"
cp -nr "$TOMCAT_DEFAULT_CONF_DIR"/. "$TOMCAT_CONF_DIR"

if [[ "$*" = *"/opt/bitmoa/scripts/tomcat/run.sh"* ]]; then
    info "** Starting tomcat setup **"
    /opt/bitmoa/scripts/tomcat/setup.sh
    info "** tomcat setup finished! **"
fi

echo ""
exec "$@"
