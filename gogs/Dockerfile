FROM arm64v8/golang:alpine

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    && apk add --no-cache --repository  http://dl-cdn.alpinelinux.org/alpine/edge/community \
    && apk update && apk upgrade \
    && echo "*** Set Time Zone ***" \
    && apk --no-cache add tzdata \
    && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && apk del tzdata \
    && echo "*** Create SSH key ***" \
    && apk --no-cache add openssh-keygen \
    && ssh-keygen -q -t ed25519 -N '' -f ~/id_ed25519 \
    && apk del openssh-keygen \
    && echo "*** Build Gogs ***" \
    && apk add --no-cache git gcc libc-dev\
    && git clone --depth 1 https://github.com/gogs/gogs.git gogs
# https://github.com/mattn/go-sqlite3/issues/803
ENV CGO_CFLAGS="-g -O2 -Wno-return-local-addr"
RUN cd gogs && /usr/local/go/bin/go build -tags "cert" -o /app/gogs/gogs \
    && mkdir -p /data/gogs/data \
    && chmod 777 /data/gogs/data \
    && ln -s /data/gogs/data /app/gogs/data \
    && mkdir -p /data/gogs/log && chmod 777 /data/gogs/log \
    && ln -s /data/gogs/log /app/gogs/log

RUN echo "*** Create User git ***" \
    && addgroup -S git && adduser -S git -G git \
    && chown -R git:git /app/gogs

VOLUME ["/data"]
EXPOSE 22 3000

WORKDIR /app/gogs

RUN echo "#!/bin/ash" > /data/start.sh && echo 'exec "$@"' >> /data/start.sh \
    && chmod +x /data/start.sh \
    && chown git:git /data/start.sh

ENTRYPOINT ["/data/start.sh"]

CMD ["/app/gogs/gogs", "web"]

USER git
