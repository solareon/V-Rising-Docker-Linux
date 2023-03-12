###########################################################
# Dockerfile that builds a V-Rising Gameserver
###########################################################
FROM solareon/docker-steamcmd-wine:root
LABEL maintainer = "https://github.com/solareon"

ENV STEAMAPPID 1829350
ENV STEAMAPP vrising
ENV STEAMAPPDIR "/${STEAMAPP}"
ENV STEAMAPPSERVER "${STEAMAPPDIR}/server"
ENV STEAMAPPDATA "${STEAMAPPDIR}/data" 

ARG DEBIAN_FRONTEND=noninteractive

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

# Install xvfb and jq
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        xvfb \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Install mcrcon
ADD rcon.sh /usr/bin/rcon
RUN chmod a+x /usr/bin/rcon \
    && curl -fsSL https://github.com/Tiiffi/mcrcon/releases/download/v0.7.2/mcrcon-0.7.2-linux-x86-64.tar.gz | tar -zxvf - -C /usr/bin/ mcrcon \
    && chmod a+x /usr/bin/mcrcon

# Setup logging to docker container and build directories
RUN mkdir ${STEAMAPPDIR} ${STEAMAPPSERVER} ${STEAMAPPDATA} \
    && ln -sf /proc/1/fd/1 ${STEAMAPPDATA}/VRisingServer.log \
    && chown steam:steam -R ${STEAMAPPDIR} \
    && mkdir /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix \
    && chown root /tmp/.X11-unix/

# Switch to user
USER ${USER}

WORKDIR ${HOMEDIR}

COPY run.sh .

ENTRYPOINT [ "bash", "run.sh" ]

EXPOSE ${GAME_PORT}/udp ${QUERY_PORT}/udp ${RCON_PORT}/udp