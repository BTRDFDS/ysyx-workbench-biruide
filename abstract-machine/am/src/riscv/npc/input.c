#include <am.h>

#define KEYDOWN_MASK 0x8000
void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  uint32_t data;
  asm volatile("lw %0, 0(%1)" : "=r"(data) : "r"(0x10011000));
  uint32_t keycode = data & 0x7FFF;
  if (keycode == AM_KEY_NONE) {
    kbd->keydown = 0;
    kbd->keycode = AM_KEY_NONE;
    return;
  }
  kbd->keydown = (data & KEYDOWN_MASK) ? 1 : 0;
  if (keycode > AM_KEY_PAGEDOWN) {
    kbd->keycode = AM_KEY_NONE;
    kbd->keydown = 0;
  } else {
    kbd->keycode = keycode;
  }
  // kbd->keydown = 0;
  // kbd->keycode = AM_KEY_NONE;
}
