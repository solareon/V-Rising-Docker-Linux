FROM steamcmd/steamcmd

USER root
VOLUME ["/mnt/vrising/server", "/mnt/vrising/persistentdata"]

ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils && \
    apt-get install -y software-properties-common && \
    add-apt-repository multiverse && \
    dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get upgrade -y 

RUN apt-get update && \
    apt-get install -y wine-stable wine32 wine64 xvfb xserver-xorg jq wget && \
    apt-get clean

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT [ "/run.sh" ]