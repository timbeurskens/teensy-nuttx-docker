FROM ubuntu:20.04

# manually set timezone before installing packages
RUN ln -snf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

RUN apt update    

# install dependencies
RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y --no-install-recommends \
    git wget curl \
    bison flex gettext texinfo libncurses5-dev libncursesw5-dev \
    gperf automake libtool pkg-config build-essential gperf genromfs \
    libgmp-dev libmpc-dev libmpfr-dev libisl-dev binutils-dev libelf-dev \
    libexpat-dev gcc-multilib g++-multilib picocom u-boot-tools util-linux \
    kconfig-frontends libusb-dev \
    ca-certificates

# configure tzdata package
RUN dpkg-reconfigure --frontend noninteractive tzdata

# download & install arm toolchain
RUN mkdir /opt/gcc && \
    cd /opt/gcc && \
    HOST_PLATFORM=x86_64-linux && \
    curl -L -O https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-${HOST_PLATFORM}.tar.bz2 && \
    tar xf gcc-arm-none-eabi-9-2019-q4-major-${HOST_PLATFORM}.tar.bz2 && \
    rm gcc-arm-none-eabi-9-2019-q4-major-${HOST_PLATFORM}.tar.bz2

# add arm toolchain to path
ENV PATH="/opt/gcc/gcc-arm-none-eabi-9-2019-q4-major/bin:${PATH}"

# download & install NuttX
RUN mkdir nuttxspace && \
    cd nuttxspace && \
    curl -L https://www.apache.org/dyn/closer.lua/incubator/nuttx/10.2.0/apache-nuttx-10.2.0-incubating.tar.gz?action=download -o nuttx.tar.gz && \
    curl -L https://www.apache.org/dyn/closer.lua/incubator/nuttx/10.2.0/apache-nuttx-apps-10.2.0-incubating.tar.gz?action=download -o apps.tar.gz && \
    tar zxf nuttx.tar.gz && \
    tar zxf apps.tar.gz && \
    rm nuttx.tar.gz apps.tar.gz

# build the teensy-loader-cli application for flashing binaries to teensy
RUN git clone https://github.com/PaulStoffregen/teensy_loader_cli.git && \
    cd teensy_loader_cli && \
    make

# add teensy loader to path
ENV PATH="/teensy_loader_cli:${PATH}"

COPY tools /nuttxspace/tools

RUN chmod +x /nuttxspace/tools/*

ENV PATH="/nuttxspace/tools:${PATH}"

# start container with bash
CMD /bin/bash