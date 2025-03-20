## Development
  - Source [OpenWRT](https://github.com/openwrt/openwrt/tree/openwrt-24.10),`v24.10.0`
  - 调整分区表,充分利用`256MB`的SLC-NAND
  - ```
    git apply mt7622-netgear-wax206.dts.patch
    git apply mt7622.mk.patch
    ```
  - <img width="552" alt="161119shdtpnoq78htrp2h" src="https://github.com/user-attachments/assets/f128226c-41c9-4723-9f9b-c5d0680db54a" />


## Env
  - 推荐`Ubuntu 22.04 LTS`
