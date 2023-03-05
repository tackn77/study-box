FROM debian:stable-slim

RUN    echo "*** upgrade ***" \
    && apt update && apt upgrade -y \

    && echo "*** Create SSH key ***" \
    && apt install -y openssh-client \
    && ssh-keygen -q -t ed25519 -N '' -f ~/id_ed25519 \

    && echo "*** Install ***" \
    && apt install -y sudo git zip wget curl gnupg2 lsb-release jq ttf-bitstream-vera \

    && echo "*** docker ***" \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
    && echo "deb [arch=arm64] https://download.docker.com/linux/debian $(lsb_release -sc) stable" > /etc/apt/sources.list.d/docker-ce.list \
    && apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io \

    && echo "*** docker-compose ***" \
    && apt install -y python3-pip python3-distutils-extra python3-cffi coreutils python3-distutils \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install docker-compose \
    && apt remove -y python3-pip python3-distutils-extra python3-cffi \
 
    && echo "*** Set Time Zone ***" \
    && apt install -y tzdata \
    && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && apt remove -y tzdata \

    && echo "*** Java ***" \
    && apt update && apt install -y default-jdk

# Jenkin
ENV JENKINS_HOME=/var/jenkins_home
ENV JENKINS_MASTER_AGENT_PORT=8080
ENV JENKINS_SLAVE_AGENT_PORT=50000

ENV USER=jenkins
ENV UID=1000
ENV GROUP=${USER}
ENV GID=1000
ENV CONFIG_FILE=supervisord.conf

RUN    echo "*** Create User jenkins ***" \
    && groupadd --gid ${GID} ${GROUP} \
    && useradd -d ${JENKINS_HOME} -s /sbin/nologin -u ${UID} -g ${GROUP} ${USER}  \
    && mkdir -p ${JENKINS_HOME}/log \

    && echo "*** Install jenkins ***" \
    && curl -sSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add - \
    && echo 'deb https://pkg.jenkins.io/debian binary/'  >> /etc/apt/sources.list \
    && apt update && apt install -y jenkins supervisor iptables \

    && echo "*** add sudoers ***" \
    && echo "jenkins ALL=(root) NOPASSWD: /usr/bin/docker" >> /etc/sudoers \
    && echo "jenkins ALL=(root) NOPASSWD: /etc/init.d/jenkins" >> /etc/sudoers \
    && echo "jenkins ALL=(root) NOPASSWD: /bin/bash" >> /etc/sudoers \

    && apt autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR ${JENKINS_HOME}

COPY "src" ${JENKINS_HOME}

EXPOSE ${JENKINS_MASTER_AGENT_PORT} ${JENKINS_SLAVE_AGENT_PORT}

RUN    echo "#!/bin/bash" > "/var/jenkins_home/start.sh" \
    && echo 'exec "$@"' >> "/var/jenkins_home/start.sh" \
    && chmod +x "/var/jenkins_home/start.sh" \
    && chown -R ${USER}:${GROUP} "/var/jenkins_home"

ENTRYPOINT ["/var/jenkins_home/start.sh"]

CMD ["/usr/bin/supervisord" ,"-c", "/var/jenkins_home/supervisord.conf" ]

USER "jenkins"
