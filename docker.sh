#!/bin/bash

# echo with color
function f_echo {
	echo -e "\e[1m\e[33m$1\e[0m"
}

export HOME=/home/user
export OPENASIP_DIR=openasip-devel

f_echo "Installing LLVM"
cd $HOME/$OPENASIP_DIR/openasip
./tools/scripts/install_llvm_17.sh $HOME/local

f_echo "Creating openasip.rc file"
cat > $HOME/openasip.rc << EOF
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$HOME/local/lib
export PATH=\$HOME/local/bin:\$PATH
export LDFLAGS=-L\$HOME/local/lib
EOF

f_echo "Sourceing openasip.rc"
. $HOME/openasip.rc 

f_echo "Installing RISCV tools"
cd $HOME/$OPENASIP_DIR/openasip
./tools/scripts/install_riscv_tools.sh $HOME/local

f_echo "Compiling OpenASIP"
cd $HOME/$OPENASIP_DIR/openasip
./autogen.sh && ./configure --prefix=$HOME/local && make -j4 && make install
