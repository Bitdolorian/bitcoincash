#!/bin/bash

# Version 1.0
working_directory="$HOME/bitcoincash/ckpool"
pm2_name="ckpool-bch"
configure_flags="--enable-sv2"

print () {
  no_color='\033[0m'
  if [ "$2" = "green" ]; then     color='\033[1;32m'
  elif [ "$2" = "yellow" ]; then  color='\033[1;33m'
  elif [ "$2" = "red" ]; then     color='\033[1;31m'
  fi
  echo -e "${color}$1${no_color}"
}

main () {
  cd "$working_directory" || exit 1

  # Check if update is available
  git fetch origin 2>/dev/null
  local behind=$(git rev-list --count HEAD..origin/master)
  if [ "$behind" = "0" ]; then
    print "Already up to date" green
    exit 0
  fi
  print "Updates available: $behind commit(s) behind upstream" yellow

  # Show what's coming
  print "Incoming changes:" yellow
  git log --oneline HEAD..origin/master | head -20

  read -r -p "Update ckpool-bch? [Y/n]: " answer
  if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then
    exit 0
  fi

  print "Stopping $pm2_name" yellow
  pm2 stop "$pm2_name" 2>/dev/null
  sleep 2

  # Stash uncommitted changes (config, etc.)
  print "Stashing local changes..." yellow
  git stash

  # Pull upstream (rebase to keep local commits on top)
  print "Pulling upstream..." yellow
  if ! git pull --rebase origin master; then
    print "git pull failed, aborting rebase" red
    git rebase --abort
    git stash pop
    pm2 start "$pm2_name"
    exit 1
  fi

  # Restore local changes
  print "Restoring local changes..." yellow
  if ! git stash pop; then
    print "WARNING: stash pop had conflicts - resolve manually" red
    print "Your changes are in: git stash list" yellow
  fi

  # Rebuild
  print "Rebuilding..." yellow
  if ! ./autogen.sh || ! ./configure $configure_flags || ! make -j$(nproc); then
    print "Build failed!" red
    pm2 start "$pm2_name"
    exit 1
  fi

  print "Restarting $pm2_name" yellow
  pm2 start "$pm2_name"
  print "Done." green
}

main
