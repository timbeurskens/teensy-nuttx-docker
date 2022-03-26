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



## Building and flashing



## Console

