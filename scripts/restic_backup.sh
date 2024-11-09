#!/usr/bin/env bash
# This script is intended to be run by a systemd timer

# Exit on failure or pipefail
set -e -o pipefail

BACKUP_TAG=systemd.timer

# Retention policy
RETENTION_DAYS=14
RETENTION_WEEKS=16
RETENTION_MONTHS=18
RETENTION_YEARS=3

# generate exclude options
EXCLUDE_OPTIONS=""
for EXCLUDE_PATH in "${EXCLUDE_PATHS[@]}" 
do
    EXCLUDE_OPTIONS+="--exclude $EXCLUDE_PATH "
done

source /etc/backup/restic_env

# Remove locks in case other stale processes kept them in
restic unlock &
wait $!


#Do the backup for each path
restic backup --verbose --tag $BACKUP_TAG /mnt/backup-server/immich/backups/database/immich-db.sql
restic backup --verbose --tag $BACKUP_TAG /mnt/backup-server/immich/library --exclude /mnt/backup-server/immich/library/thumbs --exclude /mnt/backup-server/immich/library/encoded-video

# Remove old Backups

restic forget \
       --verbose \
       --tag $BACKUP_TAG \
       --prune \
       --keep-daily $RETENTION_DAYS \
       --keep-weekly $RETENTION_WEEKS \
       --keep-monthly $RETENTION_MONTHS \
       --keep-yearly $RETENTION_YEARS &
wait $!

# Check if everything is fine
restic check &
wait $!

unset RESTIC_PASSWORD
unset RESTIC_REPOSITORY
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

echo "Backup done!"
