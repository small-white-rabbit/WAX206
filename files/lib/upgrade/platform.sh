#
# Copyright (C) 2016 OpenWrt.org
#
# mediatek arm/arm64 kernel image partition name
PART_NAME=Kernel
KERNEL_PARTA_NAME=ImageA
#KERNEL_PARTA_NAME=Kernel
KERNEL_PARTB_NAME=Kernel_backup
IMAGEA_NAME=/tmp/kernelFs.bin
IMAGEB_NAME=/tmp/Kernel_backup.bin
OLD_IMAGE_NAME=/tmp/old_sysupgrade.bin
BOOT_PART_NAME=Bootloader
BOOT_NAME=/tmp/uboot.bin
BLOCK_SIZE=131072
BOOT_BLOCK=4
BOOT_OFFSET=1
KERNEL_BLOCK_OFFSET=17
BOOT_TAG_OFFSET=4
KERNEL_TAG_OFFSET=0x220004
TAG_SIZE=32
BOOT_TAG=MTD_BOOT_TAG
IMAGEA_TAG=MTD_IMAGEA_TAG
IMAGEB_TAG=MTD_IMAGEB_TAG

platform_do_upgrade() {
	local board="$(cat /tmp/sysinfo/board_name)"
	##$ write image file to Kernel parttition directly ###
	case "$board" in
	*)
		echo "platform_do_upgrade here"
		default_do_upgrade "$ARGV"
		;;
	esac

	return 0
}

platform_check_image() {
	local img_file="$1"
	local board=$(cat /tmp/sysinfo/board_name)

	case "$board" in
	*)
		echo "platform_check_image here."
		;;
	esac

	return 0
}

platform_pre_upgrade() {
	echo "platform_pre_upgrade here."
}
