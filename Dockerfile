#ver-2020.01.16.12.47
###############################################################################
# BUILD STAGE
FROM alpine as builder
MAINTAINER niiv0832 <dockerhubme-sslibev@yahoo.com>
##
RUN set -ex && \
    apk add --no-cache --update git \
                                autoconf \
                                automake \
                                build-base \
                                libev-dev \
                                c-ares-dev \
                                libtool \
                                linux-headers \
                                libsodium-dev \
                                mbedtls-dev \
                                upx \
                                pcre-dev && \
                                echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
##                                apk update && \
                                apk add --no-cache --update \
                                                            libbloom-dev \
                                                            libcork-dev \        
                                                            libbloom-dev && \
    cd /tmp/ && \
    git clone https://github.com/shadowsocks/shadowsocks-libev.git && \
    cd shadowsocks-libev && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure --prefix=/usr --disable-documentation && \
    make install 
#    && \
#    upx --ultra-brute -qq /usr/bin/ss-server
#    
###############################################################################
# PACKAGE STAGE

FROM alpine:latest
##
COPY --from=builder /usr/bin/ss-server /usr/bin/ss-server
##
RUN set -ex && \
    mkdir -p /etc/ss/cfg && \
    apk add --no-cache c-ares \
                       libev \
                       libsodium \
                       mbedtls \
                       musl \
                       pcre 
##                       
VOLUME ["/etc/ss/cfg/"]
##
EXPOSE 7300
##
USER nobody
##
CMD /usr/bin/ss-server -c /etc/ss/cfg/shadowsocks.json -u
