#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load SonarQube environment
. /opt/bitmoa/scripts/sonarqube-env.sh

# Load PostgreSQL Client environment for 'postgresql_remote_execute' (after 'sonarqube-env.sh' so that MODULE is not set to a wrong value)
if [[ -f /opt/bitmoa/scripts/postgresql-client-env.sh ]]; then
    . /opt/bitmoa/scripts/postgresql-client-env.sh
elif [[ -f /opt/bitmoa/scripts/postgresql-env.sh ]]; then
    . /opt/bitmoa/scripts/postgresql-env.sh
fi

# Load libraries
. /opt/bitmoa/scripts/libsonarqube.sh

# Ensure SonarQube environment variables are valid
sonarqube_validate

# Ensure SonarQube is initialized
sonarqube_initialize
