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
. /opt/bitmoa/scripts/libpostgresql.sh

# Load PostgreSQL environment variables
. /opt/bitmoa/scripts/postgresql-env.sh

print_welcome_page

# Enable the nss_wrapper settings
postgresql_enable_nss_wrapper

# We add the copy from default config in the entrypoint to not break users 
# bypassing the setup.sh logic. If the file already exists do not overwrite (in
# case someone mounts a configuration file in /opt/bitmoa/postgresql/conf)
debug "Copying files from $POSTGRESQL_DEFAULT_CONF_DIR to $POSTGRESQL_CONF_DIR"
cp -nr "$POSTGRESQL_DEFAULT_CONF_DIR"/. "$POSTGRESQL_CONF_DIR"

if [[ "$*" = *"/opt/bitmoa/scripts/postgresql/run.sh"* ]]; then
    info "** Starting PostgreSQL setup **"
    /opt/bitmoa/scripts/postgresql/setup.sh
    touch "$POSTGRESQL_TMP_DIR"/.initialized
    info "** PostgreSQL setup finished! **"
fi

echo ""
exec "$@"
