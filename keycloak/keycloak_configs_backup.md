You can copy most settings from `datapack-dev` to a new realm called `dips_services` by exporting `datapack-dev`, editing the exported JSON, and importing it as a new realm.

Keycloak officially supports realm export/import using `kc.sh export` and `kc.sh import`; export can target a specific realm with `--realm`, and import can read from a directory or file. Keycloak also notes that the server should not be running when using these commands directly. ([Keycloak][1])

## Recommended approach

### 1. Export the existing realm

Stop your current Keycloak container first:

```bash
docker stop keycloak-local
```

Create a folder:

```bash
mkdir -p ./keycloak-dips-services-export
```

Export `datapack-dev`:

```bash
docker run --rm \
  --name keycloak-export-datapack-dev \
  --volumes-from keycloak-local \
  -v "$(pwd)/keycloak-dips-services-export:/backup" \
  keycloak-keycloak:latest \
  export --dir /backup --realm datapack-dev
```

After this, you should see files like:

```bash
datapack-dev-realm.json
datapack-dev-users-0.json
```

The exact user files depend on your export strategy. Keycloak uses specific file naming conventions for directory imports, such as `<realm-name>-realm.json` and `<realm-name>-users-<number>.json`. ([Keycloak][1])

---

### 2. Copy and rename the exported realm file

```bash
cd keycloak-dips-services-export

cp datapack-dev-realm.json dips_services-realm.json
```

Then edit the new file:

```bash
nano dips_services-realm.json
```

Change at least these fields:

```json
"realm": "dips_services",
"id": "dips_services"
```

You may also want to update:

```json
"displayName": "DIPS Services"
```

Important: if the exported JSON contains hard-coded URLs for clients, redirect URIs, web origins, audience mappers, or client names, check whether they should still point to the old services or be renamed for the new realm.

---

### 3. Usually skip users when cloning realm settings

For your case, I suggest copying **settings only**, not users.

You can export without users like this:

```bash
docker run --rm \
  --name keycloak-export-datapack-dev \
  --volumes-from keycloak-local \
  -v "$(pwd)/keycloak-dips-services-export:/backup" \
  keycloak-keycloak:latest \
  export --dir /backup --realm datapack-dev --users skip
```

This gives you a cleaner new realm with the same clients, roles, groups, mappers, flows, etc., but without copying existing user accounts.

---

### 4. Import the new realm

Make sure the file name is:

```bash
dips_services-realm.json
```

Then import:

```bash
docker run --rm \
  --name keycloak-import-dips-services \
  --volumes-from keycloak-local \
  -v "$(pwd)/keycloak-dips-services-export:/backup" \
  keycloak-keycloak:latest \
  import --dir /backup --override false
```

I recommend `--override false` so Keycloak will not overwrite an existing realm accidentally. By default, Keycloak’s import uses override behavior unless configured otherwise. ([Keycloak][1])

Then start Keycloak again:

```bash
docker start keycloak-local
```

Open the Admin Console and check whether `dips_services` appears in the realm list.

---

## Important things to check after import

In the new `dips_services` realm, review these settings carefully:

```text
Clients
Client secrets
Valid redirect URIs
Web origins
Audience mappers
Client scopes
Realm roles
Client roles
Authentication flows
SMTP settings
Identity providers
Required actions
Token settings
```

Especially for your DIPS tools, check whether you need new clients such as:

```text
negotiation-web
negotiation-api
contract-service
consent-manager
authentication-api
```

If you copy from `datapack-dev`, old client IDs and old audience values may still exist. For example, an access token may still contain an old audience like `negotiation-api` or `datapack-api`, depending on your mapper settings.

---

## Simple note version

You can write this in your project notes:

```text
Create a new Keycloak realm dips_services by copying settings from datapack-dev

1. Stop the current Keycloak container

docker stop keycloak-local

2. Create a backup/export folder

mkdir -p ./keycloak-dips-services-export

3. Export the existing datapack-dev realm without users

docker run --rm \
  --name keycloak-export-datapack-dev \
  --volumes-from keycloak-local \
  -v "$(pwd)/keycloak-dips-services-export:/backup" \
  keycloak-keycloak:latest \
  export --dir /backup --realm datapack-dev --users skip

4. Copy the exported realm file

cd keycloak-dips-services-export
cp datapack-dev-realm.json dips_services-realm.json

5. Edit dips_services-realm.json

Change:

"realm": "datapack-dev"

to:

"realm": "dips_services"

Also change the id/displayName if present:

"id": "dips_services"
"displayName": "DIPS Services"

6. Import the new realm

docker run --rm \
  --name keycloak-import-dips-services \
  --volumes-from keycloak-local \
  -v "$(pwd)/keycloak-dips-services-export:/backup" \
  keycloak-keycloak:latest \
  import --dir /backup --override false

7. Start Keycloak again

docker start keycloak-local

8. Check in Keycloak Admin Console

Confirm the new realm dips_services exists.

9. Review important settings

Check clients, redirect URIs, web origins, client secrets, roles, client scopes, audience mappers, authentication flows, and token settings.
```

My recommendation: create `dips_services` from the exported `datapack-dev` settings, but use `--users skip` unless you specifically need to copy all existing users.

[1]: https://www.keycloak.org/server/importExport?utm_source=chatgpt.com "Importing and exporting realms"


