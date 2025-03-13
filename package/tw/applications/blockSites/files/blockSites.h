#include "fwk/fwk.h"
#include "dai/dai.h"

#define BLOCKSITES_LOG_NAME         "blockSites"
#define BLOCKSITES_SAVE_LOCK1     "/etc/config/config/block_sites_save_lock1"
#define BLOCKSITES_SAVE_LOCK2     "/etc/config/config/block_sites_save_lock2"

#define BLOCKSITES_SAVE_FILE      "/etc/config/config/block_sites"
#define BLOCKSITES_SAVE_FILE_BAK  "/etc/config/config/block_sites.bak"

#define BLOCKSITES_ADD_FIREWALL_RULE_EVENT           "blockSites_add_rule"


typedef struct{
    char keyword[BUFLEN_128];        //url关键字
} __attribute__((__packed__)) BLOCK_SITES_INFO_T;

typedef struct
{
    struct list_head dlist;
    BLOCK_SITES_INFO_T blocksiteInfo;
} BLOCK_SITES_NODE_T;


