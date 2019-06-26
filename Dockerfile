FROM openjdk:8-jdk-slim

ARG jenkins_user=jenkins
ARG jenkins_group=jenkins
ARG docker_group=docker
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${jenkins_user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

# setup SSH server
RUN apt-get update \
    && apt-get install --no-install-recommends -y openssh-server git curl \
    && curl -sSL https://get.docker.com/ | sh \
    && mkdir /var/run/sshd \ 
    && rm -rf /var/lib/apt/lists/* \
    && apt-get remove -y curl

RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin yes/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/'

RUN groupadd -g ${gid} ${jenkins_group} \
    && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -G "${docker_group}" -m -s /bin/bash "${jenkins_user}"

VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

COPY setup-sshd /usr/local/bin/setup-sshd

EXPOSE 22

ENTRYPOINT ["setup-sshd"]
