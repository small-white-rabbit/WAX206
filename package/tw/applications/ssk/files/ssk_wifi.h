#ifndef __SSK_WIFI_H__
#define __SSK_WIFI_H__

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include <libubus.h>
#include "fwk/fwk.h"
#include "dai/dai.h"
#include <linux/if.h>
#include <syslog.h>
#include <errno.h>

void SSK_processWifiIncorrectSecuritySetting(unsigned char *mac);

#endif