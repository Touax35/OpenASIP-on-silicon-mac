#!/bin/zsh

# echo with color
function f_echo {
	echo -e "\e[1m\e[33m$1\e[0m"
}

script_dir=$(dirname -- "$(readlink -nf $0)";)

# check internet connectivity
if ! ping -q -c1 google.com &>/dev/null
	then
		f_echo "Could not connect to the internet. Recheck and run ./install again."
		exit 1
fi

# check if Docker is installed
if ! [ -d "/Applications/Docker.app" ]
	then
		f_echo "You need to install Docker first."
		exit 1
fi

# check if XQuartz is installed
if ! [ -d "/Applications/Utilities/XQuartz.app" ]
	then
		f_echo "You need to install XQuartz first."
		exit 1
fi

# change XQuartz settings, otherwise no X11 connection from container possible
defaults write org.xquartz.X11 no_auth 1
defaults write org.xquartz.X11 nolisten_tcp 0

# Launch Docker daemon and XQuartz
mkdir -p /tmp/.X11-unix
f_echo "Launching Docker daemon and XQuartz..."
open -a XQuartz

# Wait for docker to start
while ! docker ps &> /dev/null
do
	open -a Docker
	sleep 5
done

export image="openasip-x64"

if ! [ -d openasip-devel ]
	then
		f_echo "Cloning OpenASIP from github into openasip-devel"
                (cd openasip-devel ; git submodule update --init --recursive)
fi


# Build the Docker image according to the dockerfile
f_echo "Building Docker image"
docker build -t $image .

# Running install script in docker container
f_echo "Launching Docker container and installation script"
/usr/local/bin/docker run -it --init --rm --mount type=bind,source="/tmp/.X11-unix",target="/tmp/.X11-unix" --mount type=bind,source="$script_dir",target="/home/user" --platform linux/amd64 $image bash /home/user/docker.sh


# Create App icon
f_echo "Generating App icon"

input_file="openasip_design_flow.png"
mkdir icon.iconset
sips -z 16 16 "$input_file" --out "icon.iconset/icon_16x16.png"
sips -z 32 32 "$input_file" --out "icon.iconset/icon_16x16@2x.png"
sips -z 32 32 "$input_file" --out "icon.iconset/icon_32x32.png"
sips -z 64 64 "$input_file" --out "icon.iconset/icon_32x32@2x.png"
sips -z 128 128 "$input_file" --out "icon.iconset/icon_128x128.png"
sips -z 256 256 "$input_file" --out "icon.iconset/icon_128x128@2x.png"
sips -z 256 256 "$input_file" --out "icon.iconset/icon_256x256.png"
sips -z 512 512 "$input_file" --out "icon.iconset/icon_256x256@2x.png"
sips -z 512 512 "$input_file" --out "icon.iconset/icon_512x512.png"
iconutil -c icns icon.iconset
rm -rf icon.iconset
mv icon.icns OpenASIP_shell.app/Contents/Resources/icon.icns

# Create Launch_Vivado script; needed for getting script path
# Launch XQuartz and Docker
cat > OpenASIP_shell.app/OpenASIP_shell <<EOF
#!/bin/zsh

open -a XQuartz
open -a Docker
while ! /usr/local/bin/docker ps &> /dev/null
do
  open -a Docker
  sleep 5
done
while ! [ -d "/tmp/.X11-unix" ]
do
  open -a XQuartz
  sleep 5
done

# Run docker container by starting hw_server first to establish an XVC connection and then Vivado
/usr/local/bin/docker run --init --rm --name openasip_container --mount type=bind,source="/tmp/.X11-unix",target="/tmp/.X11-unix" --mount type=bind,source="/Users/lionel/Projects/Ubuntu-on-silicon-mac",target="/home/user" --platform linux/amd64 openasip-x64 sudo -H -u user sleep infinity&

while [ \$(ps aux | grep openasip_container | wc -l | grep -vc "^ *[01]$") != "1" ] ; do
  sleep 1
done
osascript -e 'tell app "Terminal" to do script "docker exec -it openasip_container sudo -H -u user bash"'
docker container stop openasip_container

EOF

# Launch XVC server on host
chmod +x OpenASIP_shell.app/OpenASIP_shell
