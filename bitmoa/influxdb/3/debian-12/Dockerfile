# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="github.com/bitmoa/downloads/raw/refs/heads/main/files"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-08-28T04:11:59Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/influxdb/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/influxdb" \
      org.opencontainers.image.title="influxdb" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="3.4.1"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl jq libgcc-s1 procps
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "libpython-3.12.11-1-linux-${OS_ARCH}-debian-12" \
      "influxdb-3.4.1-0-linux-${OS_ARCH}-debian-12" \
      "wait-for-port-1.0.10-0-linux-${OS_ARCH}-debian-12" \
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
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY rootfs /
RUN /opt/bitmoa/scripts/influxdb/postunpack.sh
ENV APP_VERSION="3.4.1" \
    BITMOA_APP_NAME="influxdb" \
    IMAGE_REVISION="0" \
    LD_LIBRARY_PATH="/opt/bitmoa/python/lib:$LD_LIBRARY_PATH" \
    PATH="/opt/bitmoa/common/bin:/opt/bitmoa/influxdb/bin:$PATH"

VOLUME [ "/bitmoa/influxdb" ]

EXPOSE 8088 8181

USER 1001
ENTRYPOINT [ "/opt/bitmoa/scripts/influxdb/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/influxdb/run.sh" ]
