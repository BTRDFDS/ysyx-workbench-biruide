#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

static uint32_t initW, initH;
void __am_gpu_init() {
  int i;
  uint32_t vagctl=inl(VGACTL_ADDR);
  uint32_t w = vagctl>>16;
  uint32_t h = vagctl&0xffff;
  initW = w;
  initH = h;
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  for (i = 0; i < w * h; i ++) fb[i] = i;
  outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  uint32_t vagctl=inl(VGACTL_ADDR);
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = vagctl>>16, .height = vagctl&0xffff,
    .vmemsz = 0
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
    // outl(FB_ADDR)
    //AM_GPU_FBDRAW, AM帧缓冲控制器, 可写入绘图信息, 向屏幕(x, y)坐标处绘制w*h的矩形图像. 图像像素按行优先方式存储在pixels中, 每个像素用32位整数以00RRGGBB的方式描述颜色. 若sync为true, 则马上将帧缓冲中的内容同步到屏幕上.
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
  // for(int i=0;i<(ctl->w)*ctl->h;i++){
  //   outl(FB_ADDR+i*4,ctl->pixels[i]);
  // }
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  uint32_t *pixels=ctl->pixels;
  for(uint32_t i=ctl->y;i<ctl->h;i++){
    for(uint32_t j=ctl->x;j<ctl->w;j++){
      // outl(FB_ADDR+(i*initW+j)*4,pixels[(i-ctl->y)*ctl->w+(j-ctl->x)]);
      fb[(i*initW+j)] = pixels[(i-ctl->y)*ctl->w+(j-ctl->x)];
    }
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
