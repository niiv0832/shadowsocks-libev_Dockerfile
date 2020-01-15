FROM alpine as builder
MAINTAINER niiv0832 <dockerhubme-sslibev@yahoo.com>

## arg SS_VER=3.3.4
## arg SS_OBFS_VER=0.0.5

RUN set -ex && \
##    apk add --no-cache udns && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
    apk add --no-cache --virtual .build-deps \
                                git \
                                autoconf \
                                automake \
##                                make \
                                build-base \
##                                curl \
                                libev-dev \
                                c-ares-dev \
                                libtool \
                                linux-headers \
                                libsodium-dev \
                                mbedtls-dev \
                                pcre-dev && \
##                                udns-dev && \
                                echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
                                apk update && \
                                apk add --no-cache --virtual .build-deps-edge\
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
    
###########################################---------------------------------###########################################

FROM alpine:latest
##
COPY --from=builder /usr/bin/ss-server /usr/bin/ss-server
##
RUN \
    mkdir -p /etc/ss/cfg && \
    touch /etc/ss/log.txt && \
##    
        echo "$( \
        scanelf --needed --nobanner /usr/bin/ss-server \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" >> /etc/ss/log.txt && \
##    
    apk add --no-cache c-ares \
                       libev \
                       libsodium \
                       mbedtls \
                       musl \
                       pcre 
#1                       ca-certificates \
#1                       rng-tools && \
#1    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
#1    apk update && \
#1    apk add --no-cache libbloom \
#1                       libcork \
#1                       libcorkipset && \
#1    apk add libcap && \
#1    ls /usr/bin/ss-* | xargs -n1 setcap cap_net_bind_service+ep && \
#1   apk del libcap && \
#1    rm -rf /var/cache/apk/*
##
##  
VOLUME ["/etc/ss/cfg/"]
##
EXPOSE 8081
##
USER nobody
##
CMD /usr/bin/ss-server -c /etc/ss/cfg/shadowsocks.json -u
