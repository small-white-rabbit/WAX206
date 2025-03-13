#ifndef _DDNSD_CONF_H_
#define _DDNSD_CONF_H_
#include <syslog.h>
#define MAX_INTERFACES 16

// Defines for DDnsConfig

#define HOSTNAME 0
#define SERVICE  1
#define IFACE    2
#define USERNAME 3
#define PASSWORD 4

// Defines for DDnsCache
// #define HOSTNAME 0  Shared with DDnsConfig
#define CACHE_IP 1

#define DDNS_LOG(level, fmt, ...) \
        do { \
            syslog(level, "[%s:%d]: "fmt, __FUNCTION__, __LINE__, ##__VA_ARGS__); \
        } while (0)



#if 0
typedef struct ddns { char *vals[5];
                      struct ddns *next;
                    } BcmDDnsConfig;

typedef BcmDDnsConfig * pBcmDDnsConfig;

typedef struct ddns_cache { char *hostname;
                            char *address;
                            struct ddns_cache *next; } BcmDDnsCache;

typedef BcmDDnsCache * pBcmDDnsCache;
#endif

// Prototypes for DDnsConfig file functions

int    BcmDDnsConfig_init();
char  *BcmDDnsConfig_get( char *iface, int var );
void   BcmDDnsConfig_iter( void (*func)(char *) );
char  *BcmDDnsConfig_getInterface( char *hostname );
char  *BcmDDnsConfig_getService( char *hostname );
char  *BcmDDnsConfig_getUsername( char *hostname );
char  *BcmDDnsConfig_getPassword( char *hostname );
void   BcmDDnsConfig_close(void);


int   BcmDDnsCache_init( );
char *BcmDDnsCache_get( char *hostname );
void  BcmDDnsCache_close(void);

#endif