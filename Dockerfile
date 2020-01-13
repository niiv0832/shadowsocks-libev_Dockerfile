FROM alpine:latest
MAINTAINER niiv0832 <dockerhubme-sslibev@yahoo.com>

## arg SS_VER=3.3.4
## arg SS_OBFS_VER=0.0.5

RUN set -ex && \
    apk add --no-cache udns && \
    apk add --no-cache --virtual .build-deps \
                                git \
                                autoconf \
                                automake \
                                make \
                                build-base \
                                curl \
                                libev-dev \
                                c-ares-dev \
                                libtool \
                                linux-headers \
                                libsodium-dev \
                                mbedtls-dev \
                                pcre-dev \
                                tar \
                                udns-dev && \
##
    cd /tmp/ && \
    git clone https://github.com/shadowsocks/shadowsocks-libev.git && \
    cd shadowsocks-libev && \
##    git checkout v$SS_VER && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    cd /tmp/ && \
    git clone https://github.com/shadowsocks/simple-obfs.git shadowsocks-obfs && \
    cd shadowsocks-obfs && \
##    git checkout v$SS_OBFS_VER && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    cd .. && \
##
    runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" && \
    apk add --no-cache --virtual .run-deps $runDeps && \
    apk del .build-deps && \
    rm -rf /tmp/*
##      
    mkdir -p /etc/ss/cfg
  
VOLUME ["/etc/ss/cfg/"]

EXPOSE 80

USER nobody

CMD /usr/bin/ss-server -c /etc/ss/cfg/shadowsocks.json -u
