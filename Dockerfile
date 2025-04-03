FROM ubuntu:14.04

# Set noninteractive installation to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary tools
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA and install Python 3.8
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.8 python3.8-dev python3.8-distutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.8
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3.8 get-pip.py && \
    rm get-pip.py

# Create symbolic links
RUN ln -sf /usr/bin/python3.8 /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/pip /usr/local/bin/pip3

# Download, build, and install CMake 4.0.0
RUN cd /tmp \
    && wget https://cmake.org/files/v4.0/cmake-4.0.0.tar.gz \
    && tar -xzvf cmake-4.0.0.tar.gz \
    && cd cmake-4.0.0 \
    && ./bootstrap --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -rf /tmp/cmake-4.0.0 /tmp/cmake-4.0.0.tar.gz /usr/local/share/cmake-4.0/Help/

# Verify installations
RUN python3 --version && \
    pip3 --version && \
    gcc --version && \
    cmake --version

# Set working directory
WORKDIR /app
