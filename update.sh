#!/bin/bash
cd ~/bitcoincash || exit 1
pm2 stop bitcoincash && ./updater.sh -d ~ -n bitcoincash -s && pm2 start bitcoincash   
