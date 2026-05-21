#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/libkafka.sh

# Load Kafka environment variables
. /opt/bitmoa/scripts/kafka-env.sh

print_welcome_page

if [[ "$*" = *"/opt/bitmoa/scripts/kafka/run.sh"* || "$*" = *"/run.sh"* ]]; then
    info "** Starting Kafka setup **"
    /opt/bitmoa/scripts/kafka/setup.sh
    info "** Kafka setup finished! **"
fi

echo ""
exec "$@"
