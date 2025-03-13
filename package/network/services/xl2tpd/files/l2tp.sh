#!/bin/sh

[ -x /usr/sbin/xl2tpd ] || exit 0

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_l2tp_init_config() {
	proto_config_add_string "username"
	proto_config_add_string "password"
	proto_config_add_string "keepalive"
	proto_config_add_string "pppd_options"
	proto_config_add_boolean "ipv6"
	proto_config_add_int "demand"
	proto_config_add_int "mtu"
	proto_config_add_int "persist"
	proto_config_add_int "maxfail"
	proto_config_add_int "peerdns"
	proto_config_add_int "checkup_interval"
	proto_config_add_int "pppdod"
	proto_config_add_string "server"
	available=1
	no_device=1
	no_proto_task=1
	teardown_on_l3_link_down=1
}

proto_l2tp_setup() {
	net_proto=$(uci get network.wan.proto)

	if [ "$net_proto" = "static" ];then
		wan_ifname=$(uci get network.wan_dev.name)
		server_ip=$(uci get network.vpn.server)
		net_gw=$(uci get network.wan.gateway)
		net_dns=$(uci get network.wan.gateway)
		net_peerdns=$(uci get network.wan.peerdns)
		if [[ ! -z $server_ip ]];then
			host="${server_ip%:*}"
			for ip in $(resolveip -t 5 "$host"); do
				ip route add $ip via $net_gw dev $wan_ifname proto static
				if [ $net_peerdns -eq 0 ];then
					for i in $net_dns; do
						ip route add $i via $net_gw dev $wan_ifname proto static
					done
				fi
			done
		fi
	fi

	json_get_var pppdod pppdod
	#If the wan type is manual method,we should get the runone flag from redis. 0:No open ppp 1:Open ppp
	if [ "${pppdod:-0}" -eq 2 ]; then
		manual_pppoe=`/usr/bin/redis-cli -s /tmp/.redis.sock get manual_pppoe` 2> /dev/null
		if [ "${manual_pppoe:-0}" -lt 1 ];then
			ifdown vpn
			exit 0
		else
			/usr/bin/redis-cli -s /tmp/.redis.sock set manual_pppoe "0" > /dev/null
		fi
	fi

	local interface="$1"
	local optfile="/tmp/l2tp/options.${interface}"
	local ip serv_addr server host peerdns

	json_get_var server server
	peerdns=$(uci get network.wan.peerdns)
	host="${server%:*}"
	for ip in $(resolveip -t 5 "$host"); do
		#( proto_add_host_dependency "$interface" "$ip" )
		serv_addr=1
	done
	[ -n "$serv_addr" ] || {
		echo "Could not resolve server address" >&2
		sleep 5
		proto_setup_failed "$interface"
		exit 1
	}

	# Start and wait for xl2tpd
	if [ ! -p /var/run/xl2tpd/l2tp-control -o -z "$(pidof xl2tpd)" ]; then
		/etc/init.d/xl2tpd restart

		local wait_timeout=0
		while [ ! -p /var/run/xl2tpd/l2tp-control ]; do
			wait_timeout=$(($wait_timeout + 1))
			[ "$wait_timeout" -gt 5 ] && {
				echo "Cannot find xl2tpd control file." >&2
				proto_setup_failed "$interface"
				exit 1
			}
			sleep 1
		done
	fi

	local ipv6 demand keepalive username password pppd_options mtu persist maxfail
	json_get_vars ipv6 demand keepalive username password pppd_options mtu persist maxfail
	[ "$ipv6" = 1 ] || ipv6=""
	noipv6=""
	[ "$ipv6" = 1 ] || noipv6=1

	if [ "${demand:-0}" -gt 0 -a "${pppdod:-0}" -eq 1 ]; then
		demand="precompiled-active-filter /etc/ppp/filter demand idle $demand"
	else
		demand=""
	fi

	if [ -n "$persist" ]; then
		[ "${persist}" -lt 1 ] && persist="nopersist" || persist="persist"
	fi
	if [ -z "$maxfail" ]; then
		[ "$persist" = "persist" ] && maxfail=0 || maxfail=1
	fi

	if [ "$peerdns" -eq 0 ]; then
		usepeerdns=""
	else
		usepeerdns="usepeerdns"
	fi

	local interval="${keepalive##*[, ]}"
	[ "$interval" != "$keepalive" ] || interval=5

	try_failure=${keepalive%%[, ]*}
	keepalive="${keepalive:+lcp-echo-interval $interval lcp-echo-failure ${keepalive%%[, ]*}}"
	username="${username:+user \"$username\" password \"$password\"}"
	ipv6_up="${ipv6:+ipv6-up-script /lib/netifd/ppp6-up}"
	ipv6_down="${ipv6:+ipv6-down-script /lib/netifd/ppp-down}"
	ipv6="${ipv6:++ipv6}"
	mtu="${mtu:+mtu $mtu mru $mtu}"

	mkdir -p /tmp/l2tp
	cat <<EOF >"$optfile"
$usepeerdns
nodefaultroute
ipparam "$interface"
ifname "l2tp-$interface"
ip-up-script /lib/netifd/ppp-up
$ipv6_up
ip-down-script /lib/netifd/ppp-down
$ipv6_down
$demand
$persist
maxfail $maxfail
# Don't wait for LCP term responses; exit immediately when killed.
lcp-max-terminate 0
$keepalive
$username
${noipv6:+noipv6}
$ipv6
$mtu
$pppd_options
EOF

	#xl2tpd-control add-lac l2tp-${interface} pppoptfile=${optfile} lns=${server} redial=yes "max redials"=$try_failure "redial timeout"=$interval || {
	xl2tpd-control add-lac l2tp-${interface} pppoptfile=${optfile} lns=${server} redial=yes "redial timeout"=1 || {
		echo "xl2tpd-control: Add l2tp-$interface failed" >&2
		proto_setup_failed "$interface"
		exit 1
	}
	xl2tpd-control connect-lac l2tp-${interface} || {
		echo "xl2tpd-control: Connect l2tp-$interface failed" >&2
		proto_setup_failed "$interface"
		exit 1
	}
}

proto_l2tp_teardown() {
	local interface="$1"
	local optfile="/tmp/l2tp/options.${interface}"

	rm -f ${optfile}
	if [ -p /var/run/xl2tpd/l2tp-control ]; then
		xl2tpd-control remove-lac l2tp-${interface} || {
			echo "xl2tpd-control: Remove l2tp-$interface failed" >&2
		}
	fi
	# Wait for interface to go down
        while [ -d /sys/class/net/l2tp-${interface} ]; do
		sleep 1
	done
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol l2tp
}
