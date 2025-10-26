# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-10-17T13:03:55Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/parse-dashboard/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/parse-dashboard" \
      org.opencontainers.image.title="parse-dashboard" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="7.5.0"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl jq libbz2-1.0 libffi8 libgcc-s1 liblzma5 libncursesw6 libreadline8 libsqlite3-0 libssl3 libstdc++6 libtinfo6 procps zlib1g
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "python-3.14.0-4-linux-${OS_ARCH}-debian-12" \
      "node-24.10.0-0-linux-${OS_ARCH}-debian-12" \
      "parse-dashboard-7.5.0-0-linux-${OS_ARCH}-debian-12" \
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
RUN mkdir /.local && chmod g+rwX /.local

COPY rootfs /
RUN /opt/bitmoa/scripts/parse-dashboard/postunpack.sh
ENV APP_VERSION="7.5.0" \
    BITMOA_APP_NAME="parse-dashboard" \
    IMAGE_REVISION="12" \
    PATH="/opt/bitmoa/python/bin:/opt/bitmoa/node/bin:/opt/bitmoa/parse-dashboard/bin:$PATH"

EXPOSE 3000 4040

USER 1001
ENTRYPOINT [ "/opt/bitmoa/scripts/parse-dashboard/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/parse-dashboard/run.sh" ]
