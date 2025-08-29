#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libnginx.sh

# Load NGINX environment variables
. /opt/bitmoa/scripts/nginx-env.sh

/opt/bitmoa/scripts/nginx/stop.sh
/opt/bitmoa/scripts/nginx/start.sh
