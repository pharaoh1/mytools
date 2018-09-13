#!/usr/bin/env bash
if [ -z $2 ] || [ -z $3 ]
then
	printf "\nUsage: \n\n\tbash build.sh [thread_amount] version_# release_type\n\n\tNOTE: '[thread_amount]' can be an integer or 'auto'.\n\n"
	exit 1
fi

KDIR=$PWD
AK2DIR=~/AnyKernel2
TCDIR=~/mytools/toolchains/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
DATE=$(date +"%m%d%y")
KNAME="OrgasmKernel"

export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=$TCDIR
export USE_CCACHE=1
export COMPRESS_CACHE=1
export DEVICE="perry"
export KBUILD_BUILD_USER="RblLn"
export KBUILD_BUILD_HOST="PleasureBox"
VER="-v$2"
TYPE="_$3"
export FINAL_ZIP="$KNAME"-"$DEVICE""$TYPE""$VER"_"$DATE".zip

if [ -e  out/arch/$ARCH/boot/*Image* ]
	then
	rm -r out
	rm $AK2DIR/*.dtb
	rm $AK2DIR/*Image*
	rm -r $AK2DIR/modules/*
	make clean
	make mrproper
	mkdir out
	mkdir -p $AK2DIR/modules/system/lib/modules
	touch $AK2DIR/modules/system/lib/modules/placeholder
fi

if [ "$1" == 'auto' ]
then
	t=$(nproc --all)
else
	t=$1
fi
GCCV=$("$CROSS_COMPILE"gcc -v 2>&1 | tail -1 | cut -d ' ' -f 3)
printf "\nTHREADS: $t\nVERSION: $2\nRELEASE: $3\nGCC VERSION: $GCCV\n\n"
echo "==> Adapted build script, courtest of @facuarmo"
echo "==> Making kernel binary..."
make O=out perry_defconfig
make O=out -j$t zImage |& tee build.log
if [ $? -ne 0 ]
then
	echo "!!! Kernel compilation failed, can't continue !!!"
	exit 1
fi
echo "=> Making modules..."
make O=out -j$t modules
if [ $? -ne 0 ]
then
	echo "Module compilation failed, can't continue."
	exit 1
fi
rm -rf out/modinstall
mkdir out/modinstall
make O=out -j$t modules_install INSTALL_MOD_PATH=modinstall INSTALL_MOD_STRIP=1
if [ $? -ne 0 ]
then
	echo "Module installation failed, can't continue."
	exit 1
fi

echo "==> Kernel compilation completed"

echo "==> Making Flashable zip"

echo "=> Finding modules"

rsync -P --include '*.ko' --exclude '*' out/modinstall/ $AK2DIR/modules/system/lib/modules
mkdir -p "$AK2DIR/modules/system/lib/modules/pronto"
mv "$AK2DIR/modules/system/lib/modules/wlan.ko" "$AK2DIR/modules/system/lib/modules/pronto/pronto_wlan.ko"

cp  $KDIR/out/arch/$ARCH/boot/zImage $AK2DIR
#cp  $KDIR/out/arch/$ARCH/boot/dts/qcom/*.dtb $AK2DIR

cd $AK2DIR

if [ -e $AK2DIR/*.zip ]
then
	rm *.zip
fi

zip -r9 $FINAL_ZIP * -x .git README.md *placeholder > /dev/null

if [ -e $FINAL_ZIP ]
then
	echo "==> Flashable zip created"
	echo "==> Flashable zip is stored in $AK2DIR folder with name $FINAL_ZIP"
	exit 0
else
	echo "!!! Failed to make zip. Abort !!!"
	exit 1
fi

