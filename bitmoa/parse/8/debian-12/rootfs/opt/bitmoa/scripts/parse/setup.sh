#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Parse environment
. /opt/bitmoa/scripts/parse-env.sh

# Load MongoDB&reg; Client environment for 'mongodb_remote_execute' (after 'parse-env.sh' so that MODULE is not set to a wrong value)
if [[ -f /opt/bitmoa/scripts/mongodb-shell-env.sh ]]; then
    . /opt/bitmoa/scripts/mongodb-shell-env.sh
elif [[ -f /opt/bitmoa/scripts/mongodb-env.sh ]]; then
    . /opt/bitmoa/scripts/mongodb-env.sh
fi

# Load libraries
. /opt/bitmoa/scripts/libparse.sh

# Ensure Parse environment variables are valid
parse_validate

# Ensure Parse is initialized
parse_initialize
