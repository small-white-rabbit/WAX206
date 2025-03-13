#!/bin/sh

CLIENT_CONF="/tmp/openvpn/client.ovpn"

echo "Generate and pack files for openvpn client"

# get the conf from uci
OPENVPN_PROTO=`uci -q get openvpn.sample_server.taproto`
OPENVPN_PORT=`uci -q get openvpn.sample_server.taport`
OPENVPN_CIPHER=`uci -q get openvpn.sample_server.cipher`
DDNS_ENABLE=`uci -q get ddns.common.enable`
REMOTE_HOST=""
if [ $DDNS_ENABLE == "1" ]; then
	REMOTE_HOST=`uci -q get ddns.common.hostname`
else
	NETTYPE=`uci -q get network.wan.nettype`
	if [ $NETTYPE == 1 ]; then
		REMOTE_HOST=`ubus call network.interface.wan status | jsonfilter -e '@["ipv4-address"][0].address'`
	else
		PPPTYPE=`uci -q get network.wan.netppptype`
		if [ $PPPTYPE == 1 ] || [ $PPPTYPE == 4 ] ; then #pptp l2tp
			REMOTE_HOST=`ubus call network.interface.vpn status | jsonfilter -e '@["ipv4-address"][0].address'`
		else
			REMOTE_HOST=`ubus call network.interface.wan status | jsonfilter -e '@["ipv4-address"][0].address'`
		fi
	fi
fi

rm -rf /tmp/openvpn/client
mkdir -p /tmp/openvpn/client
cp -f /tmp/openvpn/ca.crt  		/tmp/openvpn/client/ 1>/dev/null 2>&1
cp -f /tmp/openvpn/client.crt  	/tmp/openvpn/client/ 1>/dev/null 2>&1
cp -f /tmp/openvpn/client.key  	/tmp/openvpn/client/ 1>/dev/null 2>&1
if [ $2 == "windows" ]; then
	CLIENT_CONF="/tmp/openvpn/client.ovpn"
	rm -f $CLIENT_CONF
	echo "client" > $CLIENT_CONF
	echo "dev-node NETGEAR-VPN" >> $CLIENT_CONF
	echo "resolv-retry infinite" >> $CLIENT_CONF
	echo "nobind" >> $CLIENT_CONF
	echo "persist-key" >> $CLIENT_CONF
	echo "persist-tun" >> $CLIENT_CONF
	echo "ca ca.crt" >> $CLIENT_CONF
	echo "cert client.crt" >> $CLIENT_CONF
	echo "key client.key" >> $CLIENT_CONF
	echo "comp-lzo" >> $CLIENT_CONF
	echo "verb 5" >> $CLIENT_CONF
	echo "dev tap" >> $CLIENT_CONF
	echo "proto $OPENVPN_PROTO" >> $CLIENT_CONF
	echo "cipher $OPENVPN_CIPHER" >> $CLIENT_CONF
	echo "remote $REMOTE_HOST $OPENVPN_PORT" >> $CLIENT_CONF
	
	cp -f $CLIENT_CONF	/tmp/openvpn/client/ 1>/dev/null 2>&1
	zip -jr $1 /tmp/openvpn/client 1>/dev/null 2>&1
elif [ $2 == "nonwindows" ]; then
	CLIENT_CONF="/tmp/openvpn/client.conf"
	CLIENT_DHCP_CONF="/tmp/openvpn/dhcp-client-request.sh"
	rm -f $CLIENT_CONF
	echo "client" > $CLIENT_CONF
	echo "dev-node NETGEAR-VPN" >> $CLIENT_CONF
	echo "resolv-retry infinite" >> $CLIENT_CONF
	echo "nobind" >> $CLIENT_CONF
	echo "persist-key" >> $CLIENT_CONF
	echo "persist-tun" >> $CLIENT_CONF
	echo "ca ca.crt" >> $CLIENT_CONF
	echo "cert client.crt" >> $CLIENT_CONF
	echo "key client.key" >> $CLIENT_CONF
	echo "comp-lzo" >> $CLIENT_CONF
	echo "verb 5" >> $CLIENT_CONF
	echo "script-security 2" >> $CLIENT_CONF
	echo "up dhcp-client-request.sh" >> $CLIENT_CONF
	echo "dev tap" >> $CLIENT_CONF
	echo "proto $OPENVPN_PROTO" >> $CLIENT_CONF
	echo "cipher $OPENVPN_CIPHER" >> $CLIENT_CONF
	echo "remote $REMOTE_HOST $OPENVPN_PORT" >> $CLIENT_CONF
	
	echo "#!/bin/bash" > $CLIENT_DHCP_CONF
	echo "/usr/sbin/ipconfig set tap0 dhcp" >> $CLIENT_DHCP_CONF

	cp -f $CLIENT_CONF	/tmp/openvpn/client/ 1>/dev/null 2>&1
	cp -f $CLIENT_DHCP_CONF	/tmp/openvpn/client/ 1>/dev/null 2>&1
	zip -jr $1 /tmp/openvpn/client 1>/dev/null 2>&1
else
	CLIENT_CONF="/tmp/openvpn/smart_phone.ovpn"
	OPENVPN_TUN_PROTO=`uci -q get openvpn.sample_server.tunproto`
	OPENVPN_TUN_PORT=`uci -q get openvpn.sample_server.tunport`
	rm -f $CLIENT_CONF
	echo "client" > $CLIENT_CONF
	echo "dev-node NETGEAR-VPN" >> $CLIENT_CONF
	echo "resolv-retry infinite" >> $CLIENT_CONF
	echo "nobind" >> $CLIENT_CONF
	echo "persist-key" >> $CLIENT_CONF
	echo "persist-tun" >> $CLIENT_CONF
	echo "ca ca.crt" >> $CLIENT_CONF
	echo "cert client.crt" >> $CLIENT_CONF
	echo "key client.key" >> $CLIENT_CONF
	echo "comp-lzo" >> $CLIENT_CONF
	echo "verb 5" >> $CLIENT_CONF	
	echo "dev tun" >> $CLIENT_CONF
	echo "proto $OPENVPN_TUN_PROTO" >> $CLIENT_CONF
	echo "cipher $OPENVPN_CIPHER" >> $CLIENT_CONF
	echo "remote $REMOTE_HOST $OPENVPN_TUN_PORT" >> $CLIENT_CONF
	echo "<ca>" >> $CLIENT_CONF
	cat /tmp/openvpn/ca.crt >> $CLIENT_CONF
	echo "</ca>" >> $CLIENT_CONF
	echo "<cert>" >> $CLIENT_CONF
	cat /tmp/openvpn/client.crt >> $CLIENT_CONF
	echo "</cert>" >> $CLIENT_CONF	
	echo "<key>" >> $CLIENT_CONF
	cat /tmp/openvpn/client.key >> $CLIENT_CONF
	echo "</key>" >> $CLIENT_CONF

	zip -jr $1 $CLIENT_CONF 1>/dev/null 2>&1

fi