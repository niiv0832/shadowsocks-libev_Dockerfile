FROM alpine:edge
MAINTAINER niiv0832 <dockerhubme-ssr@yahoo.com>


RUN apk update && \
      apk upgrade && \
      cat /etc/apk/repositories && \
      apk add --no-cache --virtual unzip \
          wget \
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
      apk add --no-cache --virtual shadowsocks-libev && \
      mkdir -p /etc/ss/cfg && \
      ls /usr/bin/
  
VOLUME ["/etc/ss/cfg/"]

EXPOSE 80

USER nobody

CMD /usr/bin/ss-server -c /etc/ss/cfg/shadowsocks.json
