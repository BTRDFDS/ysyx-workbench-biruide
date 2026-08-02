#include <am.h>

static uint64_t beginTime;
void __am_timer_init() {
  uint32_t timeU,timeD;
  asm volatile("lw %0, 0(%1)" : "=r"(timeD) : "r"(0x0200BFF8));
  asm volatile("lw %0, 0(%1)" : "=r"(timeU) : "r"(0x0200BFF8 + 4));
  beginTime=((uint64_t)timeU << 32) | (uint64_t)timeD;
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  uint64_t nowTime;
  uint32_t timeU,timeD;
  asm volatile("lw %0, 0(%1)" : "=r"(timeD) : "r"(0x0200BFF8));
  asm volatile("lw %0, 0(%1)" : "=r"(timeU) : "r"(0x0200BFF8 + 4));
  nowTime=((uint64_t)timeU << 32) | (uint64_t)timeD;
  uptime->us=(nowTime-beginTime);//CLINT系数
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}
