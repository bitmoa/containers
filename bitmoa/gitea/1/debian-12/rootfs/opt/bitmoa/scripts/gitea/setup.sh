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
. /opt/bitmoa/scripts/libgitea.sh

# Load Gitea environment settings
. /opt/bitmoa/scripts/gitea-env.sh

# Ensure Gitea environment settings are valid
gitea_validate
# Ensure Gitea is stopped when this script ends.
trap "gitea_stop" EXIT
# Ensure 'daemon' user exists when running as 'root'
am_i_root && ensure_user_exists "$GITEA_DAEMON_USER" --group "$GITEA_DAEMON_GROUP"
# Ensure  is initialized
gitea_initialize
# Stop Gitea before flagging it as fully initialized.
# Relying only on the trap defined above could produce a race condition.
gitea_stop
