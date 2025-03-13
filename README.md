## 说明

1. 官方V1.0.4，SPL 源代码存档(基于 LEDE 17.01):https://www.downloads.netgear.com/files/GPL/WAX206_V1.0.4.0_Source.rar
2. 推荐Ubuntu 18.04 LTS
3. 下载`Releases`中`dl.tar.gz`，解压至`dl/`目录下，内含相关闭源驱动

## 编译环境

```bash
sudo apt update -y
sudo apt full-upgrade -y
sudo apt install -y git git-core wget p7zip p7zip-full unzip \
g++ gcc libncurses5-dev zlib1g-dev bison flex autoconf gawk \
make gettext binutils patch bzip2 libz-dev asciidoc subversion
```
```
# Select
g++-multilib gcc-multilib build-essential asciidoc binutils gawk gettext \
libz-dev patch python3.5 python2.7 zlib1g-dev lib32gcc1 libc6-dev-i386 \
uglifyjs msmtp libssl-dev texinfo libglib2.0-dev xmlto libelf-dev autoconf \
automake libtool autopoint device-tree-compiler antlr3 gperf qemu-utils upx
```
```
unrar x WAX206_V1.0.4.0_Source.rar
tar -xzvf dl.tar.gz -C WAX206_V1.0.4.0_Source/
cd WAX206_V1.0.4.0_Source

chmod +x scripts/* scripts/.*
chmod +x scripts/config/* scripts/config/.*
chmod +x scripts/flashing/* scripts/flashing/.*
chmod +x include/*.sh
find tools -name "*.sh" -exec chmod +x {} \;
find package -name "*.sh" -exec chmod +x {} \;

# 先尝试使用`模版配置'编译
cp autobuild/mt7622-mt7915-AP-AX3200-hostapd/.config .
cp -r autobuild/mt7622-mt7915-AP-AX3600/target/linux/mediatek/base-files/sbin/smp.sh target/linux/mediatek/base-files/sbin/smp.sh

cp -r autobuild/mt7622-mt7915-AP-AX3200-hostapd/config-4.4 target/linux/mediatek/mt7622/config-4.4  // 可选，可能有匹配内核冲突
```
---
# NETGEAR WAX206

- ## Hardware Info

| **Component**      |                         **详细信息**                           |
|--------------------|---------------------------------------------------------------|
| **Architecture**   | Ralink ARM                                                    |
| **Vendor**         | MediaTek                                                      |
| **Bootloader**     | U-Boot                                                        |
| **System-On-Chip** | MediaTek MT7622BV - ARM Cortex-A53                            |
| **CPU/Speed**      | 1.35GHz (Dual Core)                                           |
| **Flash-Chip**     | Toshiba TC58CVG1S3HRAIJ                                       |
| **Flash size**     | SPI-NAND 256 MiB (Toshiba TC58CVG1S3HRAIJ)                    |
| **RAM**            | DDR3 512 MiB (Nanya NT5CC256M16ER-EK)                         |
| **Wireless 1**     | MediaTek MT7622BV - 802.11bgn (2.4GHz) 4×4 MIMO               |
| **Wireless 2**     | MediaTek MT7915AN/MT7975AN - 802.11a/n/ac/ax (5GHz) 4×4 MIMO  |
| **Ethernet Lan**   | 4 x 1000M MT7531AE                                            |
| **Ethernet Wan**   | 1 x 2500M RTL8221B                                            |
| **Switch**         | MediaTek MT7531AE                                             |
| **USB**            | None                                                          |
| **Serial**         | Yes                                                           |
| **JTAG**           | Does not appear to be exposed                                 |

- ## 闪存布局
| 分区名          | 大小       | 功能描述 |
|---------------|----------|--------|
| **mtd0: Preloader**       | 512 KB  | 设备启动的前置加载程序，初始化硬件并加载Bootloader。 |
| **mtd1: ATF**             | 256 KB  | ARM Trusted Firmware，负责安全启动和加密功能。 |
| **mtd2: Bootloader**      | 512 KB  | 设备的引导加载程序，负责加载内核和文件系统。 |
| **mtd3: Config**         | 512 KB  | 设备的系统配置参数或硬件设置。 |
| **mtd4: Factory**        | 1 MB    | 存储出厂时的固件或设备原始配置信息。 |
| **mtd5: ImageA**         | 38 MB   | 可能是主系统固件映像，存储操作系统或完整固件。 |
| **mtd6: Kernel**         | 37.94 MB| 操作系统内核分区，存放Linux等系统的核心代码。 |
| **mtd7: kernel**         | 2.64 MB | 可能是备用内核分区或内核的部分存储。 |
| **mtd8: rootfs**         | 35.25 MB| 根文件系统，存储操作系统文件及相关数据。 |
| **mtd9: rootfs_var**     | 12.38 MB| 可能是 `rootfs` 的可变存储部分，存放动态数据或缓存。 |
| **mtd10: Kernel_backup** | 38 MB   | 备份的操作系统内核，防止系统损坏时无法启动。 |
| **mtd11: CFG**           | 8 MB    | 配置数据分区，存储系统配置信息。 |
| **mtd12: RAE**           | 4 MB    | 可能用于存储特定安全相关数据，如加密存储。 |
| **mtd13: POT**           | 1 MB    | 可能是预设或临时存储区域，具体功能需查阅设备文档。 |
| **mtd14: Language**      | 4 MB    | 语言设置分区，包含界面语言、翻译等相关数据。 |
| **mtd15: Traffic**       | 2 MB    | 可能存储网络流量日志或相关统计信息。 |
| **mtd16: Cert**          | 1 MB    | 存储设备的安全证书，如SSL证书或身份验证文件。 |
| **mtd17: NTGRcryptK**    | 1 MB    | 加密密钥存储区，可能用于固件或文件系统加密。 |
| **mtd18: NTGRcryptD**    | 5 MB    | 加密数据分区，配合 `NTGRcryptK` 使用。 |
| **mtd19: LOG**           | 1 MB    | 设备的日志存储分区，存放系统日志文件。 |
| **mtd20: User_data**     | 6.4 MB  | 用户数据存储分区，可能用于用户自定义设置或存储文件。 |


- ## 官方固件
    * https://www.netgear.com/support/download/?model=WAX206
    * WAX206_Firmware_V1.0.4.0 可刷机、可恢复  
    * WAX206_Firmware_V1.0.5.3 已修复，官方最终版
    * 通过web页面“ https://router.ip/debug_detail.htm ”页面上的隐藏表单启用 `Telnet`
        * web页面右键'检查',在 HTML 中搜索 `hid_telnet` ，通过更改 style="display: hidden" 至 style="display: center" 来显示条目。
        * 网页上应出现“启用 Telnet”复选框。点击后，页面刷新，可以通过 `telnet` 连接。
        * webUI 管理员帐户允许访问 root shell。
        * 在 https://router.ip/cgi-bin/luci/ 上设置`root`密码以访问`luci`
    * 官方V1.0.4，SPL 源代码存档(基于 LEDE 17.01):https://www.downloads.netgear.com/files/GPL/WAX206_V1.0.4.0_Source.rar
    * 改地区:`cd /usr/bin/fw_setenv fenv_region US`

- ## OpenWRT
    * https://openwrt.org/toh/netgear/wax206
    * 从V1.0.4.0页面升级“netgear_wax206-squashfs-factory.img”会自动扩容空间；
    * 在OpenWRT使用"sysupgrade.bin"升级即可;
    * wifi硬件加速`sed -i -e "s/mt7915e/mt7915e wed_enable=Y/g" /etc/modules.d/mt7915e`

- ## nmrpflash刷机
    * 快速刷机:`sudo nmrpflash -i en0 -f immortalwrt-mediatek-mt7622-netgear_wax206-squashfs-factory.img`
    * 自定义刷机:`sudo nmrpflash -v -i en0 -a 192.168.1.1 -m 94:18:65:37:27:21 -F firmware -f 固件.img -t 10000 -T 10000`

- ## 备份/恢复分区(前提是分区可读写)
    * 备份分区: `dd if=/dev/mtd0 of=/tmp/mtd0_Preloader.bin`
    * 恢复分区: `dd if=/tmp/mtd0_Preloader.bin of=/dev/mtd0`  
    或 `mtd write /tmp/mtd0_Preloader.bin Preloader`  
    或 `nandwrite -p /dev/mtd20 /tmp/User_data_backup.bin`  
    或 `nandwrite /dev/mtd9 - < mtd11.dump`
