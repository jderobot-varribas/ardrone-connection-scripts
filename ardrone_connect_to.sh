#!/bin/sh
#
# Copyright (c) 2015 Victor Arribas Raigadas
#
# This software is under GPL3 Lincense.
# You could get a copy at http://www.gnu.org/licenses/gpl-3.0.html
#
# Requires:
# * NetworkManager >= 0.96
#

ARDRONE_NAME=ardrone2_071042
[ ! -z "$1" ] && ARDRONE_NAME=$*


NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
FAIL_COLOR='\033[31;01m'

# Power down and up iface to force network scan (and recover a clean list ;)).
# Also `nmcli **-p** dev wifi list` might work (-p = force scan).
nmcli nm wifi off
nmcli nm wifi on
sleep 1
if ! nmcli -p dev wifi list | grep -q "$ARDRONE_NAME"
then
        echo "$FAIL_COLOR [FAIL] $NO_COLOR No wifi nammed '$ARDRONE_NAME'"
        return 1
else
        echo "Connecting to '$ARDRONE_NAME'..."
        if nmcli con list | grep -q "$ARDRONE_NAME"
        then
                # Already paired, just connect it
                nmcli con up id "$ARDRONE_NAME"
        else
                # Define new connection (may prompt root password)
                nmcli dev wifi connect "$ARDRONE_NAME"
        fi

        echo "Verifying connection..."
        ping -q -c 1 -W 0.1 192.168.1.1 1>/dev/null
        status=$?

        [ $status -eq 0 ] && msg="$OK_COLOR [SUCCESS$] $NO_COLOR" || msg="$FAIL_COLOR [FAIL] $NO_COLOR"
        echo "$msg connection to '$ARDRONE_NAME'"

        return $status
fi

