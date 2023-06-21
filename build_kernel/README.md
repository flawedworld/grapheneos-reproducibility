# Building GrapheneOS Kernels

This folder contains the essentials to download, build, and export the kernels GrapheneOS uses on their devices.

If you are using `docker run`, use this template.

```bash
# Build the container
docker build -t kernel-builder .
# Run the container
docker run -e "DEVICES_TO_BUILD=coral" -e "MANIFESTS_FOR_BUILD=TQ3A.230605.012.2023061402" -v "./grapheneos-kernel/:/opt/build/kernel" -v "./grapheneos-compiled-kernel/:/opt/build/compiled_kernel" kernel-builder
```

If you are using `docker compose`, use this template.

```yaml
services:
  kernel-builder:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: kernel-builder
    # These are the bare minimum to build the kernel
    environment:
      - DEVICES_TO_BUILD="coral"
      - MANIFESTS_FOR_BUILD="TQ3A.230605.012.2023061402"
      - NPROC_SYNC=8
    volumes:
      - ./grapheneos-kernel/:/opt/build/kernel
      - ./grapheneos-compiled-kernel:/opt/build/compiled_kernel
```

If you don't know which one to choose, we recommend using `docker compose`.

## Environment Variables

`DEVICES_TO_BUILD` - This chooses which device kernel you'd like to build. Accepted values are: `coral`, `sunfish`, `bramble`, `redfin`, `barbet`, `oriole`, `raven`, `bluejay`, `panther`, `cheetah`, `lynx`.

Examples:

- `DEVICES_TO_BUILD=coral`
- `DEVICES_TO_BUILD="raven oriole"`

`MANIFESTS_FOR_BUILD` - This chooses what manifest you'd like to build at. There is no directly accepted values, you will need to provide a manifest like `TQ3A.230605.012.2023061402`.

Examples:

- `MANIFESTS_FOR_BUILD=TQ3A.230605.012.2023061402`
- `MANIFEST="TQ3A.230605.012.2023061402 TQ3A.230605.012.2023061402"`

Note: when you have multiple devices, you NEED to have the same amount of manifests even if you're building for the same manifest.

`DEVICES_TO_BUILD="raven oriole"`
`MANIFEST="TQ3A.230605.012.2023061402 TQ3A.230605.012.2023061402"`
