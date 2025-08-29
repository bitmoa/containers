# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm AS builder

ARG DOWNLOADS_URL="downloads.bitmoa.com/files/stacksmith"
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
      "chainloop-artifact-cas-1.43.1-0-linux-${OS_ARCH}-debian-12" \
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

ARG DOWNLOADS_URL="downloads.bitmoa.com/files/stacksmith"
ARG TARGETARCH

ENV OS_ARCH="${TARGETARCH:-amd64}"

LABEL org.opencontainers.image.base.name="scratch" \
      org.opencontainers.image.created="2025-08-27T16:25:14Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.title="chainloop-artifact-cas" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="1.43.1"

COPY rootfs /
COPY --from=builder /opt/bitmoa/chainloop/.spdx-chainloop-artifact-cas.spdx /opt/bitmoa/chainloop/.spdx-chainloop-artifact-cas.spdx
COPY --from=builder /opt/bitmoa/chainloop/bin/artifact-cas /opt/bitmoa/chainloop/bin/artifact-cas
COPY --from=builder /opt/bitmoa/chainloop/licenses /opt/bitmoa/chainloop/licenses

ENV APP_VERSION="1.43.1" \
    BITMOA_APP_NAME="chainloop-artifact-cas" \
    IMAGE_REVISION="0" \
    PATH="/opt/bitmoa/chainloop/bin:$PATH"

USER 1001

CMD [ "artifact-cas" ]
