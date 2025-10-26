#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/librails.sh
. /opt/bitmoa/scripts/libfs.sh
. /opt/bitmoa/scripts/liblog.sh

# Load Rails environment
. /opt/bitmoa/scripts/rails-env.sh

# Ensure required directories exist
ensure_dir_exists "/app"
configure_permissions_ownership "/app" -d "775" -f "664"
