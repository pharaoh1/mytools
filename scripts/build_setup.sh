sudo add-apt-repository ppa:keithw/mosh
sudo apt-get update
sudo apt full-upgrade -y
sudo apt-get install mosh build-essential bc libncurses5-dev libelf-dev python-all-dev python-software-properties diffutils colordiff zip liblz4-tool vim tmux -y
# Import .tmux.conf
cat tmux.conf > ~/.tmux.conf
# Install ccache
sudo apt-get install ccache -y
sudo /usr/sbin/update-ccache-symlinks
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
# Install gdrive
wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download"
mv uc?id* gdrive
chmod +x gdrive
sudo install gdrive /usr/local/bin/gdrive
gdrive list
sudo dpkg-reconfigure tzdata
# Clone kernel source
cd ~
git clone -b dev https://github.com/RebelLion420/android_kernel_motorola_msm8937 ok
cd ok
tmux a
