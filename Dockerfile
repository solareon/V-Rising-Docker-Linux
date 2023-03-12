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

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        cabextract \
        git \
        gnupg \
        gosu \
        gpg-agent \
        jq \
        locales \
        p7zip \
        pulseaudio \
        pulseaudio-utils \
        sudo \
        tzdata \
        unzip \
        wget \
        winbind \
        xvfb \
        zenity \
    && rm -rf /var/lib/apt/lists/*

# Install wine
ARG WINE_BRANCH="stable"
RUN mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --install-recommends winehq-${WINE_BRANCH} \
    && rm -rf /var/lib/apt/lists/*

# Install winetricks
RUN wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/bin/winetricks

# Install mcrcon
RUN wget -O /tmp/mcrcon.tar.gz https://github.com/Tiiffi/mcrcon/releases/download/v0.7.2/mcrcon-0.7.2-linux-x86-64.tar.gz \
    && tar -zxvf /tmp/mcrcon.tar.gz -C /usr/bin/ mcrcon \
    && chmod +x /usr/bin/mcrcon \
    && rm /tmp/mcrcon.tar.gz

# Setup logging to docker container
RUN ln -sf /proc/1/fd/1 ${STEAMAPPDATA}/VRisingServer.log

# Switch to user
USER ${USER}

WORKDIR ${HOMEDIR}

COPY run.sh .

ENTRYPOINT [ "bash", "run.sh" ]

EXPOSE ${GAME_PORT}/udp ${QUERY_PORT}/udp ${RCON_PORT}/udp