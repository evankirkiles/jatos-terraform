#!/bin/bash
# 0. if disable flag is set, exit immediately
if [ "$3" -eq "0" ]; then
  echo "Skipping mounting volume $1"
  exit
fi
# 1. get the real mount path
VOLUME="/dev/$(readlink /dev/$1)"
echo "Mounting volume $1: $VOLUME"
# 2. if the mount is unformatted, format it
if ! file -s $VOLUME | grep -q 'filesystem' && file -s $VOLUME | grep -q 'data' ; then
  mkfs -t xfs $VOLUME
fi
# 3. get the mount's UUID
if [[ "$(sudo blkid | grep $VOLUME)" =~ UUID=\"([^\s\"]*)\" ]]; then
  UUID=${BASH_REMATCH[1]}
else
  exit
fi
# 4. if mount not in fstab, it's unseen, so add it
if ! grep -q "$UUID" /etc/fstab; then
  mkdir -p $2
  if ! mountpoint -q $2; then
    mount $VOLUME $2
  fi
  # add fstab entry for auto-mount on reboot
  echo "UUID=$UUID $2 xfs defaults,nofail 0 2" | tee -a /etc/fstab >/dev/null
  echo "Added binded volume to $2 to /etc/fstab"
fi
