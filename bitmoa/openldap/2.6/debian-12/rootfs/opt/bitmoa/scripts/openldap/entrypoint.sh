#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail

# Load libraries
. /opt/bitmoa/scripts/liblog.sh

if [[ "$1" = "/opt/bitmoa/scripts/openldap/run.sh" ]]; then
    info "** Starting LDAP setup **"
    /opt/bitmoa/scripts/openldap/setup.sh
    info "** LDAP setup finished! **"
fi

echo ""
exec "$@"
