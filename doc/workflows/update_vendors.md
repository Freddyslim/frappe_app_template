# update-vendors.yml

Watches `vendors.txt` and `custom_vendors.json` to keep vendor repositories in sync.

```mermaid
flowchart TD
    files[vendors.txt & custom_vendors.json] --> workflow(update-vendors.yml)
    workflow --> script[run update_vendors.sh]
    script --> commit[commit changes]
```
