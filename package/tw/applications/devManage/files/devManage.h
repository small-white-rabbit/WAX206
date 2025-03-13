#include "fwk/fwk.h"
#include "dai/dai.h"

#define DEVMANAGE_LOG_NAME         "devManage"
#define DEV_ONLINE_EVENT           "device_online"
#define DEV_OFFLINE_EVENT          "device_offline"
#define INTERNET_STATUS_UP         "internet_status_up"
#define DEVMANAGE_HANDLE_FING_RESULT  "fing_result"
#define DEVMANAGE_ATTACHDEV_INIT   "attach_device_init"
#define DEVMANAGE_DEV_SAVE_FILE      "/etc/config/config/attach_devices"
#define DEVMANAGE_DEV_SAVE_FILE_BAK  "/etc/config/config/attach_devices.bak"
#define DEVMANAGE_DEV_SAVE_LOCK1     "/etc/config/config/attach_devices_save_lock1"
#define DEVMANAGE_DEV_SAVE_LOCK2     "/etc/config/config/attach_devices_save_lock2"
#define UBUS_EVENT_FING_RESULT  "ubus send fing_result \"%s\""
#define DEVMANAGE_EBT_RULES_CAPTURE_HTTP    "http_user_agent"
#define DEVMANAGE_ACCESSCONTROL_REF_RULE    "access_control_refresh_rule"
#define DEVMANAGE_FING_USE_FILE1    "/tmp/fingUsefile1"
#define DEVMANAGE_FING_USE_FILE2    "/tmp/fingUsefile2"

#define FING_CMD "curl -k -X POST --key %s  --cert %s \
  https://netgear-devrecog.fing.io/2/devrecog \
  -H \'Accept: application/json\' \
  -H \'Cache-Control: no-cache\' \
  -H \'Content-Type: application/json\' \
  -H \'X-API-Key: %s\' \
  -T /tmp/fing_json"

#define ONE_DEV_FING_INFO_SIZE           (512)
#define DEFAULT_NETGEAR_DEVICE_TYPE_NUM  (19)
#define DM_FING_QUERY_WEEKLY             (604800000)

typedef struct{
    char ip[32];         //下挂设备的ip地址
    char mac[32];        //下挂设备的mac地址
    char devName[64];    //下挂设备名称
    char devVendor[64];  //MAC地址的前三个字节代表的厂商
    char connType[16];   //连接类型, 取值范围 'wired' / '2.4G' / '5G' / '5G-2'
    char ifname[24];     //连接的接口 如ra0 eth0.0
    char accessStatus[16];     //当前设备是否允许连接或不允许连接 Allowed or Blocked
    char deviceType[32]; //当前设备连接类型
    UINT32  deviceTypeNum;          // 当前设备连接NUM,NETGEAR定义
    char deviceModel[64]; //当前设备连接mode,NETGEAR定义
    char deviceBrand[64]; //当前设备连接brand,NETGEAR定义
    char onlineStatus[16]; //当前设备在线状态 'online' 'offline'
    char customName[64];
    char customModel[64];
    UINT32 customTypeNum;
    UINT64 timeStamp;   //设备上线的具体时间
    char dhcpHostName[64];
    char dhcpOptions[128];
    char dhcpVendor[64];
    char devHua[256];
    UINT32 fingRecognised;
    char padding[128];
} __attribute__((__packed__)) ATTACH_DEV_INFO_T;

typedef struct
{
    struct list_head dlist;
    ATTACH_DEV_INFO_T devInfo;
    UINT8 forceDoFingQuery;
    UINT8 captureHttpPacketFlag;
    UINT8 firstOnLineFlag;
} DEVICE_MANAGE_DEV_NODE_T;

typedef struct
{
    char nuid[32];
    char netaddress[24];
    char internetip[20];
    char gatewayip[20];
    char gatewaymac[20];
    char dnsip[20];
} DEVICE_MANAGE_SIGNATURE_NETWORK_T;

typedef struct
{
    int typeNum;
    char *netgearType;
    char *fingDetectedType[30];
} FING_TYPE_MAP_NETGEAR_TYPE_T;

typedef struct
{
    UINT32 devNum;
    DEVICE_MANAGE_DEV_NODE_T node[ATTACH_DEV_MAX];
    UINT32 isFingQuery;
    pthread_t fingQueryThread;
} FING_QUERY_PARAM_T;
