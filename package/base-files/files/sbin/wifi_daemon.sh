#!/bin/sh

function register_switch_apmode()
{
#   ext to ap mode
    local apcaFinish="$(uci get system.@system[0].apcaFinish)"
    local apnetWizardState="$(uci get system.@system[0].apnetWizardState)"
    local caFinish="$(uci get system.@system[0].caFinish)"
    local netWizardState="$(uci get system.@system[0].netWizardState)"

    uci set system.@system[0].extcaFinish=$caFinish
    uci set system.@system[0].extnetWizardState=$netWizardState
    if [ "x$apnetWizardState" = "x" ]; then
        uci set system.@system[0].netWizardState='0'
        uci set system.@system[0].caFinish='0'
        uci commit system
    else
        uci set system.@system[0].netWizardState=$apnetWizardState
        uci set system.@system[0].caFinish=$apcaFinish
        uci commit system
    fi
}

function register_switch_extmode()
{
#   ap to ext mode
    local ext_caFinish="$(uci get system.@system[0].extcaFinish)"
    local ext_netWizardState="$(uci get system.@system[0].extnetWizardState)"
    local caFinish="$(uci get system.@system[0].caFinish)"
    local netWizardState="$(uci get system.@system[0].netWizardState)"

    uci set system.@system[0].apcaFinish=$caFinish
    uci set system.@system[0].apnetWizardState=$netWizardState
    if [ "x$ext_netWizardState" = "x" ]; then
        uci set system.@system[0].netWizardState='0'
        uci set system.@system[0].caFinish='0'
        uci commit system
    else
        uci set system.@system[0].netWizardState=$ext_netWizardState
        uci set system.@system[0].caFinish=$ext_caFinish
        uci commit system
    fi
}

function switch_apmode()
{
    echo "switch_apmode"
    uci set wireless.2g_5g.conf_mode=0
    uci commit wireless
    # register_switch_apmode
#    local linkStatus="$(uci get network.lan.linkrootap)"
#    if [ $linkStatus == "0" ] || [ $linkStatus == "9" ];then
#        local brMac=$(ifconfig br-lan | grep "HWaddr" | awk '{print $5}')
#        ebtables -I filter_arp -o eth1 -p arp -s $brMac -j DROP 2>>/dev/null
#    fi
    list="0 1 2"
    local if_wds_2g="$(uci get wireless.apcli_2g.ifName)"
    local if_wds_5g="$(uci get wireless.apcli_2g.ifName)"
    local if_base_2g="$(uci get wireless.2g.ifName)"
    local if_base_5g="$(uci get wireless.5g.ifName)"

    ebtables -F filter_arp
    iwpriv $if_wds_2g set ApCliEnable=0
    ifconfig $if_wds_2g down
    iwpriv $if_wds_5g set ApCliEnable=0
    ifconfig $if_wds_5g down
    local ap2=$(brctl show | grep $if_wds_2g)
    local ap5=$(brctl show | grep $if_wds_5g)
    local ethifName=$(uci get network.lan.ifname)
    if [ -n "$ap2" ]; then
        brctl delif br-lan $if_wds_2g
    fi
    if [ -n "$ap5" ]; then
        brctl delif br-lan $if_wds_5g
    fi
    killall linkapCheck
    conntrack -F
    ethtool -r $ethifName

    for idx in $list
    do
        iwpriv $if_base_2g$idx set DisConnectAllSta=1
    done

    for idx in $list
    do
        iwpriv $if_base_5g$idx set DisConnectAllSta=1
    done

    echo 2 > /proc/br_dns_hijack
    uci set network.lan.linkrootap=9
    uci set network.lan.pingrootap=0
    uci set network.lan.ipaddr='192.168.1.250'
    uci set network.lan.gateway='192.168.1.250'
    uci set network.lan.netmask='255.255.255.0'
    uci set network.lan.dns='0.0.0.0'
    route delete default
    ip route add default via 192.168.1.250 dev br-lan
    /etc/init.d/dnsmasq restart
    ifconfig br-lan:0 down
    ifconfig br-lan 192.168.1.250
    sleep 1
    /etc/init.d/system restart

    for idx in $list
    do
        ebtables  -D OUTPUT -o $if_base_2g$idx -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP 2>/dev/null
    done

    for idx in $list
    do
        ebtables  -D OUTPUT -o $if_base_5g$idx -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP 2>/dev/null
    done

    ebtables  -D OUTPUT -o $ethifName -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP 2>/dev/null
    ebtables  -D INPUT  -i $ethifName -p IPv4 --ip-proto 17 --ip-sport 67 --ip-dport 68 -j DROP 2>/dev/null

    for idx in $list
    do
        ebtables  -A OUTPUT -o $if_base_2g$idx -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP
    done

    for idx in $list
    do
        ebtables  -A OUTPUT -o $if_base_5g$idx -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP
    done

    local dhcppid=$(cat /var/run/udhcpc-br-lan.pid)
    if [ $dhcppid -gt 0 ];then
        kill -SIGUSR2 $dhcppid
        kill -SIGUSR1 $dhcppid
    fi
}

function switch_extmode()
{
    echo "switch_extmode"
    local ethifName=$(uci get network.lan.ifname)
    uci set wireless.2g_5g.conf_mode=2
    uci commit wireless
    # register_switch_extmode
    list="0 1 2"
    local if_wds_2g="$(uci get wireless.apcli_2g.ifName)"
    local if_wds_5g="$(uci get wireless.apcli_2g.ifName)"
    local if_base_2g="$(uci get wireless.2g.ifName)"
    local if_base_5g="$(uci get wireless.5g.ifName)"

    for idx in $list
    do
        ebtables  -D OUTPUT -o $if_base_2g$idx -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP 2>/dev/null
    done

    for idx in $list
    do
        ebtables  -D OUTPUT -o $if_base_5g$idx -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP 2>/dev/null
    done

    ebtables  -D OUTPUT -o $ethifName -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP 2>/dev/null
    ebtables  -D INPUT  -i $ethifName -p IPv4 --ip-proto 17 --ip-sport 67 --ip-dport 68 -j DROP 2>/dev/null

    for idx in $list
    do
        ebtables  -A OUTPUT -o $if_base_2g$idx -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP
    done

    for idx in $list
    do
        ebtables  -A OUTPUT -o $if_base_5g$idx -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP
    done

    ebtables  -A OUTPUT -o $ethifName -p IPv4 --ip-proto 17 --ip-sport 68 --ip-dport 67 -j DROP
    ebtables  -A INPUT  -i $ethifName -p IPv4 --ip-proto 17 --ip-sport 67 --ip-dport 68 -j DROP

    ebtables -F filter_arp
    killall linkapCheck
    echo 2 > /proc/br_dns_hijack
    uci set network.lan.linkrootap=9
    uci set network.lan.pingrootap=0
    uci set network.lan.ipaddr='192.168.1.250'
    uci set network.lan.gateway='192.168.1.250'
    uci set network.lan.netmask='255.255.255.0'
    uci set network.lan.dns='0.0.0.0'
    route delete default
    ip route add default via 192.168.1.250 dev br-lan
    /etc/init.d/dnsmasq restart
    ifconfig br-lan:0 down
    ifconfig br-lan 192.168.1.250
    local linkStatus="$(uci get network.lan.linkrootap)"
    if [ $linkStatus == "0" ] || [ $linkStatus == "9" ];then
        local brMac=$(ifconfig br-lan | grep "HWaddr" | awk '{print $5}')
        ebtables -I filter_arp -o $if_wds_2g -p arp -s $brMac -j DROP 2>>/dev/null
        ebtables -I filter_arp -o $if_wds_5g -p arp -s $brMac -j DROP 2>>/dev/null
    fi
    sleep 2
    /etc/init.d/system restart
    touch /tmp/mtk/wifi/$if_wds_2g.changed
    touch /tmp/mtk/wifi/$if_wds_5g.changed
    wifi reload

    local dhcppid=$(cat /var/run/udhcpc-br-lan.pid)
    if [ $dhcppid -gt 0 ];then
        kill -SIGUSR2 $dhcppid
        kill -SIGUSR1 $dhcppid
    fi
}

function monitor_wifi_switch()
{
    if [ -e /tmp/wifimonitorrunning ];then
        return
    fi
    touch /tmp/wifimonitorrunning
    touch /tmp/wifimonitor
    local cfgMdoe=$(uci get wireless.2g_5g.conf_mode)
    currentMode="extmode"
    if [ "x$cfgMdoe" = "x0" ];then
        currentMode="apmode"
    fi
    while [ -e /tmp/wifimonitor ]
    do
        sleep 1
        if [[ -e /tmp/apmode && "$currentMode" != "apmode" ]];then
            switch_apmode
            currentMode="apmode"
        fi

        if [[ -e /tmp/extmode && "$currentMode" != "extmode" ]];then
            switch_extmode
            currentMode="extmode"
        fi
    done
    rm /tmp/wifimonitorrunning
}


function monitor_wifi_switch_exit()
{
    if [ -e /tmp/wifimonitor ];then
        rm /tmp/wifimonitor
    fi

    while [ -e /tmp/wifimonitorrunning ]
    do
        sleep 1
    done
}


