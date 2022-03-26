#!/usr/bin/env bash

(docker start teensy-nuttx-instance && docker exec -it teensy-nuttx-instance /bin/bash) || docker run --name teensy-nuttx-instance -it -v /dev:/dev -v "$(pwd)/user_src":/nuttxspace/apps/user_src --privileged teensy-nuttx:latest