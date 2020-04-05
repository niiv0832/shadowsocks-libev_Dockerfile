#ver-2020.04.05.12.24
###############################################################################
# BUILD STAGE
FROM alpine:edge as builder
##
RUN set -ex && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk add --no-cache --update --virtual build-depmain \
                                git \
                                autoconf \
                                automake \
                                build-base \
                                libev-dev \
                                c-ares-dev \
                                libtool \
                                linux-headers \
                                libsodium-dev \
                                mbedtls-dev \
                                pcre-dev \
                                libbloom-dev \
                                libcork-dev \        
                                libbloom-dev && \
    cd /tmp/ && \
    git clone https://github.com/shadowsocks/shadowsocks-libev.git && \
    cd shadowsocks-libev && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    rm -rf /tmp/shadowsocks-libev && \
    apk del build-depmain && \
    rm -rf /var/cache/apk/*
#    
###############################################################################
# PACKAGE STAGE
##
FROM alpine:edge
MAINTAINER niiv0832 <dockerhubme-sslibev@yahoo.com>
##
COPY --from=builder /usr/bin/ss-server /usr/bin/ss-server
##
RUN set -ex && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk add --no-cache --update c-ares \
                                libev \
                                libsodium \
                                mbedtls \
                                musl \
                                pcre \
                                libbloom \
                                libcork \
                                libcorkipset && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/ss/cfg 
##                       
VOLUME ["/etc/ss/cfg/"]
##
EXPOSE 7300
##
USER nobody
##
CMD /usr/bin/ss-server -c /etc/ss/cfg/shadowsocks.json -u
