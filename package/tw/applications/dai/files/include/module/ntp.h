#ifndef __NTP_H__
#define __NTP_H__
#include "fwk/fwk.h"

typedef struct
{
    char time_zone[BUFLEN_32];
    char zone_city[BUFLEN_64];
    char dst_rule[BUFLEN_64];
    char tz_offset[BUFLEN_8];
    char pri_server[BUFLEN_32];
    char sec_server[BUFLEN_32];
    char tz_desc[BUFLEN_128];
} NTP_TIMEZONE_T;

typedef struct {
    int tz_index;
    int tz_mode;
    int dst_enable;
    int ntp_type;
    char ntp_server1[BUFLEN_256];
    char ntp_server2[BUFLEN_256];
    char manual_server[BUFLEN_256];
    char time_zone[BUFLEN_64];
    char zone_name[BUFLEN_64];
} NTP_CONFIG_T;

typedef enum
{
    TZ_MODE_MANUAL = 0,
    TZ_MODE_AUTO,
    TZ_MODE_INVALID,
} NTP_TZ_MODE_E;

typedef enum
{
    NTP_SRV_NTGR = 0, // Use Netgear NTP server
    NTP_SRV_MANUAL, // Use Manual NTP server
    NTP_SRV_MAX
} NTP_SERVER_TYPE_E;

extern NTP_TIMEZONE_T ntgr_tz[];

int dai_ntp_ntgr_tz_List_length();
int dai_ntpGetNtgrTimeZoneIndex(char *value, int len);
int dai_ntpSetNtgrTimeZoneIndex(char *value);
int dai_ntpGetNtgrAutoTimeZoneEnable(char *value, UINT32 len);
int dai_ntpSetNtgrAutoTimeZoneEnable(char *value);
int dai_ntpGetNtgrDayLightSaving(char *value, int len);
int dai_ntpSetNtgrDayLightSaving(char *value);
int dai_ntpGetNtgrNtpServerType(char *value, int len);
int dai_ntpSetNtgrNtpServerType(char *value);
int dai_ntpGetNtgrManualServer(char *value, int len);
int dai_ntpSetNtgrManualServer(char *value);
void dai_ntpReload();
int dai_setNtpParms(NTP_CONFIG_T *ntpCfg);

#endif
