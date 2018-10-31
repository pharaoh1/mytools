#!/bin/bash
# Uncomment lines starting with '###' if your build produces Device Tree Blob (.dtb) files
if [ -z $1 ] || [ -z $2 ] ; then
	printf "\nUsage: \n\n\tbash build.sh <thread_amount> <version_#> <release_type> <make_clean>\n\n\tNOTE: '<thread_amount>' can be an integer or 'auto'.\n\n\t'<make_clean>' is either 'y', or blank\n\n"
	exit 1
fi

# Adjust these variables for your build
KNAME="OrgasmKernel"
IMG=Image.gz
KDIR=$PWD
TCDIR=~/mytools/toolchains/linaro-4.9.4-aarch64-linux-gnu/bin/aarch64-linux-gnu-
AK2DIR=$KDIR/AnyKernel2
export ARCH=arm64
export DEVICE="perry"
export KBUILD_BUILD_USER="RblLn"
export KBUILD_BUILD_HOST="PleasureBox"
# For GDrive uploading
BETA_DIR=1kck7RBzMCc8k1DgExWLQWGnftADI_yn6
UPSTREAM_DIR=1N7VCEe7KloVF_MFIn3lwcvYodLNhNhNs
REDO_DIR=1C29fLGrow11cFyo8rwz0SLL7he8wxHi5
#

export SUBARCH=$ARCH
export CROSS_COMPILE=$TCDIR
export USE_CCACHE=1
export COMPRESS_CACHE=1
DATE=$(date +"%m%d%y")
VER="-v$2"
TYPE="_$3"
FINAL_ZIP="$KNAME"-"$DEVICE""$TYPE""$VER"_"$DATE".zip
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
	rm $AK2DIR/*Image*
	rm $AK2DIR/*.zip
###	rm $AK2DIR/*.dtb
	rm -f $AK2DIR/modules/system/lib/modules/*.ko
	echo "==> Ready!"
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
	rm $AK2DIR/*Image*
	rm $AK2DIR/*.zip
###	rm $AK2DIR/*.dtb
	rm -f $AK2DIR/modules/system/lib/modules/*.ko
fi

echo "==> Kernel compilation completed"

echo "==> Making Flashable zip"

echo "==> Finding modules"

find out/modinstall/ -name '*.ko' -type f -exec cp '{}' "$AK2DIR/modules/system/lib/modules/pronto/" \;
ln -sf "$AK2DIR/modules/system/lib/modules/pronto/pronto_wlan.ko" "$AK2DIR/modules/system/lib/modules/wlan.ko"

cp  $KDIR/out/arch/$ARCH/boot/$IMG $AK2DIR
###cp  $KDIR/out/arch/$ARCH/boot/dts/qcom/*.dtb $AK2DIR

cd $AK2DIR

zip -r9 $FINAL_ZIP * -x .git README.md *placeholder > /dev/null

if [ -e $FINAL_ZIP ]; then
	echo "==> Flashable zip created"
	echo "==> Uploading $FINAL_ZIP to Google Drive"
	if [[ $3 == 'Beta' ]]; then
		gdrive upload --delete --parent $BETA_DIR $AK2DIR/$FINAL_ZIP
	elif [[ $3 == 'Upstream' ]]; then
		gdrive upload --delete --parent $UPSTREAM_DIR $AK2DIR/$FINAL_ZIP
	elif [[ $3 == 'Redo*' ]]; then
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
 
