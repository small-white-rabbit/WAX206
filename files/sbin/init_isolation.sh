#!/bin/sh 

ssidIsolation=2
clientIsolation1=2
clientIsolation2=2
clientIsolation3=2
wlan1allowToWired=2
wlan2allowToWired=2
wlan3allowToWired=2


ssidIsolation=$(uci get wireless.2g_5g.ssidIsolation) 2> /dev/null
ethIfNameList=$(uci get network.lan.ifname) 2> /dev/null

if [ $(uci get wireless.@wifi-iface[0].radio) -eq 1 ];then
    clientIsolation1=$(uci get wireless.@wifi-iface[0].clientIsolation) 2> /dev/null
    wlan1allowToWired=$(uci get wireless.@wifi-iface[0].allowToWired) 2> /dev/null
else
    if [ $(uci get wireless.@wifi-iface[3].radio) -eq 1 ];then
        clientIsolation1=$(uci get wireless.@wifi-iface[3].clientIsolation) 2> /dev/null
        wlan1allowToWired=$(uci get wireless.@wifi-iface[3].allowToWired) 2> /dev/null
    fi
fi

if [ $(uci get wireless.@wifi-iface[1].radio) -eq 1 ];then
    clientIsolation2=$(uci get wireless.@wifi-iface[1].clientIsolation) 2> /dev/null
    wlan2allowToWired=$(uci get wireless.@wifi-iface[1].allowToWired) 2> /dev/null
else
    if [ $(uci get wireless.@wifi-iface[4].radio) -eq 1 ];then
        clientIsolation2=$(uci get wireless.@wifi-iface[4].clientIsolation) 2> /dev/null
        wlan2allowToWired=$(uci get wireless.@wifi-iface[4].allowToWired) 2> /dev/null
    fi
fi

if [ $(uci get wireless.@wifi-iface[2].radio) -eq 1 ];then
    clientIsolation3=$(uci get wireless.@wifi-iface[2].clientIsolation) 2> /dev/null
    wlan3allowToWired=$(uci get wireless.@wifi-iface[2].allowToWired) 2> /dev/null
else
    if [ $(uci get wireless.@wifi-iface[5].radio) -eq 1 ];then
        clientIsolation3=$(uci get wireless.@wifi-iface[5].clientIsolation) 2> /dev/null
        wlan3allowToWired=$(uci get wireless.@wifi-iface[5].allowToWired) 2> /dev/null
    fi
fi

baseifName2G=$(uci get wireless.2g.ifName) 2> /dev/null
baseifName5G=$(uci get wireless.5g.ifName) 2> /dev/null
if [ "x$baseifName2G" = "x" -o "x$baseifName5G" = "x" ];then
    model=$(uci get system.@system[0].model) 2> /dev/null
    if [ "$model" = "WAX202" ];then
        baseifName2G="ra"
        baseifName5G="rax"
    elif [ "$model" = "WAX206" ];then
        baseifName2G="ra"
        baseifName5G="rai"
    else
        return
    fi
fi

ebtables -F ssid_client_isolation
ebtables -F ssid_url_isolation

ebtables -D FORWARD -j ssid_client_isolation
ebtables -D INPUT -j ssid_url_isolation

netmode=$(/sbin/uci get system.@system[0].netmode 2> /dev/null)
netmode="${netmode:-"router"}"
[ "$netmode" = "wds" ] && return

br_lan_ip=$(/sbin/ifconfig br-lan |sed -n '/inet addr/p' |cut -d ":" -f2 |cut -d " " -f1)
br_lan_ipv6_entries=$(/sbin/ifconfig br-lan  | grep 'inet6 addr:' | grep -v '::1/128' | awk '{print $3}' | sed -e "s/\/.*//g" | uniq | sort)
echo "br_lan_ip = ${br_lan_ip}"
echo "br_lan_ipv6_entries = ${br_lan_ipv6_entries}"

ebtables -N ssid_client_isolation
ebtables -N ssid_url_isolation

ebtables -A FORWARD -j ssid_client_isolation
ebtables -A INPUT -j ssid_url_isolation

if [ $wlan2allowToWired -eq 0 -o  $wlan3allowToWired -eq 0 ];then
    ebtables -A ssid_url_isolation -p IPv4 --ip-proto udp --ip-dport 67:68 -j ACCEPT 
    ebtables -A ssid_url_isolation -p IPv4 --ip-proto udp --ip-dport 53 -j ACCEPT
    ebtables -A ssid_url_isolation -p IPv4 --ip-proto udp --ip-dport 5333 -j ACCEPT
    ebtables -A ssid_url_isolation -p IPv6 --ip6-proto ipv6-icmp --ip6-icmp-type ! echo-request -j ACCEPT  
    ebtables -A ssid_url_isolation -p IPv6 --ip6-proto udp --ip6-dport 546:547 -j ACCEPT 
    ebtables -A ssid_url_isolation -p IPv6 --ip6-proto udp --ip6-dport 53 -j ACCEPT
    ebtables -A ssid_url_isolation -p IPv6 --ip6-proto udp --ip6-dport 5333 -j ACCEPT

    ebtables -A ssid_client_isolation -p ARP -j ACCEPT
    ebtables -A ssid_client_isolation -p IPv4 -o eth0 --ip-proto udp --ip-dport 67:68 -j ACCEPT
    ebtables -A ssid_client_isolation -p IPv4 --ip-proto udp --ip-dport 53 -j ACCEPT
    ebtables -A ssid_client_isolation -p IPv4 --ip-proto udp --ip-dport 5333 -j ACCEPT
    ebtables -A ssid_client_isolation -p IPv6 --ip6-proto ipv6-icmp --ip6-icmp-type ! echo-request -j ACCEPT 
    ebtables -A ssid_client_isolation -p IPv6 -o eth0 --ip6-proto udp --ip6-dport 546:547 -j ACCEPT 
    ebtables -A ssid_client_isolation -p IPv6 --ip6-proto udp --ip6-dport 53 -j ACCEPT
    ebtables -A ssid_client_isolation -p IPv6 --ip6-proto udp --ip6-dport 5333 -j ACCEPT 
fi

if [ $wlan2allowToWired -eq 0 ];then
    ebtables -A ssid_url_isolation -p IPv4 -i ${baseifName2G}1 --ip-dst=${br_lan_ip} -j DROP
    ebtables -A ssid_url_isolation -p IPv4 -i ${baseifName5G}1 --ip-dst=${br_lan_ip} -j DROP
    for ipv6_entry in ${br_lan_ipv6_entries}
    do
        ebtables -A ssid_url_isolation -p IPv6 -i ${baseifName2G}1 --ip6-dst=${ipv6_entry} -j DROP
        ebtables -A ssid_url_isolation -p IPv6 -i ${baseifName5G}1 --ip6-dst=${ipv6_entry} -j DROP
    done
fi

if [ $wlan3allowToWired -eq 0 ];then
    ebtables -A ssid_url_isolation -p IPv4 -i ${baseifName2G}2 --ip-dst=${br_lan_ip} -j DROP
    ebtables -A ssid_url_isolation -p IPv4 -i ${baseifName5G}2 --ip-dst=${br_lan_ip} -j DROP
    for ipv6_entry in ${br_lan_ipv6_entries}
    do
        ebtables -A ssid_url_isolation -p IPv6 -i ${baseifName2G}2 --ip6-dst=${ipv6_entry} -j DROP
        ebtables -A ssid_url_isolation -p IPv6 -i ${baseifName5G}2 --ip6-dst=${ipv6_entry} -j DROP
    done
fi

if [ $ssidIsolation -eq 1 ];then
    if [ $clientIsolation1 -eq 0 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}0 -o ${baseifName5G}0 -j ACCEPT
        ebtables -A ssid_client_isolation -i ${baseifName5G}0 -o ${baseifName2G}0 -j ACCEPT
    fi

    if [ $clientIsolation2 -eq 0 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}1 -o ${baseifName5G}1 -j ACCEPT
        ebtables -A ssid_client_isolation -i ${baseifName5G}1 -o ${baseifName2G}1 -j ACCEPT
    fi

    if [ $clientIsolation3 -eq 0 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}2 -o ${baseifName5G}2 -j ACCEPT
        ebtables -A ssid_client_isolation -i ${baseifName5G}2 -o ${baseifName2G}2 -j ACCEPT
    fi
    
    if [ $clientIsolation1 -ne 2 -o $clientIsolation2 -ne 2 -o $clientIsolation3 -ne 2 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}+ -o ${baseifName5G}+ -j DROP
        ebtables -A ssid_client_isolation -i ${baseifName5G}+ -o ${baseifName2G}+ -j DROP
    fi
else
    if [ $clientIsolation1 -eq 1 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}0 -o ${baseifName5G}0 -j DROP
        ebtables -A ssid_client_isolation -i ${baseifName5G}0 -o ${baseifName2G}0 -j DROP
    fi

    if [ $clientIsolation2 -eq 1 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}1 -o ${baseifName5G}1 -j DROP
        ebtables -A ssid_client_isolation -i ${baseifName5G}1 -o ${baseifName2G}1 -j DROP
    fi

    if [ $clientIsolation3 -eq 1 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}2 -o ${baseifName5G}2 -j DROP
        ebtables -A ssid_client_isolation -i ${baseifName5G}2 -o ${baseifName2G}2 -j DROP
    fi
fi

for ethIfName in $ethIfNameList; do
    if [ "$ethIfName" = "eth0.4095" ];then
        continue
    fi

    if [ $wlan1allowToWired -eq 0 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}0 -o $ethIfName -j DROP
        ebtables -A ssid_client_isolation -i ${baseifName5G}0 -o $ethIfName -j DROP
    fi

    if [ $wlan2allowToWired -eq 0 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}1 -o $ethIfName -j DROP
        ebtables -A ssid_client_isolation -i ${baseifName5G}1 -o $ethIfName -j DROP
    fi

    if [ $wlan3allowToWired -eq 0 ];then
        ebtables -A ssid_client_isolation -i ${baseifName2G}2 -o $ethIfName -j DROP
        ebtables -A ssid_client_isolation -i ${baseifName5G}2 -o $ethIfName -j DROP
    fi
done
