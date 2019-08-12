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
wd=`pwd`

# Enable I2C kernel module
sudo modprobe i2c-dev
if ! `grep -q "^i2c[-_]dev" /etc/modules`; then
    printf "i2c-dev\n" | sudo tee -a /etc/modules
fi

# Set locale to US UTF-8
sudo sed -i "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen \
    && sudo locale-gen en_US.UTF-8 \
    && sudo update-locale en_US.UTF-8

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh \
    && chmod u+x get-docker.sh \
    && sudo ./get-docker.sh

# Add pi user to docker group
sudo usermod -aG docker ${u}

# Install Docker Compose
sudo apt-get -y install python3-pip \
    && sudo pip3 install docker-compose~=1.23.0

# Create local volume mountpoints
mkdir homebridge logs instance
# Get latest version of configuration files
curl -sL https://raw.githubusercontent.com/alexmensch/nido/master/Dockerfile > Dockerfile
curl -sL https://raw.githubusercontent.com/alexmensch/nido/master/mosquitto.conf > mosquitto.conf
curl -sL https://raw.githubusercontent.com/alexmensch/nido/master/homebridge/config.json > homebridge/config.json
curl -sL https://raw.githubusercontent.com/alexmensch/nido/master/homebridge/package.json > homebridge/package.json
curl -sL https://raw.githubusercontent.com/alexmensch/nido/master/${dc} > ${dc}
curl -sL https://raw.githubusercontent.com/alexmensch/nido/master/docker-compose-nido.service > docker-compose-nido.service
# Substitute placeholder UID and GID for actual values
sed -i "s/USER/${uid}/g" ${dc}
sed -i "s/GROUP/${gid}/g" ${dc}
# Substitute working directory in systemd service with current directory
sed -i "s@WORKING_DIRECTORY@${wd}@g" docker-compose-nido.service

# Generate random strings for private-config.py
a=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
b=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

cat <<EOF > private-config.py
# Flask secret key
SECRET_KEY = "${a}"

# Nido API secret key
PUBLIC_API_SECRET = "${b}"
EOF

sed -i "s/NIDO_API_SECRET/${b}/g" homebridge/config.json

echo "Flask secret: ${a}"
echo "Nido API secret: ${b}"

# Install new systemd service
sudo cp docker-compose-nido.service /etc/systemd/system
sudo systemctl enable docker-compose-nido

# Restart
echo
echo "**********************************************"
echo "Restarting in 15 seconds..."
echo "Nido will run automatically on system startup."
echo "Press CTRL-C to cancel."
echo "**********************************************"
echo
sleep 15s
sudo /sbin/shutdown -r now
