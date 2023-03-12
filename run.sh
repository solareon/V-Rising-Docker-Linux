#!/usr/bin/env bash
MCRCON_PASS=${RCON_PASSWORD}

term_handler() {
	
#!/usr/bin/bash
# without this, server exits suddenly due to systemd killing wrong pid (wine pid, not vrising)
PID=$(pgrep -f "^${STEAMAPPSERVER}/VRisingServer.exe")
echo "Stopping PID: $PID"
kill -SIGINT "$PID"

# systemd will eventually kill this if it doesnt work after 90s
while true; do
    sleep 1
    PID=PID=$(pgrep -f "^${STEAMAPPSERVER}/VRisingServer.exe")
    if [ -z "$PID" ]; then
        echo "Process successfully stopped gracefully"
        echo "Killing any leftover wine processes"
        wineserver -k
        sleep 1
        exit
    fi
    sleep 1
done
}
trap 'kill ${!}; term_handler' SIGTERM

#clear tmp
cd /tmp || exit
rm -R /tmp/* 2>/dev/null

if [ ! -d "${STEAMAPPDATA}/Settings" ]; then
    mkdir "${STEAMAPPDATA}/Settings"
fi

echo " "
echo "Updating V-Rising Dedicated Server files..."
# Override SteamCMD launch arguments if necessary
# Used for subscribing to betas or for testing
if [ -z "$STEAMCMD_UPDATE_ARGS" ]; then
        bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "$STEAMAPPSERVER" +login anonymous +app_update "$STEAMAPPID" +quit
else
        steamcmd_update_args=("${STEAMCMD_UPDATE_ARGS}")
        bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "$STEAMAPPSERVER" +login anonymous +app_update "$STEAMAPPID" "${steamcmd_update_args[@]}" +quit
fi

if [ ! -f "${STEAMAPPDATA}/Settings/ServerGameSettings.json" ]; then
        echo "${STEAMAPPDATA}/Settings/ServerGameSettings.json not found. Copying default file."
        cp "${STEAMAPPSERVER}/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "${STEAMAPPDATA}/Settings/" 2>&1
fi

CONFIG_FILE="${STEAMAPPDATA}/Settings/ServerHostSettings.json"
echo "Updating environment variables to server config"
jq '.Name = env.SERVER_NAME |
     .Description = env.SERVER_DESCRIPTION |
     .Address = env.SERVER_ADDRESS |
     .Port = env.GAME_PORT |
     .QueryPort = env.QUERY_PORT |
     .MaxConnectedUsers = env.MAX_USERS |
     .MaxConnectedAdmins = env.MAX_ADMIN |
     .Secure = env.VAC_ENABLE |
     .ListOnMasterServer = env.STEAM_LIST |
     .SaveName = env.SAVE_NAME |
     .Password = env.SERVER_PASS |
     .ServerFps = env.SERVER_FPS |
     .AutoSaveCount = env.AUTOSAVE_NUM |
     .AutoSaveInterval = env.AUTOSAVE_INT |
     .GameSettingsPreset = env.GAME_PRESET |
     .LanMode = env.LAN_MODE |
     .Rcon.Enabled = env.RCON_ENABLE |
     .Rcon.Port = env.RCON_PORT |
     .Rcon.Password = env.RCON_PASSWORD |
     .Rcon.BindAddress = env.RCON_ADDRESS' \
  < "${STEAMAPPSERVER}/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" \
  > "${CONFIG_FILE}"


#Restart cleanup
if [ -f "/tmp/.X0-lock" ]; then rm /tmp/.X0-lock; fi

cd "${STEAMAPPDIR}" || exit
echo "Starting V Rising Dedicated Server with name ${SERVER_NAME}"
echo "SteamAppId set to ${STEAMAPPID}"
echo "Starting Xvfb and wine64 ..."
echo " "

Xvfb :0 -screen 0 1024x768x16 & \
DISPLAY=:0.0 wine64 "${STEAMAPPSERVER}"/VRisingServer.exe -persistentDataPath "${STEAMAPPDATA}" \
    -serverName "$SERVER_NAME" -saveName "$SAVE_NAME" \
    -gamePort "$GAME_PORT" -queryPort "$QUERY_PORT" \
    -maxConnectedUsers "$MAX_USERS" -maxConnectedAdmins "$MAX_ADMIN" \
    -logFile "${STEAMAPPDATA}/VRisingServer.log" "${ADDITIONAL_ARGS}" 2>&1

while true
do
  tail -f /dev/null & wait ${!}
done