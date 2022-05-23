#!/usr/bin/env bash
#Builds server settings
echo Building server config
if [[ -z "${SERVER_NAME}" ]]; then SERVER_NAME="A V-Rising Server" fi
if [[ -z "${SERVER_DESCRIPTION}" ]]; then SERVER_DESCRIPTION="A Default V-Rising Server Description" fi
if [[ -z "${GAME_PORT}" ]]; then GAME_PORT=27015 fi
if [[ -z "${QUERY_PORT}" ]]; then QUERY_PORT=27016 fi
if [[ -z "${MAX_USERS}" ]]; then MAX_USERS=40 fi
if [[ -z "${MAX_ADMIN}" ]]; then MAX_ADMIN=4 fi
if [[ -z "${SAVE_NAME}" ]]; then SAVE_NAME="world1" fi
if [[ -z "${SERVER_PASS}" ]]; then SERVER_PASS="password" fi
if [[ -z "${STEAM_LIST}" ]]; then STEAM_LIST=true fi
if [[ -z "${AUTOSAVE_NUM}" ]]; then AUTOSAVE_NUM=50 fi
if [[ -z "${AUTOSAVE_INT}" ]]; then AUTOSAVE_INT=300 fi
if [[ -z "${ADMIN_DBG}" ]]; then ADMIN_DBG=true fi
if [[ -z "${DISABLE_DBGEVT}" ]]; then DISABLE_DBGEVT=false fi

jq \
    --arg Name $SERVER_NAME \
    --arg Description $SERVER_DESCRIPTION \
    --arg Port $GAME_PORT \
    --arg QueryPort $QUERY_PORT \
    --arg MaxConnectedUsers $MAX_USERS \
    --arg MaxConnectedAdmins $MAX_ADMIN \
    --arg SaveName $SAVE_NAME \
    --arg Password $SERVER_PASS \
    --arg ListOnMasterServer $STEAM_LIST \
    --arg AutoSaveCount $AUTOSAVE_NUM \
    --arg AutoSaveInterval $AUTOSAVE_INT \
    --arg AdminOnlyDebugEvents $ADMIN_DBG \
    --arg DisableDebugEvents $DISABLE_DBGEVT \
    </template/ServerHostSettings.json >/config/ServerHostSettings.json

cp /template/ServerGameSettings.json /config/
cp /template/*.txt /config/

ln -s /config/ /root/.wine/drive_c/users/root/AppData/LocalLow/Stunlock\ Studios/VRisingServer/Settings
ln -s /saves/ /root/.wine/drive_c/users/root/AppData/LocalLow/Stunlock\ Studios/VRisingServer/Saves

cd /root/.wine/drive_c/steamcmd
if [ ! -e "./steaminstalled.txt" ]; then
    wincfg
    wine steamcmd.exe +force_install_dir "C:\VRisingServer" +login anonymous +app_update 1829350 validate +quit
    touch ./steaminstalled.txt
fi

rm -r /tmp/.X0-lock
cd /root/.wine/drive_c/VRisingServer/
Xvfb :0 -screen 0 1024x768x16 & \
DISPLAY=:0.0 wine VRisingServer.exe 2>&1