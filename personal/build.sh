#!/usr/bin/env bash
# Uncomment lines starting with '###' if your build produces Device Tree Blob (.dtb) files
if [ -z $2 ] || [ -z $3 ] ; then
	printf "\nUsage: \n\n\tbash build.sh <thread_amount> <version_#> <release_type> <make_clean>\n\n\tNOTE: '<thread_amount>' can be an integer or 'auto'.\n\n\t'<make_clean>' is either 'ya' (yes after), 'yb' (yes before), 'b' (both) or blank\n\n"
	exit 1
fi

# Function definition

function fail()
{
	echo $1
        gdrive upload --delete fail.log
        exit 1
}

# Adjust these variables for your build
KNAME="OrgasmKernel"
IMG=zImage
TCDIR=~/mytools/toolchains/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
AK2DIR=~/AnyKernel2
export ARCH=arm
export DEVICE="perry"
export KBUILD_BUILD_USER="RblLn"
export KBUILD_BUILD_HOST="PleasureBox"
#

export SUBARCH=$ARCH
export CROSS_COMPILE=$TCDIR
export USE_CCACHE=1
export COMPRESS_CACHE=1
KDIR=$PWD
DATE=$(date +"%m%d%y")
VER="-v$2"
TYPE="_$3"
FINAL_ZIP="$KNAME"-"$DEVICE""$TYPE""$VER"_"$DATE".zip
GCCV=$("$CROSS_COMPILE"gcc -v 2>&1 | tail -1 | cut -d ' ' -f 3)

# Sanity check to avoid using erroneous binaries
if [ -e  out/arch/$ARCH/boot/$IMG ]; then
	rm -rf out/
	mkdir -p out/modinstall
fi

if [ $1 == 'auto' ]; then
	t=$(nproc --all)
else
	t=$1
fi

# Check if cleaning
if [[ $4 == 'yb' ]] || [[ $4 == 'b' ]]; then
	echo "==> Hold on a sec..."
	make clean
	make mrproper
	echo "==> Ready!"
fi

printf "\nTHREADS: $t\nVERSION: $2\nRELEASE: $3\nGCC VERSION: $GCCV\n\n"
echo "==> Adapted build script, courtest of @facuarmo"
sleep 1
echo "==> Making kernel binary..."
make O=out perry_defconfig
make O=out -j$t $IMG 2> fail.log || fail "!!! Kernel copilation failed, can't continue !!!"
echo "=> Making modules..."
make O=out -j$t modules 2>> fail.log || fail "Module compilation failed, can't continue."
make O=out -j$t modules_install INSTALL_MOD_PATH=modinstall INSTALL_MOD_STRIP=1 2>> fail.log || fail "Module installation failed, can't continue."

if [ -e fail.log ]; then
	rm fail.log
fi

# One more sanity check
if [ -e $AK2DIR/$IMG ]; then
	rm $AK2DIR/$IMG
###	rm $AK2DIR/*.dtb
	rm -rf $AK2DIR/modules/system/lib/modules/*
	touch $AK2DIR/modules/system/lib/modules/placeholder
fi

echo "==> Kernel compilation completed"

echo "==> Making Flashable zip"

echo "=> Finding modules"

find out/modinstall/ -name '*.ko' -type f -exec cp '{}' "$AK2DIR/modules/system/lib/modules/" \;
mkdir -p "$AK2DIR/modules/system/lib/modules/pronto"
mv "$AK2DIR/modules/system/lib/modules/wlan.ko" "$AK2DIR/modules/system/lib/modules/pronto/pronto_wlan.ko"

cp  $KDIR/out/arch/$ARCH/boot/$IMG $AK2DIR
###cp  $KDIR/out/arch/$ARCH/boot/dts/qcom/*.dtb $AK2DIR

cd $AK2DIR

zip -r9 $FINAL_ZIP * -x .git README.md *placeholder > /dev/null

if [ -e $FINAL_ZIP ]; then
	echo "==> Flashable zip created"
	echo "==> Uploading $FINAL_ZIP to Google Drive"
	gdrive upload --delete $AK2DIR/$FINAL_ZIP
	echo "==> Upload complete!"
	echo "*** Enjoy your kernel! ***"
	if [[ $4 == 'ya' ]] || [[ $4 == 'b' ]]; then
		cd $KDIR
		echo "==> Cleaning up..."
		make clean
		make mrproper
		rm -rf out/
		mkdir -p out/modinstall
		echo "==> All done!"
	fi
	exit 0
else
	echo "!!! Unexpected error. Abort !!!"
	exit 1
fi
