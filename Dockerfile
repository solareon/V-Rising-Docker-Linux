###########################################################
# Dockerfile that builds a V-Rising Gameserver
###########################################################
FROM cm2network/steamcmd:root
LABEL maintainer = "https://github.com/solareon"

ENV STEAMAPPID 1829350
ENV STEAMAPP vrising
ENV STEAMAPPDIR "/${STEAMAPP}"
ENV STEAMAPPSERVER "${STEAMAPPDIR}/server"
ENV STEAMAPPDATA "${STEAMAPPDIR}/data" 

ENV SERVER_NAME="A V-Rising Server" \
    SERVER_DESCRIPTION="A Default V-Rising Server powered by Docker" \
    GAME_PORT=27015 \
    QUERY_PORT=27016 \
    SERVER_ADDRESS="" \
    SERVER_FPS=30 \
    MAX_USERS=40 \
    MAX_ADMIN=4 \
    SAVE_NAME="world1" \
    SERVER_PASS="password" \
    STEAM_LIST=true \
    AUTOSAVE_NUM=50 \
    AUTOSAVE_INT=300 \
    GAME_PRESET="" \
    STEAM_LIST=true \
    LAN_MODE=false \
    VAC_ENABLE=true \
    RCON_ENABLE=false \
    RCON_PASSWORD="" \
    RCON_PORT=25575 \
    RCON_ADDRESS="" \
    ADDITIONAL_ARGS="" \
    STEAMCMD_UPDATE_ARGS=""

RUN mkdir ${STEAMAPPDIR} ${STEAMAPPSERVER} ${STEAMAPPDATA}

RUN chown steam:steam -R ${STEAMAPPDIR}

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils && \
    apt-get install -y software-properties-common && \
    dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get upgrade -y 

RUN mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources

RUN apt-get update && \
    apt-get install -y --no-install-recommends winehq-stable wine32 wine64 xvfb xserver-xorg jq wget && \
    apt-get clean

# Switch to user
USER ${USER}

WORKDIR ${HOMEDIR}

COPY run.sh .

ENTRYPOINT [ "bash", "run.sh" ]

EXPOSE ${GAME_PORT}/udp ${QUERY_PORT}/udp ${RCON_PORT}/udp