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

## Repository Layout

This repository expects the application repositories to be cloned inside the `dips-local-dev` directory so that the folder names match the paths used in `docker-compose.yml`.

Expected local directories include:

- `Consent-Manager`
- `Negotiation-Tool`
- `Contract_Service`
- `User-Management`
- `Policy-Editor`

## Clone the Required Repositories

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
git clone git@github.com:DATAPACT/Consent-Manager.git
```

## Environment Configuration

Create or update the root `.env` file before starting the stack.

Review the example values and update them for your machine, especially:

- `HOST_ADDR`
- `MONGO_PASSWORD`
- `OPENAI_API_KEY`, if required by the services you plan to run

## Start the Environment

Build and start all configured services:

```bash
docker compose up -d --build
```

To inspect the resolved configuration:

```bash
docker compose config
```

## Using the Negotiation Tool

Once the stack is running:

1. Open `http://localhost:8001/negotiation/`.
2. Register users through the UI or API.
3. To simulate a negotiation between two parties, create:
   * one **consumer** account; and
   * one **provider** account.
4. Log in using one of the registered accounts.
5. If the following error occurs during login:
   ```text
   sqlite3.OperationalError: no such table: django_session
   ```
   execute these commands in order:
   ```bash
   docker compose exec negotiation-web python manage.py migrate custom_accounts --fake
   docker compose exec negotiation-web python manage.py migrate
   ```
   Then restart the `negotiation-web` service if necessary:
   ```bash
   docker compose restart negotiation-web
   ```
6. Create an offer from the provider side using the API. See the example below.
7. Submit a request from the consumer side through the UI or API.
8. Review the offer and exchange counter-offers as needed.
9. Accept the final offer.
10. Complete the provider agreement step.
11. Sign the negotiation from both the provider and consumer sides to finalise the negotiation.


The finalised negotiation should then appear in the finalised negotiations table and be available for download.

## Example: Create an Offer via API

Call the provider endpoint `/provider/offer/new` with a request body similar to the example below:

```json
{
  "title": "Population Census",
  "consumer_id": "<CONSUMER-ID>",
  "provider_id": "<PROVIDER-ID>",
  "data_processing_workflow_object": {
    "description": "Default data processing workflow",
    "data_processing_stages": [],
    "processing_purpose": "General data processing"
  },
  "natural_language_document": "",
  "resource_description_object": {
    "title": "Population Census",
    "price": 349.9,
    "price_unit": "USD/Month",
    "uri": "https://upcast-project.eu/dataset/3f8f9ee5-310d-488e-a6dd-8856d2639258",
    "policy_url": "https://upcast-project.eu/policy/71339e4f-36fb-4e95-8877-e100855c3e04",
    "environmental_cost_of_generation": {},
    "environmental_cost_of_serving": {},
    "description": "Results of the Population and Housing Census concerning the permanent population of the Municipality of Thessaloniki. The data were collected by ELSTAT (Hellenic Statistical Authority).",
    "type_of_data": "XML",
    "data_format": "XLS",
    "data_size": "246",
    "geographic_scope": ["UK", "Spain"],
    "tags": ["Home&Garden", "Family", "Community"],
    "languages": ["English", "Spanish"],
    "temporal_coverage": ["12/12/2022", "12/12/2025"],
    "publisher": "https://upcast-project.eu/producer/edc8b623-1c90-4980-9a60-1545278e79c2",
    "theme": [],
    "distribution": {
      "format": "XLS",
      "mediaType": "TEXT",
      "url": "https://tds.okfn.gr/product/209"
    },
    "created_at": "2025-12-16T16:17:33.790938",
    "updated_at": "2025-12-16T16:17:33.790947",
    "raw_object": null
  },
  "validity_period": "24",
  "odrl_policy": {},
  "contract_type": "dsa"
}
```

After the offer is created, the consumer can view the available offer and make a request (by clicking the 'Create Request' button through the UI) to the provider.

## Consent Manager

The Consent Manager uses the local emulator and supporting scripts in this repository. Add project-specific operational notes here; this will be updated soon.
