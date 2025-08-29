#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libapache.sh

# Load Apache environment variables
. /opt/bitmoa/scripts/apache-env.sh

/opt/bitmoa/scripts/apache/stop.sh
/opt/bitmoa/scripts/apache/start.sh
