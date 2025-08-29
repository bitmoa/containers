#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load SuiteCRM environment
. /opt/bitmoa/scripts/suitecrm-env.sh

# Load libraries
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libservice.sh
. /opt/bitmoa/scripts/libwebserver.sh

# Catch SIGTERM signal and stop all child processes
_forwardTerm() {
    warn "Caught signal SIGTERM, passing it to child processes..."
    pgrep -P $$ | xargs kill -TERM 2>/dev/null
    wait
    exit $?
}
trap _forwardTerm TERM

# Start cron
if am_i_root; then
    info "** Starting cron **"
    if ! cron_start; then
        error "Failed to start cron. Check that it is installed and its configuration is correct."
        exit 1
    fi
else
    warn "Cron will not be started because of running as a non-root user"
fi

# Start Apache
exec "/opt/bitmoa/scripts/$(web_server_type)/run.sh"
