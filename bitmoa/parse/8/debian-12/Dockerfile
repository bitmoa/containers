# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="github.com/bitmoa/downloads/raw/refs/heads/main/files"
ARG TARGETARCH

LABEL com.vmware.cp.artifact.flavor="sha256:c50c90cfd9d12b445b011e6ad529f1ad3daea45c26d20b00732fae3cd71f6a83" \
      org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-08-07T18:00:04Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/parse/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/parse" \
      org.opencontainers.image.title="parse" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="8.2.3"

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
      "python-3.13.6-0-linux-${OS_ARCH}-debian-12" \
      "node-24.5.0-0-linux-${OS_ARCH}-debian-12" \
      "mongodb-shell-2.5.6-0-linux-${OS_ARCH}-debian-12" \
      "parse-8.2.3-0-linux-${OS_ARCH}-debian-12" \
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
RUN uninstall_packages curl

COPY rootfs /
RUN /opt/bitmoa/scripts/parse/postunpack.sh
ENV APP_VERSION="8.2.3" \
    BITMOA_APP_NAME="parse" \
    PATH="/opt/bitmoa/python/bin:/opt/bitmoa/node/bin:/opt/bitmoa/mongodb/bin:/opt/bitmoa/parse/bin:$PATH"

EXPOSE 1337 3000

USER 1001
ENTRYPOINT [ "/opt/bitmoa/scripts/parse/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/parse/run.sh" ]
