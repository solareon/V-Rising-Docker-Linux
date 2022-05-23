FROM steamcmd/steamcmd

USER root

ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install --no-install-recommends -y wine-stable wine32 wine64 xvfb jq && \
    apt-get clean

# RUN dpkg --add-architecture i386 \
#     && apt update \
#     && apt install -y wine64 wine32 wget unzip xvfb \
#     && mkdir -p /root/.wine/drive_c/steamcmd \
#     && mkdir -p /root/.wine/drive_c/users/root/AppData/LocalLow/'Stunlock Studios'/VRisingServer/Settings \
#     && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -P /root/.wine/drive_c/steamcmd/ \
#     && cd /root/.wine/drive_c/steamcmd/ \
#     && unzip steamcmd.zip \
#     && mkdir -p /root/.wine/drive_c/VRisingServer/ \
#     && cd /root/.wine/drive_c/steamcmd 

RUN mkdir -p /root/.wine/drive_c/users/root/AppData/LocalLow/'Stunlock Studios'/VRisingServer/ /root/.wine/drive_c/VRisingServer/ /template /config

COPY root .

COPY settings /template

WORKDIR /scripts

RUN chmod +x ./run.sh

CMD ./run.sh