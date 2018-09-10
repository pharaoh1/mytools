sudo apt-get update
sudo apt full-upgrade -y
sudo apt-get install build-essential bc libncurses5-dev libelf-dev python-all-dev diffutils colordiff vim rsync tmux -y
# Install ccache
sudo apt-get install ccache -y
sudo /usr/sbin/update-ccache-symlinks
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
# Install gdrive
wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download"
mv uc\?id\=0B3X9GlR6EmbnWksyTEtCM0VfaFE gdrive
chmod +x gdrive
sudo install gdrive /usr/local/bin/gdrive
gdrive list
sleep 5
dpkg-reconfigure tzdata
# Clone kernel source
git clone -b dev https://github.com/RebelLion420/kernel-msm_perry ok
cd ok
