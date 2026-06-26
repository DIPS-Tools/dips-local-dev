## Using the Negotiation Tool

Once the stack is running:

1. Open `http://localhost:8001/negotiation/`.
2. Register users through the UI.
3. To simulate a negotiation between two parties, create one **consumer** account and one **provider** account.
4. To find the user IDs needed by the system, open the User Management UI at `http://localhost:8801` and view the user information for both accounts. Use that page to get the `<CONSUMER-ID>` and `<PROVIDER-ID>` values when needed.
5. Log in using one of the registered accounts.
6. If the following error occurs during login:
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
7. Log in as the provider and create an offer through the GUI. The API can also be used for this, but the normal local test flow should use the web interface.
8. Log in as the consumer and submit a request through the GUI.
9. Review the offer and exchange counter-offers as needed.
10. Accept the final offer.
11. Complete the provider agreement step.
12. Sign the negotiation from both the provider and consumer sides to finalise the negotiation.


The finalised negotiation should then appear in the finalised negotiations table and be available for download.

## Example: Create an Offer via API

The GUI should be used for the main walkthrough above. If you need to create an offer programmatically, call the provider endpoint `/provider/offer/new` with a request body similar to the example below.

You can obtain `<CONSUMER-ID>` and `<PROVIDER-ID>` from the User Management UI at `http://localhost:8801` by opening the corresponding user records.

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

## Example: Exchange a Counter-Offer through the GUI

After a consumer submits a request, both parties can review the negotiation details in the Negotiation Tool UI and respond with counter-offers.

1. Open the negotiation entry from the dashboard.
2. Review the current offer details, including the ODRL policy terms shown in the negotiation page.
3. Modify one of the proposed terms. For example, update an ODRL permission so that the allowed use is narrower than the original provider offer.
4. Submit the updated proposal as a counter-offer from the GUI.
5. Log in as the other party, open the same negotiation, and review the updated terms.
6. Repeat this process until both sides agree on the final version.

Example counter-offer idea:

- Original offer: allow the consumer to use the dataset for `commercial-use`.
- Counter-offer: change that permission to a more limited use such as internal organisational use only, then submit the updated offer back through the negotiation screen.

The exact labels and editable fields depend on the current GUI version, but the negotiation page is the place where each side reviews the active terms and sends the next counter-offer.

## Example: Create a Request through the GUI

On the consumer side, Find the **Request New Dataset** area.

1. Click **Choose file**.

2. Select a JSON file, such as:

   ```text
   data_file_initialize_offer.json (Download link:  https://github.com/DIPS-Tools/dips-local-dev/blob/main/data_file_initialize_offer.json)
   ```
<img width="1555" height="291" alt="image" src="https://github.com/user-attachments/assets/ab4eb078-99ad-4266-9a7b-812857b217a2" />



3. Ensure that the JSON file contains a valid `dcat:contactPoint` field.

   The value of `dcat:contactPoint` can be the provider's organisation or email address. This information is used by the system to associate the request with the correct provider.

   For example:

   ```
     "dcat:contactPoint": "JOT"
     OR
     "dcat:contactPoint": "some-provider@example.com"
   ```

4. Click **Create Request**.

You can review the offer and respond it with a request.


