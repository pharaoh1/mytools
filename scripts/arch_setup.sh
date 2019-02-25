#!/bin/bash
#TERM=xterm-256color

# Script output appearance
red="\033[1;91m"
green="\033[1;92m"
green1="\033[1;4;92m"
blue="\033[1;94m"
cyan="\033[1;96m"
blinkred="\033[1;5;91m"
blinkgreen="\033[1;5;92m"
blinkcyan="\033[1;5;96m"
die="\033[1;5;91m"
reset="\033[0m"
top="${cyan}    ╔═════════════════════════════════════════════════════════════════════┅┄ ${reset}"
mid="${cyan}    ║ ${reset}"
end="${cyan}    ╚═════════════════════════════════════════════════════════════════════┅┄ ${reset}"

printf "\n$top\n$mid\t${green}Build Environment Setup Script\n\n\t\tby RebelLion420$reset$end\n"
echo "${cyan}Updating environment and installing required packages...${reset}"
mkdir ~/kernel
HOME=~/kernel
DIR=~/kernel/mytools
read -sp "Sudo Password: " passwd
pswd=(echo '$passwd' | sudo -S)
install=(yes | $pswd pacman -S)
${install}yu
$install mosh build-essential bc libncurses5-dev libelf-dev python-all-dev python-software-properties diffutils colordiff zip rar liblz4-dev vim tmux
echo -e "${green}Done.$reset"
sleep 0.5
echo -e "${cyan}Importing config files...$reset"
sleep 1
cp $DIR/personal/.tmux.conf ~/
cp $DIR/personal/.bashrc ~/
echo -e "${green}Done.$reset"
sleep 0.5
echo -e "${cyan}Installing ccache...$reset"
sleep 1
$install ccache -y
$pswd /usr/sbin/update-ccache-symlinks
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
echo -e "${green}Done.$reset"
sleep 0.5
echo -e "${cyan}Cloning kernel source...$reset"
sleep 1
cd $HOME
git clone -b rebel --recurse-submodules https://github.com/RebelLion420/kernel_perry
echo -e "${green}Done.$reset"
sleep 0.5
echo -e "${cyan}Setting up the little things...$reset"
sleep 1
cd kernel_perry
cp $DIR/scripts/build.sh ./
cp $DIR/scripts/linux-stable.sh ./
chmod +x build.sh && chmod +x linux-stable.sh
#git config --global user.name RebelLion420
#git config --global user.email gaigecarlos@gmail.com
git config --global merge.renameLimit 99999
git config --global push.default simple
git config --global rerere.enabled true
read -sp "Mega Password: " mpwd
mega-login gaigecarlos@gmail.com '$mpwd'
$pswd dpkg-reconfigure tzdata
gdrive list
tmux a

