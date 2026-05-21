#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/libfs.sh
. /opt/bitmoa/scripts/libopenresty.sh

# Load OpenResty environment variables
. /opt/bitmoa/scripts/openresty-env.sh

# Ensure OpenResty environment variables settings are valid
openresty_validate

# Ensure OpenResty is stopped when this script ends
trap "openresty_stop" EXIT

# Ensure OpenResty daemon user exists when running as 'root'
am_i_root && ensure_user_exists "$OPENRESTY_DAEMON_USER" --group "$OPENRESTY_DAEMON_GROUP"

# Fix logging issue when running as root
! am_i_root || chmod o+w "$(readlink /dev/stdout)" "$(readlink /dev/stderr)"

# Execute init scripts
openresty_custom_init_scripts

# Initialize OpenResty
openresty_initialize
