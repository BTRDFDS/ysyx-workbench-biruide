#include <am.h>
#include <klib-macros.h>

#define KEYDOWN_MASK 0xf0

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  uint8_t data = *(volatile uint8_t *)(0x10011000);
  uint8_t keycode = data;
  if(data == 0xF0) {
    kbd->keydown = 0;
    keycode = *(volatile uint8_t *)(0x10011000);
  } else {
    kbd->keydown = 1;
  }
    switch(keycode){
      case 0x1c:kbd->keycode = AM_KEY_A;    break;
      case 0x32:kbd->keycode = AM_KEY_B;    break;
      case 0x21:kbd->keycode = AM_KEY_C;    break;
      case 0x23:kbd->keycode = AM_KEY_D;    break;
      case 0x24:kbd->keycode = AM_KEY_E;    break;
      case 0x2b:kbd->keycode = AM_KEY_F;    break;
      case 0x34:kbd->keycode = AM_KEY_G;    break;
      case 0x33:kbd->keycode = AM_KEY_H;    break;
      case 0x43:kbd->keycode = AM_KEY_I;    break;
      case 0x3b:kbd->keycode = AM_KEY_J;    break;
      case 0x42:kbd->keycode = AM_KEY_K;    break;
      case 0x4b:kbd->keycode = AM_KEY_L;    break;
      case 0x3a:kbd->keycode = AM_KEY_M;    break;
      case 0x31:kbd->keycode = AM_KEY_N;    break;
      case 0x44:kbd->keycode = AM_KEY_O;    break;
      case 0x4d:kbd->keycode = AM_KEY_P;    break;
      case 0x15:kbd->keycode = AM_KEY_Q;    break;
      case 0x2d:kbd->keycode = AM_KEY_R;    break;
      case 0x1b:kbd->keycode = AM_KEY_S;    break;
      case 0x2c:kbd->keycode = AM_KEY_T;    break;
      case 0x3c:kbd->keycode = AM_KEY_U;    break;
      case 0x2a:kbd->keycode = AM_KEY_V;    break;
      case 0x1d:kbd->keycode = AM_KEY_W;    break;
      case 0x22:kbd->keycode = AM_KEY_X;    break;
      case 0x35:kbd->keycode = AM_KEY_Y;    break;
      case 0x1a:kbd->keycode = AM_KEY_Z;    break;
      case 0x16:kbd->keycode = AM_KEY_1;    break;
      case 0x1e:kbd->keycode = AM_KEY_2;    break;
      case 0x26:kbd->keycode = AM_KEY_3;    break;
      case 0x25:kbd->keycode = AM_KEY_4;    break;
      case 0x2e:kbd->keycode = AM_KEY_5;    break;
      case 0x36:kbd->keycode = AM_KEY_6;    break;
      case 0x3d:kbd->keycode = AM_KEY_7;    break;
      case 0x3e:kbd->keycode = AM_KEY_8;    break;
      case 0x46:kbd->keycode = AM_KEY_9;    break;
      case 0x45:kbd->keycode = AM_KEY_0;    break;
      default:  kbd->keycode = AM_KEY_NONE; break;
    }
  
  // if (keycode == AM_KEY_NONE) {
  //   kbd->keydown = 0;
  //   kbd->keycode = AM_KEY_NONE;
  //   return;
  // }
  // kbd->keydown = (data != 0xF0);
  // if (keycode > AM_KEY_PAGEDOWN) {
  //   kbd->keycode = AM_KEY_NONE;
  //   kbd->keydown = 0;
  // } else {
  //   kbd->keycode = keycode;
  // }
}
