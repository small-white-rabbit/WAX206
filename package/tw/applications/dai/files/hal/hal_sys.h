#ifndef __HAL_SYS_H__
#define __HAL_SYS_H__

#define HAL_FENV_MAC  "mac"
#define HAL_UENV_LANGUAGE  "language"

#define HAL_128MBFLASHMEMORY  128
#define HAL_256MBFLASHMEMORY  256

#define HAL_LED_POWER_STATE_RESET 2
#define HAL_LED_POWER_STATE_ON 1
#define HAL_LED_POWER_STATE_OFF 0


#define HAL_LED_CONTROL_SCRIPT "/sbin/led.sh"
#define HAL_LED_INIT_SCRIPT "/etc/init.d/led"
#define HAL_LED_COLORCONTROL_SCRIPT "/sbin/ledColorControl.sh"

int hal_sysGetFactoryEnv(const char *name, char *value, int valueLen);
int hal_sysSetFactoryEnv(const char *name, const char *value);

int hal_sysGetUserEnv(const char *name, char *value, int valueLen);
int hal_sysSetUserEnv(const char *name, const char *value);

int hal_sysRestoreFactory();
int hal_sysGetRestoreFactoryStatus();
int hal_sysIsOrNotRestoreStatus(void);
unsigned long hal_sysGetFlashMemory();
int hal_sysLedOn(const char *ledName, const char *color);
int hal_sysLedOff(const char *ledName, const char *color);
int hal_sysSetGreenLedOn(void);
int hal_sysSetRedLedOn(void);
int hal_sysLedBlink(const char *ledName, const char *color, int delayOn, int delayOff);
int hal_sysSyncLedCtrlMode(void);

#endif
