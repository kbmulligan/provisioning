#!/bin/bash
# installs docker by manually curling the packages
# requires sudo for install portion

DISTRO="jammy"
FILL_PATH="pool/stable"
ARCH="amd64"
EXT=".deb"

BASE_URL="download.docker.com/linux/ubuntu/dists"
SCHEME="https"

TEMP_DIR="/tmp/docker-install"

# ENSURE THESE VERSIONS ARE CORRECT/LATEST NEXT INSTALL OR UPGRADE
CONTAINERD_VER="1.6.9-1"
DOCKER_CE_VER="24.0.6-1~ubuntu.22.04~$DISTRO"
DOCKER_CE_CLI_VER="24.0.6-1~ubuntu.22.04~$DISTRO"
DOCKER_BUILDX_VER="0.11.2-1~ubuntu.22.04~$DISTRO"
DOCKER_COMPOSE_PLUGIN_VER="2.21.0-1~ubuntu.22.04~$DISTRO"

CONTAINERD_NAME="containerd.io"
DOCKER_CE_NAME="docker-ce"
DOCKER_CE_CLI_NAME="docker-ce-cli"
DOCKER_BUILDX_NAME="docker-buildx-plugin"
DOCKER_COMPOSE_PLUGIN_NAME="docker-compose-plugin"


function get_filename () {
    ITEM_NAME=$1
    VERSION=$2
    MY_FILENAME="${ITEM_NAME}_${VERSION}_${ARCH}${EXT}"
    echo $MY_FILENAME
}

MAIN_DIR="$SCHEME://$BASE_URL/$DISTRO/$FILL_PATH/$ARCH"

CON_FILENAME=$(get_filename $CONTAINERD_NAME $CONTAINERD_VER)
DCE_FILENAME=$(get_filename $DOCKER_CE_NAME $DOCKER_CE_VER)
DCC_FILENAME=$(get_filename $DOCKER_CE_CLI_NAME $DOCKER_CE_CLI_VER)
DBX_FILENAME=$(get_filename $DOCKER_BUILDX_NAME $DOCKER_BUILDX_VER)
DCP_FILENAME=$(get_filename $DOCKER_COMPOSE_PLUGIN_NAME $DOCKER_COMPOSE_PLUGIN_VER)

REQUIRED_FILES=(
    $CON_FILENAME
    $DCC_FILENAME
    $DCE_FILENAME
    $DBX_FILENAME
    $DCP_FILENAME
)

echo 'Starting to install docker-ce ...'

# prep
mkdir -p $TEMP_DIR
cd $TEMP_DIR

# download all
for FILENAME in ${REQUIRED_FILES[@]}; do
    echo "Download $FILENAME ..."
    URL="$MAIN_DIR/$FILENAME"
    curl -s $URL -o $FILENAME
done

# install all
for FILENAME in ${REQUIRED_FILES[@]}; do
    echo "Install $FILENAME ..."
    sudo dpkg -i "./$FILENAME"
done

# return to previous dir
cd -

echo "Packages left in $TEMP_DIR"

echo 'Creating docker group...'
sudo groupadd docker

echo "Adding user $USER to docker group..."
sudo usermod -aG docker $USER

echo 'Add more users to the docker group with this command:'
echo '  $ sudo usermod -aG docker $USER'

echo "Install complete!"
