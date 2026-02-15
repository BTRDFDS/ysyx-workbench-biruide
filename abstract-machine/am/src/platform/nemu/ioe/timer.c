#include <am.h>
#include <nemu.h>

static uint64_t beginTime;
void __am_timer_init() {
  uint32_t timeU,timeD;
  timeD=inl(MMIO_BASE+0x48);
  timeU=inl(MMIO_BASE+0x4C);
  beginTime=((uint64_t)timeU << 32) | (uint64_t)timeD;
  // printf("beginTime=%x timeU=%x timeD=%x\n",beginTime,timeU,timeD);
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  uint64_t nowTime;
  uint32_t timeU,timeD;
  timeD=inl(MMIO_BASE+0x48);
  timeU=inl(MMIO_BASE+0x4C);
  nowTime=((uint64_t)timeU << 32) | (uint64_t)timeD;
  uptime->us=nowTime-beginTime;
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}
