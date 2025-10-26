#!/bin/bash -e
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

. /opt/bitmoa/base/functions
. /opt/bitmoa/base/helpers

print_welcome_page

exec "$@"
