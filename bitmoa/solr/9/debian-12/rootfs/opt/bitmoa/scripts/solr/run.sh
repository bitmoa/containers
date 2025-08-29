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
. /opt/bitmoa/scripts/libsolr.sh
. /opt/bitmoa/scripts/libos.sh

# Load solr environment variables
. /opt/bitmoa/scripts/solr-env.sh

info "** Starting solr **"
start_command=("${SOLR_BIN_DIR}/solr" "-p" "${SOLR_PORT_NUMBER}" "-d" "/opt/bitmoa/solr/server" "-f")

if is_boolean_yes "$SOLR_ENABLE_CLOUD_MODE"; then
    start_command+=("-cloud" "-z" "${SOLR_ZK_HOSTS}${SOLR_ZK_CHROOT}")
fi

is_boolean_yes "$SOLR_SSL_ENABLED" && export SOLR_SSL_ENABLED=true

if am_i_root; then
    exec_as_user "$SOLR_DAEMON_USER" "${start_command[@]}"
else
    exec "${start_command[@]}"
fi
