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

printf "\n$top\n$mid\t${green}Build Environment Setup Script\n\n\t\tby RebelLion420$reset\n$end\n"
echo -e "${cyan}Updating environment and installing required packages...${reset}\n"
HOME=~/kernel
DIR=~/kernel/mytools
read -sp "${cyan}Sudo Password: $reset" passwd
pswd=$(echo '$passwd' | sudo -S -k)
install=$($pswd aptitude install -y)
$pswd apt update && $pswd apt dist-upgrade -y
$pswd apt install aptitude
$install build-essential bc libncurses5-dev libelf-dev python-all-dev python-software-properties diffutils colordiff zip rar liblz4-dev vim tmux
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
source ~/.bashrc && echo $PATH
echo -e "${green}Done.$reset"
sleep 0.5
echo "${cyan}Installing gdrive, mega-cmd, and hub...$reset"
sleep 1
cp $DIR/personal/gdrive ./
cp $DIR/personal/mega* ./
chmod +x gdrive
$pswd install gdrive /usr/local/bin/gdrive
$pswd dpkg -i mega*.deb
if ( $? -ne 0 ); then
	$install -f && $pswd dpkg -i mega*.deb
fi
rm -f gdrive mega*.deb
$pswd bash $DIR/personal/hub/install
echo "${green}Done.$reset"
sleep 0.5
echo -e "${cyan}Cloning kernel source...$reset"
sleep 1
cd $HOME
git clone --recurse-submodules https://github.com/RebelLion420/kernel_perry
echo -e "${green}Done.$reset"
sleep 0.5
echo -e "${cyan}Setting up the little things...$reset"
sleep 1
cd kernel_perry
cp $DIR/scripts/build.sh ./
cp $DIR/scripts/linux-stable.sh ./
chmod +x build.sh && chmod +x linux-stable.sh
read -p "${cyan}Git Username: $reset" gitusr
read -p "${cyan}Git Email: $reset" gitmail
git config --global user.name $gitusr
git config --global user.email $gitmail
git config --global merge.renameLimit 99999
git config --global push.default simple
git config --global rerere.enabled true
read -p "${cyan}MEGA Email: $reset" mmail
read -sp "${cyan}MEGA Password: $reset" mpwd
mega-login $mmail '$mpwd'
$pswd dpkg-reconfigure tzdata
gdrive list
echo -e "${green}Done.$reset"
sleep 1
echo -e "${green}Setup complete!$reset"
tmux a

