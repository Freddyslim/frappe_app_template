# update_vendors_copy.sh

Variant of `update_vendors.sh` that clones vendor repositories and stores them as normal directories without git metadata. Use this when you prefer not to keep submodules.

```mermaid
flowchart TD
    lists[vendors.txt + custom_vendors.json] --> update(update_vendors_copy.sh)
    update --> vendor[vendor/]
    update --> appsjson[apps.json]
```
