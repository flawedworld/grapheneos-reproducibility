# Reproducing GrapheneOS Builds

This repository is an unofficial build container focused on reproducing and verifying GrapheneOS builds.

## Instructions

There are three different ways you can run this container with differing usecases:

First and foremost, build the container:

```bash
docker build -t gos-reproducibility .
```

### Picking a `BUILD_TARGET` (EASY)

Build targets are essentially latest builds that GrapheneOS has published. There's currently 5 build targets.

- stable
- beta
- alpha
- testing
- development

Each of these are pulled from the Update Server metadata. For example, [here is the stable branch for the Pixel 6 Pro (raven).](https://releases.grapheneos.org/raven-stable) These follow the `https://releases.grapheneos.org/DEVICE_CODENAME-BRANCH` convention.

For `docker run`:

```bash
docker run --privileged -e "DEVICES_TO_BUILD=bluejay" -e "BUILD_TARGET=stable" -v "./grapheneos-tree/:/opt/build/grapheneos/" -v "./local_manifests:/.repo/local_manifests:ro" -v "./keys:/opt/build/grapheneos/build:ro" -v "./.gitcookies:/.gitcookies:ro" gos-reproducibility
```

For `docker compose`:

```yaml
services:
  grapheneos-builder:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: grapheneos-builder
    privileged: true
    environment:
      - DEVICES_TO_BUILD="bluejay"
      - BUILD_TARGET=stable
      - USE_PREBUILT_KERNEL=false
      - USE_PREBUILT_APPS=false
      - PACKAGE_OS=true
      - USE_AOSP_TEST_KEYS=false
      - OFFICIAL_BUILD=true
      - NPROC_SYNC=8
      - NPROC_BUILD=8
    volumes:
      - ./grapheneos-tree/:/opt/build/grapheneos
      - ./local_manifests:/.repo/local_manifests:ro # Optional, if you have forks with patches to apply
      - ./keys:/opt/build/grapheneos/build:ro
      - ./.gitcookies:/.gitcookies:ro # Optional, but highly recommended
```

### Cherrypicking a specific manifest (MEDIUM)

Using `DEVICES_TO_BUILD` and `MANIFESTS_FOR_BUILD` in tandem, you can build multiple devices with differing manifests sequentially. Note: this route will NOT produce an official build.

For `docker run`:

```bash
docker run --privileged -e "DEVICES_TO_BUILD=redfin oriole lynx" -e "TQ2A.230505.002.2023060700 TQ2A.230505.002.2023060700 TQ2B.230505.005.A1.2023060700" -e "OFFICIAL_BUILD=false" -v "./grapheneos-tree/:/opt/build/grapheneos/" -v "./local_manifests:/.repo/local_manifests:ro" -v "./keys:/opt/build/grapheneos/build:ro" -v "./.gitcookies:/.gitcookies:ro" gos-reproducibility
```

For `docker compose`:

```yaml
services:
  grapheneos-builder:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: grapheneos-builder
    privileged: true
    environment:
      - DEVICES_TO_BUILD="redfin oriole lynx"
      - MANIFESTS_FOR_BUILD="TQ2A.230505.002.2023060700 TQ2A.230505.002.2023060700 TQ2B.230505.005.A1.2023060700"
      - USE_PREBUILT_KERNEL=false
      - USE_PREBUILT_APPS=false
      - PACKAGE_OS=true
      - USE_AOSP_TEST_KEYS=false
      - OFFICIAL_BUILD=false
      - NPROC_SYNC=8
      - NPROC_BUILD=8
    volumes:
      - ./grapheneos-tree/:/opt/build/grapheneos
      - ./local_manifests:/.repo/local_manifests:ro # Optional, if you have forks with patches to apply
      - ./keys:/opt/build/grapheneos/build:ro
      - ./.gitcookies:/.gitcookies:ro # Optional, but highly recommended
```

### Manually defining a specific `BUILD_ID`, `BUILD_DATETIME`, and `BUILD_NUMBER` (HARD)

Using `BUILD_ID`, `BUILD_DATETIME`, and `BUILD_NUMBER`, you can build a reproducible past build. The reason this is marked as hard is because you must supply each variable and for past builds, these are hard to come by as GrapheneOS does not publish previous builds. These would be found in the `ota-update.zip` file.

For `docker run`:

```bash
docker run --privileged -e "DEVICES_TO_BUILD=bluejay" -e "BUILD_TARGET=stable" -v "./grapheneos-tree/:/opt/build/grapheneos/" -v "./local_manifests:/.repo/local_manifests:ro" -v "./keys:/opt/build/grapheneos/build:ro" -v "./.gitcookies:/.gitcookies:ro" gos-reproducibility
```

For `docker compose`:

```yaml
services:
  grapheneos-builder:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: grapheneos-builder
    privileged: true
    environment:
      - DEVICES_TO_BUILD="redfin oriole lynx"
      - BUILD_NUMBER=2023060700
      - BUILD_DATETIME=1686159583 
      - BUILD_ID=TQ2A.230505.002
      - USE_PREBUILT_KERNEL=false
      - USE_PREBUILT_APPS=false
      - PACKAGE_OS=true
      - USE_AOSP_TEST_KEYS=false
      - OFFICIAL_BUILD=true
      - NPROC_SYNC=8
      - NPROC_BUILD=8
    volumes:
      - ./grapheneos-tree/:/opt/build/grapheneos
      - ./local_manifests:/.repo/local_manifests:ro # Optional, if you have forks with patches to apply
      - ./keys:/opt/build/grapheneos/build:ro
      - ./.gitcookies:/.gitcookies:ro # Optional, but highly recommended
```
