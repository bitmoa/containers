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
. /opt/bitmoa/scripts/liblogstash.sh

# Load Logstash environment variables
. /opt/bitmoa/scripts/logstash-env.sh

print_welcome_page

# We add the copy from default config in the entrypoint to not break users
# bypassing the setup.sh logic. If the file already exists do not overwrite (in
# case someone mounts a configuration file in /opt/bitmoa/logstash/config
# /opt/bitmoa/logstash/pipeline)
if ! is_dir_empty "$LOGSTASH_DEFAULT_CONF_DIR"; then
    debug "Copying files from $LOGSTASH_DEFAULT_CONF_DIR to $LOGSTASH_CONF_DIR"
    cp -nr "$LOGSTASH_DEFAULT_CONF_DIR"/. "$LOGSTASH_CONF_DIR"
fi
if ! is_dir_empty "$LOGSTASH_DEFAULT_PIPELINE_CONF_DIR"; then
    debug "Copying files from $LOGSTASH_DEFAULT_PIPELINE_CONF_DIR to $LOGSTASH_PIPELINE_CONF_DIR"
    cp -nr "$LOGSTASH_DEFAULT_PIPELINE_CONF_DIR"/. "$LOGSTASH_PIPELINE_CONF_DIR"
fi

if [[ "$*" = *"/opt/bitmoa/scripts/logstash/run.sh"* ]]; then
    info "** Starting Logstash setup **"
    /opt/bitmoa/scripts/logstash/setup.sh
    info "** Logstash setup finished! **"
fi

echo ""
exec "$@"
