FROM ubuntu:22.04 as builder

# Installing packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    git \
    python3.10 \
    python3-pip \
    python3.10-venv \
    libcurl4-openssl-dev \
    liblzma-dev \
    libssl-dev \
    gdb \
    ca-certificates \
    && update-ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Cloning MongoDB repository and installing dependencies
WORKDIR /mongo
RUN git clone https://github.com/mongodb/mongo.git . && \
    git checkout r7.0.8 && \
    python3 -m pip install --upgrade pip -r etc/pip/compile-requirements.txt

# Building MongoDB
#   NOTE: the build requires a lot of resources
#         -j1 limits the number of parallel build tasks to 1
#         -j$(nproc) uses all available threads
#         --ssl=off sometimes Basel cannot be downloaded over ssl
#         DESTDIR=/opt/mongo if the directory is incorrect
RUN python3 buildscripts/scons.py \
    install-servers MONGO_VERSION=7.0.8 --opt --disable-warnings-as-errors \
    --variables-files=etc/scons/developer_versions.vars \
    -j$(nproc) \
    --link-model=dynamic \
    --linker=gold \
    --dbg \
    --cache

FROM ubuntu:22.04

LABEL org.opencontainers.image.authors="Roman Grishin <grroma.dev@gmail.com>" \
      org.opencontainers.image.title="mongodb:7.0.8"

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    liblzma-dev \
    libssl-dev \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copying built files to the resulting image
COPY --from=builder /mongo/build/install /mongo

# Configuring environment variables and port
ENV PATH="/mongo/bin:${PATH}"
EXPOSE 27017

# Starting MongoDB
CMD ["mongod", "--bind_ip_all"]