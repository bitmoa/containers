# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-10-21T16:47:36Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/laravel/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/laravel" \
      org.opencontainers.image.title="laravel" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="12.9.0"

ENV OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libbrotli1 libbsd0 libbz2-1.0 libcom-err2 libcurl4 libexpat1 libffi8 libfftw3-double3 libfontconfig1 libfreetype6 libgcc-s1 libgcrypt20 libglib2.0-0 libgmp10 libgnutls30 libgomp1 libgpg-error0 libgssapi-krb5-2 libhashkit2 libhogweed6 libicu72 libidn2-0 libjpeg62-turbo libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 liblcms2-2 libldap-2.5-0 liblqr-1-0 libltdl7 liblzma5 libmagickcore-6.q16-6 libmagickwand-6.q16-6 libmd0 libmemcached11 libncursesw6 libnettle8 libnghttp2-14 libonig5 libp11-kit0 libpcre2-8-0 libpng16-16 libpq5 libpsl5 libreadline8 librtmp1 libsasl2-2 libsodium23 libsqlite3-0 libssh2-1 libssl3 libstdc++6 libsybdb5 libtasn1-6 libtidy5deb1 libtinfo6 libunistring2 libwebp7 libx11-6 libxau6 libxcb1 libxdmcp6 libxext6 libxml2 libxslt1.1 libzip4 libzstd1 procps sqlite3 sudo zlib1g
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "python-3.14.0-4-linux-${OS_ARCH}-debian-12" \
      "wait-for-port-1.0.10-3-linux-${OS_ARCH}-debian-12" \
      "php-8.4.13-6-linux-${OS_ARCH}-debian-12" \
      "node-24.10.0-0-linux-${OS_ARCH}-debian-12" \
      "laravel-12.9.0-0-linux-${OS_ARCH}-debian-12" \
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
RUN /build/bitmoa-user.sh
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY rootfs /
RUN /opt/bitmoa/scripts/laravel/postunpack.sh
RUN /opt/bitmoa/scripts/php/postunpack.sh
ENV APP_VERSION="12.9.0" \
    BITMOA_APP_NAME="laravel" \
    IMAGE_REVISION="0" \
    NODE_PATH="/opt/bitmoa/node/lib/node_modules" \
    PATH="/opt/bitmoa/python/bin:/opt/bitmoa/common/bin:/opt/bitmoa/php/bin:/opt/bitmoa/php/sbin:/opt/bitmoa/node/bin:$PATH" \
    PHP_ENABLE_OPCACHE="0"

EXPOSE 3000 8000

WORKDIR /app
ENTRYPOINT [ "/opt/bitmoa/scripts/laravel/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/laravel/run.sh" ]
