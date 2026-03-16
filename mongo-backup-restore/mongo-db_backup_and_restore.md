# Mongo Backup and Restore

## 1. Backup

### 1.1 Backup `negotiation-plugin`

```bash
docker exec -t be9cf0c18b46 mongodump \
  --username "root" \
  --password "gz1mQj9JuNty4R1TNT2qeChDPtJFhsdGP00wUxHeytWvnXke3wFnpjjfC7Q6zy3YTiWT7CDXYRue5quZ5EnQw13MmizHdcpqm6Mp" \
  --authenticationDatabase "admin" \
  --archive=./mongo_backup_negotiation.archive \
  --gzip
```

### 1.2 Backup `contract-service`

```bash
docker exec -t dd68b4ae0554 mongodump \
  --username "root" \
  --password "12345678" \
  --authenticationDatabase "admin" \
  --archive=./mongo_backup_contract.archive \
  --gzip
```

## 2. Copy to Local Machine

```bash
docker cp be9cf0c18b46:./mongo_backup_negotiation.archive ./mongo_backup_negotiation.archive
docker cp dd68b4ae0554:./mongo_backup_contract.archive ./mongo_backup_contract.archive
```

## 3. Import to Another Machine

### 3.1 For `Negotiation-Manager`

Go into the container and create a folder:

```bash
docker exec -it ea869deca3f1 /bin/bash
mkdir dump
```

Copy the backup file into the container:

```bash
docker cp mongo-backup-restore/mongo_backup_negotiation.archive ea869deca3f1:./dump/mongo_backup_negotiation.archive
```

### 3.2 For `contract-service`

Go into the container and create a folder:

```bash
docker exec -it 3030c6b10d52 /bin/bash
mkdir dump
```

Copy the backup file into the container:

```bash
docker cp mongo-backup-restore/mongo_backup_contract.archive 3030c6b10d52:./dump/mongo_backup_contract.archive
```

## 4. Restore

### 4.1 Restore `Negotiation-Manager`

```bash
docker exec -t ea869deca3f1 mongorestore \
  --username "root" \
  --password "gz1mQj9JuNty4R1TNT2qeChDPtJFhsdGP00wUxHeytWvnXke3wFnpjjfC7Q6zy3YTiWT7CDXYRue5quZ5EnQw13MmizHdcpqm6Mp" \
  --authenticationDatabase "admin" \
  --archive=./dump/mongo_backup_negotiation.archive \
  --gzip
```

### 4.2 Restore `contract-service`

```bash
docker exec -t 3030c6b10d52 mongorestore \
  --username "root" \
  --password "12345678" \
  --authenticationDatabase "admin" \
  --archive=./dump/mongo_backup_contract.archive \
  --gzip
```