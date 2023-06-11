# Instructions

Build docker container with which to build GrapheneOS:
```
docker build -t gos-reproducibility .
```

Environment variables for entrypoint build script:
`DEVICE` - defaults to bluejay
`BUILD_ID` - defaults to "TQ2A.230505.002"
`OFFICIAL_BUILD` - defaults to true
`BUILD_DATETIME` - defaults to 1686159583
`BUILD_NUMBER` - defaults to 2023060700


Build GrapheneOS for a specific device using the `grapheneos-tree` directory in the current working directory to
store repository and build information, removing the ephemeral container when done:
```
docker run --rm --privileged -e "DEVICE=raven" -v "./grapheneos-tree/:/opt/build/grapheneos/" gos-reproducibility
```
Note: permitting TTY use results in git complaining about the user configuration inside the container,
do not pass `-t` (for now).
