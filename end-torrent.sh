#!/bin/bash
#echo "torrent;$TR_TORRENT_NAME" | sponge >> /home/alban/.local/share/dwm/notification
notify-send -u normal "Torrent end" "$TR_TORRENT_NAME"
