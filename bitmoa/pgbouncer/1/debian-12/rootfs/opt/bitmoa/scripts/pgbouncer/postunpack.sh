#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load pgbouncer environment
. /opt/bitmoa/scripts/pgbouncer-env.sh

# Load libraries
. /opt/bitmoa/scripts/libpgbouncer.sh
. /opt/bitmoa/scripts/libfile.sh
. /opt/bitmoa/scripts/libfs.sh
. /opt/bitmoa/scripts/liblog.sh

for dir in "$PGBOUNCER_CONF_DIR" "$PGBOUNCER_LOG_DIR" "$PGBOUNCER_TMP_DIR" "$PGBOUNCER_MOUNTED_CONF_DIR" "$PGBOUNCER_INITSCRIPTS_DIR" "$PGBOUNCER_VOLUME_DIR"; do
    ensure_dir_exists "$dir"
    chmod -R g+rwX "$dir"
done
