#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0
#
# Environment configuration for flink

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
export MODULE="${MODULE:-flink}"
export BITMOA_DEBUG="${BITMOA_DEBUG:-false}"

# By setting an environment variable matching *_FILE to a file path, the prefixed environment
# variable will be overridden with the value specified in that file
flink_env_vars=(
    FLINK_MODE
    FLINK_CFG_REST_PORT
    FLINK_TASK_MANAGER_NUMBER_OF_TASK_SLOTS
    FLINK_PROPERTIES
)
for env_var in "${flink_env_vars[@]}"; do
    file_env_var="${env_var}_FILE"
    if [[ -n "${!file_env_var:-}" ]]; then
        if [[ -r "${!file_env_var:-}" ]]; then
            export "${env_var}=$(< "${!file_env_var}")"
            unset "${file_env_var}"
        else
            warn "Skipping export of '${env_var}'. '${!file_env_var:-}' is not readable."
        fi
    fi
done
unset flink_env_vars

# Paths
export FLINK_BASE_DIR="${BITMOA_ROOT_DIR}/flink"
export FLINK_BIN_DIR="${FLINK_BASE_DIR}/bin"
export FLINK_WORK_DIR="${FLINK_BASE_DIR}"
export FLINK_LOG_DIR="${FLINK_BASE_DIR}/log"
export FLINK_CONF_DIR="${FLINK_BASE_DIR}/conf"
export FLINK_DEFAULT_CONF_DIR="${FLINK_BASE_DIR}/conf.default"
export FLINK_CONF_FILE="config.yaml"
export FLINK_CONF_FILE_PATH="${FLINK_CONF_DIR}/${FLINK_CONF_FILE}"
export FLINK_MODE="${FLINK_MODE:-jobmanager}"
export FLINK_CFG_REST_PORT="${FLINK_CFG_REST_PORT:-8081}"
export FLINK_TASK_MANAGER_NUMBER_OF_TASK_SLOTS="${FLINK_TASK_MANAGER_NUMBER_OF_TASK_SLOTS:-$(grep -c ^processor /proc/cpuinfo)}"
export FLINK_PROPERTIES="${FLINK_PROPERTIES:-}"

# Flink persistence configuration
export FLINK_VOLUME_DIR="${BITMOA_VOLUME_DIR}/flink"
export FLINK_DATA_TO_PERSIST="conf plugins"

# Flink system parameters
export FLINK_DAEMON_USER="flink"
export FLINK_DAEMON_GROUP="flink"
export PATH="/opt/bitmoa/common/bin:/opt/bitmoa/flink/bin:$PATH"

# Custom environment variables may be defined below
