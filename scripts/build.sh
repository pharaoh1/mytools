#!/usr/bin/env bash
if [ -z $2 ] || [ -z $3 ] ; then
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

# Sanity check to avoid using erroneous binaries
if [ -e  out/arch/$ARCH/boot/*Image* ] ; then
	rm -r out
#	rm $AK2DIR/*.dtb
	rm $AK2DIR/*Image*
	rm -r $AK2DIR/modules/*
	make clean
	make mrproper
	mkdir out
	mkdir -p $AK2DIR/modules/system/lib/modules
	touch $AK2DIR/modules/system/lib/modules/placeholder
fi

if [ "$1" == 'auto' ] ; then
	t=$(nproc --all)
else
	t=$1
fi
GCCV=$("$CROSS_COMPILE"gcc -v 2>&1 | tail -1 | cut -d ' ' -f 3)
printf "\nTHREADS: $t\nVERSION: $2\nRELEASE: $3\nGCC VERSION: $GCCV\n\n"
echo "==> Adapted build script, courtest of @facuarmo"
echo "==> Making kernel binary..."
make O=out perry_defconfig
make O=out -j$t zImage |& tee fail.log
if [ ${PIPESTATUS[0]} -ne 0 ] ; then
	echo "!!! Kernel compilation failed, can't continue !!!"
	gdrive upload --delete fail.log
	exit 2
fi
echo "=> Making modules..."
make O=out -j$t modules |& tee -a fail.log
if [ ${PIPESTATUS[0]} -ne 0 ] ; then
	echo "Module compilation failed, can't continue."
	gdrive upload --delete fail.log
	exit 1
fi
rm -rf out/modinstall
mkdir out/modinstall
make O=out -j$t modules_install INSTALL_MOD_PATH=modinstall INSTALL_MOD_STRIP=1 |& tee -a fail.log
if [ ${PIPESTATUS[0]} -ne 0 ] ; then
	echo "Module installation failed, can't continue."
	gdrive upload --delete fail.log
	exit 1
fi

# One more sanity check
if [ -e $AK2DIR/*Image* ] ; then
	rm $AK2DIR/*Image*
#	rm $AK2DIR/*.dtb
	rm $AK2DIR/modules/system/lib/modules/pronto/*.ko
fi

echo "==> Kernel compilation completed"

echo "==> Making Flashable zip"

echo "=> Finding modules"

find out/modinstall/ -name '*.ko' -type f -exec cp '{}' "$AK2DIR/modules/system/lib/modules/" \;
mkdir -p "$AK2DIR/modules/system/lib/modules/pronto"
mv "$AK2DIR/modules/system/lib/modules/wlan.ko" "$AK2DIR/modules/system/lib/modules/pronto/pronto_wlan.ko"

cp  $KDIR/out/arch/$ARCH/boot/zImage $AK2DIR
#cp  $KDIR/out/arch/$ARCH/boot/dts/qcom/*.dtb $AK2DIR

cd $AK2DIR

zip -r9 $FINAL_ZIP * -x .git README.md *placeholder > /dev/null

if [ -e $FINAL_ZIP ] ; then
	echo "==> Flashable zip created"
	echo "==> Uploading $FINAL_ZIP to Google Drive"
	gdrive upload --delete $AK2DIR/$FINAL_ZIP
	echo "==> Upload complete!"
	echo "*** Enjoy your kernel! ***"
	exit 0
else
	echo "!!! Unexpected error. Abort !!!"
	exit 1
fi

