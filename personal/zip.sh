if [ -z $1 ] || [ -z $2 ]
then
	printf "\nUsage: \n\n\tbash zip.sh version release_type\n\n"
	exit 1
fi

KERNEL_DIR=$PWD
AK2DIR=$KERNEL_DIR/AnyKernel2
DATE=$(date +"%m%d%y")
KERNEL_NAME="OrgasmKernel"
export DEVICE="perry"
export KBUILD_BUILD_USER="RblLn"
export KBUILD_BUILD_HOST="PleasureBox"
VER="-v$1"
TYPE="_$2"
export FINAL_ZIP="$KERNEL_NAME"-"$DEVICE""$TYPE""$VER"_"$DATE".zip

echo "==> Making Flashable zip"

echo "=> Finding modules"

rsync -a --prune-empty-dirs --include '*/' --include '*.ko' --exclude '*' out/ $AK2DIR/modules/
mkdir -p "$AK2DIR/modules/system/lib/modules/pronto"
cp "$AK2DIR/modules/system/lib/modules/wlan.ko" "$AK2DIR/modules/system/lib/modules/pronto/pronto_wlan.ko"

cp  $KERNEL_DIR/out/arch/arm/boot/zImage $AK2DIR
cp  $KERNEL_DIR/out/arch/arm/boot/dts/qcom/*.dtb $AK2DIR

cd $AK2DIR

if [ -e $AK2DIR/*.zip ];
then
	rm *.zip
fi;

zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP > /dev/null

if [ -e $FINAL_ZIP ];
then
	echo "==> Flashable zip Created"
	echo "==> Flashable zip is stored in $AK2DIR folder with name $FINAL_ZIP"
	exit 0
else
	echo "!!! Failed to make zip. Abort !!!"
	exit 1
fi;

