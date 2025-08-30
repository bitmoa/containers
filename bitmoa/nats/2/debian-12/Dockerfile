# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm AS builder

ARG DOWNLOADS_URL="github.com/bitmoa/downloads/raw/refs/heads/main/files"
ARG TARGETARCH

ENV OS_ARCH="${TARGETARCH:-amd64}"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

# Install required system packages and dependencies
RUN install_packages ca-certificates curl
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "nats-2.11.8-0-linux-${OS_ARCH}-debian-12" \
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
RUN uninstall_packages curl

######

FROM scratch

ARG DOWNLOADS_URL="github.com/bitmoa/downloads/raw/refs/heads/main/files"
ARG TARGETARCH

ENV OS_ARCH="${TARGETARCH:-amd64}"

LABEL com.vmware.cp.artifact.flavor="sha256:c50c90cfd9d12b445b011e6ad529f1ad3daea45c26d20b00732fae3cd71f6a83" \
      org.opencontainers.image.base.name="scratch" \
      org.opencontainers.image.created="2025-08-14T16:48:04Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.title="nats" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="2.11.8"

COPY rootfs /
COPY --from=builder /opt/bitmoa/nats/.spdx-nats.spdx /opt/bitmoa/nats/.spdx-nats.spdx
COPY --from=builder /opt/bitmoa/nats/bin/nats-server /opt/bitmoa/nats/bin/nats-server
COPY --from=builder /opt/bitmoa/nats/licenses /opt/bitmoa/nats/licenses

ENV APP_VERSION="2.11.8" \
    BITMOA_APP_NAME="nats" \
    PATH="/opt/bitmoa/nats/bin:$PATH"

EXPOSE 4222 6222 8222

USER 1001

ENTRYPOINT [ "nats-server" ]
