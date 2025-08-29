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
. /opt/bitmoa/scripts/libejbca.sh

# Load ejbca environment variables
. /opt/bitmoa/scripts/ejbca-env.sh

print_welcome_page

# We add the copy from default config in the entrypoint to not break users
# bypassing the setup.sh logic. If the file already exists do not overwrite (in
# case someone mounts a configuration file in /opt/bitmoa/ejbca/conf or /opt/bitmoa/wildfly/standalone)
debug "Copying files from $EJBCA_DEFAULT_CONF_DIR to $EJBCA_CONF_DIR"
cp -nr "$EJBCA_DEFAULT_CONF_DIR"/. "$EJBCA_CONF_DIR" || true
debug "Copying files from $EJBCA_WILDFLY_DEFAULT_STANDALONE_DIR to $EJBCA_WILDFLY_STANDALONE_DIR"
cp -nr "$EJBCA_WILDFLY_DEFAULT_STANDALONE_DIR"/. "$EJBCA_WILDFLY_STANDALONE_DIR" || true
debug "Copying files from $EJBCA_WILDFLY_DEFAULT_DOMAIN_DIR to $EJBCA_WILDFLY_DOMAIN_DIR"
cp -nr "$EJBCA_WILDFLY_DEFAULT_DOMAIN_DIR"/. "$EJBCA_WILDFLY_DOMAIN_DIR" || true

if [[ "$*" = *"/opt/bitmoa/scripts/ejbca/run.sh"* ]]; then
    info "** Starting ejbca setup **"
    /opt/bitmoa/scripts/ejbca/setup.sh
    info "** ejbca setup finished! **"
fi

echo ""
exec "$@"
