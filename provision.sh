#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

sudo aptitude update -q

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
sudo cat >> /home/vagrant/.bashrc <<EOF

# Adding PSXSDK to PATH
PATH="/usr/local/psxsdk/bin:\$PATH"
EOF
