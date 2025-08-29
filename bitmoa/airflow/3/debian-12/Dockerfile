# Copyright Bitmoa All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM ghcr.io/bitmoa/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitmoa.com/files/stacksmith"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="ghcr.io/bitmoa/minideb:bookworm" \
      org.opencontainers.image.created="2025-08-28T06:18:41Z" \
      org.opencontainers.image.description="Application packaged by Bitmoa" \
      org.opencontainers.image.documentation="https://github.com/bitmoa/containers/tree/main/bitmoa/airflow/README.md" \
      org.opencontainers.image.source="https://github.com/bitmoa/containers/tree/main/bitmoa/airflow" \
      org.opencontainers.image.title="airflow" \
      org.opencontainers.image.vendor="Bitmoa" \
      org.opencontainers.image.version="3.0.5"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl git krb5-user libbz2-1.0 libcom-err2 libcrypt1 libffi8 libgcc-s1 libgmp10 libgnutls30 libgss-dev libgssapi-krb5-2 libhogweed6 libidn2-0 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5-dev libkrb5support0 libldap-2.5-0 liblzma5 libmariadb3 libncursesw6 libnettle8 libnsl2 libp11-kit0 libreadline8 libsasl2-2 libsasl2-modules libsqlite3-0 libssl3 libstdc++6 libtasn1-6 libtinfo6 libtirpc3 libudev1 libunistring2 locales netbase openssh-client procps tzdata zlib1g
RUN --mount=type=secret,id=downloads_url,env=SECRET_DOWNLOADS_URL \
    DOWNLOADS_URL=${SECRET_DOWNLOADS_URL:-${DOWNLOADS_URL}} ; \
    mkdir -p /tmp/bitmoa/pkg/cache/ ; cd /tmp/bitmoa/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "ini-file-1.4.9-0-linux-${OS_ARCH}-debian-12" \
      "wait-for-port-1.0.10-0-linux-${OS_ARCH}-debian-12" \
      "airflow-3.0.5-0-linux-${OS_ARCH}-debian-12" \
      "python-3.12.11-9-linux-${OS_ARCH}-debian-12" \
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
RUN update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
RUN mkdir /.local && chmod g+rwX /.local
RUN uninstall_packages curl

COPY rootfs /
RUN /opt/bitmoa/scripts/airflow/postunpack.sh
RUN update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
RUN /opt/bitmoa/scripts/locales/generate-locales.sh
ENV AIRFLOW_HOME="/opt/bitmoa/airflow" \
    APP_VERSION="3.0.5" \
    BITMOA_APP_NAME="airflow" \
    IMAGE_REVISION="1" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LD_LIBRARY_PATH="/opt/bitmoa/airflow/venv/lib/python3.12/site-packages/numpy.libs:/opt/bitmoa/python/lib:$LD_LIBRARY_PATH" \
    LIBNSS_WRAPPER_PATH="/opt/bitmoa/common/lib/libnss_wrapper.so" \
    LNAME="airflow" \
    NSS_WRAPPER_GROUP="/opt/bitmoa/airflow/nss-wrapper/nss_group" \
    NSS_WRAPPER_PASSWD="/opt/bitmoa/airflow/nss-wrapper/nss_passwd" \
    PATH="/opt/bitmoa/airflow/venv/bin:/opt/bitmoa/common/bin:/opt/bitmoa/python/bin:$PATH"

EXPOSE 8080 8125 8793 8794

USER 1001
ENTRYPOINT [ "/opt/bitmoa/scripts/airflow/entrypoint.sh" ]
CMD [ "/opt/bitmoa/scripts/airflow/run.sh" ]
