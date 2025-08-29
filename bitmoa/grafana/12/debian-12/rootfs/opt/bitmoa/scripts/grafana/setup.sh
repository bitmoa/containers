#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Grafana environment
. /opt/bitmoa/scripts/grafana-env.sh

# Load MySQL Client environment for 'mysql_remote_execute' (after 'grafana-env.sh' so that MODULE is not set to a wrong value)
if [[ -f /opt/bitmoa/scripts/mysql-client-env.sh ]]; then
    . /opt/bitmoa/scripts/mysql-client-env.sh
elif [[ -f /opt/bitmoa/scripts/mysql-env.sh ]]; then
    . /opt/bitmoa/scripts/mysql-env.sh
elif [[ -f /opt/bitmoa/scripts/mariadb-env.sh ]]; then
    . /opt/bitmoa/scripts/mariadb-env.sh
fi

# Load libraries
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libgrafana.sh

# Ensure Grafana environment variables are valid
grafana_validate

# Ensure Grafana is initialized
grafana_initialize
