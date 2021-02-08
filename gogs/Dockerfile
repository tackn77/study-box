FROM multiarch/ubuntu-core:arm64-focal

USER root

# update
RUN apt-get update && apt-get upgrade -y

# install sudo
RUN apt-get install -y sudo

# set TimeZone
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
RUN sudo apt-get install -y tzdata

# install git
RUN sudo apt-get install -y git

# add user
RUN sudo adduser --disabled-login --home /app/gogs --gecos 'Gogs' git

# Go言語 1.15.8 のインストール (1.14 以降が必要のためパッケージではNG)
# RUN sudo add-apt-repository ppa:longsleep/golang-backports 
# RUN sudo apt-get update
# RUN sudo apt-get install golang-go

# get src
ADD https://golang.org/dl/go1.15.8.linux-arm64.tar.gz /usr/local/src/go1.15.8.linux-arm64.tar.gz
RUN sudo tar -C /usr/local -xzf /usr/local/src/go1.15.8.linux-arm64.tar.gz

# setup build
WORKDIR /usr/local/src
RUN sudo apt-get install build-essential -y

# install Gogs
RUN git clone --depth 1 https://github.com/gogs/gogs.git gogs
RUN cd gogs && /usr/local/go/bin/go build -tags "cert" -o /app/gogs/gogs

RUN mkdir -p /data/gogs/data && chmod 777 /data/gogs/data
RUN ln -s /data/gogs/data /app/gogs/data
RUN mkdir -p /data/gogs/log && chmod 777 /data/gogs/log
RUN ln -s /data/gogs/log /app/gogs/log
RUN chown -R git:git /app/gogs

VOLUME ["/data"]
EXPOSE 22 3000

WORKDIR /app/gogs

RUN echo "#!/bin/bash" > data/start.sh && echo 'exec "$@"' >> data/start.sh && chmod +x data/start.sh
ENTRYPOINT ["/app/gogs/datastart.sh"]

CMD ["/app/gogs/gogs", "web"]

USER git
