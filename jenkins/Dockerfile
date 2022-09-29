FROM alpine:edge as build-jdk

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    && apk add --no-cache --repository  http://dl-cdn.alpinelinux.org/alpine/edge/community \
    && apk update && apk upgrade \
    && apk --no-cache add openjdk11 \
    && rm -rf /var/cache/apk/*

RUN /usr/lib/jvm/java-11-openjdk/bin/jlink \
     --module-path /usr/lib/jvm/java-11-openjdk/jmods \
     --compress=2 \
     --add-modules jdk.jfr,jdk.management.agent,jdk.crypto.ec,java.base,java.logging,java.xml,jdk.unsupported,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument \
     --no-header-files \
     --no-man-pages \
     --output /opt/jdk-11-mini-runtime

FROM alpine:edge as jenkins

# Packages
RUN set -x \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    && apk add --no-cache --repository  http://dl-cdn.alpinelinux.org/alpine/edge/community \
    && apk update && apk upgrade \
    && echo "*** Create SSH key ***" \
    && apk --no-cache add openssh-keygen \
    && ssh-keygen -q -t ed25519 -N '' -f ~/id_ed25519 \
    && apk del openssh-keygen \
    && apk add --no-cache ca-certificates git curl zip wget docker ttf-dejavu jq coreutils openssh py3-pip py3-distutils-extra py3-cffi \
    && echo "*** Installing docker-compose ***" \
    && pip3 install --upgrade pip \
    && pip3 install docker-compose \
    && apk del py3-pip py3-distutils-extra py3-cffi \
    && echo "*** Set Time Zone ***" \
    && apk --no-cache add tzdata \
    && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && apk del tzdata \
    && apk --no-cache add supervisor bash \
    && rm -rf /var/cache/apk/*

# Jlink runtime
ENV JAVA_HOME=/opt/jdk-11-mini-runtime
ENV PATH=$PATH:${JAVA_HOME}/bin
COPY --from=build-jdk /opt/jdk-11-mini-runtime /opt/jdk-11-mini-runtime

# Jenkin
# https://www.jenkins.io/download/
ENV JENKINS_HOME=/var/jenkins_home
ENV JENKINS_MASTER_AGENT_PORT=8080
ENV JENKINS_SLAVE_AGENT_PORT=50000
ARG JENKINS_VERSION=main

ENV USER=jenkins
ENV UID=1000
ENV GROUP=${USER}
ENV GID=1000
ENV CONFIG_FILE=supervisord.conf

RUN echo "*** Create User jenkins ***" && \
    addgroup -S ${GROUP} --gid ${GID} && \
    adduser -S ${USER} --home ${JENKINS_HOME} --shell /sbin/nologin --uid ${UID} -G ${GROUP} && \
    mkdir -p ${JENKINS_HOME}/log && \
    apk --no-cache add supervisor bash \
    && rm -rf /var/cache/apk/* \
    && mkdir -p ${JENKINS_HOME}

WORKDIR ${JENKINS_HOME}

COPY "src" ${JENKINS_HOME}

# Install Jenkins and plugins from plugins.txt
RUN set -x && \
    echo "*** Installing jenkins ***" && \
    curl -sSL --create-dirs --retry 1 http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war -o ${JENKINS_HOME}/jenkins.war && \
    echo "*** Recursive solve and reduce plugin dependencies ***" && \
    bash -c 'curl -sSO https://updates.jenkins-ci.org/current/update-center.actual.json && \
    function solve { \
        for dependency in $(cat update-center.actual.json | jq --arg p "${1%:*}" -r '"'"'.plugins[] | select(.name == $p) | .dependencies[] | select(.optional == false) | .name + ":" + .version'"'"');do \
            echo $dependency >> ${JENKINS_HOME}/plugins.txt; \
            solve $dependency; \
        done \
    } && \
    for plugin in $(tr '"'"'\n'"'"' '"'"' '"'"' < ${JENKINS_HOME}/plugins.txt);do solve $plugin; done && \
    sort -Vr ${JENKINS_HOME}/plugins.txt | sort -u -t: -k1,1 -o ${JENKINS_HOME}/plugins.txt' && \
    echo "*** Jenkins install plugins from plugins.txt *** " && \
    while read plugin; do \
    echo "*** Downloading ${plugin} ***" && \
    curl -sSL --create-dirs --retry 3 https://updates.jenkins-ci.org/download/plugins/${plugin%:*}/${plugin#*:}/${plugin%:*}.hpi -o ${JENKINS_HOME}/plugins/${plugin%:*}.jpi && \
    touch ${JENKINS_HOME}/${plugin%:*}.jpi.pinned; \
    done < ${JENKINS_HOME}/plugins.txt

EXPOSE ${JENKINS_MASTER_AGENT_PORT} ${JENKINS_SLAVE_AGENT_PORT}

RUN echo "#!/bin/bash" > "/var/jenkins_home/start.sh" \
    && echo 'exec "$@"' >> "/var/jenkins_home/start.sh" \
    && chmod +x "/var/jenkins_home/start.sh"

RUN chown -R ${USER}:${GROUP} "/var/jenkins_home"

ENTRYPOINT ["/var/jenkins_home/start.sh"]

CMD ["/usr/bin/supervisord" ,"-c", "/var/jenkins_home/supervisord.conf" ]

USER "jenkins"