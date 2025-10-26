# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-10-22T01:48:36Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/rails/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/rails" \
      org.opencontainers.image.title="rails" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="8.1.0"

ENV OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages build-essential ca-certificates curl git libaudit1 libbz2-1.0 libcap-ng0 libcrypt1 libffi8 libgcc-s1 libicu72 liblzma5 libmariadb3 libncurses6 libncursesw6 libpam0g libreadline-dev libreadline8 libsqlite3-0 libssl-dev libssl3 libstdc++6 libtinfo6 libxml2 libyaml-0-2 libyaml-dev pkg-config procps sqlite3 sudo unzip zlib1g zlib1g-dev
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "python-3.14.0-4-linux-${OS_ARCH}-debian-12" \
      "wait-for-port-1.0.10-3-linux-${OS_ARCH}-debian-12" \
      "ruby-3.2.9-2-linux-${OS_ARCH}-debian-12" \
      "node-24.10.0-0-linux-${OS_ARCH}-debian-12" \
      "mysql-client-12.0.2-0-linux-${OS_ARCH}-debian-12" \
      "rails-8.1.0-0-linux-${OS_ARCH}-debian-12" \
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
RUN /opt/bitmoa/scripts/rails/postunpack.sh
ENV APP_VERSION="8.1.0" \
    BITMOA_APP_NAME="rails" \
    IMAGE_REVISION="0" \
    PATH="/opt/bitmoa/python/bin:/opt/bitmoa/common/bin:/opt/bitmoa/ruby/bin:/opt/bitmoa/node/bin:/opt/bitmoa/mysql/bin:$PATH"

EXPOSE 3000

WORKDIR /app
ENTRYPOINT [ "/opt/bitmoa/scripts/rails/entrypoint.sh" ]
CMD [ "bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000" ]
