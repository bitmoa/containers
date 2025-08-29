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
. /opt/bitmoa/scripts/librabbitmq.sh

# Load RabbitMQ environment variables
. /opt/bitmoa/scripts/rabbitmq-env.sh

# Ensure RabbitMQ environment variables settings are valid
rabbitmq_validate
# Ensure RabbitMQ is stopped when this script ends.
trap "rabbitmq_stop" EXIT
# Ensure 'daemon' user exists when running as 'root'
am_i_root && ensure_user_exists "$RABBITMQ_DAEMON_USER" --group "$RABBITMQ_DAEMON_GROUP"
# Ensure RabbitMQ is initialized
rabbitmq_initialize
# Load custom init scripts
rabbitmq_custom_init_scripts
