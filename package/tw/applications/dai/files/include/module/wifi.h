#ifndef __WIFI_H__
#define __WIFI_H__

#include "fwk/fwk.h"

typedef enum{
    WIFI_CONF_MODE_AP        = 0x00,
    WIFI_CONF_MODE_ROUTER    = 0x01,
    WIFI_CONF_MODE_EXT       = 0x02,
    WIFI_CONF_MODE_BRIDGE    = 0x03
}WIFI_CONF_MODE;

typedef struct
{
    UBOOL8 isEanble;
    char ssid[BUFLEN_64];
    char wirelessBand[BUFLEN_64];
    UBOOL8 isBroadcast;
    char security[BUFLEN_32];
    char password[BUFLEN_128];
    UINT32 wepAuthType;
    char auth_server[BUFLEN_128];
    UINT32 auth_port;
    char auth_secret[BUFLEN_128 + 1];
    UINT32 clientIsolation;
    UINT32 allowToWired;
}WLAN_IF_CONFIG_T;

typedef struct
{
    int smartConnect;
    UINT32 mode;
    UBOOL8 mu_Mimo;
    UBOOL8 fastLane;
    char  fastLaneBand[BUFLEN_8];
    UBOOL8 oneWifiName;
    UBOOL8 syncConfigFromNtgrRouter;
    UINT32 wlFrag;
}WLAN_COMMON_CONFIG_T;

typedef struct
{
    UINT32 channel;
    UINT32 enableCoexist;
    char wirelssMode[BUFLEN_32];
    char wifiCountryCode[BUFLEN_8];
    char macAddress[BUFLEN_32];
    UINT32 ofdma;
    UINT32 wlRts;
    UINT32 axEnable;
    UINT32 preambleMode;
    UINT32 enableRfRadioOn;
    UINT32 txPower;
    UINT32 beaconPeriod;
    UINT32 dtimPeriod;
    UINT32 mumimo;
    UINT32 txbf;
    UINT32 pmf;
    UINT32 wpsConfStatus;
}WLAN_DEV_CONFIG_T;

typedef struct
{
   WLAN_IF_CONFIG_T wlanIfConfig1;
   WLAN_IF_CONFIG_T wlanIfConfig2;
   WLAN_IF_CONFIG_T wlanIfConfig3;
   char ssidIsolation[BUFLEN_32];
}WIFI_CONFIG_SET_T;

typedef struct
{
    UINT32 enable2GSchedule;
    UINT32 enable5GSchedule;
} WLAN_SCH_CONFIG_T;

typedef struct 
{
    WLAN_COMMON_CONFIG_T  wifiAdvCommonCfg;
    WLAN_DEV_CONFIG_T     wifi2GDevCfg;
    WLAN_DEV_CONFIG_T     wifi5GDevCfg;
    WLAN_SCH_CONFIG_T     wifiScheduleCfg;
}WIFI_ADVANCED_CONFIG_SET_T;

typedef enum
{
    WLAN_2G = 1,
    WLAN_5G,
} WLAN_BAND_E;

#define WLAN_ENABLE  TRUE
#define WLAN_DISABLE FALSE

#define WIRELESS_1     1
#define WIRELESS_2     2
#define WIRELESS_3     3

#define WLAN1_2G_INDEX 0
#define WLAN2_2G_INDEX 1
#define WLAN3_2G_INDEX 2
#define WLAN1_5G_INDEX 3
#define WLAN2_5G_INDEX 4
#define WLAN3_5G_INDEX 5

#define WPA3_PASS_PHRASE_LENGTH 63

#define WLAN_2G_DEV "wireless.2g"
#define WLAN_5G_DEV "wireless.5g"
#define WLAN_2G_APCLI_DEV "wireless.apcli_2g"
#define WLAN_5G_APCLI_DEV "wireless.apcli_5g"
#define WLAN_2G_FIRST_IF "wireless.@wifi-iface[0]"
#define WLAN_2G_SECOND_IF "wireless.@wifi-iface[1]"
#define WLAN_2G_THIRD_IF "wireless.@wifi-iface[2]"
#define WLAN_5G_FIRST_IF "wireless.@wifi-iface[3]"
#define WLAN_5G_SECOND_IF "wireless.@wifi-iface[4]"
#define WLAN_5G_THIRD_IF "wireless.@wifi-iface[5]"
#define WLAN_2G5G_DEV "wireless.2g_5g"

#define STR_SECURITY_NONE                        "None"
#define STR_SECURITY_WPA2SAE                     "WPA2-Personal"
#define STR_SECURITY_WPASAE_WPA2SAE              "WPA/WPA2-Personal"
#define STR_SECURITY_WPA_WPA2_ENTERPRISE         "WPA/WPA2-Enterprise"
#define STR_SECURITY_WPA2_ENTERPRISE             "WPA2-Enterprise"
#define STR_SECURITY_WPA3SAE                     "WPA3-Personal"
#define STR_SECURITY_WPA2SAE_WPA3SAE             "WPA2/WPA3-Personal"


typedef enum{
    SECURITY_NONE                 = 0x01,
    SECURITY_WPA2SAE              = 0x04,
    SECURITY_WPASAE_WPA2SAE       = 0x05,
    SECURITY_WPA_WPA2_ENTERPRISE  = 0x06,
    SECURITY_WPA3SAE              = 0x07,
    SECURITY_WPA2SAE_WPA3SAE      = 0x08,
}WLAN_ENCRYPTTYPE_E;


static inline void wifiIfConfigGet(int ssidIdx, const char *keySuffix, char *value, UINT32 valueLen)
{
#ifdef UCI
    char getStr[BUFLEN_256] = {0};

    memset(value, 0, valueLen);

    UTIL_SNPRINTF(getStr, sizeof(getStr), "wireless.@wifi-iface[%d].%s", ssidIdx, keySuffix);
    ucix_get(getStr, value, valueLen);
#endif
}

static inline void wifiIfConfigSet(int ssidIdx, const char *keySuffix, char *value)
{
#ifdef UCI

    char setStr[BUFLEN_256] = {0};

    UTIL_SNPRINTF(setStr, sizeof(setStr), "wireless.@wifi-iface[%d].%s=%s", ssidIdx, keySuffix, value);
    ucix_set(setStr);
#endif
}

static inline void wifiConfigSet(const char *keySuffix, char *value)
{
#ifdef UCI
    char setStr[BUFLEN_128] = {0};

    UTIL_SNPRINTF(setStr, sizeof(setStr), "wireless.2g_5g.%s=%s", keySuffix, value);

    ucix_set(setStr);
#endif
}

static inline void wifiConfigGet(const char *keySuffix, char *value, UINT32 valueLen)
{
#ifdef UCI
    char getStr[BUFLEN_128] = {0};

    memset(value, 0, valueLen);

    UTIL_SNPRINTF(getStr, sizeof(getStr), "wireless.2g_5g.%s", keySuffix);

    ucix_get(getStr, value, valueLen);
#endif
}

static inline void wifiDevConfigGet(int band, const char *keySuffix, char *value, UINT32 valueLen)
{
#ifdef UCI
    char getStr[BUFLEN_128] = {0};

    memset(value, 0, valueLen);
    if (WLAN_2G == band)
    {
        UTIL_SNPRINTF(getStr, sizeof(getStr), "wireless.2g.%s", keySuffix);
    }
    else
    {
        UTIL_SNPRINTF(getStr, sizeof(getStr), "wireless.5g.%s", keySuffix);
    }
    ucix_get(getStr, value, valueLen);
#endif
}

static inline void wifiDevConfigSet(int band, const char *keySuffix, char *value)
{
#ifdef UCI
    char setStr[BUFLEN_128] = {0};

    if (WLAN_2G == band)
    {
        UTIL_SNPRINTF(setStr, sizeof(setStr), "wireless.2g.%s=%s", keySuffix, value);
    }
    else
    {
        UTIL_SNPRINTF(setStr, sizeof(setStr), "wireless.5g.%s=%s", keySuffix, value);
    }
    ucix_set(setStr);
#endif
}

static inline void wifiApcliConfigGet(int band, const char *keySuffix, char *value, UINT32 valueLen)
{
#ifdef UCI
    char getStr[BUFLEN_128] = {0};

    memset(value, 0, valueLen);
    if (WLAN_2G == band)
    {
        UTIL_SNPRINTF(getStr, sizeof(getStr), "wireless.apcli_2g.%s", keySuffix);
    }
    else
    {
        UTIL_SNPRINTF(getStr, sizeof(getStr), "wireless.apcli_5g.%s", keySuffix);
    }
    ucix_get(getStr, value, valueLen);
#endif
}

static inline void wifiApcliConfigSet(int band, const char *keySuffix, char *value)
{
#ifdef UCI
    char setStr[BUFLEN_128] = {0};

    if (WLAN_2G == band)
    {
        UTIL_SNPRINTF(setStr, sizeof(setStr), "wireless.apcli_2g.%s=%s", keySuffix, value);
    }
    else
    {
        UTIL_SNPRINTF(setStr, sizeof(setStr), "wireless.apcli_5g.%s=%s", keySuffix, value);
    }
    ucix_set(setStr);
#endif
}

int dai_getWirelessInterfaceInfo(int index, WLAN_IF_CONFIG_T *wlanIfConfig);
int dai_setWirelessInterfaceInfo(int ifIdx, WLAN_IF_CONFIG_T *wlanIfConfig);
int dai_setWirelessInfo(WIFI_CONFIG_SET_T *wlanConfig);
int dai_getSmartConnect();
int dai_setSmartConnect(int enable);
int dai_getAvailableExtChannel(UINT32 band, char *extChanel, int len, int wlanIdx, int *bw);
int dai_wifiDevConfigGet(int band, const char *keySuffix, char *value, UINT32 valueLen);
int dai_wifiConfigGet(const char *keySuffix, char *value, UINT32 valueLen);
int dai_setWirelessAdvanceInfo(WIFI_ADVANCED_CONFIG_SET_T *wlanAdvConfig);
uint32_t dai_getWlanLinkUpTime(int band);
int dai_getWirelessInterfaceParamValue(int wirelessIndex, const char *key, char *value, int valueLen);
int dai_getAvailableChannel(UINT32 band, char *chanel, int len, int wlanIdx, int *bw);
int dai_setChannel(UINT32 band, int chanel, int wlanIdx);
int dai_wifiIfConfigGet(int ifIdx, const char *keySuffix, char *value, UINT32 valueLen);
int dai_wifiIfConfigSet(int ifIdx, const char *keySuffix, char *value);
int dai_wifiApcliConfigGet(int band, const char *keySuffix, char *value, UINT32 valueLen);
int dai_wifiApcliConfigSet(int band, const char *keySuffix, char *value);
void dai_wifiDevConfigSet(int band, const char *keySuffix, int *value);
void dai_wifiReload();
void dai_setSsidClientIsolation();
int dai_wifiSwitchApcliSync(int enable);
void dai_countryCodeToRegion(char *pCountryCode, int pCountryCode_len, char *pRegion, int pRegion_len,
                             char *pRegionCode, int pRegionCode_len);
void dai_getWiFiInfStatus(UINT32 band, int wlanIdx, int* status);
void dai_getWirelessInterfaceStatus(int index, int* status);
void dai_uciCommit(const char* pConfig, UBOOL8 bOverWrite);
int dai_setWifiBeaconDtimInfo(WIFI_ADVANCED_CONFIG_SET_T *wlanAdvConfig);
void dai_wifiReloadRfRadioOn(int lastRadioOnFlag2G, int currentRadioOnFlag2G, int lastRadioOnFlag5G, int currentRadioOnFlag5G);
void dal_setAllowToWired();
int dai_backUpWifiRadioStatus();
int dai_recoverWifiRadioStatus();
int dai_getApcliRate(int *rate);
void dai_wifiUci2Dat();
void dai_onlyWifiReloadAndRfRadioOn(int lastRadioOnFlag2G, int currentRadioOnFlag2G, int lastRadioOnFlag5G, int currentRadioOnFlag5G);
#endif
