#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libfs.sh
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/libinfluxdb.sh

# Load InfluxDB environment variables
. /opt/bitmoa/scripts/influxdb-env.sh

print_welcome_page

if ! is_influxdb_3 && ! is_dir_empty "$INFLUXDB_DEFAULT_CONF_DIR"; then
    # We add the copy from default config in the entrypoint to not break users 
    # bypassing the setup.sh logic. If the file already exists do not overwrite (in
    # case someone mounts a configuration file in /opt/bitmoa/influxdb/etc)
    debug "Copying files from $INFLUXDB_DEFAULT_CONF_DIR to $INFLUXDB_CONF_DIR"
    cp -nr "$INFLUXDB_DEFAULT_CONF_DIR"/. "$INFLUXDB_CONF_DIR"
fi

if [[ "$*" = *"/opt/bitmoa/scripts/influxdb/run.sh"* ]]; then
    info "** Starting InfluxDB setup **"
    /opt/bitmoa/scripts/influxdb/setup.sh
    info "** InfluxDB setup finished! **"
fi

echo ""
exec "$@"
