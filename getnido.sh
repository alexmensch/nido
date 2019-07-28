#!/bin/bash

#   Nido, a Raspberry Pi-based home thermostat.
#
#   Copyright (C) 2016 Alex Marshall
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.
#   If not, see <http://www.gnu.org/licenses/>.

uid=`id -u`
gid=`id -g`
dc="docker-compose.yml"
u=`whoami`

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh \
    && chmod u+x get-docker.sh \
    && sudo VERSION=18.06 ./get-docker.sh

# Add pi user to docker group
sudo usermod -aG docker ${u} \
    && newgrp -

# Install Docker Compose
sudo apt-get -y install python-setuptools \
    && sudo easy_install pip \
    && sudo pip install docker-compose~=1.23.0

# Get latest version of Nido docker-compose.yml
curl -L https://raw.githubusercontent.com/alexmensch/nido/master/${dc} > ${dc}

# Substitute placeholder UID and GID for actual values
sed -i 's/UID/${uid}/g' ${dc}
sed -i 's/GID/${gid}/g' ${dc}

# Get latest version of Nido Dockerfile
curl -L https://raw.githubusercontent.com/alexmensch/nido/master/Dockerfile > Dockerfile
# Mosquitto configuration file
curl -L https://raw.githubusercontent.com/alexmensch/nido/master/mosquitto.conf > mosquitto.conf

# Pull Homebridge configuration files
mkdir homebridge
curl -L https://raw.githubusercontent.com/alexmensch/nido/master/homebridge/config.json > homebridge/config.json
curl -L https://raw.githubusercontent.com/alexmensch/nido/master/homebridge/package.json > homebridge/package.json

# Start Nido
docker-compose up
