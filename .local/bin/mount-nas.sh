#!/bin/bash

# Wait for network to be available (up to 60 seconds)
for i in $(seq 1 30); do
    if ping -c 1 -W 2 truenas.ucg.sparky.best &>/dev/null; then
        break
    fi
    sleep 2
done

PASS=$(security find-internet-password -D "Network Password" -s "truenas.ucg.sparky.best" -w)

mount_share() {
    local share="$1"
    local mountpoint="$HOME/mnt/$share"
    mkdir -p "$mountpoint"
    # Only mount if not already mounted
    if ! mount | grep -q "$mountpoint"; then
        mount -t smbfs "//howie:${PASS}@truenas.ucg.sparky.best/${share}" "$mountpoint"
    fi
}

mount_share "media"
