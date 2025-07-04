# generate_diagrams.sh

Render all Mermaid files under `doc/` to SVG using `mmdc`.

```mermaid
flowchart TD
    mmd(mmd files) --> gen(generate_diagrams.sh)
    gen --> svg(SVG files)
```
