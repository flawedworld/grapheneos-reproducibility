# Building GrapheneOS Reproducibly

This folder contains the essentials to build GrapheneOS and its components in a reproducible manner solely for comparison to builds provided from GrapheneOS.

If you are using `docker run`, use this template.

```bash
# Build the container
docker build -t reproducible-gos-builder .
# Run the container
docker run -e DEVICES_TO_BUILD="coral" -e BUILD_TARGET=stable -e NPROC_SYNC=8 -e NPROC_BUILD=8 -v "./grapheneos-repro:/opt/build/grapheneos" reproducible-gos-builder
```

If you are using `docker compose`, use this template.

```yaml
services:
  reproducible-gos-builder:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: reproducible-gos-builder
    privileged: true
    # These are the bare minimum to have a reproducible build
    environment:
      - DEVICES_TO_BUILD="coral"
      - BUILD_TARGET=stable
      # - BUILD_ID=TQ3A.230605.012
      # - BUILD_NUMBER=2023061402
      # - BUILD_DATETIME=1686786286
      - NPROC_SYNC=8
      - NPROC_BUILD=8
    volumes:
      - ./grapheneos-repro:/opt/build/grapheneos
```

If you don't know which one to choose, we recommend using `docker compose`.

## Environment Variables

`DEVICES_TO_BUILD` - This chooses which device you'd like to build. Accepted values are: `coral`, `sunfish`, `bramble`, `redfin`, `barbet`, `oriole`, `raven`, `bluejay`, `panther`, `cheetah`, `lynx`, and `tangorpro`.

Examples:

- `DEVICES_TO_BUILD=coral`
- `DEVICES_TO_BUILD="raven oriole"`

`BUILD_TARGET` - This chooses what branch you want to build from. Accepted values are: `stable`, `alpha`, `beta`, and `testing`.

Note: this is considered "build method 1". Build methods are functionally incompatible.

Examples:

- `BUILD_TARGET=stable`
- `BUILD_TARGET=beta`

`BUILD_ID`, `BUILD_NUMBER`, `BUILD_DATETIME` - This lets you set what BUILD_ID, BUILD_NUMBER and what BUILD_DATETIME you want to build from. Note: all three must be used and cannot be used with `BUILD_TARGET`.

Note: this is considered "build method 3". Build methods are functionally incompatible.

Examples:

- `BUILD_ID=TQ3A.230605.012`
- `BUILD_NUMBER=2023061402`
- `BUILD_DATETIME=1686786286`

`NPROC_SYNC` - This lets you set how many sync jobs can run concurrently. Note that if you set this too high, it will result in ratelimits.

Examples:

- `NPROC_SYNC=8`
- `NPROC_SYNC=4`
