#!/bin/bash

printf "\tBuild Environment Setup Script\n\n\t\tby RebelLion420"
echo "Updating environment and installing required packages..."
mkdir ~/kernel
HOME=~/kernel
DIR=~/kernel/mytools
read -sp "Sudo Password: " pwd 
echo '$pwd' | sudo -S add-apt-repository ppa:keithw/mosh
echo '$pwd' | sudo -S apt-get update
echo '$pwd' | sudo -S apt full-upgrade -y
echo '$pwd' | sudo -S apt-get install mosh build-essential bc libncurses5-dev libelf-dev python-all-dev python-software-properties diffutils colordiff zip liblz4-tool vim tmux -y
echo "Done."
sleep 0.5
echo "Importing config files..."
sleep 1
cp $DIR/personal/.tmux.conf ~/
cp $DIR/personal/.bashrc ~/
echo "Done."
sleep 0.5
echo "Installing ccache..."
sleep 1
echo '$pwd' | sudo -S apt-get install ccache -y
echo '$pwd' | sudo -S /usr/sbin/update-ccache-symlinks
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
echo "Done."
sleep 0.5
echo "Installing gdrive, mega-cmd, and hub..."
sleep 1
cp $DIR/personal/gdrive ./
cp $DIR/personal/mega* ./
chmod +x gdrive
echo '$pwd' | sudo -S install gdrive /usr/local/bin/gdrive
echo '$pwd' | sudo -S dpkg -i mega*.deb
if ( $? -ne 0 ); then
	echo '$pwd' | sudo -S apt-get install -f -y && sudo dpkg -i mega*.deb
fi
echo '$pwd' | sudo -S bash $DIR/personal/hub/install
echo "Done."
sleep 0.5
echo "Cloning kernel source..."
sleep 1
cd $HOME
git clone --recurse-submodules https://github.com/RebelLion420/kernel_perry
echo "Done."
sleep 0.5
echo "Setting up the little things..."
sleep 1
cd kernel_perry
cp $DIR/scripts/build.sh ./
cp $DIR/scripts/linux-stable.sh ./
chmod +x build.sh && chmod +x linux-stable.sh
read -sp "Mega Password: " mpwd
mega-login gaigecarlos@gmail.com '$mpwd'
echo '$pwd' | sudo -S dpkg-reconfigure tzdata
gdrive list
tmux a

