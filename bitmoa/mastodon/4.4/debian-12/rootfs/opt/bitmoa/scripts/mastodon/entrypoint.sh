#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/liblog.sh

# Load Mastodon environment variables
. /opt/bitmoa/scripts/mastodon-env.sh

print_welcome_page

if [[ "$1" = "/opt/bitmoa/scripts/mastodon/run.sh" ]]; then
    info "** Starting Mastodon ${MASTODON_MODE} setup **"
    /opt/bitmoa/scripts/mastodon/setup.sh
    info "** Mastodon ${MASTODON_MODE} setup finished! **"
fi

echo ""
exec "$@"
