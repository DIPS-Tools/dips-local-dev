#!/bin/bash

# Script to restore MongoDB volume from tar.gz backup
# Usage: ./restore-mongo-volume.sh [backup-file.tar.gz]

set -e

VOLUME_NAME="upcast-local-dev_mongo-data"  # Local Docker volume name
BACKUP_FILE="${1:?Please provide path to backup tar.gz file}"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup file $BACKUP_FILE does not exist"
    exit 1
fi

echo "📦 Backup file: $BACKUP_FILE"
echo "🎯 Target volume: $VOLUME_NAME"
echo ""

# Stop containers using the volume
echo "⏸️  Stopping containers that use the volume..."
docker compose stop negotiation-web negotiation-api mongo

# Check if volume exists, if not create it
if ! docker volume inspect "$VOLUME_NAME" > /dev/null 2>&1; then
    echo "📁 Creating volume $VOLUME_NAME..."
    docker volume create "$VOLUME_NAME"
fi

# Clear existing data (optional - uncomment if you want to clear first)
# echo "🗑️  Clearing existing data..."
# docker run --rm -v "${VOLUME_NAME}:/data" alpine sh -c "rm -rf /data/*"

# Restore data from backup
echo "📥 Restoring data from backup..."
docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  -v "$(dirname $(realpath $BACKUP_FILE)):/backup" \
  alpine \
  tar xzf "/backup/$(basename $BACKUP_FILE)" -C /data

echo "✅ Restore completed!"

# Start containers
echo "🚀 Starting containers..."
docker compose up -d mongo negotiation-web negotiation-api

echo ""
echo "✅ All done! Waiting for MongoDB to be ready..."
sleep 10

# Verify data
echo ""
echo "📊 Checking databases:"
docker exec mongo-local mongosh \
    --username root \
    --password gz1mQj9JuNty4R1TNT2qeChDPtJFhsdGP00wUxHeytWvnXke3wFnpjjfC7Q6zy3YTiWT7CDXYRue5quZ5EnQw13MmizHdcpqm6Mp \
    --authenticationDatabase admin \
    --quiet \
    --eval "db.adminCommand('listDatabases').databases.forEach(db => print(db.name + ' - ' + (db.sizeOnDisk/1024/1024).toFixed(2) + ' MB'))"

echo ""
echo "🎉 Restore complete!"

