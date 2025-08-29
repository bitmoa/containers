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
. /opt/bitmoa/scripts/libfs.sh

# Load etcd environment variables
. /opt/bitmoa/scripts/etcd-env.sh

print_welcome_page

if ! is_dir_empty "$ETCD_DEFAULT_CONF_DIR"; then
    # We add the copy from default config in the entrypoint to not break users 
    # bypassing the setup.sh logic. If the file already exists do not overwrite (in
    # case someone mounts a configuration file in /opt/bitmoa/etcd/conf)
    debug "Copying files from $ETCD_DEFAULT_CONF_DIR to $ETCD_CONF_DIR"
    cp -nfr "$ETCD_DEFAULT_CONF_DIR"/. "$ETCD_CONF_DIR"
fi

if [[ "$1" = "/opt/bitmoa/scripts/etcd/run.sh" ]]; then
    info "** Starting etcd setup **"
    /opt/bitmoa/scripts/etcd/setup.sh
    info "** etcd setup finished! **"
fi

echo ""
exec "$@"
