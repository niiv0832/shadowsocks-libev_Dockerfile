FROM alpine:latest
MAINTAINER niiv0832 <dockerhubme-ssr@yahoo.com>

ARG VERSION=3.3.3

RUN wget --no-check-certificate https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${VERSION}/shadowsocks-libev-${VERSION}.tar.gz -O /tmp/${VERSION}.tar.gz && \
      mkdir -p /tmp/repo && \
      tar -C /tmp/repo/ -xf /tmp/${VERSION}.tar.gz && \
      rm /tmp/${VERSION}.tar.gz && \
      mkdir -p /etc/ss/cfg && \
      set -ex && \
 #
 # Build environment setup
 #
  apk add --no-cache --virtual .build-deps \
      autoconf \
      automake \
      build-base \
      c-ares-dev \
      libcap \
      libev-dev \
      libtool \
      libsodium-dev \
      linux-headers \
      mbedtls-dev \
      pcre-dev && \
 #
 # Build & install
 #
  cd /tmp/repo && \
  ./autogen.sh && \
  ./configure --prefix=/usr --disable-documentation && \
  make install && \
  ls /usr/bin/ss-* | xargs -n1 setcap cap_net_bind_service+ep && \
  apk del .build-deps && \
 #
 # Runtime dependencies setup
 #
  apk add --no-cache \
      ca-certificates \
      rng-tools \
      $(scanelf --needed --nobanner /usr/bin/ss-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) && \
  rm -rf /var/cache/apk/* && \
  rm -rf /tmp/repo
  
VOLUME ["/etc/ss/cfg/"]

EXPOSE 80

USER nobody

CMD exec ss-server -c /etc/ss/cfg/shadowsocks.json
