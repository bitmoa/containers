#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load ActiveMQ environment
. /opt/bitmoa/scripts/activemq-env.sh

# Load libraries
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libactivemq.sh

info "** Starting ActiveMQ **"
if am_i_root; then
    exec_as_user "$ACTIVEMQ_DAEMON_USER" "${ACTIVEMQ_BASE_DIR}/bin/activemq" "console"
else
    exec "${ACTIVEMQ_BASE_DIR}/bin/activemq" "console"
fi