--This file is created for check some deamons like miniupnpd,8021xd...

    local mtkwifi = require("mtkwifi")
    local nixio = require("nixio")

function miniupnpd_chk(devname,vif,enable)
    local WAN_IF=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get network.wan.ifname"))
    os.execute("rm -rf /etc/miniupnpd.conf")

    if mtkwifi.exists("/tmp/run/miniupnpd."..vif) then
        os.execute("cat /tmp/run/miniupnpd."..vif.." | xargs kill -9")
    end

    if enable then
        local profile = mtkwifi.search_dev_and_profile()[devname]
        local cfgs = mtkwifi.load_profile(profile)
        local devs = mtkwifi.get_all_devs()
        local ssid_index = devs[devname]["vifs"][vif].vifidx
        local wsc_conf_mode = ""
        local PORT_NUM = 7777+(string.byte(vif, -1)+string.byte(vif, -2))
        local LAN_IPADDR = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get network.lan.ipaddr"))
        local LAN_MASK = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get network.lan.netmask"))
        local port = 6352 + (string.byte(vif, -1)+string.byte(vif, -2))
        LAN_IPADDR = LAN_IPADDR.."/"..LAN_MASK
        wsc_conf_mode = mtkwifi.token_get(cfgs["WscConfMode"], ssid_index, "")

        local file = io.open("/etc/miniupnpd.conf", "w")
        if nil == file then
            nixio.syslog("debug","open file /etc/miniupnpd.conf fail")
        end

        file:write("ext_ifname=",WAN_IF,'\n','\n',
                   "listening_ip=",LAN_IPADDR,'\n','\n',
                   "port=",port,'\n','\n',
                   "bitrate_up=800000000",'\n',
                   "bitrate_down=800000000",'\n','\n',
                   "secure_mode=no",'\n','\n',
                   "system_uptime=yes",'\n','\n',
                   "notify_interval=30",'\n','\n',
                   "uuid=68555350-3352-3883-2883-335030522880",'\n','\n',
                   "serial=12345678",'\n','\n',
                   "model_number=1",'\n','\n',
                   "enable_upnp=no",'\n','\n')
        file:close()

        if wsc_conf_mode ~= "" and wsc_conf_mode ~= "0" then
            os.execute("miniupnpd -m 1 -I "..vif.." -P /var/run/miniupnpd."..vif.." -G -i "..WAN_IF.." -a "..LAN_IPADDR.." -n "..PORT_NUM)
        end
    end
end

function d8021xd_chk(devname, prefix, vif, enable)
    --if mtkwifi.exists("/tmp/run/8021xd_"..vif..".pid") then
        --os.execute("cat /tmp/run/8021xd_"..vif..".pid | xargs kill -9")
        --os.execute("rm /tmp/run/8021xd_"..vif..".pid")
    --end

    if enable then
        local profile = mtkwifi.search_dev_and_profile()[devname]
        local cfgs = mtkwifi.load_profile(profile)
        local auth_mode = cfgs.AuthMode:split(";")
        local ieee8021x = cfgs.IEEE8021X
        local pat_auth_mode = {"WPA$", "WPA;", "WPA2$", "WPA2;", "WPA1WPA2$", "WPA1WPA2;", "WPA3$", "WPA3;", "192$", "192;", "WPA2-Ent-OSEN$", "WPA2-Ent-OSEN;"}
        local pat_ieee8021x = {"1$", "1;"}
        local apd_en = {}
        local BssidNum = tonumber(cfgs.BssidNum)
        local vifidx = cfgs.radio:split(";")
        local str = ""
        local tmpStr = ""

        os.execute("echo [d8021xd_chk] enable is true >> /tmp/wifiLuaDebug.log")
        for i = 1, BssidNum do
            for _, pat in ipairs(pat_auth_mode) do
                if string.find(auth_mode[i], pat) then
                    apd_en[i] = true
                    --print(i, apd_en[i])
                end
            end
        end

        for i = 1, BssidNum do
            for _, pat in ipairs(pat_ieee8021x) do
                if string.find(ieee8021x, pat) then
                    apd_en[i] = true
                end
            end
        end

        --mt9815dbdc mode:8021xd -p ra -i ra0, 8021xd -p rax -i rax0
        if devname == "MT7915D.1.1" or devname == "MT7915D.1.2" then

            if prefix ~= nil then
                tmpStr = prefix.."0"

                if mtkwifi.exists("/tmp/run/8021xd_"..tmpStr..".pid") then
                    os.execute("cat /tmp/run/8021xd_"..tmpStr..".pid | xargs kill -9")
                    os.execute("rm /tmp/run/8021xd_"..tmpStr..".pid")
                end

                for i = 1, BssidNum do
                    if apd_en[i] == true and vifidx[i] == "1" then
                        os.execute("8021xd -p "..prefix.. " -i "..tmpStr.."")
                        break
                    end
                end
            end
        else
            if prefix ~= nil then
                --mt7622:8021xd -p ra -i ra0 ra1 ra2
                if prefix == "ra" then
                        for i = 1, BssidNum do  
                            if apd_en[i] == true then
                                tmpStr = prefix..tostring(tonumber(i) - 1)
                                if mtkwifi.exists("/tmp/run/8021xd_"..tmpStr..".pid") then
                                    os.execute("cat /tmp/run/8021xd_"..tmpStr..".pid | xargs kill -9")
                                    os.execute("rm /tmp/run/8021xd_"..tmpStr..".pid")
                                end
                            end
                        end

                        if apd_en[1] == true  and vifidx[1] == "1" then
                            os.execute("8021xd -p "..prefix.. " -i  ra0")
                        else
                            if apd_en[2] == true  and vifidx[2] == "1"  then
                                os.execute("8021xd -p "..prefix.. " -i  ra1")
                            end

                            if apd_en[3] == true  and vifidx[3] == "1"  then
                                os.execute("8021xd -p "..prefix.. " -i  ra2")
                            end
                        end
                else
                    --mt7915:8021xd -p rai -i rai0, 8021xd -p rai -i rai1, 8021xd -p rai -i rai2
                    for i = 1, BssidNum do  
                        str = prefix..tostring(tonumber(i) - 1)
                        if apd_en[i] == true then 
                            if mtkwifi.exists("/tmp/run/8021xd_"..str..".pid") then
                                os.execute("cat /tmp/run/8021xd_"..str..".pid | xargs kill -9")
                                os.execute("rm /tmp/run/8021xd_"..str..".pid")
                            end
                        end
                        --print(i, apd_en[i])
                        --print(i, vifidx[i])
                        if apd_en[i] == true  and vifidx[i] == "1" then
                            os.execute("8021xd -p "..prefix.. " -i  "..str.."")
                        end
                    end
                end
            end
        end
    end
end


function doBrctlAddIf(onlyDoBrctlAddIf)
    local fastlaneApMode=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g_5g.fastlaneApMode"))
    local fastlaneApBand=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g_5g.fastlaneApBand"))
    local ap2gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[0].ifName")) 
    local ap5gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[3].ifName"))
    local apcli2gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_2g.ifName")) 
    local apcli5gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_5g.ifName"))
    local ap2gRadio=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[0].radio"))
    local ap5gRadio=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[3].radio"))
    local guset2gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[1].ifName")) 
    local guset5gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[4].ifName"))
    local guset2gRadio=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[1].radio"))
    local guset5gRadio=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[4].radio"))
    local guset2gName1=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[2].ifName")) 
    local guset5gName1=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[5].ifName"))
    local guset2gRadio1=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[2].radio"))
    local guset5gRadio1=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[5].radio"))
    local isRootApExist_2g=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_2g.apcli_existOption"))
    local isRootApExist_5g=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_5g.apcli_existOption"))
    local isRfRadioOn_2g=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g.rfRadioOn"))
    local isRfRadioOn_5g=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.5g.rfRadioOn"))

    if isRfRadioOn_2g == '0' and onlyDoBrctlAddIf == 0 then
        ap2gRadio = '0'
        guset2gRadio = '0'
        guset2gRadio1 = '0'
        os.execute("iwpriv %s set RadioOn=0", ap2gName)
        os.execute("iwpriv %s set RadioOn=0", guset2gName)
        os.execute("iwpriv %s set RadioOn=0", guset2gName1)
    end

    if isRfRadioOn_5g == '0' and onlyDoBrctlAddIf == 0 then
        ap5gRadio = '0'
        guset5gRadio = '0'
        guset5gRadio1 = '0'
        os.execute("iwpriv %s set RadioOn=0", ap5gName)
        os.execute("iwpriv %s set RadioOn=0", guset5gName)
        os.execute("iwpriv %s set RadioOn=0", guset5gName1)
    end

    if fastlaneApMode == '1' then
        if fastlaneApBand == '2.4G' then
            os.execute("brctl delif br-lan "..ap2gName.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..ap2gName.." down 1>/dev/null 2>&1")
            os.execute("brctl delif br-lan "..guset2gName.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..guset2gName.." down 1>/dev/null 2>&1")
            if ap5gRadio == '1' then
                os.execute("ifconfig "..ap5gName.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..ap5gName.." 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..ap5gName.." down 1>/dev/null 2>&1")
                os.execute("brctl delif br-lan "..ap5gName.." 1>/dev/null 2>&1")
            end
            if guset5gRadio == '1' then
                os.execute("ifconfig "..guset5gName.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..guset5gName.." 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..guset5gName.." down 1>/dev/null 2>&1")
                os.execute("brctl delif br-lan "..guset5gName.." 1>/dev/null 2>&1")
            end
            if guset5gRadio1 == '1' then
                os.execute("ifconfig "..guset5gName1.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..guset5gName1.." 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..guset5gName1.." down 1>/dev/null 2>&1")
                os.execute("brctl delif br-lan "..guset5gName1.." 1>/dev/null 2>&1")
            end

            if isRootApExist_2g == '1' then
                os.execute("brctl addif br-lan "..apcli2gName.." 1>/dev/null 2>&1")
            end
            os.execute("ifconfig "..apcli5gName.." down 1>/dev/null 2>&1")
            os.execute("brctl delif br-lan "..apcli5gName.." 1>/dev/null 2>&1")

        elseif fastlaneApBand == '5G' then
            os.execute("brctl delif br-lan "..ap5gName.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..ap5gName.." down 1>/dev/null 2>&1")
            os.execute("brctl delif br-lan "..guset5gName.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..guset5gName.." down 1>/dev/null 2>&1")
            os.execute("brctl delif br-lan "..guset5gName1.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..guset5gName1.." down 1>/dev/null 2>&1")
            if ap2gRadio == '1' then
                os.execute("ifconfig "..ap2gName.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..ap2gName.." 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..ap2gName.." down 1>/dev/null 2>&1")
                os.execute("brctl delif br-lan "..ap2gName.." 1>/dev/null 2>&1")
            end
            if guset2gRadio == '1' then
                os.execute("ifconfig "..guset2gName.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..guset2gName.." 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..guset2gName.." down 1>/dev/null 2>&1")
                os.execute("brctl delif br-lan "..guset2gName.." 1>/dev/null 2>&1")
            end

            if guset2gRadio1 == '1' then
                os.execute("ifconfig "..guset2gName1.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..guset2gName1.." 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..guset2gName1.." down 1>/dev/null 2>&1")
                os.execute("brctl delif br-lan "..guset2gName1.." 1>/dev/null 2>&1")
            end

            if isRootApExist_5g == '1' then
                os.execute("brctl addif br-lan "..apcli5gName.." 1>/dev/null 2>&1")
            end
            os.execute("ifconfig "..apcli2gName.." down 1>/dev/null 2>&1")
            os.execute("brctl delif br-lan "..apcli2gName.." 1>/dev/null 2>&1")

        else
            if ap2gRadio == '0' then
                os.execute("brctl delif br-lan "..ap2gName.." 1>/dev/null 2>&1")
                os.execute("ifconfig "..ap2gName.." down 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..ap2gName.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..ap2gName.." 1>/dev/null 2>&1")
            end

            if guset2gRadio == '0' then
                os.execute("brctl delif br-lan "..guset2gName.." 1>/dev/null 2>&1")
                os.execute("ifconfig "..guset2gName.." down 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..guset2gName.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..guset2gName.." 1>/dev/null 2>&1")
            end

            if guset2gRadio1 == '0' then
                os.execute("brctl delif br-lan "..guset2gName1.." 1>/dev/null 2>&1")
                os.execute("ifconfig "..guset2gName1.." down 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..guset2gName1.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..guset2gName1.." 1>/dev/null 2>&1")
            end

            if ap5gRadio == '0' then
                os.execute("brctl delif br-lan "..ap5gName.." 1>/dev/null 2>&1")
                os.execute("ifconfig "..ap5gName.." down 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..ap5gName.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..ap5gName.." 1>/dev/null 2>&1")
            end

            if guset5gRadio == '0' then
                os.execute("brctl delif br-lan "..guset5gName.." 1>/dev/null 2>&1")
                os.execute("ifconfig "..guset5gName.." down 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..guset5gName.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..guset5gName.." 1>/dev/null 2>&1")
            end
            if guset5gRadio1 == '0' then
                os.execute("brctl delif br-lan "..guset5gName1.." 1>/dev/null 2>&1")
                os.execute("ifconfig "..guset5gName1.." down 1>/dev/null 2>&1")
            else
                os.execute("ifconfig "..guset5gName1.." up 1>/dev/null 2>&1")
                os.execute("brctl addif br-lan "..guset5gName1.." 1>/dev/null 2>&1")
            end
        end
    else
        if ap2gRadio == '0' then
            os.execute("brctl delif br-lan "..ap2gName.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..ap2gName.." down 1>/dev/null 2>&1")
        else
            os.execute("ifconfig "..ap2gName.." up 1>/dev/null 2>&1")
            os.execute("brctl addif br-lan "..ap2gName.." 1>/dev/null 2>&1")
        end

        if ap5gRadio == '0' then
            os.execute("brctl delif br-lan "..ap5gName.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..ap5gName.." down 1>/dev/null 2>&1")
        else
            os.execute("ifconfig "..ap5gName.." up 1>/dev/null 2>&1")
            os.execute("brctl addif br-lan "..ap5gName.." 1>/dev/null 2>&1")
        end

        if guset2gRadio == '0' then
            os.execute("brctl delif br-lan "..guset2gName.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..guset2gName.." down 1>/dev/null 2>&1")
        else
            os.execute("ifconfig "..guset2gName.." up 1>/dev/null 2>&1")
            os.execute("brctl addif br-lan "..guset2gName.." 1>/dev/null 2>&1")
        end

        if guset2gRadio1 == '0' then
            os.execute("brctl delif br-lan "..guset2gName1.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..guset2gName1.." down 1>/dev/null 2>&1")
        else
            os.execute("ifconfig "..guset2gName1.." up 1>/dev/null 2>&1")
            os.execute("brctl addif br-lan "..guset2gName1.." 1>/dev/null 2>&1")
        end

        if guset5gRadio == '0' then
            os.execute("brctl delif br-lan "..guset5gName.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..guset5gName.." down 1>/dev/null 2>&1")
        else
            os.execute("ifconfig "..guset5gName.." up 1>/dev/null 2>&1")
            os.execute("brctl addif br-lan "..guset5gName.." 1>/dev/null 2>&1")
        end
        if guset5gRadio1 == '0' then
            os.execute("brctl delif br-lan "..guset5gName1.." 1>/dev/null 2>&1")
            os.execute("ifconfig "..guset5gName1.." down 1>/dev/null 2>&1")
        else
            os.execute("ifconfig "..guset5gName1.." up 1>/dev/null 2>&1")
            os.execute("brctl addif br-lan "..guset5gName1.." 1>/dev/null 2>&1")
        end
        if isRootApExist_2g == '1' then
            os.execute("brctl addif br-lan "..apcli2gName.." 1>/dev/null 2>&1")
        end
        if isRootApExist_5g == '1' then
            os.execute("brctl addif br-lan "..apcli5gName.." 1>/dev/null 2>&1")
        end
    end
    if onlyDoBrctlAddIf == 0 then
        local wlan2gRadio = '0'
        local wlan5gRadio = '0'
        local rootAp2gUptime = '0'
        local rootAp5gUptime = '0'
        local sysUptime = mtkwifi.__trim(mtkwifi.read_pipe("cat /proc/uptime"))
        local conf_mode = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get system.@system[0].netmode"))
        if sysUptime then sysUptime = string.split(sysUptime, ".") end
        if ap2gRadio == '0' and guset2gRadio == '0' and guset2gRadio1 == '0' then
            wlan2gRadio = '0'
        else
            wlan2gRadio = sysUptime[1]
        end
        if ap5gRadio == '0' and guset5gRadio == '0' and guset5gRadio1 == '0' then
            wlan5gRadio = '0'
        else
            wlan5gRadio = sysUptime[1]
        end
        if isRootApExist_2g == '1' then
            rootAp2gUptime = sysUptime[1]
        else
            rootAp2gUptime = '0'
        end
        if isRootApExist_5g == '1' then
            rootAp5gUptime = sysUptime[1]
        else
            rootAp5gUptime = '0'
        end
        if conf_mode == "wds" then
            os.execute("echo "..rootAp2gUptime.." > /tmp/wlan_link_time_stamp_2g")
            os.execute("echo "..rootAp5gUptime.." > /tmp/wlan_link_time_stamp_5g")
        else
            os.execute("echo "..wlan2gRadio.." > /tmp/wlan_link_time_stamp_2g")
            os.execute("echo "..wlan5gRadio.." > /tmp/wlan_link_time_stamp_5g")
        end
    end
end



function connetRootAp(dev)
    local conf_mode=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get system.@system[0].netmode"))
    
    if conf_mode == "wds" then
        local isRootApExist_2g=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_2g.apcli_existOption")) 
        local isRootApExist_5g=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_5g.apcli_existOption"))
        local devname_2g=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_2g.device")) 
        local devname_5g=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_5g.device"))
        if devname_2g then devname_2g = devname_2g:gsub("%_", ".") end
        if devname_5g then devname_5g = devname_5g:gsub("%_", ".") end

        if isRootApExist_2g == '1' and dev == "2g" then
            for _,vif in ipairs(string.split(mtkwifi.read_pipe("ls /sys/class/net"), "\n"))
            do
                if string.match(vif, "apcli%d") then
                    mtkwifi.apcli_connect(devname_2g, vif);
                end
            end
        end

        if isRootApExist_5g == '1' and dev == "5g" then
            for _,vif in ipairs(string.split(mtkwifi.read_pipe("ls /sys/class/net"), "\n"))
            do
                if string.match(vif, "apclix%d") or string.match(vif, "apclii%d") then
                    mtkwifi.apcli_connect(devname_5g, vif);
                end
            end
        end

        for _,vif in ipairs(string.split(mtkwifi.read_pipe("ls /sys/class/net"), "\n")) do
            if isRootApExist_2g == '1' or isRootApExist_5g == '1' then
                if string.match(vif, "ra.") then
                    mtkwifi.set_netgear_vie(vif, 1)
                end
            elseif string.match(vif, "ra.") then
                mtkwifi.set_netgear_vie(vif, 0)
            end
        end
    end
end

function startAllApPin()
    local pinCode = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g_5g.wpsPinCode"))
    local attackNum = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g_5g.wpsPinAttackNum"))
    local wpsLock = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g_5g.wpsLockdown"))
    local attackCheck = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g_5g.wpsPinAttackCheck"))

    if attackCheck == '0' then
        attackNum = '0'
    end

    for _,vif in ipairs(string.split(mtkwifi.read_pipe("ls /sys/class/net"), "\n"))
    do
        if string.match(vif, "ra%a-%d+") then
            mtkwifi.__wps_ap_pin_start_all(vif, pinCode, wpsLock, attackNum)
        end
    end
end

function enableBlackList()
    local devList = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g.blacklist"))
    for _,vif in ipairs(string.split(devList, " "))
    do
        local devMac = string.match(vif, ".+/")
        if devMac then
            devMac =string.gsub(devMac, "/", " ")
                for _,tif in ipairs(string.split(mtkwifi.read_pipe("ls /sys/class/net"), "\n"))
                do
                    if string.match(tif, "ra%a-0") then
                        mtkwifi.__attach_dev_black_list_enable(tif, devMac)
                    end
                end
        end
    end

    devList = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g.guest_blacklist"))
    for _,vif in ipairs(string.split(devList, " "))
    do
        local devMac = string.match(vif, ".+/")
        if devMac then
            devMac =string.gsub(devMac, "/", " ")
                for _,tif in ipairs(string.split(mtkwifi.read_pipe("ls /sys/class/net"), "\n"))
                do
                    if string.match(tif, "ra%a-1") then
                        mtkwifi.__attach_dev_black_list_enable(tif, devMac)
                    end
                end
        end
    end
end

function guestNetActive(vif, allowed)
    os.execute("ebtables -D INPUT -p IPv4 -i "..vif.." --ip-proto 17 --ip-dport 67:68 -j ACCEPT 1>/dev/null 2>&1")
    os.execute("ebtables -D INPUT -p ARP -i "..vif.." -j ACCEPT 1>/dev/null 2>&1")
    os.execute("ebtables -D INPUT -i "..vif.." -j DROP 1>/dev/null 2>&1")

    if allowed == "0" then
        os.execute("ebtables -A INPUT -p IPv4 -i "..vif.." --ip-proto 17 --ip-dport 67:68 -j ACCEPT")
        os.execute("ebtables -A INPUT -p ARP -i "..vif.." -j ACCEPT")
        os.execute("ebtables -A INPUT -i "..vif.." -j DROP")
    end

    os.execute("ebtables -D FORWARD -p IPv4 -i "..vif.." --ip-proto 17 --ip-dport 53 -j ACCEPT 1>/dev/null 2>&1")
    os.execute("ebtables -D FORWARD -p IPv4 -i "..vif.." --ip-proto 17 --ip-dport 67:68 -j ACCEPT 1>/dev/null 2>&1")

    if allowed == "0" then
        os.execute("ebtables -A FORWARD -p IPv4 -i "..vif.." --ip-proto 17 --ip-dport 53 -j ACCEPT")
        os.execute("ebtables -A FORWARD -p IPv4 -i "..vif.." --ip-proto 17 --ip-dport 67:68 -j ACCEPT")
    end

    local fd = io.open("/tmp/br-lan-ipaddr"..vif, "r")
    if fd ~= nil then
        local oldIp = fd:read("*l")
        fd:close()
        if oldIp ~= nil then
            os.execute("ebtables -D FORWARD -p IPv4 -i "..vif.." --ip-dst "..oldIp.." -j DROP 1>/dev/null 2>&1")
        end
    end

    local cmdfd = io.popen("ifconfig br-lan | awk -F '[ :]+' '/inet addr/ {print $4}'")
    local curIp = cmdfd:read("*l")
    cmdfd:close()

    local cmdfd = io.popen("ifconfig br-lan | awk -F '[ :]+' '/inet addr/ {print $8}'")
    local curIpMask = cmdfd:read("*l")
    cmdfd:close()

    if allowed == "0"  and curIp ~= nil and curIpMask ~= nil then
        os.execute("ebtables -A FORWARD -p IPv4 -i "..vif.." --ip-dst "..curIp.."/"..curIpMask.." -j DROP")
    end

    if curIp ~= nil and  curIpMask ~= nil then
        local fd = io.open("/tmp/br-lan-ipaddr"..vif, "w")
        if nil ~= fd then
            fd:write(curIp.."/"..curIpMask)
            fd:close()
        end
    else
        os.remove("/tmp/br-lan-ipaddr"..vif)
    end
end

function guestNetwork()
    local if2g="ra1"
    local if2g1="ra2"
    local if5g="rai1"
    local if5g1="rai2"
    local guest2g = mtkwifi.__trim(mtkwifi.read_pipe("uci get wireless.@wifi-iface[1].allowLocalNetwork"))
    local guest5g = mtkwifi.__trim(mtkwifi.read_pipe("uci get wireless.@wifi-iface[4].allowLocalNetwork"))
    local guest2g1 = mtkwifi.__trim(mtkwifi.read_pipe("uci get wireless.@wifi-iface[2].allowLocalNetwork"))
    local guest5g1 = mtkwifi.__trim(mtkwifi.read_pipe("uci get wireless.@wifi-iface[5].allowLocalNetwork"))

    if mtkwifi.exists("/sys/class/net/"..if2g) then
        guestNetActive(if2g, guest2g)
    end

    if mtkwifi.exists("/sys/class/net/"..if2g1) then
        guestNetActive(if2g1, guest2g1)
    end

    if mtkwifi.exists("/sys/class/net/"..if5g) then
        guestNetActive(if5g, guest5g)
    end

    if mtkwifi.exists("/sys/class/net/"..if5g1) then
        guestNetActive(if5g1, guest5g1)
    end
end

function startFwdd()
    os.execute("/etc/init.d/fwdd stop")
    os.execute("/etc/init.d/fwdd start")
end

function ledAction()
    local ap2gRadio=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[0].radio"))
    local ap5gRadio=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[1].radio"))
    local wpsLock = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.2g_5g.wpsLockdown"))
    local ap2gsecurity = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[0].security"))
    local ap5gsecurity = mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[1].security"))

    --os.execute("iwpriv ra0 e2p 3a=0d00") --config wifi driver LED_MODE:WPS_LED_MODE_13
    --os.execute("iwpriv rax0 e2p 3a=0d00") --config wifi driver LED_MODE:WPS_LED_MODE_13

    if ap2gRadio == '0' and ap5gRadio == '0' then
        os.execute(". /lib/functions/led_control.sh && platform_led_off green wps")
    --elseif wpsLock == '1' then
        --os.execute(". /lib/functions/led_control.sh && platform_led_set_timer green wps 200 200")
    else
        if ap2gRadio == '1' or ap5gRadio == '0' then
            if ap2gsecurity == "None" or ap2gsecurity == "OFF" then
                os.execute(". /lib/functions/led_control.sh && platform_led_off green wps")
            else
                os.execute(". /lib/functions/led_control.sh && platform_led_on green wps")
            end
        elseif ap2gRadio == '0' or ap5gRadio == '1' then
            if ap5gsecurity == "None" or ap5gsecurity == "OFF" then
                os.execute(". /lib/functions/led_control.sh && platform_led_off green wps")
            else
                os.execute(". /lib/functions/led_control.sh && platform_led_on green wps")
            end
        else
            if (ap2gsecurity == "None" or ap2gsecurity == "OFF") and (ap5gsecurity == "None" or ap5gsecurity == "OFF") then
                os.execute(". /lib/functions/led_control.sh && platform_led_off green wps")
            else
                os.execute(". /lib/functions/led_control.sh && platform_led_on green wps")
            end
        end
    end
end

function closeWifiForFactory()
    local factory_mode=mtkwifi.__trim(mtkwifi.read_pipe("envctl factory get factory_mode")) 
    local ap2gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[0].ifName")) 
    local ap5gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[3].ifName"))

    if factory_mode ~= "off" then
        os.execute("ifconfig "..ap2gName.." down 1>/dev/null 2>&1")
        os.execute("ifconfig "..ap5gName.." down 1>/dev/null 2>&1")
    end
end

function otpAction()
    local model=mtkwifi.__trim(mtkwifi.read_pipe("envctl factory get model"))
    local ap2gRadio0=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[0].radio"))
    local ap2gRadio1=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[1].radio"))
    local ap2gRadio2=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[2].radio"))
    local ap5gRadio0=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[3].radio"))
    local ap5gRadio1=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[4].radio"))
    local ap5gRadio2=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.@wifi-iface[5].radio"))

    if model == "WAX206" then
        --2.4G
        local radio2g="ra0"

        if ap2gRadio0 == '1' then
            radio2g="ra0"
        elseif ap2gRadio1 == '1' then
            radio2g="ra1"
        elseif ap2gRadio2 == '1' then
            radio2g="ra2"
        end

        if ap2gRadio0 == '1' or ap2gRadio1 == '1' or ap2gRadio2 == '1'then
            os.execute("iwpriv "..radio2g.." set tpc_duty=100:090:080:060")
            os.execute("iwpriv "..radio2g.." set tpc=1:1:1:122:116:125:0060:1")
        end

        --5G
        local radio5g="rai0"

        if ap5gRadio0 == '1' then
            radio5g="rai0"
        elseif ap5gRadio1 == '1' then
            radio5g="rai1"
        elseif ap5gRadio2 == '1' then
            radio5g="rai2"
        end

        if ap5gRadio0 == '1' or ap5gRadio1 == '1' or ap5gRadio2 == '1'then
            os.execute("iwpriv "..radio5g.." set thermal_protect_duty_cfg=0:0:100")
            os.execute("iwpriv "..radio5g.." set thermal_protect_duty_cfg=0:1:90")
            os.execute("iwpriv "..radio5g.." set thermal_protect_duty_cfg=0:2:80")
            os.execute("iwpriv "..radio5g.." set thermal_protect_duty_cfg=0:3:60")
            os.execute("iwpriv "..radio5g.." set thermal_protect_disable=0:1:1")
            os.execute("iwpriv "..radio5g.." set thermal_protect_disable=0:2:1")
            os.execute("iwpriv "..radio5g.." set thermal_protect_enable=0:1:1:122:116:0060")
            os.execute("iwpriv "..radio5g.." set thermal_protect_enable=0:2:1:125:000:0060")
        end
    end

    if model == "WAX202" then
        --2.4G
        local radio2g="ra0"

        if ap2gRadio0 == '1' then
            radio2g="ra0"
        elseif ap2gRadio1 == '1' then
            radio2g="ra1"
        elseif ap2gRadio2 == '1' then
            radio2g="ra2"
        end

        if ap2gRadio0 == '1' or ap2gRadio1 == '1' or ap2gRadio2 == '1'then
            os.execute("iwpriv "..radio2g.." set thermal_protect_duty_cfg=0:0:100")
            os.execute("iwpriv "..radio2g.." set thermal_protect_duty_cfg=0:1:80")
            os.execute("iwpriv "..radio2g.." set thermal_protect_duty_cfg=0:2:70")
            os.execute("iwpriv "..radio2g.." set thermal_protect_duty_cfg=0:3:60")
            os.execute("iwpriv "..radio2g.." set thermal_protect_disable=0:1:1")
            os.execute("iwpriv "..radio2g.." set thermal_protect_disable=0:2:1")
            os.execute("iwpriv "..radio2g.." set thermal_protect_enable=0:1:1:122:116:0060")
            os.execute("iwpriv "..radio2g.." set thermal_protect_enable=0:2:1:125:000:0060")
        end

        --5G
        local radio5g="rax0"

        if ap5gRadio0 == '1' then
            radio5g="rax0"
        elseif ap5gRadio1 == '1' then
            radio5g="rax1"
        elseif ap5gRadio2 == '1' then
            radio5g="rax2"
        end

        if ap5gRadio0 == '1' or ap5gRadio1 == '1' or ap5gRadio2 == '1'then
            os.execute("iwpriv "..radio5g.." set thermal_protect_duty_cfg=1:0:100")
            os.execute("iwpriv "..radio5g.." set thermal_protect_duty_cfg=1:1:80")
            os.execute("iwpriv "..radio5g.." set thermal_protect_duty_cfg=1:2:70")
            os.execute("iwpriv "..radio5g.." set thermal_protect_duty_cfg=1:3:60")
            os.execute("iwpriv "..radio5g.." set thermal_protect_disable=1:1:1")
            os.execute("iwpriv "..radio5g.." set thermal_protect_disable=1:2:1")
            os.execute("iwpriv "..radio5g.." set thermal_protect_enable=1:1:1:122:116:0060")
            os.execute("iwpriv "..radio5g.." set thermal_protect_enable=1:2:1:125:000:0060")
        end
    end
end


-- wifi service that require to start after wifi up
function wifi_service_misc()
    local apclient2gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_2g.ifName")) 
    local apclient5gName=mtkwifi.__trim(mtkwifi.read_pipe("uci -q get wireless.apcli_5g.ifName"))
    os.execute("echo [wifi_services] start wifi_service_misc >> /tmp/wifiLuaDebug.log")
    -- 0.brctl
    --doBrctlAddIf()

    -- 1.startFwdd
    startFwdd()

    -- 2.apcli_connect
    if mtkwifi.exists("/tmp/mtk/wifi/"..apclient2gName..".changed") or mtkwifi.exists("/tmp/mtk/wifi/normal_reload") then
        os.execute("rm /tmp/mtk/wifi/"..apclient2gName..".changed")
        connetRootAp("2g")
    end
    if mtkwifi.exists("/tmp/mtk/wifi/"..apclient5gName..".changed") or mtkwifi.exists("/tmp/mtk/wifi/normal_reload") then
        os.execute("rm /tmp/mtk/wifi/normal_reload")
        os.execute("rm /tmp/mtk/wifi/"..apclient5gName..".changed")
        connetRootAp("5g")
    end

    -- 3.startAllApPin
    --startAllApPin()

    -- 4.enableBlackList
    enableBlackList()

    -- 5.guestnetwork
    --guestNetwork()

    -- 6.ledAction
    --ledAction()

    -- 7.close WIFI for factory model
    closeWifiForFactory()

    -- 8.Wapp
    if mtkwifi.exists("/usr/bin/wapp_openwrt.sh") then
        os.execute("/usr/bin/wapp_openwrt.sh")
    end

    -- 9.EasyMesh
    if mtkwifi.exists("/usr/bin/EasyMesh_openwrt.sh") then
        os.execute("/usr/bin/EasyMesh_openwrt.sh")
    end

    -- otp
    otpAction()
end

if arg[1] == "guestNetwork" then
    guestNetwork()
end

-- wifi service that require to clean up before wifi down
function wifi_service_misc_clean()
    os.execute("rm -rf /tmp/wapp_ctrl")
    os.execute("killall -15 mapd")
    os.execute("killall -15 wapp")
    os.execute("killall -15 p1905_managerd")
    os.execute("killall -15 bs20")
end
