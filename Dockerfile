FROM ubuntu:14.04

# Set noninteractive installation to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary tools
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git zip unzip tar \
    build-essential \
    software-properties-common \
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
    uuid-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Build and install OpenSSL 1.1.1q and Python 3.8.6
RUN cd /tmp \
    # Build OpenSSL
    && wget https://www.openssl.org/source/openssl-1.1.1q.tar.gz \
    && tar -xzf openssl-1.1.1q.tar.gz \
    && cd openssl-1.1.1q \
    && ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib \
    && make -j$(nproc) \
    && make install \
    && cd /tmp \
    && rm -rf openssl-1.1.1q openssl-1.1.1q.tar.gz \
    # Set OpenSSL environment variables for Python
    && export LDFLAGS="-L/usr/local/openssl/lib" \
    && export CPPFLAGS="-I/usr/local/openssl/include" \
    && export LD_LIBRARY_PATH="/usr/local/openssl/lib:$LD_LIBRARY_PATH" \
    && export PKG_CONFIG_PATH="/usr/local/openssl/lib/pkgconfig" \
    # Build Python
    && wget https://www.python.org/ftp/python/3.8.6/Python-3.8.6.tgz \
    && tar -xzf Python-3.8.6.tgz \
    && cd Python-3.8.6 \
    && ./configure --with-openssl=/usr/local/openssl \
    && make -j$(nproc) \
    && make altinstall \
    && cd /tmp \
    && rm -rf Python-3.8.6 Python-3.8.6.tgz

# Persistent environment variables for OpenSSL
ENV LDFLAGS="-L/usr/local/openssl/lib"
ENV CPPFLAGS="-I/usr/local/openssl/include"
ENV LD_LIBRARY_PATH="/usr/local/openssl/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/openssl/lib/pkgconfig"

# Create symbolic links
RUN ln -sf /usr/local/bin/python3.8 /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/pip3.8 /usr/local/bin/pip3

# Download, build, and install CMake 4.0.0
RUN cd /tmp \
    && wget https://cmake.org/files/v4.0/cmake-4.0.0.tar.gz \
    && tar -xzvf cmake-4.0.0.tar.gz \
    && cd cmake-4.0.0 \
    && ./bootstrap --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -rf /tmp/cmake-4.0.0 /tmp/cmake-4.0.0.tar.gz

# Download, build, and install GoogleTest
RUN cd /tmp \
    && wget https://github.com/google/googletest/archive/refs/tags/release-1.12.1.zip \
    && unzip release-1.12.1.zip \
    && cd googletest-release-1.12.1 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -rf /tmp/googletest-release-1.12.1 /tmp/release-1.12.1.zip

# Make sure the Python SSL module works and install requests
RUN ldconfig && \
    python3 -c "import ssl; print(ssl.OPENSSL_VERSION)" && \
    python3 -m pip install --no-cache-dir requests pyyaml

# Verify installations
#RUN python3 --version && \
#    pip3 --version && \
#    gcc --version && \
#    cmake --version && \
#    python3 -c "import requests; print(f'requests {requests.__version__} installed successfully')"

# Set working directory
WORKDIR /app
