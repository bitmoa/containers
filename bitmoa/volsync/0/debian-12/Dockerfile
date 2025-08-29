# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitmoa.com/files/stacksmith"
ARG TARGETARCH

LABEL com.vmware.cp.artifact.flavor="sha256:c50c90cfd9d12b445b011e6ad529f1ad3daea45c26d20b00732fae3cd71f6a83" \
      org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-08-22T17:03:30Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/volsync/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/volsync" \
      org.opencontainers.image.title="volsync" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="0.13.0"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages acl ca-certificates curl openssh-client openssh-server openssl perl procps rsync stunnel4
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "volsync-0.13.0-4-linux-${OS_ARCH}-debian-12" \
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
RUN useradd -r -u 1001 -g root volsync
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true
RUN sed -ir 's|^[#\s]*\(.*/etc/ssh/ssh_host_ecdsa_key\)$|#\1|' /etc/ssh/sshd_config && \
    sed -ir 's|^[#\s]*\(.*/etc/ssh/ssh_host_ed25519_key\)$|#\1|' /etc/ssh/sshd_config && \
    sed -ir 's|^[#\s]*\(PasswordAuthentication\)\s.*$|\1 no|' /etc/ssh/sshd_config && \
    sed -ir 's|^[#\s]*\(GSSAPIAuthentication\)\s.*$|\1 no|' /etc/ssh/sshd_config && \
    sed -ir 's|^[#\s]*\(AllowTcpForwarding\)\s.*$|\1 no|' /etc/ssh/sshd_config && \
    sed -ir 's|^[#\s]*\(X11Forwarding\)\s.*$|\1 no|' /etc/ssh/sshd_config && \
    sed -ir 's|^[#\s]*\(PermitTunnel\)\s.*$|\1 no|' /etc/ssh/sshd_config && \
    sed -ir 's|^[#\s]*\(PidFile\)\s.*$|\1 /tmp/sshd.pid|' /etc/ssh/sshd_config && \
    ln -s /opt/bitmoa/volsync/mover-restic /mover-restic && \
    ln -s /opt/bitmoa/volsync/mover-rsync /mover-rsync && \
    ln -s /opt/bitmoa/volsync/mover-rclone /mover-rclone && \
    ln -s /opt/bitmoa/volsync/mover-rsync-tls /mover-rsync-tls && \
    ln -s /opt/bitmoa/volsync/mover-syncthing /mover-syncthing && \
    chmod +r /mover-restic/* /mover-rsync/* /mover-rsync-tls/* /mover-rclone/* /mover-syncthing/* && \
    chmod +x /mover-restic/*.sh /mover-rsync/*.sh /mover-rsync-tls/*.sh /mover-rclone/*.sh /mover-syncthing/*.sh
RUN uninstall_packages curl

ENV APP_VERSION="0.13.0" \
    BITMOA_APP_NAME="volsync" \
    IMAGE_REVISION="3" \
    PATH="/opt/bitmoa/diskrsync/bin:/opt/bitmoa/rclone/bin:/opt/bitmoa/syncthing/bin:/opt/bitmoa/volsync/bin:$PATH"

USER 1001
