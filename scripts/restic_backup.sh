#!/usr/bin/env bash
# This script is intended to be run by a systemd timer

# Exit on failure or pipefail
set -e -o pipefail

BACKUP_TAG=systemd.timer
source /etc/backup/restic_env

# Remove locks in case other stale processes kept them in
restic unlock &
wait $!

#Do the backup

restic backup \
       --verbose
       --one-file-system \
       --tag $BACKUP_TAG \
       $BACKUP_PATH &

wait $!

# Remove old Backups

# Check if everything is fine
restic check &
wait $!

echo "Backup done!"
