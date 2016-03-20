#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

sudo aptitude update -q

# -------------------------------------------------------------------------

# standard user configuration

mkdir $HOME/bin

sudo cat >> $HOME/.bashrc <<EOF

# Adding custom user bin folder
PATH="\$HOME/bin:$PATH"
EOF


# -------------------------------------------------------------------------
# SDL

sudo aptitude install -q -y -f libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-gfx-dev

# -------------------------------------------------------------------------

# PSXSDK

# (from sources, needs mipsel-unknown-elf toolchain)
# cd /tmp/
# wget -O psxsdk.tar.bz2 http://unhaut.x10host.com/psxsdk/psxsdk-20150729.tar.bz2
# tar xvjf psxsdk.tar.bz2
# cd psxsdk-20150729
# make

cd /tmp/
#wget http://unhaut.x10host.com/psxsdk/psxsdk-20150729-linux-i686-toolchain.tar.xz
wget http://unhaut.fav.cc/psxsdk/psxsdk-20150729-linux-i686-toolchain.tar.xz
tar xf psxsdk-20150729-linux-i686-toolchain.tar.xz
sudo mv usr/local/psxsdk /usr/local/psxsdk
sudo cat >> $HOME/.bashrc <<EOF

# Adding PSXSDK to PATH
PATH="/usr/local/psxsdk/bin:\$PATH"
EOF

sudo aptitude install -q -y -f genisoimage

ln -sf /vagrant/psxsdk-make.sh $HOME/bin/psxsdk-make
chmod u+x $HOME/bin/psxsdk-make
