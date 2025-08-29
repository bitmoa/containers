#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libkeycloak.sh

# Load Keycloak environment variables
. /opt/bitmoa/scripts/keycloak-env.sh

# Ensure Keycloak environment variables are valid
keycloak_validate

# Ensure 'daemon' user exists when running as 'root'
am_i_root && ensure_user_exists "$KEYCLOAK_DAEMON_USER" --group "$KEYCLOAK_DAEMON_GROUP"

# Ensure Keycloak is initialized
keycloak_initialize

# Keycloak init scripts
keycloak_custom_init_scripts
