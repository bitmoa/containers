#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

# Load libraries
. /opt/bitmoa/scripts/libfs.sh
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/libconsul.sh

# Load Consul env. variables
. /opt/bitmoa/scripts/consul-env.sh

for dir in ${CONSUL_CONF_DIR} ${CONSUL_DEFAULT_CONF_DIR} ${CONSUL_DATA_DIR} ${CONSUL_LOG_DIR} ${CONSUL_TMP_DIR} ${CONSUL_SSL_DIR} ${CONSUL_EXTRA_DIR}; do
    ensure_dir_exists "${dir}"
    chmod -R g+rwX "${dir}"
done

if ! is_dir_empty "$CONSUL_CONF_DIR"; then
    # Copy all initially generated configuration files to the default directory
    # (this is to avoid breaking when entrypoint is being overridden)
    cp -r "${CONSUL_CONF_DIR}/"* "$CONSUL_DEFAULT_CONF_DIR"
fi