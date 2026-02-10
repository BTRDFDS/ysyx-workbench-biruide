#include <am.h>
#include <klib-macros.h>
#include <stdio.h>
void draw(uint32_t color) {
  int w = 400, h = 300;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      io_write(AM_GPU_FBDRAW, x, y, &color, 1, 1, false);
    }
  }
  io_write(AM_GPU_FBDRAW, 0, 0, NULL, 0, 0, true);
}
uint32_t colorful[8] = {0x000000, 0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0xff00ff, 0x00ffff, 0xffffff};
uint32_t colorChange(uint32_t color1, uint32_t color2, uint8_t rate) {
    float r1 = rate / 255.0;
    float r2 = (255 - rate) / 255.0;
    return (uint32_t)(color1 * r1 + color2* r2);
}

// #define NAMEINIT(key)  [ AM_KEY_##key ] = #key,
// static const char *names[] = {
//   AM_KEYS(NAMEINIT)
// };

// static bool has_uart, has_kbd;
// static void drain_keys() {
//     AM_INPUT_KEYBRD_T ev = io_read(AM_INPUT_KEYBRD);
//     if (ev.keycode == AM_KEY_NONE) return;
//     if( ev.keycode == AM_KEY_ESCAPE) {
//       printf("Got ESC\n");
//       exit(0);
//     }
//     //printf("Got  (kbd): %s (%d) %s\n", names[ev.keycode], ev.keycode, ev.keydown ? "DOWN" : "UP");
  
// }




int screensaver() {
    printf("screensaver test\n");
    
  ioe_init(); // initialization for GUI
    uint8_t i = 0;
    uint8_t j = 0;

    // AM_INPUT_KEYBRD_T ev;
  while (1) {
    draw(colorChange(colorful[j],colorful[j+1]%8, i));
    if(i==0xff){
      i = 0;
      j++;
      printf("%d %d\n",j,i);
    }else(i++);
    // drain_keys();
    if( io_read(AM_INPUT_KEYBRD).keycode == AM_KEY_ESCAPE){
      printf("Got ESC\n");
      return 0;
    }
    while(io_read(AM_TIMER_UPTIME).us / 10000 < 1) ;
  }
  return 0;
}