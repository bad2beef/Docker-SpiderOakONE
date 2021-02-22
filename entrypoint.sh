#!/bin/bash
SPIDEROAK_BIN=/usr/bin/SpiderOakONE
SPIDEROAK_CONFIG=/home/spideroakone/.config/SpiderOakONE/

run_su() {
    su -c "$1" spideroakone
}

if [[ ! -z "${SPIDEROAK_UID}" ]]; then
    echo "Setting UID"
    usermod -u "${SPIDEROAK_UID}" spideroakone
fi
if [[ ! -z "${SPIDEROAK_GID}" ]]; then
    echo "Setting GID"
    groupmod -g "${SPIDEROAK_GID}" spideroakone
fi

if [[ -f "${SPIDEROAK_CONFIG}/setup.json" ]]; then
    echo "Starting SpiderOakONE Setup"
    run_su "\"${SPIDEROAK_BIN}\" --verbose --setup=\"${SPIDEROAK_CONFIG}/setup.json\""

    if [[ $? -ne 0 ]]; then
        echo "Failed SpiderOakONE Setup (${?})"
    else
        run_su "rm -f \"${SPIDEROAK_CONFIG}/setup.json\""
        echo "Completed SpiderOakONE Setup"
    fi
else
    if [[ -f "${SPIDEROAK_CONFIG}/selections.txt" ]]; then
        echo "Processing Selections"
        run_su "\"${SPIDEROAK_BIN}\" --reset-selection --force"
        while read LINE; do
            IFS=":" read -ra SELECTION <<< "$LINE"
            if [[ ! -z "${SELECTION[0]}" ]]; then
                run_su "\"${SPIDEROAK_BIN}\" --\"${SELECTION[0]}\"=\"${SELECTION[1]}\" --force"
            fi
        done < "${SPIDEROAK_CONFIG}/selections.txt"
        run_su "rm -f \"${SPIDEROAK_CONFIG}/selections.txt\""
        echo "Completed Processing Selections"
    fi
    
    echo "Starting SpiderOakONE"
    exec su -c "exec \"${SPIDEROAK_BIN}\" $*" spideroakone
fi
