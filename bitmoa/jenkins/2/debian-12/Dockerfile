# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG JAVA_EXTRA_SECURITY_DIR="/bitmoa/java/extra-security"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-10-15T13:48:36Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/jenkins/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/jenkins" \
      org.opencontainers.image.title="jenkins" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="2.528.1"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl fontconfig git jq libfontconfig1 openssh-client procps unzip zlib1g
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "nss-wrapper-1.1.16-0-linux-${OS_ARCH}-debian-12" \
      "render-template-1.0.9-158-linux-${OS_ARCH}-debian-12" \
      "jre-21.0.8-12-1-linux-${OS_ARCH}-debian-12" \
      "jenkins-2.528.1-0-linux-${OS_ARCH}-debian-12" \
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
RUN /opt/bitmoa/scripts/jenkins/postunpack.sh
ENV APP_VERSION="2.528.1" \
    BITMOA_APP_NAME="jenkins" \
    IMAGE_REVISION="0" \
    JAVA_HOME="/opt/bitmoa/java" \
    PATH="/opt/bitmoa/common/bin:/opt/bitmoa/java/bin:$PATH"

EXPOSE 8080 8443 50000

USER 1001
ENTRYPOINT [ "/opt/bitmoa/scripts/jenkins/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/jenkins/run.sh" ]
