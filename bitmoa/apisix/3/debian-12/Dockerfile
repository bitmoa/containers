# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="github.com/bitmoa/downloads/raw/refs/heads/main/files"
ARG TARGETARCH

LABEL com.vmware.cp.artifact.flavor="sha256:c50c90cfd9d12b445b011e6ad529f1ad3daea45c26d20b00732fae3cd71f6a83" \
      org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-08-18T15:43:44Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/apisix/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/apisix" \
      org.opencontainers.image.title="apisix" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="3.13.0"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libcrypt1 libgcc-s1 libpcre3 libstdc++6 libyaml-0-2 procps zlib1g
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "apisix-3.13.0-2-linux-${OS_ARCH}-debian-12" \
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
RUN useradd -r -u 1001 -g root apisix
RUN chmod g+rwX /opt/bitmoa/apisix/conf && mkdir -p /usr/local/apisix/logs && chmod -R g+rwX /usr/local/apisix && ln -s /opt/bitmoa/apisix/conf /usr/local/apisix && ln -s /opt/bitmoa/apisix/ui /usr/local/apisix && ln -s /opt/bitmoa/apisix/deps /usr/local/apisix && ln -s /opt/bitmoa/apisix/openresty/luajit/share/lua/*/apisix /usr/local/apisix
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true
RUN uninstall_packages curl

ENV APP_VERSION="3.13.0" \
    BITMOA_APP_NAME="apisix" \
    IMAGE_REVISION="4" \
    LUA_PATH="/opt/bitmoa/apisix/deps/share/lua/5.1/?/init.lua" \
    PATH="/opt/bitmoa/apisix/bin:/opt/bitmoa/apisix/openresty/bin:/opt/bitmoa/apisix/openresty/luajit/bin:/opt/bitmoa/apisix/openresty/luarocks/bin:/opt/bitmoa/apisix/openresty/nginx/sbin:$PATH"

USER 1001
ENTRYPOINT [ "/opt/bitmoa/apisix/bin/apisix" ]
