FROM ubuntu:18.04

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates fontconfig locales vim dnsutils iputils-ping unzip libc6-i386 \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
# download java versions

# JDK 8 preparation start

ARG JDK8_MD5SUM='3511152bd52c867f8b550d7c8d7764aa'
ARG JDK8_URL='https://d3pxv6yz143wms.cloudfront.net/8.232.09.1/amazon-corretto-8.232.09.1-linux-x64.tar.gz'

RUN set -eux; \
    curl -LfsSo /tmp/openjdk.tar.gz ${JDK8_URL}; \
    echo "${JDK8_MD5SUM} */tmp/openjdk.tar.gz" | md5sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    JRE_HOME=/opt/java/openjdk/jre \
    JDK_18=/opt/java/openjdk \
    JDK_18_x64=/opt/java/openjdk \
    JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

RUN update-alternatives --install /usr/bin/java java ${JRE_HOME}/bin/java 1 && \
    update-alternatives --set java ${JRE_HOME}/bin/java && \
    update-alternatives --install /usr/bin/javac javac ${JRE_HOME}/../bin/javac 1 && \
    update-alternatives --set javac ${JRE_HOME}/../bin/javac

# JDK preparation end
##################################



ENV CONFIG_FILE=/data/teamcity_agent/conf/buildAgent.properties \
    LANG=C.UTF-8

LABEL dockerImage.teamcity.version="latest" \
      dockerImage.teamcity.buildNumber="latest"

COPY run-agent.sh /run-agent.sh
COPY run-services.sh /run-services.sh

RUN useradd -m buildagent -u 1024 && \
    chmod +x /run-agent.sh /run-services.sh && sync

LABEL dockerImage.teamcity.version="latest" \
      dockerImage.teamcity.buildNumber="latest"

    # Opt out of the telemetry feature
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true \
    # Disable first time experience
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true \
    # Configure Kestrel web server to bind to port 80 when present
    ASPNETCORE_URLS=http://+:80 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps perfomance
    NUGET_XMLDOC_MODE=skip \
    GIT_SSH_VARIANT=ssh \
    # Install .NET Core SDK
    DOTNET_SDK_VERSION=3.0.100
#
RUN apt-get update && apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install -y python3 git mercurial apt-transport-https ca-certificates software-properties-common sudo && \
                apt-get install -y libc6 \
                libgcc1 \
                libgssapi-krb5-2 \
                libicu60 \
                liblttng-ust0 \
                libssl1.0.0 \
                libstdc++6 \
                zlib1g \
                gettext \
                make \
                && rm -rf /var/lib/apt/lists/*

RUN     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
        apt-get update && \
        apt-cache policy docker-ce && \
        apt-get install -y  docker-ce=5:19.03.3~3-0~ubuntu-bionic \
                            docker-ce-cli=5:19.03.3~3-0~ubuntu-bionic \
                            containerd.io=1.2.6-3 \
                            systemd && \
        apt-get clean all && \
        rm -rf /var/lib/apt/lists/*

RUN        systemctl disable docker \
            && curl -SL "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
            && chmod +x /usr/local/bin/docker-compose \
            && usermod -aG docker buildagent

    # A better fix for TW-52939 Dockerfile build fails because of aufs
VOLUME /var/lib/docker

COPY run-docker.sh /services/run-docker.sh

COPY dist/buildagent /opt/buildagent

RUN mkdir -p /data/teamcity_agent/conf \
    && mkdir -p /opt/buildagent/work \
    && mkdir -p /opt/buildagent/system \
    && mkdir -p /opt/buildagent/temp \
    && mkdir -p /opt/buildagent/logs \
    && mkdir -p /opt/buildagent/tools \
    && chown -R buildagent:buildagent /data/teamcity_agent/ \
    && chown -R buildagent:buildagent /opt/buildagent \
    && chown -R buildagent:buildagent /services \
    && chmod +x /opt/buildagent/bin/*.sh

VOLUME /data/teamcity_agent/conf
VOLUME /opt/buildagent/work
VOLUME /opt/buildagent/system
VOLUME /opt/buildagent/temp
VOLUME /opt/buildagent/logs
VOLUME /opt/buildagent/tools

EXPOSE 8111

USER buildagent

CMD ["/run-services.sh"]

