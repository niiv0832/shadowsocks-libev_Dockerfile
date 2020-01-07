FROM alpine:latest
MAINTAINER niiv0832 <dockerhubme-ssr@yahoo.com>

ARG VERSION=3.3.3

RUN apk update && \
      apk upgrade && \
      apk add --no-cache --virtual unzip \
          wget && \
      mkdir -p /tmp/repo && \
      wget --no-check-certificate https://github.com/shadowsocks/shadowsocks-libev/archive/v${VERSION}.zip -O /tmp/repo/${VERSION}.zip && \
      unzip -d /tmp/repo /tmp/repo/${VERSION}.zip && \
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
  apk add libbloom-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
  apk add libcork-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
  apk add libcorkipset-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
  apk add asciidoc --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main && \
  apk add xmlto --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main && \
  
 #
 # Build & install
 #
  cd /tmp/repo/shadowsocks-libev-${VERSION} && \
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
