#!/bin/bash
# Uncomment lines starting with '###' if your build produces Device Tree Blob (.dtb) files
# Redefine KNAME, BUILD_USER and BUILD_HOST for your build

usage() {
	printf "\nUsage: \n\t./build.sh <arm|arm64> <device> <jobs> <type> <version #>"
	printf "\n\n  Arguments:"
	printf "\n\n\t'<device>' is the name of target defconfig"
	printf "\n\t'<jobs>' is number of threads or blank for 'auto'"
	printf "\n\t'<type>' can be 'Release', 'Beta' or blank"
	printf "\n\t'<version #>' is preceded by 'v' (eg. 'v1.0')\n\n"
	exit 1
}

if [ -z $1 ]; then
	usage
fi

KDIR=$PWD
AK2DIR=$KDIR/AnyKernel2

if [[ $1 == 'arm' ]]; then
	IMG=zImage
	export ARCH=arm
	export CROSS_COMPILE=$KDIR/../mytools/toolchains/linaro-4.9.4-arm-eabi/bin/arm-eabi-
elif [[ $1 == 'arm64' ]]; then
	IMG=Image.gz
	export ARCH=arm64
	export CROSS_COMPILE=$KDIR/../mytools/toolchains/linaro-4.9.4-aarch64-linux-gnu/bin/aarch64-linux-gnu-
else
	echo "ERROR: ARCH is either arm or arm64"
	exit 1
fi

if [ -z $3 ]; then
	t=$(nproc --all)
else
	t=$3
fi

KNAME="RebelKernel"
export KBUILD_BUILD_USER="RblLn"
export KBUILD_BUILD_HOST="Lion's_Den"
DATE=$(date +"%m%d%y")
GCCV=$("$CROSS_COMPILE"gcc -v 2>&1 | tail -1 | cut -d ' ' -f 3)
# For GDrive uploading
BETA_DIR=1kck7RBzMCc8k1DgExWLQWGnftADI_yn6
RELEASE_DIR=1N7VCEe7KloVF_MFIn3lwcvYodLNhNhNs
#

export SUBARCH=$ARCH
export DEVICE=$2
export USE_CCACHE=1
export COMPRESS_CACHE=1
EXTRA_CFLAGS=-w

# Consistency checks
if [ -e fail.log ]; then
	rm fail.log
fi
if [ -e out/arch/arm/boot/*Image* ]; then
	rm -f out/arch/arm/boot/*Image*
	rm -rf out/modinstall/
	mkdir out/modinstall/
fi
#

printf "\nARCHITECTURE: $1\nDEVICE: $2\nTHREADS: $t\n"
if [ -z $4 ] && [ -z $5 ]; then
	printf "GCC VERSION: $GCCV\n\n"
else
	printf "TYPE: $4\nVERSION: $5\nGCC VERSION: $GCCV\n\n"
fi
echo "==> Build script by facuarmo and RebelLion420"
sleep 1
echo "==> Making kernel image..."
make O=out "$DEVICE"_defconfig
make O=out -j$t $IMG |& tee fail.log
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	echo "!!! Kernel compilation failed, can't continue !!!"
	gdrive upload --delete fail.log
	exit 1
fi
###echo "=> Making DTBs..."
###make O=out -j$t dtbs |& tee -a fail.log
###if [ ${PIPESTATUS[0]} -ne 0 ]; then
###	echo "DTB compilation failed, cannot continue."
###	gdrive upload --delete fail.log
###	exit 1
###fi
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

# One more check
if [ -e fail.log ]; then
	rm fail.log
fi
if [ -e $AK2DIR/*Image* ]; then
	rm -f $AK2DIR/*Image*
	rm -f $AK2DIR/*.zip
###	rm -f $AK2DIR/*.dtb
	rm -f $AK2DIR/modules/system/lib/modules/*.ko
fi
#

echo "==> Kernel compilation completed"

echo "==> Finding modules"

find out/modinstall/ -name '*.ko' -type f -exec cp '{}' "$AK2DIR/modules/system/lib/modules/" \;

echo "==> Making Flashable zip"

if [ -z $4 ] || [ -z $KNAME ]; then
	FINAL_ZIP="$DEVICE"_kernel-"$DATE".zip
elif [ -z $4 ]; then
	FINAL_ZIP="$KNAME"_"$DATE".zip
else
	FINAL_ZIP="$KNAME"_"$4"-"v$5"_"$DATE".zip
fi

cp  $KDIR/out/arch/$ARCH/boot/$IMG $AK2DIR
###cp  $KDIR/out/arch/$ARCH/boot/dts/qcom/*.dtb $AK2DIR

cd $AK2DIR

zip -r9 $FINAL_ZIP * -x .git README.md *placeholder > /dev/null

if [ -e $FINAL_ZIP ]; then
	echo "==> Flashable zip created"
	echo "==> Uploading Kernel Zip to Google Drive"
	if [[ $4 == 'Beta'* ]]; then
		gdrive upload --delete --parent $BETA_DIR $AK2DIR/$FINAL_ZIP
	elif [[ $4 == 'Release'* ]]; then
		gdrive upload --delete --parent $RELEASE_DIR $AK2DIR/$FINAL_ZIP
	else
		gdrive upload --delete $AK2DIR/$FINAL_ZIP
	fi
	if [ $? -ne 0 ]; then
		echo "!!! Upload failed. Unexpected error. !!!"
	else
		echo "==> Upload complete!"
	fi
	exit 0
else
	echo "!!! Unexpected error. Abort !!!"
	exit 1
fi
 
