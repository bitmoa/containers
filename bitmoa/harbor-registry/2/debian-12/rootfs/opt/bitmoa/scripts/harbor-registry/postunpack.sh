#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libfs.sh
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/libservice.sh
. /opt/bitmoa/scripts/libharbor.sh

# Load environment
. /opt/bitmoa/scripts/harbor-registry-env.sh

ensure_user_exists "$HARBOR_REGISTRY_DAEMON_USER" --group "$HARBOR_REGISTRY_DAEMON_GROUP"

# Ensure a set of directories exist and the non-root user has write privileges to them
read -r -a directories <<<"$(get_system_cert_paths)"
directories+=("/var/lib/registry" "$HARBOR_REGISTRY_STORAGE_DIR")
for dir in "${directories[@]}"; do
    ensure_dir_exists "$dir"
    chmod -R g+rwX "$dir"
    chown -R "$HARBOR_REGISTRY_DAEMON_USER" "$dir"
done

ensure_dir_exists "/etc/registry"

# Ensure permissions for Internal TLS
configure_permissions_system_certs "$HARBOR_REGISTRY_DAEMON_USER"
