#!/bin/zsh
#
IMAGE_NAME="openasip-x64"
CONTAINER_NAME="openasip"

function light_green_echo {
  echo -e "\e[1m\e[32m$1\e[0m"
}
function red_echo {
  echo -e "\e[1m\e[31m$1\e[0m"
}
function black_echo {
  echo -e "\e[1m\e[30m$1\e[0m"
}

function image_exists {
  image_name=$1
  if [ -z "$(docker images -q $image_name 2> /dev/null)" ]; then
    return 1
  else
    return 0
  fi
}
function container_exists {
  container_name=$1
  if [ -z "$(docker ps -q -a -f name=$container_name 2> /dev/null)" ]; then
    return 1
  else
    return 0
  fi
}

# check internet connectivity
if ! ping -q -c1 google.com &>/dev/null
	then
		red_echo "Error: Could not connect to the internet. Recheck and run ./install.sh again."
		exit 1
fi

# check if Docker is installed
if ! [ -d "/Applications/Docker.app" ]
	then
		red_echo "Error: Could not find /Application/Docker.app. Docker is probably not installed"
		exit 1
fi

# check if XQuartz is installed
if ! [ -d "/Applications/Utilities/XQuartz.app" ]
	then
		red_echo "Error: Could not find /Application/Utilities/XQuartz.app. XQuartz is probably not installed"
		exit 1
fi

# Start XQuartz
light_green_echo "Info: Launching XQuartz..."
# change XQuartz settings, otherwise no X11 connection from container possible
defaults write org.xquartz.X11 no_auth 1
defaults write org.xquartz.X11 nolisten_tcp 0
mkdir -p /tmp/.X11-unix
open -a XQuartz

# Start Docker
light_green_echo "Info: Launching Docker daemon..."
while ! docker ps &> /dev/null
do
	open -a Docker
	sleep 5
done
light_green_echo "Info: Docker and Xquartz are up an running..."

# Build docker image
if image_exists $IMAGE_NAME ; then
  light_green_echo "Info: Docker image $IMAGE_NAME already exists"
else
  # Build the Docker image according to the dockerfile
  light_green_echo "Info: Docker image $IMAGE_NAME doesn't exist, build it (it will take sometime)"
  docker build -t $IMAGE_NAME .
fi

# Build docker container
if container_exists $CONTAINER_NAME ; then
  light_green_echo "Info: Docker container $CONTAINER_NAME already exists"
else
  light_green_echo "Info: Docker container $CONTAINER_NAME doesn't exist, create it"
  docker container create -i -t -v $(pwd):/home/user --name $CONTAINER_NAME --platform linux/amd64 $IMAGE_NAME /usr/bin/sudo -H -u user xterm
fi

# Start container
docker container start --attach -i $CONTAINER_NAME &

exit
