#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libtensorflow-serving.sh

# Load tensorflow environment variables
. /opt/bitmoa/scripts/tensorflowserving-env.sh

print_welcome_page

if [[ "$*" = *"/opt/bitmoa/scripts/tensorflow-serving/run.sh"* ]]; then
    info "** Starting Tensorflow setup **"
    /opt/bitmoa/scripts/tensorflow-serving/setup.sh
    info "** Tensorflow setup finished! **"
fi

echo ""
exec "$@"
