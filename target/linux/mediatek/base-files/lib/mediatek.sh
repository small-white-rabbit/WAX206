#!/bin/sh
#
# Copyright (C) 2016 OpenWrt.org
#

mediatek_board_detect() {
	local machine
	local name

	machine=$(cat /proc/device-tree/model)

	case "$machine" in
	"MediaTek MT7623 evaluation board")
		name="mt7623"
		;;
	"MediaTek MT7623a eMMC evaluation board")
		name="mt7623"
		;;
	"MediaTek MT7623a NAND evaluation board")
		name="mt7623"
		;;
	"MediaTek MT7623n eMMC+Ephy board")
		name="mt7623-gphy"
		;;
	"MediaTek MT7622 AC2600rfb1 board")
		name="mt7622"
		;;
	"MediaTek MT7622 AC4300rfb1 board")
		name="mt7622"
		;;
	"Mediatek MT7622 AC4300-gmac1 board")
		name="mt7622-gmac1_only"
		;;
	"MediaTek MT7622 AX3600 board")
		name="mt7622-ax"
		;;
	"MediaTek MT7622 AX3600-gmac1 board")
		name="mt7622-ax-gmac1_only"
		;;
	"MediaTek MT7629 RFB1 board")
		name="mt7629"
		;;
	"MediaTek MT7622 AX3600-gmac1-WAX206 board")
		name="mt7622-gmac1_wax206"
		;;
	esac

	[ -z "$name" ] && name="unknown"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$name" > /tmp/sysinfo/board_name
	echo "$machine" > /tmp/sysinfo/model
}

mediatek_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -z "$name" ] && name="unknown"

	echo "$name"
}

mediatek_sync_uboot_env() {
	local fenv_region=$(fw_printenv fenv_region 2> /dev/null | awk -F = '{print $2;}')
	local region=$(envctl factory get region 2> /dev/null)

	if [ -n "$fenv_region" ] && [ "$fenv_region" != "$region" ]; then
		echo "Sync uboot env fenv_region o factory env"
		envctl factory set region $fenv_region
	fi

	local fenv_restore=$(fw_printenv fenv_restore 2> /dev/null | awk -F = '{print $2;}')
	local upper_dir="/var/mnt/cfg"
	if [ "$fenv_restore" == "yes" ]; then
		echo "uboot env fenv_restore is yes"
		mkdir -p $upper_dir
		touch $upper_dir/.restore
		fw_setenv fenv_restore no
	fi
}

mediatek_mount_cfg() {
	local upper_dir="/var/root_etc"
	local work_dir="/var/root_etc.work"

	mkdir -p $upper_dir
	mkdir -p $work_dir
	mount -n -t overlay overlay \
		-o rw,noatime,lowerdir=/etc,upperdir=$upper_dir,workdir=$work_dir /etc

	local mtd_id=`cat /proc/mtd | grep "CFG" | awk -F : '{print $1;}' | sed s/mtd//`

	if [ $? != 0 ] || [ ! $mtd_id ]; then
		echo "Get CFG partition failed"
		return 1
	fi

	local mount_dir="/var/mnt"
	mkdir -p $mount_dir
	mount -t jffs2 /dev/mtdblock$mtd_id $mount_dir
	if [ $? != 0 ]; then
		echo "flash_erase CFG partition"
		mtd erase /dev/mtd$mtd_id
		mount -t jffs2 /dev/mtdblock$mtd_id $mount_dir
		if [ $? != 0 ]; then
			echo "mount CFG partition failed"
			return 1
		fi
	fi

	mediatek_sync_uboot_env
	local model=$(envctl factory get model 2> /dev/null)
	local factory_mode=$(envctl factory get factory_mode 2> /dev/null)

	local cfg_dir=""
	if [ "$factory_mode" != "off" ]; then
		cfg_dir="/cfg/factory:"
	else
		if [ -n "$model" ] && [ -d "/cfg/$model" ]; then
			cfg_dir="/cfg/$model:"
		fi
	fi

	local lower_dir="$cfg_dir/cfg/common:/etc/config"
	upper_dir="$mount_dir/cfg"
	work_dir="$mount_dir/cfg.work"
	if [ "$factory_mode" != "off" ] || [ -e $upper_dir/.restore ]; then
		echo "Restore to default config"
		if [ -e $upper_dir/.restore ]; then
			cp $upper_dir/.restore /tmp/.restore
		fi

		rm -fr $upper_dir
#       in /lib/preinit/05_set_iface_mac_mediatek  check /tmp/.restore
		touch /tmp/.restore
	fi

	mkdir -p $upper_dir
	mkdir -p $work_dir
	mount -n -t overlay overlay \
		-o rw,noatime,lowerdir=$lower_dir,upperdir=$upper_dir,workdir=$work_dir /etc/config

	local upper_dir="$mount_dir/rc.d"
	local work_dir="$mount_dir/rc.d.work"

	mkdir -p $upper_dir
	mkdir -p $work_dir
	mount -n -t overlay overlay \
		-o rw,noatime,lowerdir=/etc/rc.d,upperdir=$upper_dir,workdir=$work_dir /etc/rc.d
}

mediatek_mount_rae() {
	local mtd_id=`cat /proc/mtd | grep "RAE" | awk -F : '{print $1;}' | sed s/mtd//`

	if [ $? != 0 ] || [ ! $mtd_id ]; then
		echo "Get RAE partition failed"
		return 1
	fi

	local mount_dir="/rae"
	mount -t jffs2 /dev/mtdblock$mtd_id $mount_dir
	if [ $? != 0 ]; then
		echo "flash_erase RAE partition"
		mtd erase /dev/mtd$mtd_id
		mount -t jffs2 /dev/mtdblock$mtd_id $mount_dir
		if [ $? != 0 ]; then
			echo "mount RAE partition failed"
			return 1
		fi
	fi
}

mediatek_load_systempasswd() {
	if [ ! -f /etc/config/config/shadow ]; then
		if [ ! -d /etc/config/config ]; then
			mkdir -p /etc/config/config
		fi
		cp /etc/shadow_default /etc/config/config/shadow
	fi
}