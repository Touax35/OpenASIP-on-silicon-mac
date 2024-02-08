# Container for running OpenASIP on M1/M2 macs
# though it should work equally on Intel macs

FROM --platform=linux/amd64 ubuntu
RUN apt update && apt upgrade -y

RUN  apt install -y --no-install-recommends --allow-unauthenticated dbus dbus-x11 x11-utils xorg alsa-utils mesa-utils net-tools libgl1-mesa-dri gtk2-engines lxappearance fonts-droid-fallback sudo firefox ubuntu-gnome-default-settings ca-certificates curl gnupg lxde arc-theme gtk2-engines-murrine gtk2-engines-pixbuf gnome-themes-standard nano xterm
RUN  DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt install -y --no-install-recommends --allow-unauthenticated libwxgtk3.0-gtk3-dev libboost-all-dev tcl8.6-dev libedit-dev
RUN apt install -y --no-install-recommends --allow-unauthenticated libsqlite3-dev sqlite3 libxerces-c-dev g++ make latex2html
RUN apt install -y --no-install-recommends --allow-unauthenticated libffi-dev autoconf automake libtool subversion git cmake graphviz

RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo user
RUN sh -c 'echo "user:pass" | chpasswd'
RUN chown -R user:user /home/user
RUN mkdir -p /home/user/.config/pcmanfm/LXDE/
RUN ln -sf /usr/local/share/doro-lxde-wallpapers/desktop-items-0.conf /home/user/.config/pcmanfm/LXDE/

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV JAVA_TOOL_OPTIONS -Dsun.java2d.xrender=false
ENV DISPLAY "host.docker.internal:0"
