#ver-2020.01.16.12.47
###############################################################################
# BUILD STAGE
FROM alpine:3.11 as builder
##
RUN set -ex && \
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
                                pcre-dev && \
                                echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
                                apk add --no-cache --update --virtual build-depsub \
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
    apk del build-depmain build-depsub && \
    rm -rf /var/cache/apk/*
#    
###############################################################################
# PACKAGE STAGE
##
FROM alpine:3.11
MAINTAINER niiv0832 <dockerhubme-sslibev@yahoo.com>
##
COPY --from=builder /usr/bin/ss-server /usr/bin/ss-server
##
RUN set -ex && \
    mkdir -p /etc/ss/cfg && \
    apk add --no-cache --update c-ares \
                                libev \
                                libsodium \
                                mbedtls \
                                musl \
                                pcre && \
    rm -rf /var/cache/apk/*
##                       
VOLUME ["/etc/ss/cfg/"]
##
EXPOSE 7300
##
USER nobody
##
CMD /usr/bin/ss-server -c /etc/ss/cfg/shadowsocks.json -u
