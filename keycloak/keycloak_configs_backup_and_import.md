##  Export Keycloak Configuration

if you just import the Keycloak Configuration, going down to find Section [Import Keycloak Configuration](#import-keycloak-configuration).

## Export Keycloak Configuration

Use the following steps on the source machine to export the `dips_services` realm before moving the configuration to another server.

### 1. Check that Keycloak and MySQL are running

Run:

```bash
docker ps
```

Confirm that these containers are running:

```text
keycloak-local-with-mysql
keycloak-mysql
```

### 2. Find the Docker network name

Run:

```bash
docker inspect keycloak-mysql \
  --format '{{range $name, $_ := .NetworkSettings.Networks}}{{$name}}{{"\n"}}{{end}}'
```

The output may look like:

```text
keycloak_default
```

Use this network name in the export command.

### 3. Create the export directory

Run:

```bash
mkdir -p keycloak-dips-services-export
```

Make sure the Keycloak container can write to the directory:

```bash
chmod 777 keycloak-dips-services-export
```

For a local development environment, this is the simplest option. For production systems, use more restrictive ownership and permissions where possible.

### 4. Stop the running Keycloak container

Before performing the offline export, stop the normal Keycloak container:

```bash
docker stop keycloak-local-with-mysql
```

Keep the MySQL container running.

### 5. Export the realm configuration

Run:

```bash
docker run --rm \
  --name keycloak-export-dips-services \
  --network keycloak_default \
  -e KC_DB=mysql \
  -e KC_DB_URL='jdbc:mysql://keycloak-mysql:3306/keycloak' \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=admin \
  -v "$(pwd)/keycloak-dips-services-export:/backup" \
  keycloak-keycloak:latest \
  export \
  --dir /backup \
  --realm dips_services \
  --users skip
```

If your Docker network is not `keycloak_default`, replace it with the network name found in Step 2.

### 6. Verify the exported file

Run:

```bash
ls -lah keycloak-dips-services-export
```

You should see a file similar to:

```text
dips_services-realm.json
```

This file can then be copied to the target machine and used with the Keycloak import procedure.

### 7. Start Keycloak again

After the export completes successfully, restart Keycloak:

```bash
docker start keycloak-local-with-mysql
```

or:

```bash
docker compose up -d
```

### Exporting users

The command above uses:

```bash
--users skip
```

which exports the realm configuration without realm users.

If user accounts also need to be migrated, use:

```bash
--users realm_file
```

instead:

```bash
docker run --rm \
  --name keycloak-export-dips-services \
  --network keycloak_default \
  -e KC_DB=mysql \
  -e KC_DB_URL='jdbc:mysql://keycloak-mysql:3306/keycloak' \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=admin \
  -v "$(pwd)/keycloak-dips-services-export:/backup" \
  keycloak-keycloak:latest \
  export \
  --dir /backup \
  --realm dips_services \
  --users realm_file
```

### Important notes

The export container must connect to the same MySQL database used by the running Keycloak instance. Do not rely on `--volumes-from` for this setup, because the Keycloak data is stored in the separate MySQL container.

Inside the Docker network, use:

```text
keycloak-mysql:3306
```

rather than the host-side MySQL port such as:

```text
localhost:3307
```








## Import Keycloak Configuration

After you have started the Keycloak environment with:

```bash
docker compose up -d
```

follow the steps below to import the previously exported Keycloak realm configuration.

### 1. Check that MySQL is running

Run:

```bash
docker ps --filter name=keycloak-mysql
```

You should see the `keycloak-mysql` container running.

### 2. Find the Docker network name

Run:

```bash
docker inspect keycloak-mysql \
  --format '{{range $name, $_ := .NetworkSettings.Networks}}{{$name}}{{"\n"}}{{end}}'
```

The output may look like:

```text
keycloak_default
```

Use this network name in the import command below.

### 3. Stop the Keycloak container

Before importing the realm configuration, stop the running Keycloak container:

```bash
docker stop keycloak-local-with-mysql
```

Keep the MySQL container running.

### 4. Import the Keycloak configuration

Make sure the exported configuration directory exists in the current directory, for example:

```text
keycloak-dips-services-export/
└── dips_services-realm.json
```

Then run:

```bash
docker run --rm \
  --name keycloak-import-dips-services \
  --network keycloak_default \
  -e KC_DB=mysql \
  -e KC_DB_URL='jdbc:mysql://keycloak-mysql:3306/keycloak' \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=admin \
  -v "$(pwd)/keycloak-dips-services-export:/backup:ro" \
  keycloak-keycloak:latest \
  import \
  --dir /backup
```

If your Docker network is not `keycloak_default`, replace it with the network name returned in Step 2.

A successful import should include a message indicating that the `dips_services` realm has been imported.

### 5. Start Keycloak again

After the import completes successfully, restart Keycloak:

```bash
docker start keycloak-local-with-mysql
```

Alternatively, you can run:

```bash
docker compose up -d
```

### 6. Verify the imported realm

Check the Keycloak logs:

```bash
docker logs keycloak-local-with-mysql --tail 100
```

Then open Keycloak in your browser:

```text
http://<server-ip>:9090
```

Log in with the configured administrator account and confirm that the following realm is available:

```text
dips_services
```

### Important

If the realm was originally exported using:

```bash
--users skip
```

the import contains the realm configuration but does not include Keycloak users.

If users also need to be migrated, the source Keycloak server should be exported using:

```bash
--users realm_file
```

