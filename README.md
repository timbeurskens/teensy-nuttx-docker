# Getting started with Teensy NuttX

## Setting up Docker

These instructions can also be found [here](https://docs.docker.com/engine/install/ubuntu/).

Make sure to first check if an (older) docker version is already installed and remove it.

```
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```

Then install the prerequisites

```
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
