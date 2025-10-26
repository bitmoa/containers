#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libfs.sh
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/libharbor.sh

# Load environment
. /opt/bitmoa/scripts/harbor-adapter-trivy-env.sh

# Create directories
for dir in "$SCANNER_TRIVY_CACHE_DIR" "$SCANNER_TRIVY_REPORTS_DIR"; do
    ensure_dir_exists "$dir"
    if am_i_root; then
        chown -R "${SCANNER_TRIVY_DAEMON_USER}:${SCANNER_TRIVY_DAEMON_GROUP}" "$dir"
    fi
done

install_custom_certs
