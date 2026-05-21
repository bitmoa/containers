#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load Superset environment variables
. /opt/bitmoa/scripts/superset-env.sh

# Load libraries
. /opt/bitmoa/scripts/libbitmoa.sh
. /opt/bitmoa/scripts/libsuperset.sh

print_welcome_page

# Load SUPERSET_SECRET_KEY from a file when provided
if [[ -n "${SUPERSET_SECRET_KEY_FILE:-}" ]]; then
  export SUPERSET_SECRET_KEY="$(< "${SUPERSET_SECRET_KEY_FILE}")"
fi

# Install custom python package if requirements.txt is present
if [[ -f "/bitmoa/python/requirements.txt" ]]; then
    . /opt/bitmoa/superset/venv/bin/activate
    pip install -r /bitmoa/python/requirements.txt
    deactivate
fi

if [[ "$1" = "/opt/bitmoa/scripts/superset/run.sh" ]]; then
    info "** Starting Superset setup **"
    /opt/bitmoa/scripts/superset/setup.sh
    info "** Superset setup finished! **"
fi

echo ""
exec "$@"
