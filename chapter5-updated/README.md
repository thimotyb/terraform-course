# Chapter 5 (Azure) – versione aggiornata

Versione modernizzata di `chapter5/complete`: sito serverless "Ballroom" su Azure Functions + Table Storage.
L'originale usava componenti dismessi o deprecati. L'esempio aggiornato è stato verificato con `apply`, test del sito e `destroy`.

## Come si usa

```bash
az login --tenant <tenant-id>
export ARM_SUBSCRIPTION_ID=<subscription-id>   # oppure: terraform apply -var subscription_id=<id>
terraform init
terraform apply
terraform destroy
```

Dopo l'apply, `website_url` mostra la home page. L'API è su `<website_url>api/tweet` (GET, POST, PATCH, DELETE).

## Modifiche rispetto a `chapter5/complete`

| Area | Prima | Ora |
|---|---|---|
| Terraform | `>= 0.15` | `>= 1.5` |
| Provider `azurerm` | `~> 2.47` (2.99) | `~> 5.0` |
| Subscription nel provider | non richiesta | `subscription_id` obbligatorio da azurerm 4.x: variabile `subscription_id`, altrimenti `ARM_SUBSCRIPTION_ID` |
| App Service Plan | `azurerm_app_service_plan` (deprecato) con `kind = "functionapp"` e `sku { tier, size }` | `azurerm_service_plan` con `os_type = "Linux"` e `sku_name = "Y1"` (Consumption) |
| Function App | `azurerm_function_app` (deprecato) | `azurerm_linux_function_app` |
| Functions runtime | `version = "~2"` (dismesso) | `functions_extension_version = "~4"` |
| Node.js | `WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"` | `site_config.application_stack.node_version = "20"` |
| Worker runtime | `FUNCTIONS_WORKER_RUNTIME = "node"` in app_settings | impostato da `application_stack` |
| Application Insights | chiave in `app_settings` (`APPINSIGHTS_INSTRUMENTATIONKEY`) | `site_config.application_insights_key` |
| `azurerm_storage_container` | `storage_account_name` | `storage_account_id` |
| `azurerm_storage_blob` | `storage_account_name` + `storage_container_name` | `storage_container_id` |

Invariati: modulo `terraform-in-action/ballroom/azure` (codice dell'app), `random_string`, SAS token per `WEBSITE_RUN_FROM_PACKAGE`, variabili `location` e `namespace`.

## Verifica eseguita (28/10/2026)

- `terraform validate`, `plan`, `apply`: 8 risorse create, nessun errore.
- `GET /`: HTTP 200, pagina "Ballroom!".
- `POST /api/tweet` → 201, `GET /api/tweet` → 200 con il tweet salvato.
- `terraform destroy`: 8 risorse eliminate.

## Note

- Il codice dell'app (modulo ballroom) usa la libreria `azure-storage`, a sua volta deprecata, ma funziona ancora su Node 20.
- Il SAS token ha date fisse (2016-2048) come nell'originale: va bene per un esempio didattico, non per la produzione.
- Il piano Linux Consumption (Y1) ha un ritiro già annunciato da Microsoft. Per usi a lungo termine valutare Flex Consumption.
