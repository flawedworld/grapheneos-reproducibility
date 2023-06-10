# Instructions

```
docker build -t gos-reproducibility .
```

```
docker run --privileged -v "./grapheneos-tree/:/opt/build/grapheneos/" gos-reproducibility
```
