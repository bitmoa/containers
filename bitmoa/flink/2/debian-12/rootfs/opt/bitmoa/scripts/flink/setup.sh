#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/libvalidations.sh
. /opt/bitmoa/scripts/libflink.sh

# Load Apache Flink environment variables
. /opt/bitmoa/scripts/flink-env.sh

# Ensure Flink environment variables are valid
flink_validate

# Ensure Flink is initialized
flink_initialize
