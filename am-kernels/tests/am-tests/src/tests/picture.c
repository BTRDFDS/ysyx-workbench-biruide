#include <amtest.h>

#define N   100

static inline uint32_t pixel(uint8_t r, uint8_t g, uint8_t b) {
  return (r << 16) | (g << 8) | b;
}
static uint32_t canvas[N][N];
static uint32_t color_buf[32 * 32];

void show() {
  int w = io_read(AM_GPU_CONFIG).width / N;
  int h = io_read(AM_GPU_CONFIG).height / N;
  int block_size = w * h;
  assert((uint32_t)block_size <= LENGTH(color_buf));

  int x, y, k;
  for (y = 0; y < N; y ++) {
    for (x = 0; x < N; x ++) {
      for (k = 0; k < block_size; k ++) {
        color_buf[k] = canvas[y][x];
      }
      io_write(AM_GPU_FBDRAW, x * w, y * h, color_buf, w, h, false);
    }
  }
  io_write(AM_GPU_FBDRAW, 0, 0, NULL, 0, 0, true);
}
void picture_test() {
  printf("into picture\n");
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      canvas[i][j] = 0x0f0f0f0f;
    }
  }
  show(); // 绘制一次
  // 保持程序运行，防止退出
  printf("into while\n");
  while (1);
}
