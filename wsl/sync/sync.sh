
# see 'man rsync' or https://linux.die.net/man/1/rsync

DEST_USER=Kevin
DEST_IP=192.168.0.194
DEST_USR_DIR=/cygdrive/c/Users/Kevin
HOST_USR_DIR=/cygdrive/c/Users/kevin
DIRS=(Music Documents Pictures Videos)
SEND_OPTIONS=rtvuz
RECV_OPTIONS=rtvuz
# options:
#   C: auto ignore files in CVS manner
#   a: archive (-rlptgoD) -- this breaks Windows permissions! At least on the filesystem on the remote machine
#   r: recursive
#   t: preserve times
#   v: verbose
#   u: update (skip newer files on receiver)
#   z: compress

for DIR in ${DIRS[@]}; do
    # push out local changes -- but keep newer files there
    rsync -$SEND_OPTIONS --exclude-from='exclude_list.txt' \
        $HOST_USR_DIR/$DIR/ \
        $DEST_USER@$DEST_IP:$DEST_USR_DIR/$DIR/
    # pull in remote changes -- but keep newer files here
    rsync -$RECV_OPTIONS --exclude-from='exclude_list.txt' \
        $DEST_USER@$DEST_IP:$DEST_USR_DIR/$DIR/ \
        $HOST_USR_DIR/$DIR/
done
