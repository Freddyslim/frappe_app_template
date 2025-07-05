# update_vendors.sh

Synchronise vendor submodules based on `vendors.txt` and `custom_vendors.json`. The script requires `jq` for JSON handling. Active vendor profiles are copied into `instructions/vendor_profiles/<relpath>` automatically. See [vendor_management.md](vendor_management.md) for details.

```mermaid
flowchart TD
    lists[vendors.txt + custom_vendors.json] --> update(update_vendors.sh)
    update --> vendor[vendor/]
    update --> appsjson[apps.json]
```
