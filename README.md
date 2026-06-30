# DIPS Local Development

This repository provides the local Docker Compose environment used to run the DIPS services for development and testing.

## Purpose

Use this repository to:

- manage the shared local development environment;
- start dependent services with Docker Compose;
- connect the related application repositories in a single workspace.

## Prerequisites

Before starting, ensure the following tools are installed:

- Git
- Docker
- Docker Compose

Minimal requirement: Docker with the Compose plugin is the only runtime requirement for the local stack itself. Git is also required because this repository expects the related application repositories to be cloned next to it.

Useful notes:

- You may need `sudo` for Docker commands on Linux if your user is not in the `docker` group.
- A local IP address is required for `HOST_ADDR` and `KEYCLOAK_HOST_ADDR`.
- Keycloak and MongoDB both have default test credentials in this repository so you can start quickly and change them later if needed.

## Repository Layout

This repository expects the application repositories to be cloned inside the `dips-local-dev` directory so that the folder names match the paths used in `docker-compose.yml`.

Expected local directories include:

- `Consent-Manager`
- `Negotiation-Tool`
- `Contract_Service`
- `User-Management`
- `Policy-Editor`

## Setup Local Server (Local Deployment)

1. Clone this repository:

	```bash
	git clone git@github.com:DIPS-Tools/dips-local-dev.git
	cd dips-local-dev
	```

2. Clone the related repositories into this directory:

	```bash
	git clone git@github.com:DATAPACT/Negotiation-Tool.git
	git clone git@github.com:DATAPACT/User-Management.git
	git clone git@github.com:DATAPACT/Contract_Service.git
	git clone git@github.com:DATAPACT/Policy-Editor.git
	```

3. Prepare Keycloak.

   If you already have a Keycloak server, use that server and note its IP address for the `.env` file.

   If you do not have a Keycloak server, start the default local Keycloak provided in this repository:

   ```bash
   cd keycloak
   docker compose up -d --build
   cd ..
   ```

   This starts a local Keycloak server on `http://localhost:9090` with the default admin credentials:

   - Username: `admin`
   - Password: `admin`

4. Configure Keycloak for DIPS.

   After your Keycloak server is running:

   - Open the Keycloak dashboard. For the local bundled setup, use `http://localhost:9090`
   - Sign in with your Keycloak admin account
   - Create the realm `dips_services`
   - Open `Realm settings` -> `User profile`
   - Add the user attributes (`username`, `email`, `firstName`, and `lastName` are default attributes; apart from these four attributes, create the following attributes):
     - `user_type`
     - `organization`
     - `incorporation`
     - `address`
     - `VAT_No`
     - `positionTitle`
     - `phone`
   - Add clients:
     - Open `Clients` -> `Create client`
     - For running Negotiation-Tool, add following clients:
       - `user-management-api`
       - `user-management-web`
       - `negotiation-web`
       - `negotiation-api`
       - `contract-service`
       - Note that: In the test env, for each client, the other clients are configured as allowed audiences, which means that a token requested by one client could be accepted by several other clients. 
5. Configure `.env` in the `dips-local-dev` directory.

   Review the example values and update them for your machine. At minimum, set the host IP values correctly:

   ```dotenv
   HOST_ADDR=<YOUR_MACHINE_IP_ADDRESS>
   KEYCLOAK_HOST_ADDR=<YOUR_KEYCLOAK_SERVER_IP_ADDRESS>
   ```

   If you are using the bundled local Keycloak from step 3, `KEYCLOAK_HOST_ADDR` is usually the same as `HOST_ADDR`.

   Default quick-test values are already provided for local testing:

   ```dotenv
   REALMS_NAME=dips_services
   KEYCLOAK_ADMIN_USERNAME=admin
   KEYCLOAK_ADMIN_PASSWORD=admin
   MONGO_USER=root
   MONGO_PASSWORD=admin
   ```

   If you just want a fast local installation for testing, you can keep those defaults. Change them only if you need a different local setup.

6. If required by your local Django configuration, update `Negotiation-Tool/privux/settings.py` to allow access from your machine IP:

   ```python
   ALLOWED_HOSTS = ["localhost", "127.0.0.1", "YOUR_MACHINE_IP_ADDR"]
   ```

7. Build and start the local DIPS environment.

   To build the environment without the Consent Manager, comment out the `consent-app` service in `docker-compose.yml`. The Consent Manager is still under development and is not yet ready for general use.

   ```bash
   sudo docker compose up -d --build
   ```

   MongoDB is started automatically by the main Compose stack. For a quick local test install, the default credentials are:

   - Username: `root`
   - Password: `admin`

8. Open the Negotiation Tool:

   `http://localhost:8001/negotiation/`

   - For user registration, click `Get Started` -> `Register`
   - For user login, click `Get Started` -> `Login`

9. If you get `Invalid HTTP_HOST header` while browsing:

   - Update `Negotiation-Tool/privux/settings.py`:

     ```python
     ALLOWED_HOSTS = ["localhost", "127.0.0.1", "YOUR_MACHINE_IP_ADDR"]
     ```

   - Restart the web container:

     ```bash
     sudo docker restart negotiation-web-local
     ```

10. If login fails with `OperationalError at /negotiation/login` and `no such table: django_session`, run:

   ```bash
   sudo docker compose exec negotiation-web python manage.py migrate custom_accounts --fake
   sudo docker compose exec negotiation-web python manage.py migrate
   ```

11. To inspect the resolved Docker Compose configuration:

   ```bash
   docker compose config
   ```

12. User guides are available in the `user_guide` folder. For the Negotiation Tool walkthrough, see [user_guide/Negotiation-Tool_user_guide.md](./user_guide/Negotiation-Tool_user_guide.md).
