#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Ghost environment
. /opt/bitmoa/scripts/ghost-env.sh

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libos.sh

print_welcome_page

# Configure libnss_wrapper based on the UID/GID used to run the container
# This container supports arbitrary UIDs, therefore we have do it dynamically
if ! am_i_root; then
    export LNAME="ghost"
    export LD_PRELOAD="/opt/bitmoa/common/lib/libnss_wrapper.so"
    if [[ -f "$LD_PRELOAD" ]]; then
        info "Configuring libnss_wrapper"
        NSS_WRAPPER_PASSWD="$(mktemp)"
        export NSS_WRAPPER_PASSWD
        NSS_WRAPPER_GROUP="$(mktemp)"
        export NSS_WRAPPER_GROUP
        echo "ghost:x:$(id -u):$(id -g):Ghost:/home/ghost:/bin/false" >"$NSS_WRAPPER_PASSWD"
        echo "ghost:x:$(id -g):" >"$NSS_WRAPPER_GROUP"
        chmod 400 "$NSS_WRAPPER_PASSWD" "$NSS_WRAPPER_GROUP"
    fi
fi

if [[ "$1" = "/opt/bitmoa/scripts/ghost/run.sh" ]]; then
    /opt/bitmoa/scripts/mysql-client/setup.sh
    /opt/bitmoa/scripts/ghost/setup.sh
    /post-init.sh
    info "** Ghost setup finished! **"
fi

echo ""
exec "$@"
