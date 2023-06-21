# Building GrapheneOS Applications

This folder contains the essentials to download, build, and export GrapheneOS applications like Auditor, Apps, GmsCompat, etc.

If you are using `docker run`, use this template.

```bash
# Build the container
docker build -t application-builder .
# Run the container
docker run --privileged -e "APPS_TO_BUILD=all" -e "MANIFEST=latest" -v "./grapheneos-apps/:/opt/build/apps" -v "./grapheneos-apps/:/opt/build/apps" application-builder
```

If you are using `docker compose`, use this template.

```yaml
services:
  application-builder:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: application-builder
    privileged: true
    # These are the bare minimum to build the applications
    environment:
      - APPS_TO_BUILD=all
      - MANIFEST=latest
    volumes:
      - ./grapheneos-apps/:/opt/build/apps
      - ./grapheneos-compiled-apps/:/opt/build/compiled_apps
```

If you don't know which one to choose, we recommend using `docker compose`.

## Environment Variables

`APPS_TO_BUILD` - This chooses what applications you'd like to build. Accepted values are: `all`, `Auditor`, `Apps`, `Camera`, `PdfViewer`, `TalkBack`, `GmsCompat`.

Examples:

- `APPS_TO_BUILD=all`
- `APPS_TO_BUILD=Auditor`
- `APPS_TO_BUILD="Auditor Camera PdfViewer"`

`MANIFEST` - This chooses what level you want to build them at. Accepted values are: `development`, `latest`. Latest builds the newest tags, development builds straight from Github.

Examples:

- `MANIFEST=development`
- `MANIFEST=latest`

Note: you cannot switch between manifests per applications. You can queue this container mulitiple times however.
