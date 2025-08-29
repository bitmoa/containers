#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Redis environment variables
. /opt/bitmoa/scripts/redis-env.sh

# Load libraries
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/libfs.sh
. /opt/bitmoa/scripts/libredis.sh

# Ensure Redis environment variables settings are valid
redis_validate
# Ensure Redis daemon user exists when running as root
am_i_root && ensure_user_exists "$REDIS_DAEMON_USER" --group "$REDIS_DAEMON_GROUP"
# Ensure Redis is initialized
redis_initialize
