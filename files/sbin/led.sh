#!/bin/sh
# (C) 2008 openwrt.org

. /lib/functions.sh
do_led() {
	local name
	local sysfs
	local board
	local control
	config_get name $1 name
	config_get board $1 board
	config_get control $1 control
	[ "$name" = "$NAME" -o "$sysfs" = "$NAME" -a -e "/sys/class/leds/${board}:${COLOUR}:${name}" ] && {
		case "$COLOUR" in
			"green"|"red"){
				echo none > /sys/class/leds/${board}:${COLOUR}:${name}/trigger
				echo ${trigger} > /sys/class/leds/${board}:${COLOUR}:${name}/trigger
				[ "${trigger}" = "timer" ] &&{
					[ -n "$DELAY_ON" ] && echo $DELAY_ON >/sys/class/leds/${board}:${COLOUR}:${name}/delay_on
					[ -n "$DELAY_OFF" ] && echo $DELAY_OFF >/sys/class/leds/${board}:${COLOUR}:${name}/delay_off
				}
			}
			;;
			"mixed"){
				echo none > /sys/class/leds/${board}:green:${name}/trigger;echo none > /sys/class/leds/${board}:red:${name}/trigger
				echo ${trigger} > /sys/class/leds/${board}:green:${name}/trigger;echo ${trigger} > /sys/class/leds/${board}:red:${name}/trigger
				[ "${trigger}" = "timer" ] &&{
					[ -n "$DELAY_ON" ] && {
						echo $DELAY_ON >/sys/class/leds/${board}:green:${name}/delay_on;\
							echo $DELAY_ON >/sys/class/leds/${board}:red:${name}/delay_on
					}
					[ -n "$DELAY_OFF" ] && {
						echo $DELAY_OFF >/sys/class/leds/${board}:green:${name}/delay_off;\
							echo $DELAY_OFF >/sys/class/leds/${board}:red:${name}/delay_off
					}
				}
			}
			;;
		esac
	}
}

[ -n "$1" ] && [ "all" = "$2" ] &&{
		trigger=$1
		NAME=$2
		COLOUR=mixed
		DELAY_ON=$3
		DELAY_OFF=$4
		config_load system
		for NAME in power net wifin wifia
		do
			config_foreach do_led led
		done
		exit 1
	}
[ -n "$1" ] && [ -n "$2" ] &&
	[ -n "$3" ] &&{
		trigger=$1
		NAME=$2
		COLOUR=$3
		DELAY_ON=$4
		DELAY_OFF=$5
		config_load system
		config_foreach do_led led
		exit 1
	}
	echo "usage: led.sh  <default-on|none|timer|heartbeat>  <power|net|wifin|wifia>  <green|red|mixed> [delay_on] [delay_off]"
	echo "       led.sh  <default-on|none|timer|heartbeat>  <all>  [delay_on] [delay_off]"
