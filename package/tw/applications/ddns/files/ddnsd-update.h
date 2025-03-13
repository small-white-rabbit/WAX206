#ifndef _DDNSD_UPDATE_H_
#define _DDNSD_UPDATE_H_

enum { UPDATERES_OK,
       UPDATERES_ERROR,
       UPDATERES_SHUTDOWN,
       UPDATERES_BADSERVICE };

int do_update( char *service, char *hostname, char *address, char *username, char *password );
void do_result(int result, char *service, char *hostname) ;


#endif