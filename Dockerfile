
FROM --platform=linux/amd64 ubuntu:20.04

RUN apt update && apt upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt install autoconf libtool -y
RUN apt install python3 -y
RUN apt install bison flex g++ -y
RUN apt install dbus -y
RUN apt install x11-utils xorg -y
RUN apt install bzip2 libz-dev gawk ftp curl -y
RUN apt install texinfo -y
RUN apt install libexpat1-dev libgmp-dev -y
RUN apt install libwxgtk3.0-gtk3-dev -y
RUN apt install libboost-all-dev tcl8.6-dev libedit-dev libsqlite3-dev sqlite3 libxerces-c-dev g++ -y
RUN apt install latex2html libffi-dev autoconf automake libtool subversion git graphviz -y
RUN apt install pip -y
RUN pip install cmake --upgrade

RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo user
RUN sh -c 'echo "user:pass" | chpasswd'
RUN chown -R user:user /home/user
RUN mkdir -p /home/user/.config/pcmanfm/LXDE/
RUN ln -sf /usr/local/share/doro-lxde-wallpapers/desktop-items-0.conf /home/user/.config/pcmanfm/LXDE/

ENV HOME /root
ENV INSTALL_DIR /usr/local
ENV OPENASIP_SRC_DIR $HOME/openasip-devel/openasip
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$INSTALL_DIR/lib
ENV PATH $INSTALL_DIR/bin:$PATH
ENV LDFLAGS -L$INSTALL_DIR/lib

RUN mkdir -p $INSTALL_DIR
RUN sh -c "cd $HOME ; git clone https://github.com/cpc/openasip.git openasip-devel"
RUN sh -c "cd $OPENASIP_SRC_DIR ; sed -i 's/make -j..nproc. /make /' ./tools/scripts/install_llvm_17.sh"
RUN sh -c "cd $OPENASIP_SRC_DIR ; ./tools/scripts/install_llvm_17.sh $INSTALL_DIR"

RUN sh -c "cd $OPENASIP_SRC_DIR ; sed -i 's/GNU_TOOLCHAIN_OPTS=-j..nproc./GNU_TOOLCHAIN_OPTS=/' ./tools/scripts/install_riscv_tools.sh"
RUN sh -c "cd $OPENASIP_SRC_DIR ; ./tools/scripts/install_riscv_tools.sh $INSTALL_DIR"

RUN sh -c "CPPFLAGS=-DBOOST_TIMER_ENABLE_DEPRECATED ;  cd $OPENASIP_SRC_DIR ; ./autogen.sh && ./configure --prefix=$INSTALL_DIR && make -j4 && make install"

USER user
WORKDIR /home/user
ENV HOME /home/user
CMD ["/bin/bash", "-i"]

