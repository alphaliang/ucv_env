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
    libffi-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set gcc-4.8 and g++-4.8 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 100

# Download, compile and install Python 3.8.6 from source
RUN cd /tmp \
    && wget https://www.python.org/ftp/python/3.8.6/Python-3.8.6.tgz \
    && tar -xzf Python-3.8.6.tgz \
    && cd Python-3.8.6 \
    && ./configure --enable-optimizations \
    && make -j$(nproc) \
    && make altinstall \
    && cd / \
    && rm -rf /tmp/Python-3.8.6 /tmp/Python-3.8.6.tgz

# Create symbolic links
RUN ln -sf /usr/local/bin/python3.8 /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/pip3.8 /usr/local/bin/pip3

# Download, build, and install CMake 4.0.0 from source
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
    gcc --version && \
    g++ --version && \
    cmake --version

# Set working directory
WORKDIR /app
