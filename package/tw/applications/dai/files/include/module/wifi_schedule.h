#ifndef __WIFI_SCHEDULE_H__
#define __WIFI_SCHEDULE_H__

#include "fwk/fwk.h"

typedef enum
{
    ACT_ADD = 0,
    ACT_DEL,
    ACT_EDIT
} ACTION_TYPE_E;

typedef enum
{
    RADIO_2G = 0,
    RADIO_5G
} WIFI_SCHEDULE_RADIO_E;

typedef enum
{
    ACTION_STOP = 0,
    ACTION_START
} WIFI_SCHEDULE_ACTION_E;

typedef struct{
    int daily;
    char day_week[BUFLEN_128];
    int op; /* 0: add; 1: del; 2: edit */
    int radio;
    int rule_idx;
    char start_time[BUFLEN_32];
    char stop_time[BUFLEN_32];
} WIFI_SCHEDULE_RULE_T;

#define WEEK_DAYS 7
#define WEEK_TIME_POINTS 48

int dai_wifiScheduleEnableGet(int radio, char *value, UINT32 len);
int dai_wifiScheduleEnableSet(int radio, int val);
int dai_wifiScheduleRuleAdd(WIFI_SCHEDULE_RULE_T *rule);
int dai_wifiScheduleRuleGet(WIFI_SCHEDULE_RULE_T *rule);
int dai_wifiScheduleRuleEdit(WIFI_SCHEDULE_RULE_T *rule);
int dai_wifiScheduleRuleDel(int radio, int index);
int dai_wifiScheduleTime2IndexTrans(char *time, int *index);
int dai_wifiScheduleIndex2TimeTrans(int index, char *time);
int dai_wifiScheduleWeekday2IndexTrans(char *weekday, char *index);
int dai_wifiScheduleIndex2WeekdayTrans(char *index, char *weekday);
int dai_wifiScheduleRuleHandle(WIFI_SCHEDULE_RULE_T *rule);
void dai_wifiScheduleAction();
void dai_wifiScheduleSync2GTo5G();
#endif
