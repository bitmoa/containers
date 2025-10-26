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
. /opt/bitmoa/scripts/libnginx.sh

# Catch SIGTERM signal and stop all child processes
_forwardTerm() {
    echo "Caught signal SIGTERM, passing it to child processes..."
    pgrep -P $$ | xargs kill -TERM 2>/dev/null
    wait
    exit $?
}
trap _forwardTerm TERM

info "Starting PHP-FPM..."
/opt/bitmoa/scripts/php/run.sh &

info "Starting NGINX..."
/opt/bitmoa/scripts/nginx/run.sh
