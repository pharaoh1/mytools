#!/bin/bash

echo "Updating environment and installing required packages..."
mkdir ~/kernel
HOME=~/kernel
DIR=~/kernel/mytools
sudo add-apt-repository ppa:keithw/mosh
sudo apt-get update
sudo apt full-upgrade -y
sudo apt-get install mosh build-essential bc libncurses5-dev libelf-dev python-all-dev python-software-properties diffutils colordiff zip liblz4-tool vim tmux -y
echo "Done."
sleep 1
echo "Importing config files..."
cp $DIR/personal/.tmux.conf ~/
cp $DIR/personal/.bashrc ~/
echo "Done."
sleep 1
echo "Installing ccache..."
sudo apt-get install ccache -y
sudo /usr/sbin/update-ccache-symlinks
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
echo "Done."
sleep 1
echo "Installing gdrive..."
wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download"
mv uc?id* gdrive
chmod +x gdrive
sudo install gdrive /usr/local/bin/gdrive
echo "Done."
sleep 1
sudo dpkg-reconfigure tzdata
echo "Cloning kernel source..."
cd $HOME
git clone -j4 --recurse-submodules https://github.com/RebelLion420/kernel_perry
cd kernel_perry
cp $DIR/scripts/build.sh ./
cp $DIR/scripts/64build.sh ./
cp $DIR/scripts/linux-stable.sh ./
tmux a

