#!/bin/sh

. ./flash.info

# Modify input/output image name
PRELOADER_NAME=preloader_evb7622_64_forspinand-v4.img
ATF_NAME=atf.bin
UBOOT_NAME=u-boot-mtk.bin
KERNEL_NAME=root_uImage
LANGUAGE_NAME=WAX206-V1.0.0.26-language-part-NA.bin
UPDATEFILE=$1
KERNEL_FILE=$2
BOOT_KERNEL_FILE=$3
BURNFILE=$4
CURRDIR=$(pwd)
MKHDR=${CURRDIR}/../../../staging_dir/host/bin/makePartHeader

# Modify BLOCK_SIZE in case nand block size is not 0x20000=131072 
declare -i BLOCK_SIZE=131072

# Modify below if Partition layput is changed
# Preloader = 0x80000 = 524288
# ATF = 0x40000 = 262144
# Uboot + Config + Factiry = 0x80000 + 0x80000 + 0x40000 = 1310720
# Uboot + Config + Factiry = 0x80000 + 0x80000 + 0x100000 = 2097152
# Kernel = 0x2600000  = 39845888
# Kernel_bakcup + offset = 0x2600000 + 0x0d00000 = 53477376
# offset = 0x0d00000 = 13631488
# language = 0x400000 = 4194304
declare -i PRELOADER_SZ=`ls "$PRELOADER_NAME" -la | awk '{print $5}'`
declare -i UBOOT_SZ=`ls "$UBOOT_NAME" -la | awk '{print $5}'`
declare -i ATF_SZ=`ls "$ATF_NAME" -la | awk '{print $5}'`
declare -i KERNEL_SZ=`ls "$KERNEL_NAME" -la | awk '{print $5}'`
#declare -i PRELOADER_PAD=(524288/"$BLOCK_SIZE")-1-"$PRELOADER_SZ"/"$BLOCK_SIZE"
declare -i PRELOADER_PAD=(524288/"$BLOCK_SIZE")-"$PRELOADER_SZ"/"$BLOCK_SIZE"
declare -i ATF_PAD=(262144/"$BLOCK_SIZE")-"$ATF_SZ"/"$BLOCK_SIZE"
declare -i UBOOT_PAD=(2097152/"$BLOCK_SIZE")-"$UBOOT_SZ"/"$BLOCK_SIZE"
declare -i KERNEL_PAD=(39845888/"$BLOCK_SIZE")-1-"$KERNEL_SZ"/"$BLOCK_SIZE"
declare -i KERNEL_BACKUP_PAD=(53477376/"$BLOCK_SIZE")-1-"$KERNEL_SZ"/"$BLOCK_SIZE"

# Pad each image

# Preloader partition size is 0x80000
# Device-header has 1 block, so preloader image should have 4 - 1 = 3 block
#echo "$PRELOADER_PAD"
#echo "$ATF_PAD"
#echo "$UBOOT_PAD"

./sbch i "$FLASH_NAME" "$PRELOADER_NAME" "$PRELOADER_NAME".pad 0 0 "$PRELOADER_PAD"
#./sbch i "$FLASH_NAME" "$PRELOADER_NAME".pad "$PRELOADER_NAME".img 1 64 0

# ATF's size is 0x40000, image size should be 2 block
./sbch i "$FLASH_NAME" "$ATF_NAME" "$ATF_NAME".pad 0 0 "$ATF_PAD"

# Uboot/Config/RF partition has 0x80000 + 0x80000 + 0x40000 = 0x140000
# so UBOOT Need to pad to 10 blocks
$MKHDR  "$UBOOT_NAME"  MTD_BOOT_TAG "$UBOOT_NAME".hdr
./sbch i "$FLASH_NAME" "$UBOOT_NAME".hdr "$UBOOT_NAME".hdr.pad 0 0 1
./sbch i "$FLASH_NAME" "$UBOOT_NAME" "$UBOOT_NAME".pad 0 0 "$UBOOT_PAD"

# pad imageA
$MKHDR  "$KERNEL_NAME"  "$IMAGE_TAG" "$KERNEL_NAME".hdr
./sbch i "$FLASH_NAME" "$KERNEL_NAME".hdr "$KERNEL_NAME".hdr.pad 0 0 1
./sbch i "$FLASH_NAME" "$KERNEL_NAME" "$KERNEL_NAME".pad 0 0 "$KERNEL_PAD"
# dual image
./sbch i "$FLASH_NAME" "$KERNEL_NAME" "$KERNEL_NAME"_backup.pad 0 0 "$KERNEL_BACKUP_PAD"
# Kernel is the last image, no pad is necessary

#UPDATEFILE=$1
#KERNEL_FILE=$2
#BOOT_KERNEL_FILE=$3
#BURNFILE=$4
# Generate a single image by attach each padded images
cp "$PRELOADER_NAME".pad "$UPDATEFILE"
cat "$ATF_NAME".pad >> "$UPDATEFILE"
cat "$UBOOT_NAME".pad >> "$UPDATEFILE"
cat "$KERNEL_NAME".hdr.pad >> "$UPDATEFILE"
cat "$KERNEL_NAME".pad >> "$UPDATEFILE"
cat "$KERNEL_NAME".hdr.pad >> "$UPDATEFILE"
cat "$KERNEL_NAME"_backup.pad >> "$UPDATEFILE"
cat "$LANGUAGE_NAME" >> "$UPDATEFILE"

if [ -z ${SKIP_ECC} ];then
	. ./gen_ecc.sh  $UPDATEFILE $BURNFILE
fi

# build KERNEL_FILE
cp "$KERNEL_NAME".hdr.pad  "$KERNEL_FILE"
cat "$KERNEL_NAME" >> "$KERNEL_FILE"

# build BOOT_KERNEL_FILE
cp "$UBOOT_NAME".hdr.pad  "$BOOT_KERNEL_FILE"
cat "$UBOOT_NAME".pad >> "$BOOT_KERNEL_FILE"
cat "$KERNEL_FILE" >> "$BOOT_KERNEL_FILE"

rm *.pad *.hdr -rf
#rm "$PRELOADER_NAME".img

