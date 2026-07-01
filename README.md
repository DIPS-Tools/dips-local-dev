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

   - Open the Keycloak dashboard. For the local bundled setup, use `http://localhost:9090` (it might take a minute after the docker image has been built, before this service is reachable)
   - Sign in with your Keycloak admin account
   - Create the realm `dips_services` (Manage realms --> Create realm, only set the `Realm name` required field)
   - Open `Realm settings` -> `User profile`
   - Add the user attributes 
     - No need to change `username`, `email`, `firstName`, and `lastName`, which are default attributes; 
     -  apart from these four attributes, create the following attributes (only set the required attribute name field):
        - `user_type`
        - `organization`
        - `incorporation`
        - `address`
        - `VAT_No`
        - `positionTitle`
        - `phone`
   - Add clients:
     - Open `Clients` -> `Create client`
     - To run the Negotiation Tool, create the following Keycloak clients. When creating each client in the test environment, set the required `Client ID` field with the string below, and in the second screen enable the **Direct access grants** option. This is required because the Tool requests access tokens by sending the user's username and password directly to Keycloak. If this option is disabled, Keycloak returns the error: `Client not allowed for direct access grants`.
       - `user-management-api`
       - `user-management-web`
       - `negotiation-web`
       - `negotiation-api`
       - `contract-service`
       - In the test environment, each client is configured so that the other relevant clients are included as allowed audiences. This means that an access token requested by one client may be accepted by several other clients.

5. Configure `.env` in the `dips-local-dev` directory.

   Review the example values and update them for your machine. At minimum, update the host IP values correctly (e.g. for a local installation on Windows, look for the IPv4 Address with the `ipconfig` command):

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

6. Configure Django to Allow Access from Your Machine IP (Required)

   Update `Negotiation-Tool/privux/settings.py` to include your machine's IP address in `ALLOWED_HOSTS`. This configuration is **required** to allow Django to accept requests sent to your machine's IP address.

   ```python
   ALLOWED_HOSTS = ["localhost", "127.0.0.1", "YOUR_MACHINE_IP_ADDR"]
   ```


7. Build and start the local DIPS environment.

   The Consent Manager is currently under development and is not yet ready for general use. Therefore, the `consent-app` service is commented out in `docker-compose.yml` by default. This allows the environment to be built without the Consent Manager.

   ```bash
   sudo docker compose up -d --build
   ```

   MongoDB is started automatically by the main Compose stack. For a quick local test install, the default credentials are:

   - Username: `root`
   - Password: `admin`

8. TO avoid login failing with `OperationalError at /negotiation/login` and `no such table: django_session`, run:

   ```bash
   sudo docker compose exec negotiation-web python manage.py migrate custom_accounts --fake
   sudo docker compose exec negotiation-web python manage.py migrate
   ```

9. Open the Negotiation Tool:

   `http://localhost:8001/negotiation/`

   - For user registration, click `Get Started` -> `Register`
   - For user login, click `Get Started` -> `Login`

10. If you get `Invalid HTTP_HOST header` while browsing:

   - Update `Negotiation-Tool/privux/settings.py`:

     ```python
     ALLOWED_HOSTS = ["localhost", "127.0.0.1", "YOUR_MACHINE_IP_ADDR"]
     ```

   - Restart the web container:

     ```bash
     sudo docker restart negotiation-web-local
     ```

11. To inspect the resolved Docker Compose configuration:

   ```bash
   docker compose config
   ```

12. User guides are available in the `user_guide` folder. For the Negotiation Tool walkthrough, see [user_guide/Negotiation-Tool_user_guide.md](./user_guide/Negotiation-Tool_user_guide.md).
