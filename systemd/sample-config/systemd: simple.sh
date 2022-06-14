#/opt/TSI/server-maintenance.sh

#!/bin/bash

while true;
do

  TIME="$(date +'%I:%M %p')"
  TARGET_TIME="12:00 AM"
  PROTECTED_INTERFACE="enp0s3"
  #echo $TIME

  #FOR SERVER AUTO UPDATE
  if [[ "$TIME" == "$TARGET_TIME" ]]; then
         dnf -y upgrade && sleep 59s;
  fi


  #FOR SERVER'S INTERFACE PROTECTION
  if ! ip -o address | grep -Eq "[[:digit:]]+:[[:space:]]+${PROTECTED_INTERFACE}" || ! ip -br -o address show "${PROTECTED_INTERFACE}" | grep -Eqi "[^[:space:]]+[[:space:]]+UP"; then

    if rpm -q network-scripts; then
        systemctl stop NetworkManager.service &> /dev/null
        sleep 0.5s
        ifup "${PROTECTED_INTERFACE}" || ip link set dev "${PROTECTED_INTERFACE}" up
        continue
    fi


    if ! rpm -q network-scripts; then
        systemctl unmask NetworkManager.service &> /dev/null
        systemctl restart NetworkManager.service
        nmcli device connect "${PROTECTED_INTERFACE}" || nmcli connection up "${PROTECTED_INTERFACE}" || \
          ip link set dev "${PROTECTED_INTERFACE}" up || ifup "${PROTECTED_INTERFACE}"
        continue
    fi


  fi

  sleep 1s

done
