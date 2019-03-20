#!/bin/bash
#TERM="xterm-256color"
# Uncomment lines starting with '###' if your build produces Device Tree Blob (.dtb) files
# Redefine KNAME, BUILD_USER and BUILD_HOST for your build

# Change these for your build
KNAME="RebelKernel"
export KBUILD_BUILD_USER="RblLn"
export KBUILD_BUILD_HOST="Lion's_Den"
# MEGA folder paths
KERN=RebelKernel
KERNBETA=RebelKernel/Beta
KERNREL=RebelKernel/Release
# Script output appearance
red="\033[1;91m"
green="\033[1;92m"
green1="\033[1;4;92m"
blue="\033[1;94m"
cyan="\033[1;96m"
blinkgreen="\033[1;5;92m"
blinkcyan="\033[1;5;96m"
die="\033[1;5;91m"
reset="\033[0m"
top="$cyan	╔══════════════════════════════════════════════════════════┅┄ $reset"
mid="$cyan	║ $reset"
end="$cyan	╚══════════════════════════════════════════════════════════┅┄ $reset"
# Core functions
trap "echo EXIT;  exit" 0
trap "echo HUP;   exit" 1
trap "echo CTL-C; exit" 2
trap "echo ERR;   exit" ERR
usage() {
	printf "\n$top\n$mid\t\t  ${blinkgreen}MISSING ARGUMENTS (AT LEAST 2)$reset\n$end"
	printf "\n ${green1}Usage: \n\t$reset$0 ${blue}<arm|arm64> <device> ${green}(optional) ${blue}<jobs> <type> <version #>"
	printf "\n\n ${green1}Arguments:$reset"
	printf "\n\n\t${blue}'<device>' is the name of target defconfig"
	printf "\n\t'<jobs>' is number of threads or blank for 'auto'"
	printf "\n\t'<type>' can be 'Release', 'Beta' or blank"
	printf "\n\t'<version #>' is preceded by 'v' (eg. 'v1.0')$reset\n\n"
	exit 1
}
greplog() {
	cat .errors|egrep -i 'fatal|cannot' > .errorlog
	cat .errors|awk '/error: /{flag=1} /cc1: /{flag=0} flag' >> .errorlog
	echo -e "$top"
	echo -e "$mid"
	cat .errorlog|sed -e 's/^/\	║	/'
	echo -e "$mid"
	echo -e "$end"
	gdrive upload --delete .errorlog
}
runtime() {
	end='date +%s'
	totaltime=$((end-start))
	diff=$(printf '%dm:%ds' $(($totaltime%3600/60)) $(($totaltime%60)))
	echo -e "${cyan}Process lasted $diff$reset"
}
run_build() {
cmd="make $3"
if make "$@"
then
	echo -e "$top"
	echo -e "$mid"
	echo -e "$mid    $green$cmd succeeded.$reset"
	echo -e "$mid"
	echo -e "$end"
else
	echo -e "${die}!!! $cmd failed, can't continue !!!$reset"
	greplog
	runtime
	exit 1
fi
}
# Check for needed variables
if [ -z $1 ] && [ -z $2 ]; then
	usage
fi
# Directories
KDIR=$PWD
AK2DIR=$KDIR/AnyKernel2
# Architecture check
if [[ $1 = arm ]]; then
	IMG=zImage
	export ARCH=arm
	export CROSS_COMPILE=$KDIR/../mytools/toolchains/linaro-7.4.1-arm-eabi/bin/arm-eabi-
elif [[ $1 = arm64 ]]; then
	IMG=Image.gz
	export ARCH=arm64
	export CROSS_COMPILE=$KDIR/../mytools/toolchains/linaro-4.9.4-aarch64-linux-gnu/bin/aarch64-linux-gnu-
else
	echo -e "$top"
	echo -e "$mid${die}ERROR:$reset ${red}ARCH is either arm or arm64$reset"
	echo -e "$end"
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
if [ -e $KDIR/.errors ]; then
	rm $KDIR/.errors
fi
if [ -e $KDIR/out/arch/arm/boot/zImage ] || [ -e $KDIR/out/arch/arm64/boot/Image.gz ]; then
	rm -f $KDIR/out/arch/arm/boot/zImage
	rm -f $KDIR/out/arch/arm64/boot/Image.gz
	rm -rf $KDIR/out/modinstall/
	mkdir -p $KDIR/out/modinstall/
fi
# Begin Build
start='date +%s'
printf "\n$top\n$mid\t${green}ARCHITECTURE: $blue$1\n$mid\t${green}DEVICE: $blue$2\n$mid\t${green}THREADS: $blue$t\n"
if [ -z $4 ] && [ -z $5 ]; then
	printf "$mid\t${green}GCC VERSION: $blue$GCCV\n$end\n$reset"
else
	printf "$mid\t${green}TYPE: $blue$4\n$mid\t${green}VERSION: $blue$5\n$mid\t${green}GCC VERSION: $blue$GCCV\n$end\n$reset"
fi
echo -e "$mid\t${green}Build script by ${blinkcyan}FacuM$reset ${green}and ${blinkcyan}RebelLion420$reset"
sleep 1
echo -e "$mid\t$green==> Making kernel image...$reset"
make O=out "$2"_defconfig 2> >(tee .errors >&2)
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	echo -e "$top\n$mid\t${red}TARGET DEVICE INVALID. Choose a valid defconfig.$reset\n"
	if [ $1 = arm ]; then
		printf "$mid\n$mid\t${green1}Listing available configs:\n$reset"
		ls arch/arm/configs|sed -e 's/^/\	║	/'
	elif [ $1 = arm64 ]; then
		printf "$mid\n$mid\t${green1}Listing available configs:\n$reset$cyan"
		ls arch/arm64/configs|sed -e 's/^/\	║	/'
	fi
	greplog
	runtime
	exit 1
else
	echo -e "$top\n$mid\t${green}make $2_defconfig succeeded.$reset\n$end"
fi
run_build O=out -j$t $IMG 2> >(tee -a .errors >&2)
### echo -e "$mid\t$green=> Making DTBs...$reset"
### run_build O=out -j$t dtbs 2> >(tee -a .errors >&2)
echo -e "$mid\t$green=> Making modules...$reset"
run_build O=out -j$t modules 2> >(tee -a .errors >&2)
run_build O=out -j$t modules_install INSTALL_MOD_PATH=modinstall INSTALL_MOD_STRIP=1 2> >(tee -a .errors >&2)
# One more check
if [ -e $AK2DIR/*Image* ]; then
	rm -f $AK2DIR/*Image*
	rm -f $AK2DIR/*.zip
	rm -f $AK2DIR/*.dtb
	rm -f $AK2DIR/modules/system/lib/modules/*.ko
fi
# Build Finished
echo -e "$top"
echo -e "$mid"
echo -e "$mid\t$blinkcyan==> Kernel compilation completed$reset"
echo -e "$mid"
echo -e "$end"
# Determines zip name format
if [ -z $4 ] || [ -z $KNAME ]; then
	FINAL="$2"_kernel-"$DATE".zip
elif [ -z $4 ]; then
	FINAL="$KNAME"_"$DATE".zip
else
	FINAL="$KNAME"_"$4"-"v$5"_"$DATE".zip
fi
# Zip Process
echo -e "$mid\t$green==> Finding modules$reset"
find out/modinstall/ -name '*.ko' -type f -exec cp '{}' "$AK2DIR/modules/system/lib/modules/" \;
echo -e "$mid\t$green==> Making Flashable zip$reset"
cp  $KDIR/out/arch/$ARCH/boot/$IMG $AK2DIR
### cp  $KDIR/out/arch/$ARCH/boot/dts/qcom/*.dtb $AK2DIR
cd $AK2DIR
zip -r9 $FINAL * -x .git README.md *placeholder > /dev/null
# Upload to MEGA
if [ -e $FINAL ]; then
	echo -e "$top\n$mid$cyan==> Flashable zip created$reset\n$end"
	echo -e "$mid\t$green==> Uploading Kernel Zip to Mega folder$reset"
	if [[ $4 = Beta* ]]; then
		echo -e "$cyan=> $FINAL --> $KERNBETA$reset"
		mega-put -q $FINAL $KERNBETA
	elif [[ $4 = Release* ]]; then
		echo -e "$cyan=> $FINAL --> $KERNREL$reset"
		mega-put -q $FINAL $KERNREL
	else
		echo -e "$cyan=> $FINAL --> $KERN$reset"
		mega-put -q $FINAL $KERN
	fi
	if [ $? != 0 ]; then
		echo -e "$top"
		echo -e "$mid"
		echo -e "$mid\t${die}!!! Upload failed. Unexpected error. !!!$reset"
		echo -e "$mid"
		echo -e "$end"
		runtime
		exit 1
	else
		echo -e "$top\n$mid\t${green}=> Upload complete!$reset\n$end"
	fi
else
	echo -e "$top"
	echo -e "$mid"
	echo -e "${mid}${die}!!! Unexpected error. Abort !!!$reset"
	echo -e "$mid"
	echo -e "$end"
	runtime
	exit 1
fi
runtime
exit 0

