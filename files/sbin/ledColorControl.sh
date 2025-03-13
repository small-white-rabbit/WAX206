#!/bin/sh

LED_CONTROL_SCRIPT="/sbin/led.sh"

led_off() {
	$LED_CONTROL_SCRIPT none all > /dev/null 2>&1
	tw_vty -c "eth-led off" 2>/dev/null
}

led0_on() {
	led_off

	local list="power net wifin wifia"
	for ledName in $list; do
		$LED_CONTROL_SCRIPT default-on $ledName green > /dev/null 2>&1
	done
	tw_vty -c "eth-led led0-on" 2>/dev/null
}

led1_on() {
	led_off

	local list="power net wifin wifia"
	for ledName in $list; do
		$LED_CONTROL_SCRIPT default-on $ledName red > /dev/null 2>&1
	done
	tw_vty -c "eth-led led1-on" 2>/dev/null
}
###############################################################################
# MAIN
###############################################################################

case "$1" in
	led_off) led_off ;;
	led0_on) led0_on ;;
	led1_on) led1_on ;;
esac