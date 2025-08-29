#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libexpress.sh

# Load Express environment
. /opt/bitmoa/scripts/express-env.sh

# Ensure Express environment variables are valid
express_validate

# Ensure Express app is initialized
express_initialize
