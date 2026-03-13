#!/bin/bash

# Script to restore Contract Service MongoDB volume from tar.gz backup
# Usage: ./restore-contracts.sh /path/to/backup-file.tar.gz

set -e

VOLUME_NAME="upcast-local-dev_mongo-contracts-data"   # Volume for mongo-contracts
CONTAINER_NAME="mongo-contracts-local"               # Mongo container name
BACKUP_FILE="${1:?Please provide path to backup tar.gz file}"

MONGO_USER="root"
MONGO_PASSWORD="12345678"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup file $BACKUP_FILE does not exist"
    exit 1
fi

echo "📦 Backup file: $BACKUP_FILE"
echo "🎯 Target volume: $VOLUME_NAME (container: $CONTAINER_NAME)"
echo ""

# Stop services that depend on this Mongo
echo "⏸️  Stopping contract-service and mongo-contracts..."
docker compose stop contract-service mongo-contracts

# Ensure volume exists
if ! docker volume inspect "$VOLUME_NAME" > /dev/null 2>&1; then
    echo "📁 Creating volume $VOLUME_NAME..."
    docker volume create "$VOLUME_NAME"
fi

# Restore data from backup
echo "📥 Restoring data from backup into $VOLUME_NAME..."
docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  -v "$(dirname "$(realpath "$BACKUP_FILE")"):/backup" \
  alpine \
  sh -c "rm -rf /data/* && tar xzf \"/backup/$(basename "$BACKUP_FILE")\" -C /data"

echo "✅ Restore completed!"

# Start Mongo + contract-service again
echo "🚀 Starting mongo-contracts and contract-service..."
docker compose up -d mongo-contracts contract-service

echo ""
echo "✅ All done! Waiting for MongoDB to be ready..."
sleep 10 

# Verify data on the *correct* container
echo ""
echo "📊 Checking databases on $CONTAINER_NAME:"
docker exec "$CONTAINER_NAME" mongosh \
    --username "$MONGO_USER" \
    --password "$MONGO_PASSWORD" \
    --authenticationDatabase admin \
    --quiet \
    --eval "db.adminCommand('listDatabases').databases.forEach(db => print(db.name + ' - ' + (db.sizeOnDisk/1024/1024).toFixed(2) + ' MB'))"

echo ""
echo "🎉 Restore complete!"

