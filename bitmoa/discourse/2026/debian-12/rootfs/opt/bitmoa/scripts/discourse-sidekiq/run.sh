#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Discourse environment
. /opt/bitmoa/scripts/discourse-env.sh

# Load libraries
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libdiscourse.sh

cd "$DISCOURSE_BASE_DIR"

# Based on https://github.com/discourse/discourse/blob/master/bin/docker/sidekiq
START_CMD=(
    "bundle" "exec" "sidekiq"
    "-q" "critical" "-q" "low" "-q" "default" "-q" "ultra_low" # Queues; the order is important
    "-e" "$DISCOURSE_ENV"
)

info "** Starting Sidekiq **"
if am_i_root; then
    exec_as_user "$DISCOURSE_DAEMON_USER" "${START_CMD[@]}" "$@"
else
    exec "${START_CMD[@]}" "$@"
fi
