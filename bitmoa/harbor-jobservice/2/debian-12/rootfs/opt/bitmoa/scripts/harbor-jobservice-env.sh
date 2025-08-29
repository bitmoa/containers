#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0
#
# Environment configuration for harbor-jobservice

# The values for all environment variables will be set in the below order of precedence
# 1. Custom environment variables defined below after Bitnami defaults
# 2. Constants defined in this file (environment variables with no default), i.e. BITMOA_ROOT_DIR
# 3. Environment variables overridden via external files using *_FILE variables (see below)
# 4. Environment variables set externally (i.e. current Bash context/Dockerfile/userdata)

# Load logging library
# shellcheck disable=SC1090,SC1091
. /opt/bitmoa/scripts/liblog.sh

export BITMOA_ROOT_DIR="/opt/bitmoa"
export BITMOA_VOLUME_DIR="/bitmoa"

# Logging configuration
export MODULE="${MODULE:-harbor-jobservice}"
export BITMOA_DEBUG="${BITMOA_DEBUG:-false}"

# Paths
export HARBOR_JOBSERVICE_BASE_DIR="${BITMOA_ROOT_DIR}/harbor-jobservice"
export PATH="${BITMOA_ROOT_DIR}/common/bin:${PATH}"

# System users
export HARBOR_JOBSERVICE_DAEMON_USER="harbor"
export HARBOR_JOBSERVICE_DAEMON_GROUP="harbor"

# Custom environment variables may be defined below
