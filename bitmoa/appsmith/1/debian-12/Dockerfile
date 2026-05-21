# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2026-05-21T06:51:46Z" \
      org.opencontainers.image.description="Application packaged by Broadcom, Inc." \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/appsmith/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/appsmith" \
      org.opencontainers.image.title="appsmith" \
      org.opencontainers.image.vendor="Broadcom, Inc." \
      org.opencontainers.image.version="1.99.0"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages acl ca-certificates curl gettext libbz2-1.0 libcrypt1 libffi8 libgcc-s1 libgeoip1 libicu72 liblzma5 libncursesw6 libpcre3 libreadline8 libsqlite3-0 libssl3 libstdc++6 libtinfo6 libxml2 openssl procps zlib1g
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "render-template-1.0.9-165-linux-${OS_ARCH}-debian-12" \
      "python-3.14.5-2-linux-${OS_ARCH}-debian-12" \
      "node-22.22.3-0-linux-${OS_ARCH}-debian-12" \
      "nginx-1.31.0-1-linux-${OS_ARCH}-debian-12" \
      "mongodb-shell-2.8.3-0-linux-${OS_ARCH}-debian-12" \
      "jre-25.0.3-11-1-linux-${OS_ARCH}-debian-12" \
      "appsmith-1.99.0-0-linux-${OS_ARCH}-debian-12" \
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
RUN /opt/bitmoa/scripts/nginx/postunpack.sh
RUN /opt/bitmoa/scripts/appsmith/postunpack.sh
ENV APP_VERSION="1.99.0" \
    BITMOA_APP_NAME="appsmith" \
    IMAGE_REVISION="5" \
    NGINX_HTTPS_PORT_NUMBER="" \
    NGINX_HTTP_PORT_NUMBER="" \
    PATH="/opt/bitmoa/common/bin:/opt/bitmoa/python/bin:/opt/bitmoa/node/bin:/opt/bitmoa/nginx/sbin:/opt/bitmoa/mongodb/bin:/opt/bitmoa/java/bin:$PATH"

EXPOSE 3000 8080 8091 8443

USER 1001
ENTRYPOINT [ "/opt/bitmoa/scripts/appsmith/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/appsmith/run.sh" ]
