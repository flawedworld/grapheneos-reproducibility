# Building Vanadium

This folder contains the essentials to download, build, and export Vanadium, GrapheneOS's main browser.

If you are using `docker run`, use this template.

```bash
# Build the container
docker build -t vanadium-builder .
# Run the container
docker run -e "VANADIUM_MANIFEST=114.0.5735.131.0" -v "./grapheneos-vanadium/:/opt/build/vanadium" vanadium-builder
```

If you are using `docker compose`, use this template.

```yaml
services:
  vanadium-builder:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: vanadium-builder
    privileged: true
    # These are the bare minimum to build Vanadium
    environment:
      - VANADIUM_MANIFEST=114.0.5735.131.0
    volumes:
      - ./grapheneos-vanadium/:/opt/build/vanadium
```

If you don't know which one to choose, we recommend using `docker compose`.

## Environment Variables

`VANADIUM_MANIFEST` - This chooses which manifest you'd like to build at. There is no hardcoded value, but look to the tags [here for a reference of acceptable values.](https://github.com/GrapheneOS/Vanadium/tags)

Examples:

- `VANADIUM_MANIFEST=114.0.5735.131.0`
