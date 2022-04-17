FROM alpine
ARG MKCERT_VERSION=1.4.3

WORKDIR /root

RUN apk --no-cache add wget ca-certificates
RUN set -ex \
    && wget -q -O /bin/mkcert https://github.com/FiloSottile/mkcert/releases/download/v$MKCERT_VERSION/mkcert-v$MKCERT_VERSION-linux-amd64 \
    && chmod +x /bin/mkcert

WORKDIR /root/.local/share/mkcert

CMD mkcert -install && mkcert