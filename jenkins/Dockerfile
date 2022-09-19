FROM alpine:edge as build-jdk

RUN apk update && \
    apk --no-cache add openjdk11 && \
    rm -rf /var/cache/apk/*

RUN /usr/lib/jvm/java-11-openjdk/bin/jlink \
     --module-path /usr/lib/jvm/java-11-openjdk/jmods \
     --compress=2 \
     --add-modules jdk.jfr,jdk.management.agent,jdk.crypto.ec,java.base,java.logging,java.xml,jdk.unsupported,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \
     --no-header-files \
     --no-man-pages \
     --output /opt/jdk-11-mini-runtime

FROM alpine:edge

# Packages
RUN set -x \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    && apk add --no-cache --repository  http://dl-cdn.alpinelinux.org/alpine/edge/community \
    && apk update \
    && apk upgrade \
    && echo "*** Create SSH key ***" \
    && apk --no-cache add openssh-keygen \
    && ssh-keygen -q -t ed25519 -N '' -f ~/id_ed25519 \
    && apk del openssh-keygen \
    && apk add --no-cache ca-certificates supervisor openjdk11 bash git curl zip wget docker ttf-dejavu jq coreutils openssh py3-pip py3-distutils-extra py3-cffi \
    && echo "*** Installing docker-compose ***" \
    && pip3 install --upgrade pip \
    && pip3 install docker-compose \
    && apk del openjdk11 py3-pip py3-distutils-extra py3-cffi

# Time Zone
RUN apk --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata

# Jlink runtime
ENV JAVA_HOME=/opt/jdk-11-mini-runtime
ENV PATH="$PATH:$JAVA_HOME/bin"
COPY --from=build-jdk /opt/jdk-11-mini-runtime /opt/jdk-11-mini-runtime

# Jenkin
# https://www.jenkins.io/download/
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV JENKINS_VERSION 2.368

# Add scripts and plugin list
ADD src /var/jenkins_home/

# Install Jenkins and plugins from plugins.txt
RUN set -x && \
    echo "*** Installing jenkins ***" && \
    curl -sSL --create-dirs --retry 1 http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war -o /usr/share/jenkins/jenkins.war && \
    echo "*** Recursive solve and reduce plugin dependencies ***" && \
    bash -c 'curl -sSO https://updates.jenkins-ci.org/current/update-center.actual.json && \
    function solve { \
        for dependency in $(cat update-center.actual.json | jq --arg p "${1%:*}" -r '"'"'.plugins[] | select(.name == $p) | .dependencies[] | select(.optional == false) | .name + ":" + .version'"'"');do \
            echo $dependency >> /var/jenkins_home/plugins.txt; \
            solve $dependency; \
        done \
    } && \
    for plugin in $(tr '"'"'\n'"'"' '"'"' '"'"' < /var/jenkins_home/plugins.txt);do solve $plugin; done && \
    sort -Vr /var/jenkins_home/plugins.txt | sort -u -t: -k1,1 -o /var/jenkins_home/plugins.txt' && \
    echo "*** Jenkins install plugins from plugins.txt *** " && \
    while read plugin; do \
    echo "*** Downloading ${plugin} ***" && \
    curl -sSL --create-dirs --retry 3 https://updates.jenkins-ci.org/download/plugins/${plugin%:*}/${plugin#*:}/${plugin%:*}.hpi -o /var/jenkins_home/plugins/${plugin%:*}.jpi && \
    touch /var/jenkins_home/plugins/${plugin%:*}.jpi.pinned; \
    done < /var/jenkins_home/plugins.txt

# RUN echo "*** Create User jenkins ***" \
#     && addgroup -S jenkins --gid 1000 && adduser -S jenkins --home /var/jenkins_home/ --shell /sbin/nologin --uid 1000 -G jenkins

RUN apk --no-cache add supervisor bash \
    && echo "[program:jenkins]" >> "/etc/supervisord.conf" \
    && echo 'command=java -jar jenkins.war --httpPort=8080' >> "/etc/supervisord.conf" \
    && echo 'directory=/usr/share/jenkins/' >> "/etc/supervisord.conf" \
    && echo 'user=root' >> "/etc/supervisord.conf" \
    && echo 'environment=JENKINS_HOME=/var/jenkins_home' >> "/etc/supervisord.conf" \
    && echo 'stdout_logfile=/var/jenkins_home/jenkins.log' >> "/etc/supervisord.conf" \
    && echo 'autostart=true' >> "/etc/supervisord.conf" \
    && echo 'autorestart=true' >> "/etc/supervisord.conf"
    # && echo 'startsecs=0' >> "/etc/supervisord.conf" \
    # && echo 'redirect_stderr=true' >> "/etc/supervisord.conf" \
    # && echo 'stopasgroup=true' >> "/etc/supervisord.conf" \
    # && echo 'killasgroup=true' >> "/etc/supervisord.conf"

# RUN mkdir -p "/var/jenkins_home" \
#     && touch '/var/log/supervisord.log' \
#     && chown jenkins:jenkins "/var/jenkins_home" \
#     && chown jenkins:jenkins "/etc/supervisord.conf" \
#     && chown jenkins:jenkins '/var/log/supervisord.log'

WORKDIR /var/jenkins_home

RUN echo "#!/bin/bash" > ./start.sh \
    && echo 'exec "$@"' >> ./start.sh \
    && chmod +x ./start.sh

EXPOSE 8080 8443 50000

ENTRYPOINT [ "./start.sh" ]

CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisord.conf"]
