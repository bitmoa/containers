#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/libconsul.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libfs.sh

# Load Consul env. variables
. /opt/bitmoa/scripts/consul-env.sh

print_welcome_page

if ! is_dir_empty "$CONSUL_DEFAULT_CONF_DIR"; then
    # We add the copy from default config in the entrypoint to not break users 
    # bypassing the setup.sh logic. If the file already exists do not overwrite (in
    # case someone mounts a configuration file in /opt/bitmoa/consul/conf)
    debug "Copying files from $CONSUL_DEFAULT_CONF_DIR to $CONSUL_CONF_DIR"
    cp -nr "$CONSUL_DEFAULT_CONF_DIR"/. "$CONSUL_CONF_DIR"
fi

if [[ "$*" = "/opt/bitmoa/scripts/consul/run.sh" ]]; then
    info "** Starting Consul setup **"
    /opt/bitmoa/scripts/consul/setup.sh
    info "** Consul setup finished! **"
fi

echo ""
exec "$@"
