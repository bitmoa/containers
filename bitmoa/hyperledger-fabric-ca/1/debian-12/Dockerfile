# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-10-14T02:56:24Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/hyperledger-fabric-ca/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/hyperledger-fabric-ca" \
      org.opencontainers.image.title="hyperledger-fabric-ca" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="1.5.15"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl procps
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "golang-1.25.3-0-linux-${OS_ARCH}-debian-12" \
      "hyperledger-fabric-ca-1.5.15-12-linux-${OS_ARCH}-debian-12" \
    ) ; \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz.sha256" -O ; \
      fi ; \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" ; \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/bitmoa --strip-components=2 --no-same-owner ; \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitmoa
RUN mkdir -p /opt/bitmoa/hyperledger-fabric-ca/etc && chmod g+rw /opt/bitmoa/hyperledger-fabric-ca/etc && mkdir /etc/hyperledger && ln -s /opt/bitmoa/hyperledger-fabric-ca/etc /etc/hyperledger/fabric-ca-server
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true
RUN uninstall_packages curl

ENV APP_VERSION="1.5.15" \
    BITMOA_APP_NAME="hyperledger-fabric-ca" \
    FABRIC_CA_HOME="/opt/bitmoa/hyperledger-fabric-ca/etc" \
    IMAGE_REVISION="26" \
    PATH="/go/bin:/opt/bitmoa/go/bin:/opt/bitmoa/hyperledger-fabric-ca/bin:$PATH"

USER 1001
CMD [ "fabric-ca-server", "start", "-b", "admin:adminpw" ]
