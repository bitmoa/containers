#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitmoa/scripts/liblaravel.sh
. /opt/bitmoa/scripts/liblog.sh
. /opt/bitmoa/scripts/libservice.sh

# Load Laravel environment
. /opt/bitmoa/scripts/laravel-env.sh

cd /app

declare -a start_flags=("artisan" "serve" "--host=0.0.0.0" "--port=${LARAVEL_PORT_NUMBER}")
start_flags+=("$@")

info "** Starting Laravel project **"
php "${start_flags[@]}"
