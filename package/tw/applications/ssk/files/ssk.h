#ifndef __SSK_H__
#define __SSK_H__

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include <libubus.h>
#include "fwk/fwk.h"
#include "dai/dai.h"
#include <syslog.h>
#include <errno.h>

struct ubus_context *ssk_mainCtx(void);
int ssk_ubusInit(void);
int ssk_nlInit(void);
int ssk_systemInit(void);

#endif