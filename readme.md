# Docker container for linux vrising server 
Based upon steamcmd with WINE added. Supports modifying server config via environment variables in addition to manual changes to the ServerGameSettings.json

[![Docker Pulls](https://badgen.net/docker/pulls/solareon/vrising-svr?icon=docker&label=pulls)](https://hub.docker.com/r/solareon/vrising-svr) 
[![Docker Stars](https://badgen.net/docker/stars/solareon/vrising-svr?icon=docker&label=stars)](https://hub.docker.com/r/solareon/vrising-svr) 
[![Docker Image Size](https://badgen.net/docker/size/solareon/vrising-svr?icon=docker&label=image%20size)](https://hub.docker.com/r/solareon/vrising-svr) 
![Github stars](https://badgen.net/github/stars/solareon/vrising-docker?icon=github&label=stars) 
![Github forks](https://badgen.net/github/forks/solareon/vrising-docker?icon=github&label=forks) 
![Github issues](https://img.shields.io/github/issues/solareon/vrising-docker)
![Github last-commit](https://img.shields.io/github/last-commit/solareon/vrising-docker)

# V Rising Dedicated Server Instructions
The V Rising Dedicated Server is as it sounds a dedicated server application running under WINE inside Docker for the game [V Rising](https://store.steampowered.com/app/1604030/V_Rising/).

# Running the Server
There are two methods to run the server. Docker Compose is the recommended version as it will all you to easily modify environment variables and restart/shutdown your server without remembering a complicated command line

### docker compose

```
version: "3"
services: 
  vrising:
    container_name: vrising-server
    image: solareon/vrising-svr:latest
    volumes: 
      - ~/vrising/server:/mnt/vrising/server
      - ~/vrising/persistentdata:/mnt/vrising/persistentdata
    environment:
      - "TZ=Europe/Berlin"
      - "SERVER_NAME=A V-Rising Server"
      - "SERVER_DESCRIPTION=A server for my friends"
      - GAME_PORT=27015
      - QUERY_PORT=27016
      - MAX_USERS=40
      - MAX_ADMIN=4
      - "SAVE_NAME=world1"
      - "SERVER_PASS=password"
      - STEAM_LIST=true
      - AUTOSAVE_NUM=50
      - AUTOSAVE_INT=300
      - "GAME_PRESET=StandardPvP"
    ports: 
      - "27015:27015/udp"
      - "27016:27016/udp"
    restart: unless-stopped
```

### docker cli
```
    docker run -d --name='vrising-server' \
    -e "TZ=Europe/Berlin" \
    -e "SERVER_NAME=A V-Rising Server" \ 
    -e "SERVER_DESCRIPTION=A server for my friends" \
    -e GAME_PORT=27015 \
    -e QUERY_PORT=27016 \
    -e MAX_USERS=40 \
    -e MAX_ADMIN=4 \
    -e "SAVE_NAME=world1" \
    -e "SERVER_PASS=password" \
    -e STEAM_LIST=true \
    -e AUTOSAVE_NUM=50 \
    -e AUTOSAVE_INT=300 \
    -e GAME_PRESET="StandardPvP" \
    -v '/home/user/vrising-server/server':'/mnt/vrising/server':'rw' \
    -v '/home/user/vrising-server/persistentdata':'/mnt/vrising/persistentdata':'rw' \
    -p 27015:27015/udp \
    -p 27016:27016/udp \
    'solareon/vrising-svr:latest'
```

# Configuring the Server
There are two main settings files that the server is using.
* `ServerHostSettings.json`
* `ServerGameSettings.json`

As the names suggest, one of them is for hosting related settings and the other one is for game play related settings.

The default settings of these can be found in `/server/VRisingServer_Data/StreamingAssets/Settings/`. These are only for reference and not used during the running over the server

After the server has loaded the default files it looks for local overrides. These are located in:
`/persistentdata/Settings`

Note: ServerHostSettings.json is overwritten on startup using information from server variables. If you do not define the environment variables they will be filled with the defaults from the table below.

# Environment Variables
The most important settings exposed as environment variables are the following:

| Setting | Value Type | Example Value | Comment |
|----------|:-------------:|:------:|---|
| SERVER_NAME | string | "My V Rising Server" | Name of server |
| SERVER_DESCRIPTION | string | "This is a role playing server" | Short description of server purpose, rules, message of the day |
| GAME_PORT | number | 27015 | UDP port for game traffic |
| QUERY_PORT | number | 27016 | UDP port for Steam server list features |
| MAX_USERS | number | 40 | Max number of concurrent players on server |
| MAX_ADMIN | number | 4 | Max number of admins to allow connect even when server is full |
| SAVE_NAME | string | "world1" | Name of save file/directory |
| SERVER_PASS | string | "password" | Set a password or leave empty |
| STEAM_LIST | boolean | true | Set to true to list on server list, else set to false |
| AUTOSAVE_NUM | number | 50 | Number of autosaves to keep |
| AUTOSAVE_INT | number | 300 | Interval in seconds between each auto save |
| GAME_PRESET | string | "StandardPvP" | Name of a GameSettings preset found in the GameSettingPresets folder. Using this may prevent any changes from `ServerGameSettings.json` from taking effect. |

If you want others to connect to your server, make sure you allow the server through your firewall. You might also need to forward ports on your router. To do this, please follow your manufacturer's instructions for your particular router.

If you want your server to show up on the server list you need to make sure that both the specified queryPort and gamePort is open in your firewall and forwarded on your router, otherwise just opening/forwarding the gamePort will be enough.

# Server Administration (In-Game)
To become an administrator in the game you will first need to modify the `adminlist.txt` file under `/persistentdata/Settings/` with your steamId (one steamId per line). This can be done without restarting your server. To become an administrator in the game you need to enable the console in the options menu, bring it down with `~` and authenticate using the `adminauth` console command. Once an administrator you can use a number of administrative commands like `banuser`, `bancharacter`, `banned`, `unban` and `kick`.

If you ban users through the in-game console the server will automatically modify the `banlist.txt` located under `/persistentdata/Settings/` but you can also modify this manually (one steamId per line).

## Admin Commands
Below is a list of some admin commands available in the console. This documentation is a work in progress
| Command | Arguments | Comment |
|----------|:-------------|:---|
| Alias | (Alias, Command) | Removes target alias
| Addtime | *number* | Adds up to 12 hours of in-game time. Game time only goes forward
| Adminauth | *N/A* | Grants admin privileges 
| Admindeauth | *N/A* | Relinquishes admin privileges
| Bancharacter | (Character Name) | Bans the user playing with the specified character name from the server
| Banned | *N/A* | Lists all banned players
| Banuser | (Steam ID) | Bans the user with the specified Steam ID from the server
| Changedurability | *N/A* | Change durability of equipped items
| Clear | *N/A* | Clears all text from the console
| GatherAllAllies | *N/A* | Teleports all allies to mouse cursor position
| GatherAllAlliesExceptMe | *N/A* | Teleports all allies, except you, to mouse cursor position
| GatherAllNonAllies | *N/A* | Teleport all non-allies to mouse cursor position
| GatherAllPlayers | *N/A* | Teleports all players to mouse cursor position
| GatherAllPlayersExceptMe | *N/A* | Teleports all players, except you, to mouse cursor position
| Give | (What, Amount) | Set value on the nearest entity
| Giveset | (What) | Set value on the nearest entity
| Hidecursor | (Unnamed Argument) | Set whether the cursor should be hidden or not
| Kick | (Character Name) | Kicks a player from the server
| Kill | *N/A* | Kills your character
| List | (Optional: Category) | Lists all existing commands and categories
| Listusers | (Include Disconnected) | Lists users that are active on the server
| MultiCommand | (Commands) | Executes multiple commands separated by the semi colon (;) character
| PlayerTeleport | *N/A* | Teleport player to mouse cursor position
| Reconnect | *N/A* | Reconnects to the server
| Setadminlevel | (user, level) | Set or change the admin level of a user
| TeleportPlayerToMe | (User) | Teleports a player to your location
| TeleportPlayerToMousePosition | (User) | Teleports a player to current mouse cursor position
| TeleportToChunk | (Unnamed Argument) | Teleport player to chunk co-ordinate
| TeleportToChunkWaypoint | (Unnamed Argument) | Teleport player to entered waypoint
| TeleportToNether | *N/A* | Teleport to nether
| TeleportToPlayer | (User) | Teleport to player location
| Unban | (User Index) | Unbans a player from the server. You need to run the banned command first to get a list of banned players


# Save Files
The default location for save files are:
`/persistentdata/Saves/`

## Backups
It is highly recommended to backup the save files often and before patching or before starting the server after having patched.

The current auto save settings allows you to set save interval and save count. So with the same amount of disk space you either save often but maybe not have that many save files (not so far back in time), or save less often (longer rollback in-case of crash) and have more save files, or high number of on both and consume more disk space. So, again, regularly backing up you save files is highly recommended in case your game state becomes corrupted.

For a point of comparison most save games are around 50-70MB per save. The default configuration will use around 3GB

