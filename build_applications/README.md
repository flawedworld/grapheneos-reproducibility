# Building GrapheneOS Applications

This folder contains the essentials to download, build, and export GrapheneOS applications like Auditor, Apps, GmsCompat, etc.

If you are using `docker run`, use this template.

```bash
# Build the container
docker build -t gos-app-build-kitchen .
# Run the container
docker run --privileged  
  -e "APPS_TO_BUILD=all" 
  -e "MANIFEST=latest"   
  -v "./grapheneos-apps/:/opt/build/apps" 
  -v "./grapheneos-apps/:/opt/build/apps" 
  gos-app-build-kitchen
```

If you are using `docker compose`, use this template.

```yaml
services:
  gos-app-build-kitchen:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: gos-app-build-kitchen
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


