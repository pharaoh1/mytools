#!/bin/bash

if [ -z $1 ] || [ -z $2 ] ; then
	printf "\nUsage: \n\n\tbash build.sh <thread_amount> <release_type> <version_#> <make_clean>\n\n\tNOTE: '<thread_amount>' can be an integer or 'auto'.\n\n\t'<make_clean>' is either 'y', or blank\n\n"
	exit 1
fi

# Adjust these variables for your build
KNAME="RebelKernel"
IMG=Image.gz
KDIR=$PWD
export CROSS_COMPILE=$KDIR/../mytools/toolchains/linaro-4.9.4-aarch64-linux-gnu/bin/aarch64-linux-gnu-
AK2DIR=$KDIR/AnyKernel2
export ARCH=arm64
export SUBARCH=$ARCH
export DEVICE="perry"
export KBUILD_BUILD_USER="RblLn"
export KBUILD_BUILD_HOST="lions-den"
# For GDrive uploading
BETA_DIR=1kck7RBzMCc8k1DgExWLQWGnftADI_yn6
UPSTREAM_DIR=1N7VCEe7KloVF_MFIn3lwcvYodLNhNhNs
REDO_DIR=1C29fLGrow11cFyo8rwz0SLL7he8wxHi5
#

export USE_CCACHE=1
export COMPRESS_CACHE=1
DATE=$(date +"%m%d%y")
TYPE="$2"
VER="v$3"
FINAL_ZIP="$KNAME"_"$TYPE"-"$VER"_"$DATE".zip
GCCV=$("$CROSS_COMPILE"gcc -v 2>&1 | tail -1 | cut -d ' ' -f 3)

if [ $1 == 'auto' ]; then
	t=$(nproc --all)
else
	t=$1
fi

# Check if cleaning
if [[ $4 == 'y' ]]; then
	echo "==> Hold on a sec..."
	sudo make clean && sudo make mrproper
	rm -rf out
	mkdir -p out/modinstall
	rm -f $AK2DIR/*Image*
	rm -f $AK2DIR/*.zip
	rm -f $AK2DIR/*.dtb
	rm -f $AK2DIR/modules/system/lib/modules/*.ko
	echo "==> Ready!"
fi

if [ -e fail.log ]; then
	rm fail.log
fi

printf "\nTHREADS: $t\nVERSION: $2\nRELEASE: $3\nGCC VERSION: $GCCV\n\n"
echo "==> Adapted build script, courtesy of @facuarmo"
sleep 1
echo "==> Making kernel binary..."
make O=out "$DEVICE"_defconfig
make O=out -j$t $IMG |& tee fail.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	echo "!!! Kernel compilation failed, can't continue !!!"
	gdrive upload --delete fail.log
	exit 2
fi
echo "=> Making modules..."
make O=out -j$t modules |& tee -a fail.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	echo "Module compilation failed, can't continue."
	gdrive upload --delete fail.log
	exit 1
fi
make O=out -j$t modules_install INSTALL_MOD_PATH=modinstall INSTALL_MOD_STRIP=1 |& tee -a fail.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	echo "Module installation failed, can't continue."
	gdrive upload --delete fail.log
	exit 1
fi

if [ -e fail.log ]; then
	rm fail.log
fi

# One more sanity check
if [ -e $AK2DIR/*Image* ]; then
	rm -f $AK2DIR/*Image*
	rm -f $AK2DIR/*.zip
	rm -f $AK2DIR/*.dtb
	rm -f $AK2DIR/modules/system/lib/modules/*.ko
fi

echo "==> Kernel compilation completed"

echo "==> Finding modules"

find out/modinstall/ -name '*.ko' -type f -exec cp '{}' "$AK2DIR/modules/system/lib/modules/" \;

echo "==> Making Flashable zip"

cp  $KDIR/out/arch/$ARCH/boot/$IMG $AK2DIR
cp  $KDIR/out/arch/$ARCH/boot/dts/qcom/*.dtb $AK2DIR

cd $AK2DIR

zip -r9 $FINAL_ZIP * -x .git README.md *placeholder > /dev/null

if [ -e $FINAL_ZIP ]; then
	echo "==> Flashable zip created"
	echo "==> Uploading $FINAL_ZIP to Google Drive"
	if [[ $3 == 'Beta' ]]; then
		gdrive upload --delete --parent $BETA_DIR $AK2DIR/$FINAL_ZIP
	elif [[ $3 == 'Upstream' ]]; then
		gdrive upload --delete --parent $UPSTREAM_DIR $AK2DIR/$FINAL_ZIP
	elif [[ $3 == 'Redo'* ]]; then
		gdrive upload --delete --parent $REDO_DIR $AK2DIR/$FINAL_ZIP
	else
		gdrive upload --delete $AK2DIR/$FINAL_ZIP
	fi
	if [ $? -e 0 ]; then
		echo "==> Upload complete!"
	else
		echo "==> Upload failed!"
		exit 1
	exit 0
else
	echo "!!! Unexpected error. Abort !!!"
	exit 1
fi
 
