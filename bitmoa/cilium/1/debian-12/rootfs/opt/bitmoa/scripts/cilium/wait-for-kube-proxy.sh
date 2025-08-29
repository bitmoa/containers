#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libcilium.sh
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/liblog.sh

# Load Cilium environment variables
. /opt/bitmoa/scripts/cilium-env.sh

exit_code=0
if ! retry_while "is_kube_proxy_ready"; then
    error "kube-proxy is not ready"
    exit_code=1
else
    info "kube-proxy ready"
fi

exit "$exit_code"
