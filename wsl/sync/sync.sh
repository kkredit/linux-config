
# see 'man rsync' or https://linux.die.net/man/1/rsync

# Config
DEST_USER=kevin
DEST_IP=192.168.0.194
SYNC_DIR=/mnt/c/sync/

# options:
#   C: auto ignore files in CVS manner
#   a: archive (-rlptgoD) -- this breaks Windows permissions!
#   r: recursive
#   t: preserve times
#   v: verbose
#   u: update (skip newer files on receiver)
#   z: compress
SEND_OPTIONS=rtvuz
RECV_OPTIONS=rtvuz

# push out local changes -- but keep newer files there
rsync -$SEND_OPTIONS --exclude-from='exclude_list.txt' \
    $SYNC_DIR $DEST_USER@$DEST_IP:$SYNC_DIR
# pull in remote changes -- but keep newer files here
rsync -$RECV_OPTIONS --exclude-from='exclude_list.txt' \
    $DEST_USER@$DEST_IP:$SYNC_DIR $SYNC_DIR
