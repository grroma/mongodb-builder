# mongodb-builder
This repository contains a Dockerfile for building a Docker image of MongoDB version 7.0.8 from source on an Ubuntu 22.04.

## Prerequisites

- Docker installed on your machine

## Building the Docker Image

To build the Docker image, run the following command in the directory containing the Dockerfile:

```sh
docker buildx build -t custom-mongodb:v7.0.8 . > build_output.log 2>&1
```

NOTE:
- We are building the latest stable version of `mongodb` as of April 2024 - v7.0.8 (building rc8.x will require a different approach using `Poetry`)
- `std_out` is saved to the `build_output.log` file;
- Build time on a local machine: 4 hours 57 minutes, image size: 3.34 GB;
- Besides Docker layer caching, compiled files are also cached; `SCons` (rebuilding the image will be significantly faster)

