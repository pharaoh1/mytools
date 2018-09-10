if [ -z $2 ] || [ -z $3 ]
then
 printf "\nUsage: \n\n\tbash build.sh [thread_amount] version_# release_type\n\n\tNOTE: '[thread_amount]' can be an integer or 'auto'.\n\n"
 exit 1
fi

KERNEL_DIR=$PWD
TOOLCHAINDIR=/home/linux/tc/arm-linux-androideabi-4.9
DATE=$(date +"%m%d%y")
KERNEL_NAME="OrgasmKernel"

export ARCH=arm && export SUBARCH=arm
export CROSS_COMPILE=$TOOLCHAINDIR/bin/arm-linux-androideabi-
export USE_CCACHE=1
export COMPRESS_CACHE=1
export DEVICE="perry"
export KBUILD_BUILD_USER="RblLn"
export KBUILD_BUILD_HOST="PleasureBox"
Anykernel_DIR=$KERNEL_DIR/AnyKernel2
VER="-v$2"
TYPE="_$3"
export FINAL_ZIP="$KERNEL_NAME"-"$DEVICE""$TYPE""$VER"_"$DATE".zip

if [ -e  out/arch/arm/boot/zImage ];
then
rm -r out #Just to make sure it doesn't make flashable zip with previous zImage
rm -r $Anykernel_DIR/modules/*
make clean
make mrproper
mkdir out
fi;

if [ "$1" == 'auto' ]
then
 t=$(nproc --all)
else
 t=$1
fi
GCCV=$("$CROSS_COMPILE"gcc -v 2>&1 | tail -1 | cut -d ' ' -f 3)
printf "\nTHREADS: $t\nVERSION: $2\nRELEASE: $3\nGCC VERSION: $GCCV\n\n"
echo "=> Build script courtest of @facuarmo"
echo "=> Making kernel binary..."
make O=out perry_defconfig
make O=out -j$t
if [ $? -ne 0 ]
then
 echo "!!! Kernel compilation failed, can't continue !!!"
 exit 1
fi
mkdir -p "$Anykernel_DIR/modules/system/lib/modules/pronto"
rsync -a --prune-empty-dirs --include '*/' --include '*.ko' --exclude '*' out/ $Anykernel_DIR/modules/
find vendor/ -name '*.ko' -type f -exec cp '{}' "$Anykernel_DIR/modules/system/lib/modules" \;
cp "$Anykernel_DIR/modules/system/lib/modules/wlan.ko" "$Anykernel_DIR/modules/system/lib/modules/pronto/pronto_wlan.ko"

echo "=> Kernel compilation completed"

cp  $KERNEL_DIR/out/arch/arm/boot/zImage $Anykernel_DIR
cp  $KERNEL_DIR/out/arch/arm/boot/dts/qcom/*.dtb $Anykernel_DIR

cd $Anykernel_DIR

echo "=> Making Flashable zip"

echo "==> Generating changelog"

if [ -e $Anykernel_DIR/changelog.txt ];
then
rm $Anykernel_DIR/changelog.txt
fi;

git log --graph --pretty=format:'%s' --abbrev-commit -n 200  > changelog.txt

echo "==> Changelog generated"

if [ -e $Anykernel_DIR/*.zip ];
then
rm *.zip
fi;

zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP > /dev/null

if [ -e $FINAL_ZIP ];
then
	echo "=> Flashable zip Created"
	echo "=> Flashable zip is stored in $Anykernel_DIR folder with name $FINAL_ZIP"
exit 0
else
	echo "!!! Failed to make zip. Abort !!!"
	exit 1
fi;
