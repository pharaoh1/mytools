if [ -z $1 ] || [ -z $2 ]
then
 printf "\nUsage: \n\n\tbash zip.sh version release_type\n\n"
 exit 1
fi

KERNEL_DIR=$PWD
DATE=$(date +"%m%d%y")
KERNEL_NAME="OrgasmKernel"
export DEVICE="perry"
export KBUILD_BUILD_USER="RebelLion420"
export KBUILD_BUILD_HOST="PleasureBox"
Anykernel_DIR=$KERNEL_DIR/AnyKernel2
VER="-v$1"
TYPE="_$2"
export FINAL_ZIP="$KERNEL_NAME"-"$DEVICE""$TYPE""$VER"_"$DATE".zip

echo "=> Making Flashable zip"

mkdir -p "$Anykernel_DIR/modules/system/lib/modules/pronto"
rsync -a --prune-empty-dirs --include '*/' --include '*.ko' --exclude '*' out/ $Anykernel_DIR/modules/
find vendor/ -name '*.ko' -type f -exec cp '{}' "$Anykernel_DIR/modules/system/lib/modules" \;
cp "$Anykernel_DIR/modules/system/lib/modules/wlan.ko" "$Anykernel_DIR/modules/system/lib/modules/pronto/pronto_wlan.ko"

cp  $KERNEL_DIR/out/arch/arm/boot/zImage $Anykernel_DIR
cp  $KERNEL_DIR/out/arch/arm/boot/dts/qcom/*.dtb $Anykernel_DIR

cd $Anykernel_DIR

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

