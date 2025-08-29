# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitmoa.com/files/stacksmith"
ARG TARGETARCH

LABEL com.vmware.cp.artifact.flavor="sha256:c50c90cfd9d12b445b011e6ad529f1ad3daea45c26d20b00732fae3cd71f6a83" \
      org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-08-20T13:19:22Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/discourse/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/discourse" \
      org.opencontainers.image.title="discourse" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="3.5.0"

ENV OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages acl advancecomp ca-certificates curl file gifsicle git hostname imagemagick jhead jpegoptim libbrotli1 libbsd0 libbz2-1.0 libcom-err2 libcrypt1 libcurl4 libedit2 libffi8 libgcc-s1 libgmp10 libgnutls30 libgssapi-krb5-2 libhogweed6 libicu72 libidn2-0 libjpeg-turbo-progs libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.5-0 liblz4-1 liblzma5 libmd0 libncursesw6 libnettle8 libnghttp2-14 libnsl2 libp11-kit0 libpcre2-8-0 libpsl5 libreadline-dev libreadline8 librtmp1 libsasl2-2 libsqlite3-0 libssh2-1 libssl-dev libssl3 libstdc++6 libtasn1-6 libtinfo6 libtirpc3 libunistring2 libuuid1 libxml2 libxslt1.1 libyaml-0-2 libyaml-dev libzstd1 optipng pngcrush pngquant procps rsync zlib1g
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "python-3.12.11-9-linux-${OS_ARCH}-debian-12" \
      "wait-for-port-1.0.10-0-linux-${OS_ARCH}-debian-12" \
      "ruby-3.3.9-0-linux-${OS_ARCH}-debian-12" \
      "postgresql-client-17.6.0-0-linux-${OS_ARCH}-debian-12" \
      "node-20.19.4-1-linux-${OS_ARCH}-debian-12" \
      "brotli-1.1.0-6-linux-${OS_ARCH}-debian-12" \
      "discourse-3.5.0-0-linux-${OS_ARCH}-debian-12" \
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
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true
RUN /opt/bitmoa/ruby/bin/gem install --force bundler -v '< 2'
RUN uninstall_packages curl

COPY rootfs /
RUN /opt/bitmoa/scripts/discourse/postunpack.sh
ENV APP_VERSION="3.5.0" \
    BITMOA_APP_NAME="discourse" \
    IMAGE_REVISION="0" \
    PATH="/opt/bitmoa/python/bin:/opt/bitmoa/common/bin:/opt/bitmoa/ruby/bin:/opt/bitmoa/postgresql/bin:/opt/bitmoa/node/bin:/opt/bitmoa/brotli/bin:/opt/bitmoa/discourse/app/assets/javascripts/discourse/node_modules/ember-cli/bin:$PATH"

EXPOSE 3000

ENTRYPOINT [ "/opt/bitmoa/scripts/discourse/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/discourse/run.sh" ]
