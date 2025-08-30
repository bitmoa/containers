# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="github.com/bitmoa/downloads/raw/refs/heads/main/files"
ARG JAVA_EXTRA_SECURITY_DIR="/bitmoa/java/extra-security"
ARG TARGETARCH

LABEL com.vmware.cp.artifact.flavor="sha256:c50c90cfd9d12b445b011e6ad529f1ad3daea45c26d20b00732fae3cd71f6a83" \
      org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-08-19T18:43:48Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/sonarqube/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/sonarqube" \
      org.opencontainers.image.title="sonarqube" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="25.8.0"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages acl ca-certificates curl libbsd0 libedit2 libffi8 libgcc-s1 libgmp10 libgnutls30 libhogweed6 libicu72 libidn2-0 libldap-2.5-0 liblz4-1 liblzma5 libmd0 libnettle8 libp11-kit0 libsasl2-2 libssl3 libstdc++6 libtasn1-6 libtinfo6 libunistring2 libuuid1 libxml2 libxslt1.1 procps zlib1g
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "postgresql-client-17.6.0-0-linux-${OS_ARCH}-debian-12" \
      "jre-17.0.16-12-0-linux-${OS_ARCH}-debian-12" \
      "sonarqube-25.8.0-0-linux-${OS_ARCH}-debian-12" \
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
RUN /opt/bitmoa/scripts/java/postunpack.sh
RUN /opt/bitmoa/scripts/sonarqube/postunpack.sh
ENV APP_VERSION="25.8.0" \
    BITMOA_APP_NAME="sonarqube" \
    IMAGE_REVISION="2" \
    JAVA_HOME="/opt/bitmoa/java" \
    PATH="/opt/bitmoa/postgresql/bin:/opt/bitmoa/java/bin:$PATH"

EXPOSE 9000

USER 1001
ENTRYPOINT [ "/opt/bitmoa/scripts/sonarqube/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/sonarqube/run.sh" ]
