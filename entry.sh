#!/bin/bash

# Check that the game is up-to-date
"${STEAMCMDDIR}/steamcmd.sh" "${STEAMCMDDIR}/steamcmd.sh" \
    @ShutdownOnFailedCommand \
    @NoPromptForPassword \
    +force_install_dir ${STEAMAPPDIR} \
    +login anonymous \
    +app_update ${STEAMAPPID} \
    +'quit'

cp ${BAR_CONFIG_IMPORT_DIR}/* ${STEAMAPPDIR}/ 
chown -R steam:steam "${BAR_CONFIG_IMPORT_DIR}"

# Update settings.xml using ENV varaibles
SETTINGS_XML=${STEAMAPPDIR}/serversettings.xml
sed -i "s/password=.*/password=\"${BAR_PASSWORD}\"/" "${SETTINGS_XML}"
sed -i "s/name=.*/name=\"${BAR_NAME}\"/" "${SETTINGS_XML}"
sed -i "s/ServerMessage=.*/ServerMessage=\"${BAR_SERVERMESSAGE}\"/" "${SETTINGS_XML}"
sed -i "s/startwhenclientsready=.*/startwhenclientsready=\"${BAR_START_WHEN_CLIENTS_READY}\"/" "${SETTINGS_XML}"
sed -i "s/startwhenclientsreadyratio=.*/startwhenclientsreadyratio=\"${BAR_START_WHEN_CLIENTS_READY_RATIO}\"/" "${SETTINGS_XML}"
sed -i "s/public=.*/public=\"true\"/" "${SETTINGS_XML}"

# Create client Permissions
# <Name>:<SteamID>:<Permissions>:<Commands>
# <InGameName1>:<SteamID1>:<Permission1.1>,<Permission1.2>,<Permission1.3>:<Command1.1>,<Command1.2>;<InGameName2>:<SteamID2>:<Permission2.1>,<Permission2.2>;<InGameName3>:<SteamID3>:<Permission3.1>:<Command3.1>,<Command3.2>;
# Commands are optional
CLIENT_PERMISSIONS_XML=${STEAMAPPDIR}/Data/clientpermissions.xml
echo \
    "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<ClientPermissions>" \
    >"$CLIENT_PERMISSIONS_XML"

IFS=$";"
for client_permission in ${BAR_PERMISSIONS}; do
    IFS=$":"
    client_permission_terms=($client_permission)

    name=${client_permission_terms[0]}
    steamid=${client_permission_terms[1]}
    permissions=${client_permission_terms[2]}
    commands=${client_permission_terms[3]}

    echo "  <Client name=\"${name}\" steamid=\"${steamid}\" permissions=\"${permissions}\">" >>"$CLIENT_PERMISSIONS_XML"

    IFS=$","
    for command in ${commands}; do
        echo "    <command name=\"${command}\"/>" >>"$CLIENT_PERMISSIONS_XML"
    done

    echo "  </Client>" >>"$CLIENT_PERMISSIONS_XML"
done

echo "</ClientPermissions>" >>"$CLIENT_PERMISSIONS_XML"

# Run the server!
"${STEAMAPPDIR}"/DedicatedServer
