#!/bin/bash
#TERM="xterm-256color"
# Uncomment lines starting with '###' if your build produces Device Tree Blob (.dtb) files
# Redefine KNAME, BUILD_USER and BUILD_HOST for your build

# Change these for your build
KNAME="RebelKernel"
export KBUILD_BUILD_USER="RblLn"
export KBUILD_BUILD_HOST="Lion's_Den"
# Script output colors
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
# Core functions
usage() {
	printf "\n\t\t  ${blinkgreen}MISSING ARGUMENTS (AT LEAST 2)${reset}"
	printf "\n ${green1}Usage: \n\t${reset}$0 ${blue}<arm|arm64> <device> ${green}(optional) ${blue}<jobs> <type> <version #>"
	printf "\n\n ${green1}Arguments:${reset}"
	printf "\n\n\t${blue}'<device>' is the name of target defconfig"
	printf "\n\t'<jobs>' is number of threads or blank for 'auto'"
	printf "\n\t'<type>' can be 'Release', 'Beta' or blank"
	printf "\n\t'<version #>' is preceded by 'v' (eg. 'v1.0')${reset}\n\n"
	exit 1
}
run_build() {
cmd="$1 $4"
status=${PIPESTATUS[0]}
"$@"
if [[ $status -ne 0 ]]; then
	echo -e "${die}!!! $cmd failed, can't continue !!!${reset}"
	gdrive upload --delete fail.log
	exit 1
else
	echo -e "${green}$cmd succeeded.${reset}"
fi
}
# Check for needed variables
if [ -z $1 ] && [ -z $2 ]; then
	usage
fi
# Directories
KDIR=$PWD
AK2DIR=$KDIR/AnyKernel2
# MEGA folder paths
KERN=RebelKernel
KERNBETA=RebelKernel/Beta
KERNREL=RebelKernel/Release
# Architecture check
if [[ $1 = arm ]]; then
	IMG=zImage
	export ARCH=arm
	export CROSS_COMPILE=$KDIR/../mytools/toolchains/linaro-4.9.4-arm-eabi/bin/arm-eabi-
elif [[ $1 = arm64 ]]; then
	IMG=Image.gz
	export ARCH=arm64
	export CROSS_COMPILE=$KDIR/../mytools/toolchains/linaro-4.9.4-aarch64-linux-gnu/bin/aarch64-linux-gnu-
else
	echo -e "${die}ERROR:${reset} ${red}ARCH is either arm or arm64${reset}"
	exit 1
fi
# Threads to run build
if [ -z $3 ]; then
	t=$(nproc --all)
else
	t=$3
fi
# Preconfigured variables
DATE=$(date +"%m%d%y")
GCCV=$("$CROSS_COMPILE"gcc -v 2>&1 | tail -1 | cut -d ' ' -f 3)
export SUBARCH=$ARCH
export DEVICE=$2
export USE_CCACHE=1
export COMPRESS_CACHE=1
EXTRA_CFLAGS="-w"
# Consistency checks
if [ -e $KDIR/fail.log ]; then
	rm $KDIR/fail.log
fi
if [ -e $KDIR/out/arch/arm/boot/zImage ] || [ -e $KDIR/out/arch/arm64/boot/Image.gz ]; then
	rm -f $KDIR/out/arch/arm/boot/zImage
	rm -f $KDIR/out/arch/arm64/boot/Image.gz
	rm -rf $KDIR/out/modinstall/
	mkdir $KDIR/out/modinstall/
fi
# Begin Build
printf "\n${green}ARCHITECTURE: ${blue}$1\n${green}DEVICE: ${blue}$2\n${green}THREADS: ${blue}$t\n"
if [ -z $4 ] && [ -z $5 ]; then
	printf "${green}GCC VERSION: ${blue}$GCCV\n\n${reset}"
else
	printf "${green}TYPE: ${blue}$4\n${green}VERSION: ${blue}$5\n${green}GCC VERSION: ${blue}$GCCV\n\n${reset}"
fi
echo -e "${green}Build script by ${blinkgreen}FacuM${reset} ${green}and ${blinkgreen}RebelLion420${reset}"
sleep 1
echo -e "${green}==> Making kernel image...${reset}"
make O=out "$DEVICE"_defconfig
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	echo -e "${red}TARGET DEVICE INVALID. Choose a valid defconfig.${reset}"
	if [ $1 = arm ]; then
		printf "\n${green1}Listing available configs:\n${reset}${cyan}"
		ls arch/arm/configs${reset}
	elif [ $1 = arm64 ]; then
		printf "\n${green1}Listing available configs:\n${reset}${cyan}"
		ls arch/arm64/configs${reset}
	fi
	exit 1
else
	echo -e "${green}make ${DEVICE}_defconfig succeeded.${reset}"
fi
run_build make O=out -j$t $IMG |& tee fail.log
### echo -e "${green}=> Making DTBs...${reset}"
### run_build make O=out -j$t dtbs |& tee -a fail.log
echo -e "${green}=> Making modules...${reset}"
run_build make O=out -j$t modules |& tee -a fail.log
run_build make O=out -j$t modules_install INSTALL_MOD_PATH=modinstall INSTALL_MOD_STRIP=1 |& tee -a fail.log
# One more check
if [ -e fail.log ]; then
	rm fail.log
fi
if [ -e $AK2DIR/*Image* ]; then
	rm -f $AK2DIR/*Image*
	rm -f $AK2DIR/*.zip
	rm -f $AK2DIR/*.dtb
	rm -f $AK2DIR/modules/system/lib/modules/*.ko
fi
# Build Finished
echo -e "${blinkcyan}==> Kernel compilation completed${reset}"
# Determines zip name format
if [ -z $4 ] || [ -z $KNAME ]; then
	FINAL="$DEVICE"_kernel-"$DATE".zip
elif [ -z $4 ]; then
	FINAL="$KNAME"_"$DATE".zip
else
	FINAL="$KNAME"_"$4"-"v$5"_"$DATE".zip
fi
# Zip Process
echo -e "${green}==> Finding modules${reset}"
find out/modinstall/ -name '*.ko' -type f -exec cp '{}' "$AK2DIR/modules/system/lib/modules/" \;
echo -e "${green}==> Making Flashable zip${reset}"
cp  $KDIR/out/arch/$ARCH/boot/$IMG $AK2DIR
### cp  $KDIR/out/arch/$ARCH/boot/dts/qcom/*.dtb $AK2DIR
cd $AK2DIR
zip -r9 $FINAL * -x .git README.md *placeholder > /dev/null
# Upload to MEGA
if [ -e $FINAL ]; then
	echo -e "${cyan}==> Flashable zip created${reset}"
	echo -e "${green}==> Uploading Kernel Zip to Mega folder${reset}"
	if [[ $4 = Beta* ]]; then
		echo -e "${cyan}=> $FINAL --> $KERNBETA${reset}"
		mega-put -q $FINAL $KERNBETA
	elif [[ $4 = Release* ]]; then
		echo -e "${cyan}=> $FINAL --> $KERNREL${reset}"
		mega-put -q $FINAL $KERNREL
	else
		echo -e "${cyan}=> $FINAL --> $KERN${reset}"
		mega-put -q $FINAL $KERN
	fi
	if [ $? != 0 ]; then
		echo -e "${die}!!! Upload failed. Unexpected error. !!!${reset}"
	else
		echo -e "${green}=> Upload complete!${reset}"
	fi
	exit 0
else
	echo "${die}!!! Unexpected error. Abort !!!${reset}"
	exit 1
fi
 
