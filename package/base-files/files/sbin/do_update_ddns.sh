#!/bin/sh

username=$(uci get ddns.common.username 2>/dev/null)
password=$(uci get ddns.common.password 2>/dev/null)
hostname=$(uci get ddns.common.hostname 2>/dev/null)
service=$(uci get ddns.common.service 2>/dev/null)
if [ "$service" = "dyndns" ];then
	server="members.dyndns.org"
	request="/nic/update"
elif [ "$service" = "oray" ];then
	server="ddns.oray.com"
	request="/ph/update"
elif [ "$service" = "noip" ];then
	server="dynupdate.no-ip.com"
	request="/nic/update"
elif [ "$service" = "pubyun" ];then
	server="pubyun.com"
	request="/nic/update"
fi

if [ "$service" = "oray" ];then
	curl --user $username:$password http://$server$request?hostname=$hostname > /tmp/do_update_ddns_result &
else
	curl --user $username:$password https://$server$request?hostname=$hostname > /tmp/do_update_ddns_result &
fi
