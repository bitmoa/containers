#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Load libraries
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/libfs.sh
. /opt/bitmoa/scripts/libspark.sh

# Load Spark environment settings
. /opt/bitmoa/scripts/spark-env.sh

# Ensure Spark environment variables settings are valid
spark_validate

# Ensure 'spark' user exists when running as 'root'
am_i_root && ensure_user_exists "$SPARK_DAEMON_USER" --group "$SPARK_DAEMON_GROUP"

# Ensure Spark is initialized
spark_initialize

# Run custom initialization scripts
spark_custom_init_scripts
