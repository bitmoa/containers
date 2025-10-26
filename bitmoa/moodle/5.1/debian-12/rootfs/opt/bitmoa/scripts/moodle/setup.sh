#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Moodle environment
. /opt/bitmoa/scripts/moodle-env.sh

# Load MySQL Client environment for 'mysql_remote_execute', used during initialization (after 'moodle-env.sh' so that MODULE is not set to a wrong value)
if [[ -f /opt/bitmoa/scripts/mysql-client-env.sh ]]; then
    . /opt/bitmoa/scripts/mysql-client-env.sh
elif [[ -f /opt/bitmoa/scripts/mysql-env.sh ]]; then
    . /opt/bitmoa/scripts/mysql-env.sh
elif [[ -f /opt/bitmoa/scripts/mariadb-env.sh ]]; then
    . /opt/bitmoa/scripts/mariadb-env.sh
fi

# Load PostgreSQL Client environment for 'postgresql_remote_execute' (after 'discourse-env.sh' so that MODULE is not set to a wrong value)
if [[ -f /opt/bitmoa/scripts/postgresql-client-env.sh ]]; then
    . /opt/bitmoa/scripts/postgresql-client-env.sh
elif [[ -f /opt/bitmoa/scripts/postgresql-env.sh ]]; then
    . /opt/bitmoa/scripts/postgresql-env.sh
fi

# Load PHP environment for cron configuration (after 'moodle-env.sh' so that MODULE is not set to a wrong value)
. /opt/bitmoa/scripts/php-env.sh

# Load libraries
. /opt/bitmoa/scripts/libmoodle.sh
. /opt/bitmoa/scripts/libwebserver.sh

# Load web server environment and functions (after 'moodle-env.sh' file so MODULE is not set to a wrong value)
. "/opt/bitmoa/scripts/$(web_server_type)-env.sh"

# Ensure Moodle environment variables are valid
moodle_validate

# Update web server configuration with runtime environment (needs to happen before the initialization)
web_server_update_app_configuration "moodle"

# Ensure Moodle is initialized
moodle_initialize
