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
      mkdir -p /etc/ss/cfg
 #
RUN      set -e && \
         set -o xtrace && \
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
      pcre-dev \
      alpine-sdk \
      cmake \
      udns-dev
 #
RUN apk add  --no-cache --virtual libbloom-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
  apk add  --no-cache --virtual libcork-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
  apk add  --no-cache --virtual libcorkipset-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
  apk add  --no-cache --virtual asciidoc --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main && \
  apk add  --no-cache --virtual xmlto --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main
#  apk add  --no-cache --virtual musl-utils --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main
#RUN ldconfig
  
 #
 # Build & install
 #
RUN cd /tmp/repo/shadowsocks-libev-${VERSION} && \
  ./autogen.sh && \
  ./configure --prefix=/usr --disable-documentation && \
#  make install && \
  cmake -DBUILD_STATIC=OFF . && \
  make && \
  make install && \
  ls /usr/bin/ss-* | xargs -n1 setcap cap_net_bind_service+ep && \
  apk del .build-deps 
 #
 # Runtime dependencies setup
 #
RUN  apk add --no-cache \
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
