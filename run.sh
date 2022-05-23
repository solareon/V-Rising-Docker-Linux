#!/usr/bin/env bash
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata
d=/mnt/vrising/persistentdata/dotnet
#setup directories
mkdir -p "$d" 2>/dev/null
chmod -R 777 "$d" 2>/dev/null

#clear tmp
cd /tmp
rm -R /tmp/* 2>/dev/null
echo " "
echo "Downloading and installing .NET SDK 6.0.300 and core runtime..."
echo " "
mkdir "$d" 2>/dev/null
if [ ! -f "$d/dotnet" ]; then
	if [ $(arch) == 'x86_64' ]; then
	### x64 ###
	wget https://download.visualstudio.microsoft.com/download/pr/dc930bff-ef3d-4f6f-8799-6eb60390f5b4/1efee2a8ea0180c94aff8f15eb3af981/dotnet-sdk-6.0.300-linux-x64.tar.gz
	wget https://download.visualstudio.microsoft.com/download/pr/a0e9ceb8-04eb-4510-876c-795a6a123dda/6141e57558eddc2d4629c7c14c2c6fa1/aspnetcore-runtime-6.0.5-linux-x64.tar.gz
    tar zxf dotnet-sdk-6.0.300-linux-x64.tar.gz -C "$d"
	tar zxf aspnetcore-runtime-6.0.5-linux-x64.tar.gz -C "$d"
    elif [ $(arch) == 'arm64' ]; then
    ### ARM ###
	wget https://download.visualstudio.microsoft.com/download/pr/2a6f82fe-0ae8-4867-9664-c8d012301a9a/496da28497b7c7f62151e9837eb5db6f/dotnet-sdk-6.0.300-linux-musl-arm64.tar.gz
	wget https://download.visualstudio.microsoft.com/download/pr/8ba7087e-4513-41e5-8359-a4bcd2a3661f/e6828f0d8cf1ecc63074c9ff57685e27/aspnetcore-runtime-6.0.5-linux-arm64.tar.gz
	tar zxf dotnet-sdk-6.0.300-linux-musl-arm64.tar.gz -C "$d"
	tar zxf aspnetcore-runtime-6.0.5-linux-arm64.tar.gz -C "$d"
	else
    echo "Unknown architecture"
	fi
	rm -R /tmp/*
fi

export DOTNET_ROOT=$d
export PATH=$PATH:$d
mkdir -p /root/.steam 2>/dev/null
#chmod -R 777 /root/.steam 2>/dev/null
echo " "
echo "Updating V-Rising Dedicated Server files..."
echo " "
/usr/bin/steamcmd +force_install_dir "$s" +login anonymous +app_update 1829350 +quit
echo "steam_appid: "`cat $s/steam_appid.txt`
echo " "


if [ ! -f "$p/ServerGameSettings.json" ]; then
        echo "$p/ServerGameSettings.json not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$p/" 2>&1
fi
if [ ! -f "$p/ServerHostSettings.json" ]; then
        echo "$p/ServerHostSettings.json not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$p/" 2>&1
fi
#Builds server settings from environment variables
echo Building server config
if [[ -z "${SERVER_NAME}" ]]; then export SERVER_NAME="A V-Rising Server"; fi
if [[ -z "${SERVER_DESCRIPTION}" ]]; then export SERVER_DESCRIPTION="A Default V-Rising Server Description"; fi
if [[ -z "${GAME_PORT}" ]]; then export GAME_PORT=27015; fi
if [[ -z "${QUERY_PORT}" ]]; then export QUERY_PORT=27016; fi
if [[ -z "${MAX_USERS}" ]]; then export MAX_USERS=40; fi
if [[ -z "${MAX_ADMIN}" ]]; then export MAX_ADMIN=4; fi
if [[ -z "${SAVE_NAME}" ]]; then export SAVE_NAME="world1"; fi
if [[ -z "${SERVER_PASS}" ]]; then export SERVER_PASS="password"; fi
if [[ -z "${STEAM_LIST}" ]]; then export STEAM_LIST=true; fi
if [[ -z "${AUTOSAVE_NUM}" ]]; then export AUTOSAVE_NUM=50; fi
if [[ -z "${AUTOSAVE_INT}" ]]; then export AUTOSAVE_INT=300; fi
if [[ -z "${GAME_PRESET}" ]]; then export GAME_PRESET="StandardPvP"; fi

jq \
  '.Name = env.SERVER_NAME | .Description = env.SERVER_DESCRIPTION | .Port = env.GAME_PORT | .QueryPort = env.QUERY_PORT | .MaxConnectedUsers = env.MAX_USERS | .MaxConnectedAdmins = env.MAX_ADMIN |  .SaveName = env.SAVE_NAME | .Password = env.SERVER_PASS | .ListOnMasterServer = env.STEAM_LIST | .AutoSaveCount = env.AUTOSAVE_NUM | .AutoSaveInterval = env.AUTOSAVE_INT | .GameSettingsPreset = env.GAME_PRESET' \
  < $s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json > $p/ServerHostSettings.json

cd "$s"
set SteamAppId=`cat $s/steam_appid.txt`
echo "Starting V Rising Dedicated Server with name $SERVER_NAME"
echo "SteamAppId set to $SteamAppId"
echo "Starting Xvfb and wine64 ..."
echo " "

Xvfb :0 -screen 0 1024x768x16 & \
DISPLAY=:0.0 wine64 /mnt/vrising/server/VRisingServer.exe -persistentDataPath $p -serverName $SERVER_NAME -saveName $SAVE_NAME -gamePort $GAME_PORT -queryPort $QUERY_PORT -maxConnectedUsers $MAX_USERS -maxConnectedAdmins $MAX_ADMIN -logFile "$p/VRisingServer.log" 2>&1