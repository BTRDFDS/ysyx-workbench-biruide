#include <am.h>
#include <klib-macros.h>

#define KEYDOWN_MASK 0xf0

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
	uint8_t data = *(volatile uint8_t *)(0x10011000);
	uint8_t keycode = data;
	if(data == 0xF0) {
		kbd->keydown = 0;
		keycode = *(volatile uint8_t *)(0x10011000);
		// halt(keycode);
	} else {
		kbd->keydown = 1;
		if(data == 0xE0)keycode = *(volatile uint8_t *)(0x10011000);
	}
	if(data == 0xE0){
		switch(keycode){
			case 0x2f:kbd->keycode = AM_KEY_APPLICATION;break;
			case 0x14:kbd->keycode = AM_KEY_LCTRL;		break;
			case 0x11:kbd->keycode = AM_KEY_RALT ;		break;
			case 0x75:kbd->keycode = AM_KEY_UP;			break;
			case 0x72:kbd->keycode = AM_KEY_DOWN;		break;
			case 0x6b:kbd->keycode = AM_KEY_LEFT;		break;
			case 0x74:kbd->keycode = AM_KEY_RIGHT;		break;
			case 0x70:kbd->keycode = AM_KEY_INSERT;		break;
			// case 0x71:kbd->keycode = AM_KEY_DEL;		break;
			case 0x6c:kbd->keycode = AM_KEY_HOME;		break;
			case 0x69:kbd->keycode = AM_KEY_END;		break;
			case 0x7d:kbd->keycode = AM_KEY_PAGEUP;		break;
			case 0x7a:kbd->keycode = AM_KEY_PAGEDN;		break;
			default:  kbd->keycode = AM_KEY_NONE;		break;
		}
	}else{
		switch(keycode){
			case 0x1c:kbd->keycode = AM_KEY_A;				break;
			case 0x32:kbd->keycode = AM_KEY_B;				break;
			case 0x21:kbd->keycode = AM_KEY_C;				break;
			case 0x23:kbd->keycode = AM_KEY_D;				break;
			case 0x24:kbd->keycode = AM_KEY_E;				break;
			case 0x2b:kbd->keycode = AM_KEY_F;				break;
			case 0x34:kbd->keycode = AM_KEY_G;				break;
			case 0x33:kbd->keycode = AM_KEY_H;				break;
			case 0x43:kbd->keycode = AM_KEY_I;				break;
			case 0x3b:kbd->keycode = AM_KEY_J;				break;
			case 0x42:kbd->keycode = AM_KEY_K;				break;
			case 0x4b:kbd->keycode = AM_KEY_L;				break;
			case 0x3a:kbd->keycode = AM_KEY_M;				break;
			case 0x31:kbd->keycode = AM_KEY_N;				break;
			case 0x44:kbd->keycode = AM_KEY_O;				break;
			case 0x4d:kbd->keycode = AM_KEY_P;				break;
			case 0x15:kbd->keycode = AM_KEY_Q;				break;
			case 0x2d:kbd->keycode = AM_KEY_R;				break;
			case 0x1b:kbd->keycode = AM_KEY_S;				break;
			case 0x2c:kbd->keycode = AM_KEY_T;				break;
			case 0x3c:kbd->keycode = AM_KEY_U;				break;
			case 0x2a:kbd->keycode = AM_KEY_V;				break;
			case 0x1d:kbd->keycode = AM_KEY_W;				break;
			case 0x22:kbd->keycode = AM_KEY_X;				break;
			case 0x35:kbd->keycode = AM_KEY_Y;				break;
			case 0x1a:kbd->keycode = AM_KEY_Z;				break;
			case 0x16:kbd->keycode = AM_KEY_1;				break;
			case 0x1e:kbd->keycode = AM_KEY_2;				break;
			case 0x26:kbd->keycode = AM_KEY_3;				break;
			case 0x25:kbd->keycode = AM_KEY_4;				break;
			case 0x2e:kbd->keycode = AM_KEY_5;				break;
			case 0x36:kbd->keycode = AM_KEY_6;				break;
			case 0x3d:kbd->keycode = AM_KEY_7;				break;
			case 0x3e:kbd->keycode = AM_KEY_8;				break;
			case 0x46:kbd->keycode = AM_KEY_9;				break;
			case 0x45:kbd->keycode = AM_KEY_0;				break;
			case 0x05:kbd->keycode = AM_KEY_F1;				break;
			case 0x06:kbd->keycode = AM_KEY_F2;				break;
			case 0x04:kbd->keycode = AM_KEY_F3;				break;
			case 0x0c:kbd->keycode = AM_KEY_F4;				break;
			case 0x03:kbd->keycode = AM_KEY_F5;				break;
			case 0x0b:kbd->keycode = AM_KEY_F6;				break;
			case 0x83:kbd->keycode = AM_KEY_F7;				break;
			case 0x0a:kbd->keycode = AM_KEY_F8;				break;
			case 0x01:kbd->keycode = AM_KEY_F9;				break;
			case 0x09:kbd->keycode = AM_KEY_F10;			break;
			case 0x78:kbd->keycode = AM_KEY_F11;			break;
			case 0x07:kbd->keycode = AM_KEY_F12;			break;
			case 0x76:kbd->keycode = AM_KEY_ESCAPE;			break;
			case 0x0e:kbd->keycode = AM_KEY_GRAVE;			break;
			case 0x0d:kbd->keycode = AM_KEY_TAB;			break;
			case 0x58:kbd->keycode = AM_KEY_CAPSLOCK;		break;
			case 0x12:kbd->keycode = AM_KEY_LSHIFT;			break;
			case 0x29:kbd->keycode = AM_KEY_SPACE;			break;
			case 0x4e:kbd->keycode = AM_KEY_MINUS;			break;
			case 0x55:kbd->keycode = AM_KEY_EQUALS;			break;
			case 0x66:kbd->keycode = AM_KEY_BACKSPACE;		break;
			case 0X54:kbd->keycode = AM_KEY_LEFTBRACKET;	break;
			case 0x5b:kbd->keycode = AM_KEY_RIGHTBRACKET;	break;
			case 0x5d:kbd->keycode = AM_KEY_BACKSLASH;		break;
			case 0x4c:kbd->keycode = AM_KEY_SEMICOLON;		break;
			case 0x52:kbd->keycode = AM_KEY_APOSTROPHE;		break;
			case 0x5a:kbd->keycode = AM_KEY_RETURN;			break;
			case 0x41:kbd->keycode = AM_KEY_COMMA;			break;
			case 0x49:kbd->keycode = AM_KEY_PERIOD;			break;
			case 0x4a:kbd->keycode = AM_KEY_SLASH;			break;
			case 0x59:kbd->keycode = AM_KEY_RSHIFT;			break;
			case 0x14:kbd->keycode = AM_KEY_LCTRL;			break;
			case 0x11:kbd->keycode = AM_KEY_LALT ;			break;
			default:  kbd->keycode = AM_KEY_NONE;			break;
		}
	}
}
