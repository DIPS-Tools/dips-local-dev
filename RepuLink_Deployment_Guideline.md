# RepuLink Deployment Guideline

Guide to deploying RepuLink locally via `dips-local-dev`. RepuLink is a FastAPI backend + React frontend, backed by its own PostgreSQL database, and it authenticates through the shared Keycloak + User Management services.

## Architecture

| Service | Image/Build | Port | Purpose |
|---|---|---|---|
| `repulink-db` | `postgres:17` | 5433 → 5432 | RepuLink's own database |
| `repulink-prestart` | `./RepuLink/backend` | — | One-shot: Alembic migrations + seed data, then exits |
| `repulink-backend` | `./RepuLink/backend` | 8000 | FastAPI API (`/docs` for OpenAPI) |
| `repulink-frontend` | `./RepuLink/frontend` | 8003 | React app served by nginx |

External dependencies (not part of the RepuLink build, but required for it to work):

- **Keycloak** (`dips_services` realm) — RepuLink has its own client, `repulink-web`, in the shared realm (see [Keycloak client for RepuLink](#keycloak-client-for-repulink) below). Users are still shared with the other DIPS tools; the dedicated client just means RepuLink logins are attributable in Keycloak's own event log instead of showing up as `user-management-web`.
- **`user-management-api`** (port 8800) — RepuLink's backend calls it at `USER_MANAGEMENT_API_URL`; this service in turn requires `mongo`.

Startup order is enforced by `depends_on` for the RepuLink containers themselves (`repulink-db` → `repulink-prestart` → `repulink-backend` → `repulink-frontend`), but **not** for Keycloak / `user-management-api` / `mongo` — those must be brought up separately before login will work.

## Prerequisites

- Docker + Docker Compose plugin
- Git
- A local machine IP address (for `HOST_ADDR`)

## 1. Clone required repos

RepuLink's Docker build context expects `./RepuLink/backend` and `./RepuLink/frontend` inside `dips-local-dev/`. `RepuLink/` is git-ignored here, so clone it fresh:

```bash
cd dips-local-dev/
git clone https://github.com/DIPS-Tools/RepuLink.git
git clone https://github.com/DATAPACT/User-Management.git   # RepuLink needs this for login
```

## 2. Start and configure Keycloak

```bash
cd keycloak
docker compose up -d --build
cd ..
```
Keycloak server may need a while for initialisation.
Runs at `http://localhost:9090` (usr:admin/pwd:admin). Then, one-time setup:

1. Create realm `dips_services`.
2. `Realm settings` → `User profile` → add attributes: `user_type`, `organization`, `incorporation`, `address`, `VAT_No`, `positionTitle`, `phone`. Not required for a basic login/auth smoke test — only needed if a registration flow writes these fields to the Keycloak user and you hit a user-profile validation error, or you need them to actually persist on the Keycloak side.
3. `Clients` → `Create client`:
   - `user-management-api`
   - `user-management-web` — **enable Direct access grants**
   - `repulink-web` — RepuLink's own client, see below
   - (only needed for the wider stack: `negotiation-web`, `negotiation-api`, `contract-service`)

If you already run a Keycloak server elsewhere, skip this and just point `KEYCLOAK_HOST_ADDR` at it (the `repulink-web` client and audience mapper below still need to exist on it).

## Keycloak client for RepuLink

RepuLink shares the `dips_services` user pool (so accounts still work across all DIPS tools) but authenticates through its **own client**, `repulink-web`, instead of piggybacking on `user-management-web`. This is what makes RepuLink logins distinguishable in Keycloak's event log without fragmenting the user base.

1. `Clients` → `Create client`, Client ID `repulink-web`, Client authentication **off** (public client, same as `user-management-web` — RepuLink's backend does a direct resource-owner password grant, no secret configured in compose).
2. `Capability config` → enable **Direct access grants**.
3. Add two Audience mappers under `Client scopes` → `repulink-web-dedicated` → `Add mapper` → `By configuration` → `Audience`. Keycloak does **not** automatically include the issuing client in a token's `aud` claim — only explicitly mapped audiences appear — so both are required or `repulink-backend`'s own `KEYCLOAK_AUDIENCE=repulink-web` check will reject every request after login:
   - `repulink-web-self-audience` → *Included Client Audience*: `repulink-web` (required — without this, RepuLink's own backend rejects its own tokens)
   - `user-management-api-audience` → *Included Client Audience*: `user-management-api` (so tokens are still accepted when RepuLink's backend forwards them to `user-management-api`)
4. Enable login event logging so RepuLink's usage actually shows up: `Realm settings` → `Events` → `User events settings` → toggle **Save events** on (default retention is fine for local dev). Login events will now carry `client_id=repulink-web`, filterable in `Events` → `User events`.

`docker-compose.yml` already points `repulink-prestart` and `repulink-backend` at this client (`KEYCLOAK_CLIENT_ID=repulink-web`, `KEYCLOAK_AUDIENCE=repulink-web`) — no `.env` changes needed.

## 3. Configure `.env`

At minimum, set your machine's IP:

```dotenv
HOST_ADDR=<YOUR_MACHINE_IP>
KEYCLOAK_HOST_ADDR=<YOUR_KEYCLOAK_IP>   # same as HOST_ADDR if using the bundled Keycloak
```

RepuLink-specific defaults (fine for local testing, override if needed):

```dotenv
REPULINK_POSTGRES_USER=postgres
REPULINK_POSTGRES_PASSWORD=admin_repulink
REPULINK_POSTGRES_DB=repulink
REPULINK_SECRET_KEY=repulink-local-dev-secret
REPULINK_FIRST_SUPERUSER=admin@example.com
REPULINK_FIRST_SUPERUSER_PASSWORD=admin123   # min 8 characters
```

Note: `VITE_API_URL` for the frontend is baked in at build time from `HOST_ADDR` (browser-facing), so re-run `--build` on `repulink-frontend` if `HOST_ADDR` changes.

## 4. Build and start

Bring up RepuLink plus the auth dependencies it needs (skip the rest of the stack — Negotiation Tool, Contract Service, Kafka, Policy Editor — unless you need them too):

```bash
sudo docker compose up -d --build \
  mongo user-management-api \
  repulink-db repulink-prestart repulink-backend repulink-frontend
```

Or bring up the entire DIPS environment:

```bash
sudo docker compose up -d --build
```

`repulink-prestart` runs migrations and seeds initial data automatically — no manual migration step is needed.

## 5. Access

- Frontend: `http://localhost:8003`
- Backend API docs: `http://localhost:8000/docs`
- Postgres (for inspection): host port `5433`, db `repulink`
- Login/signup go through Keycloak + `user-management-api`; an account created in RepuLink also works in the Negotiation Tool, and vice versa.

## Troubleshooting

- **Login fails / token errors** — confirm `repulink-web` exists with Direct access grants enabled, and that `user-management-api` + `mongo` are actually running (they aren't auto-started by RepuLink's `depends_on` chain).
- **Login succeeds but every page immediately logs you back out** — check `repulink-backend` logs for `Keycloak token verification failed: Audience doesn't match` (`docker logs repulink-backend-local`). Means the `repulink-web-self-audience` mapper (step 3 above) is missing, so the backend rejects its own client's tokens; the frontend treats any 401/403 as session-expired and force-logs-out. Add the mapper, then log out/in again to get a token minted with the right audience.
- **RepuLink can authenticate but calls to `user-management-api` get rejected (401/403)** — the `repulink-web` client is missing the `user-management-api` audience mapper (step 3 above), so tokens it issues aren't accepted by that service.
- **Frontend calls the wrong API host** — `VITE_API_URL` is baked in at build time; rebuild `repulink-frontend` after changing `HOST_ADDR`.
- **`repulink-backend` stuck waiting** — check `repulink-prestart` logs (`docker compose logs repulink-prestart-local`); the backend won't start until that job completes successfully.
- **`repulink-prestart` exits with code 2 on Windows** — check `RepuLink/backend/scripts/prestart.sh` for CRLF line endings. Bash will treat the trailing `\r` as part of the command name and fail with messages like `python: can't open file ...\r`; convert the file to LF and keep it covered by `.gitattributes` (`*.sh text eol=lf`).
- **Verify resolved config**: `docker compose config`

## Reference

Full RepuLink usage docs live in `RepuLink/USER_GUIDE.md` once cloned. General stack setup: [README.md](./README.md).
