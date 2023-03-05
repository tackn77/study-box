FROM arm64v8/golang:alpine as build

ARG GOGS_VERSION=main

# https://github.com/mattn/go-sqlite3/issues/803
ENV CGO_CFLAGS="-g -O2 -Wno-return-local-addr"

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main && \
    apk add --no-cache --repository  http://dl-cdn.alpinelinux.org/alpine/edge/community && \
    apk update && apk upgrade && \
    echo "*** Set Time Zone ***" && \
    apk --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    echo "*** Preparing for Build ***" && \
    apk add --no-cache git gcc libc-dev

RUN echo "*** clone ***" && \
    git clone --depth 1 --branch $GOGS_VERSION https://github.com/gogs/gogs.git gogs && \
    echo "*** Build ***" && \
    cd gogs && /usr/local/go/bin/go build -tags "cert" -ldflags="-s -w" -trimpath -o /usr/local/bin/gogs

RUN apk add --no-cache openssh-keygen bash

FROM arm64v8/alpine:edge as gogs

ARG GOGS_HOME=/app/gogs
ARG DATA_HOME=/data
ARG USER=git
ARG UID=1000
ARG GROUP=${USER}
ARG GID=1000

COPY --from=build /etc/localtime /etc/localtime
COPY --from=build /usr/local/bin/gogs ${GOGS_HOME}/gogs

RUN apk add --no-cache git openssh bash && \
    echo "*** Create User ***" && \
    addgroup -S ${GROUP} --gid ${GID} && \
    adduser -S ${USER} --home ${GOGS_HOME} --shell /sbin/nologin --uid ${UID} -G ${GROUP} && \
    chown -R ${USER}:${GROUP} /app/gogs && \
    echo "*** Preparing for Data Folder ***" && \
    mkdir -p ${DATA_HOME}/repositories && ln -s ${DATA_HOME}/repositories ${GOGS_HOME}/gogs-repositories && \
    mkdir -p ${GOGS_HOME}/custom && chown -R ${USER}:${GROUP} ${GOGS_HOME}/custom && \
    mkdir -p ${DATA_HOME}/conf && ln -s ${DATA_HOME}/conf ${GOGS_HOME}/custom/conf && \
    mkdir -p ${DATA_HOME}/data && ln -s ${DATA_HOME}/data ${GOGS_HOME}/data  && \
    mkdir -p ${DATA_HOME}/log  && ln -s ${DATA_HOME}/log  ${GOGS_HOME}/log  && \
    chown -R ${USER}:${GROUP} ${DATA_HOME} && \
    echo "*** Preparing for Start ***" && \
    echo '#!/bin/ash' > /usr/bin/start.sh && \
    echo 'exec "$@"' >> /usr/bin/start.sh && \
    chmod 777 /usr/bin/start.sh

VOLUME ["/data"]
EXPOSE 22 3000

WORKDIR ${GOGS_HOME}

ENTRYPOINT ["/usr/bin/start.sh"]

CMD ["/app/gogs/gogs", "web"]

USER ${USER}