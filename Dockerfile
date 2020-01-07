FROM alpine:edge
MAINTAINER niiv0832 <dockerhubme-ssr@yahoo.com>


RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
      echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
      echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
      apk update && \
      apk upgrade && \
      apk add wget \
          c-ares \
          libcork \
          libcorkipset \
          libev \
          mbedtls \ 
          pcre && \
      wget -P /etc/apk/keys https://alpine-repo.sourceforge.io/DDoSolitary@gmail.com-00000000.rsa.pub && \
      echo 'https://alpine-repo.sourceforge.io/packages' >> /etc/apk/repositories && \
      apk update && \
      apk upgrade && \
      apk add shadowsocks-libev && \
      rm -rf /var/cache/apk/* && \
      mkdir -p /etc/ss/cfg
  
VOLUME ["/etc/ss/cfg/"]

EXPOSE 80

USER nobody

CMD /usr/bin/ss-server -c /etc/ss/cfg/shadowsocks.json
