FROM debian:stable

# Copy SCEP server images
COPY cmd/scepserver/scepserver /usr/bin/scepserver

# Install build dependencies for VCPKG
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    automake \
    autoconf \
    autoconf-archive \
    build-essential \
    ca-certificates \
    ccache \
    cmake \
    curl \
    g++ \
    git \
    libtool-bin \
    libssl-dev \
    ninja-build \
    pkg-config \
    tar \
    texinfo \
    unzip \
    wget \
    yasm \
    zip
    #--fix-missing \    
    #&& apt-get upgrade -y \
    #&& rm -rf /var/lib/apt/lists/* \
    #&& apt clean autoclean && apt autoremove -y \
    #&& rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN git clone https://github.com/microsoft/vcpkg

RUN ./vcpkg/bootstrap-vcpkg.sh

EXPOSE 8080

ENTRYPOINT ["/usr/bin/scepserver"]
