#!/bin/sh

do_ramips() {
	. /lib/ramips.sh

	ramips_board_detect
	ramips_mount_cfg
	ramips_mount_rae
	ramips_load_systempasswd
}

boot_hook_add preinit_main do_ramips
