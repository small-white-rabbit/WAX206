#!/bin/sh
log_info=$1
ip_addr=$2

[ "x$log_info" = "x" -o "x$ip_addr" = "x" ] && exit 1

log_vpn=$(uci get system.logs.log_vpn)
if [ $log_vpn -eq 1 ];then
	if [ -f /tmp/ntp_sync_ok ];then
		if [ "$log_info" = "connection_successfully" ];then
			/usr/bin/redis-cli -s /tmp/.redis.sock lpush logs "[OpenVPN, connection successfully] from remote IP address: $ip_addr, $(date +"%A, %B %d, %Y %H:%M:%S")"
		elif [ "$log_info" = "connection_drop" ];then
			/usr/bin/redis-cli -s /tmp/.redis.sock lpush logs "[OpenVPN, connection drop] from remote IP address: $ip_addr, $(date +"%A, %B %d, %Y %H:%M:%S")"
		elif [ "$log_info" = "connection_fail" ];then
			/usr/bin/redis-cli -s /tmp/.redis.sock lpush logs "[OpenVPN, connection fail] from remote IP address: $ip_addr, $(date +"%A, %B %d, %Y %H:%M:%S")"
		fi
	else
		if [ "$log_info" = "connection_successfully" ];then
			/usr/bin/redis-cli -s /tmp/.redis.sock lpush logs "[OpenVPN, connection successfully] from remote IP address: $ip_addr, TIME::$(cat /proc/uptime | awk -F'.' '{print $1}')"
		elif [ "$log_info" = "connection_drop" ];then
			/usr/bin/redis-cli -s /tmp/.redis.sock lpush logs "[OpenVPN, connection drop] from remote IP address: $ip_addr, TIME::$(cat /proc/uptime | awk -F'.' '{print $1}')"
		elif [ "$log_info" = "connection_fail" ];then
			/usr/bin/redis-cli -s /tmp/.redis.sock lpush logs "[OpenVPN, connection fail] from remote IP address: $ip_addr, TIME::$(cat /proc/uptime | awk -F'.' '{print $1}')"
		fi
	fi
	/usr/bin/redis-cli -s /tmp/.redis.sock ltrim logs 0 1023
fi

