#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o pipefail
set -o nounset

# Load libraries
. /opt/bitmoa/scripts/libos.sh
. /opt/bitmoa/scripts/libnet.sh
. /opt/bitmoa/scripts/libetcd.sh

# Load etcd environment settings
. /opt/bitmoa/scripts/etcd-env.sh

read -r -a advertised_array <<< "$(tr ',;' ' ' <<< "$ETCD_ADVERTISE_CLIENT_URLS")"
host="$(parse_uri "${advertised_array[0]}" "host")"
port="$(parse_uri "${advertised_array[0]}" "port")"
read -r -a extra_flags <<< "$(etcdctl_auth_flags)"
extra_flags+=("--endpoints=${host}:${port}")

# if ETCD_AUTO_TLS true or CA file not exists, just skip server cert verification
if [[ $ETCD_AUTO_TLS = true ]] || ( [ -n "$ETCD_CERT_FILE" ] && [[ ! -f "$ETCD_TRUSTED_CA_FILE" ]] ); then
     extra_flags+=("--insecure-skip-tls-verify")
fi

if etcdctl endpoint health "${extra_flags[@]}"; then
    exit 0
else
    error "Unhealthy endpoint!"
    exit 1
fi
