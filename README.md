# Getting started with Teensy NuttX

This guide assumes the user has access to a host pc running Ubuntu 20.04 (or similar).
As most of the development environment is running inside a Docker container, it _should_ be possible to use a [Windows host environment](https://ubuntu.com/tutorials/windows-ubuntu-hyperv-containers#1-overview). However, WSL uses an older version of the Linux kernel which is not supported by SuperCAN. This means you cannot use the CAN<->USB functionalities on Windows.

If you are using a Windows host environment, consider using a Ubuntu VM running in [VirtualBox](https://www.virtualbox.org/). This will allow you to set-up the Teensy Docker environment, and use the SuperCAN Linux module.

## Setting up Docker

These instructions can also be found [here](https://docs.docker.com/engine/install/ubuntu/).

Make sure to first check if an (older) docker version is already installed and remove it.

```
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```

Then install the prerequisites

```bash
$ sudo apt-get update

$ sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

Add the GPG key

```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

Add the docker ppa

```
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install docker

```
$ sudo apt-get update

$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Add the current user to the docker group permissions

```
$ sudo groupadd docker

$ sudo usermod -aG docker $USER && newgrp docker
```

Test the docker installation

```
$ docker run hello-world
```

## Building the Teensy NuttX container

Open a terminal window inside this repository and run

```
$ ./build.sh
```

The image requires roughly 1.5Gb of storage and can take a while to set-up.

## Project configuration

Enter the development environment by running the following command in a terminal window in this repository

```
$ ./run.sh
```

Locate the NuttX installation

```
# cd /nuttxspace/nuttx
```

The NuttX environment contains a collection of presets for the teensy board. You can use one of these presets as a starting point for your application:

- teensy-4.x:enc-4.1
- teensy-4.x:pwm-4.1
- teensy-4.x:netnsh-4.1
- teensy-4.x:can-4.1
- teensy-4.x:sd-4.1
- teensy-4.x:lcd-4.1
- teensy-4.x:nsh-4.1

Details for these configurations can be found [here](https://nuttx.apache.org/docs/latest/platforms/arm/imxrt/boards/teensy-4.x/index.html#configurations).

Choose one of these configurations and set-up the environment with the following command:

```
# ./tools/configure.sh -l {configuration}
```

For example:

```
# ./tools/configure.sh -l teensy-4.x:nsh-4.1
```

This preset can be customized by running

```
# make menuconfig
```

and adjusting the desired parameters in the kconfig environment.

The docker environment contains a mounted `user_src` directory with a `hello_user` example project. You can enable this application by checking the `[ ] \"Hello, World!\" example (user)` parameter in `Application Configuration`. This enables the `hello_user` command in NSH.

By default, the application entry-point is set to `nsh_main`. This can be modified by setting the entry point parameter in `RTOS Features > Tasks and Scheduling > Application entry point`.

Alternatively you can run a start-up script in NSH. This method can be more convenient if more tasks need to be spawned in parallel. Instructions for start-up scripts can be found [here](https://nuttx.apache.org/docs/10.0.0/components/nsh/installation.html#nuttshell-start-up-scripts).

## Building and flashing

To compile your application, enter the nuttx directory and run the make command.

```
# cd /nuttxspace/nuttx

# make
```

The `make` command can use multiple threads to speed up the build process. The example below shows how to use 8 threads for `make`.

```
# make -j8
```

After this build step has finished successfully, a `nuttx.hex` file can be found in the nuttx directory. This is the file to be flashed on the target device. The docker image is equipped with `teensy_loader_cli` for flashing the teensy board.

First make sure the board is plugged into the host device and enter program mode (by pressing the white button on the target).

```
# teensy_loader_cli --mcu=TEENSY41 -v -w nuttx.hex
```

## Console

By default, Teensy NuttX uses the USB serial console. You can enter the console with your favorite tty terminal. The docker image has a pre-installed version of `picocom` which can be used to access the teensy console:

```
# picocom /dev/ttyACM0 -b 115200
```

If NuttX is configured to run the NSH terminal, first press the `Enter` key _three_ times to access the nsh shell. You should see the following terminal line:

```
nsh>
```

## Utilities

A number of convenience scripts are available and can be found (and modified) in the `tools` directory.

After modifying the scripts, the docker image must be recompiled.

- `ntxmake`: runs `make -j8 ...` in the nuttx dir
- `ntxflash`: flashes the `nuttx.hex` file to teensy
- `ntxconsole`: launches picocom
- `ntxmenuconfig`: runs `make menuconfig` inside the nuttx dir

## Installing udev rules for Teensy 4.1

Your Linux will probably restrict access to the Teensy USB interface. This repository includes a set of udev rules which can be installed on your system to elevate user permissions for the Teensy 4.1. These rules can be installed by the following command:

```
$ sudo cp 00-teensy.rules /etc/udev/rules.d/00-teensy.rules
```

To make sure the rules are loaded correctly, reboot your system before flashing or using the serial terminal.

## Misc.

### Running from file-system

[documentation](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=139629542)

The documentation is outdated, the following adjustments must be made:

- use `gnu-elf.ld` in `nuttx-export-10.2.0/scripts/gnu-elf.ld`
- use `Make.defs` in `nuttx-export-10.2.0/scripts/Make.defs`

At the moment, out-of-context builds do not yet work for this configuration: loading the elf file from a file system results in a system crash.
The firmware version is tightly coupled to the module version, so make sure the export is updated for new bsp versions.

### SLCAN: CAN over USB Serial

Make sure to install `can-utils` on your host device:

```bash
sudo apt install can-utils
```

[some documentation](https://python-can.readthedocs.io/en/master/interfaces/serial.html)

### View Kconfig diffs

The `kconfig-diff` utility can be used to compare `.config` revisions.

### Build SuperCAN linux kernel module

Make sure you're running version 5.13 (or higher) of the linux kernel:

```bash
uname -r
```

Install dkms:

```bash
sudo apt install dkms
```

Clone SuperCAN and the linux module source code:

```bash
$ git clone --recursive git@github.com:jgressmann/supercan.git
```

Build the kernel module:

```bash
$ cd supercan
$ ./Linux/dkms-init.sh
$ cd Linux/supercan_usb-0.2.5
$ make V=1 KERNELRELEASE=$(uname -r) -C /lib/modules/$(uname -r)/build M=$PWD
```

Sign the kernel module (only for your host machine, do not distribute):

```bash
$ sudo kmodsign sha512 \
	/var/lib/shim-signed/mok/MOK.priv \
    /var/lib/shim-signed/mok/MOK.der \
	$PWD/supercan_usb.ko
```

Load the kernel module (repeat after every reboot):

```bash
$ sudo modprobe can-dev
$ sudo rmmod supercan_usb 2>/dev/null || true && sudo insmod $PWD/supercan_usb.ko
```

When the device is connected you should see two CAN devices in the interface list:

```bash
$ ip link show
```

CAN0 is attached to the CAN-FD bus and CAN1 is the CAN interface we recommend using for the project.
The vehicle uses a CAN bitrate of 500 kbit/s. You can set-up the device using the following commands:

```bash
$ sudo ip link set can1 type can bitrate 500000
$ sudo ip link set up can1
$ sudo ifconfig can1 txqueuelen 1000
```

### CAN playback on a virtual/physical CAN bus

The latest version of the teensy-nuttx-docker container includes the `can-utils` package and all required packages for running CAN-X in Linux.

You can play-back one of the provided log files with the `canplayer` tool and view real-time data in CAN-X.
First make sure at least 1 socketcan interface is available on your host, either by connecting a teensy board with the supercan firmware (as described in the previous section) or by using a virtual can bus:

```bash
$ sudo ip link add vcan0 type vcan
$ sudo ip link set up vcan0
```

Now start CAN-X and select either a physically connected can interface, or `vcan0`.
In a separate terminal, start the logfile playback:

```bash
$ canplayer -I logfile.scl vcan0=canx
```

_Note: replace `vcan0` with the desired output interface, leave `canx` as is: this is the recorded interface name._