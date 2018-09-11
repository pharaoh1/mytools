sudo add-apt-repository ppa:keithw/mosh
sudo apt-get update
sudo apt full-upgrade -y
sudo apt-get install mosh build-essential bc libncurses5-dev libelf-dev python-all-dev python-software-properties diffutils colordiff zip rsync tmux -y
# Import .tmux.conf
cat tmux.conf > ~/.tmux.conf
# Install ccache
sudo apt-get install ccache -y
sudo /usr/sbin/update-ccache-symlinks
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
# Install gdrive
sudo install gdrive /usr/local/bin/gdrive
gdrive list
sudo dpkg-reconfigure tzdata
# Clone kernel source
cd ~
git clone -b dev https://github.com/RebelLion420/kernel-msm_perry ok
cd ok
tmux a
