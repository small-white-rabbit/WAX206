#include <stdio.h>
#include <strings.h>
#include <unistd.h>
#include <stdint.h>
#include "dai/dai.h"
#include "libswitch/mtk_eth_api.h"
#include "dai/hal/hal_switch.h"

typedef struct
{
    const char *model;
    uint8_t cpu_ports;
    uint8_t sw_cpu[2];
    uint8_t uplink;
    uint8_t lan_num;
    uint8_t lan_ports[6];
    uint16_t wan_vid;
    uint16_t lan_vid;
} swop_cfg;