# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="github.com/bitmoa/downloads/raw/refs/heads/main/files"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-08-28T10:41:39Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/cilium/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/cilium" \
      org.opencontainers.image.title="cilium" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="1.18.1"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux" \
    PATH="/opt/bitmoa/common/bin:/opt/bitmoa/cilium/bin:$PATH"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages bash-completion ca-certificates curl iproute2 ipset iptables libgcc-s1 libstdc++6 libtinfo6 nftables procps zlib1g
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "llvm-18.1.8-3-linux-${OS_ARCH}-debian-12" \
      "gops-0.3.28-25-linux-${OS_ARCH}-debian-12" \
      "bpftool-7.6.0-0-linux-${OS_ARCH}-debian-12" \
      "cilium-1.18.1-0-linux-${OS_ARCH}-debian-12" \
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
RUN uninstall_packages curl

COPY rootfs /
RUN /opt/bitmoa/scripts/cilium/postunpack.sh
ENV APP_VERSION="1.18.1" \
    BITMOA_APP_NAME="cilium" \
    IMAGE_REVISION="3"

USER 1001
ENTRYPOINT [ "/opt/bitmoa/scripts/cilium/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/cilium/run.sh" ]
