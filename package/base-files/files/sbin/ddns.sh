#!/bin/sh

#老版本过渡到新版本初始化配置
ddns_common=$(uci get ddns.common 2>/dev/null)
if [ -z "$ddns_common" ];then
	uci set ddns.common='configure'
	uci set ddns.common.version='0'
	uci set ddns.common.enable='0'
	uci set ddns.common.update='0'
	uci set ddns.common.hostname='domain'
	uci set ddns.common.service='noip'
	uci set ddns.common.address='0.0.0.0'
	uci set ddns.common.username='user'
	uci set ddns.common.password='password'
	uci set ddns.netgear='configure'
	uci set ddns.netgear.hostname='domain'
	uci set ddns.netgear.username='user'
	uci set ddns.netgear.password='password'
	uci set ddns.dyndns='configure'
	uci set ddns.dyndns.hostname='domain'
	uci set ddns.dyndns.username='user'
	uci set ddns.dyndns.password='password'
	uci set ddns.pubyun='configure'
	uci set ddns.pubyun.hostname='domain'
	uci set ddns.pubyun.username='user'
	uci set ddns.pubyun.password='password'
	uci set ddns.oray='configure'
	uci set ddns.oray.hostname='domain'
	uci set ddns.oray.username='user'
	uci set ddns.oray.password='password'
	uci set ddns.noip='configure'
	uci set ddns.noip.hostname='domain'
	uci set ddns.noip.password='password'
	uci set ddns.noip.username='user'
fi

common_enable=$(uci get ddns.common.enable 2>/dev/null)
oray_enable=$(uci get ddns.oray.enable 2>/dev/null)

oray_username=$(uci get ddns.oray.username 2>/dev/null)
oray_password=$(uci get ddns.oray.password 2>/dev/null)
#service=$(uci get dns.common.service 2>/dev/null)
common_username=$(uci get ddns.common.username 2>/dev/null)
common_password=$(uci get ddns.common.password 2>/dev/null)
common_hostname=$(uci get ddns.common.hostname 2>/dev/null)

if [ '1' = $common_enable ] && [ '1' = $oray_enable ];then
	echo "[settings]" > /etc/phlinux.conf
	echo "szHost = PhLinux3.Oray.Net" >> /etc/phlinux.conf
	echo "szUserID = $oray_username" >> /etc/phlinux.conf
	echo "szUserPWD = $oray_password" >> /etc/phlinux.conf
	echo "nicName = eth0" >> /etc/phlinux.conf
	echo "szLog = /var/log/phddns.log" >> /etc/phlinux.conf
	killall phddns
	/usr/sbin/phddns -c /etc/phlinux.conf &
fi

if [ '1' = $common_enable ] && [ $common_username != "user" ] && [ $common_password != "password" ] && [ $common_hostname != "domain" ];then
	uci set ddns.common.update='1'
elif [ '1' = $common_enable ] && [ '1' = $oray_enable ];then
	uci set ddns.common.update='1'
fi

