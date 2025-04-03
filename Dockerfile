FROM ubuntu:14.04

# Set noninteractive installation to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary tools
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    software-properties-common \
    gcc-4.8 \
    g++-4.8 \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libdb5.3-dev \
    libbz2-dev \
    libexpat1-dev \
    liblzma-dev \
    tk-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set gcc-4.8 and g++-4.8 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 100

# Install Python 3.4 (newest supported in Ubuntu 14.04)
RUN apt-get update && apt-get install -y python3 python3-dev python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download, build, and install CMake 3.0.2 from source - all in a single layer
RUN cd /tmp \
    && wget https://cmake.org/files/v4.0/cmake-4.0.0.tar.gz \
    && tar -xzvf cmakee-4.0.0.tar.gz \
    && cd cmake-4.0.0 \
    && ./bootstrap --prefix=/usr/local \
    && make \
    && make install \
    && cd / \
    && rm -rf /tmp/cmake-4.0.0 /tmp/cmake-4.0.0.tar.gz

# Verify installations
RUN python3 --version && \
    gcc --version && \
    g++ --version && \
    cmake --version

# Set working directory
WORKDIR /app
