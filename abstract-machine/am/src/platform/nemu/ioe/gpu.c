#include <am.h>
#include <nemu.h>

// #include <stdio.h>

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
  // for (i = 0; i < w * h; i ++) fb[i] = i;
  for (i = 0; i < w * h; i ++) fb[i] = 0x2f02a67c;
  outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  uint32_t vagctl=inl(VGACTL_ADDR);
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = true,
    .width = vagctl>>16, .height = vagctl&0xffff,
    .vmemsz = (vagctl>>16)*(vagctl&0xffff)
    // .vmemsz = 120000
  };
  // printf("width:%d,height:%d vmemsz:%d\n",cfg->width,cfg->height,cfg->vmemsz);
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
    // printf("x:%d,y:%d,w:%d,h:%d %d\n",ctl->x,ctl->y,ctl->w,ctl->h,ctl->sync);
  // }else{
  //   outl(SYNC_ADDR, 0);
  }
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  uint32_t *pixels=ctl->pixels;
  if(ctl->h==0||ctl->w==0) return;
  for(uint32_t i=0;i<ctl->h;i++){
    for(uint32_t j=0;j<ctl->w;j++){
      // outl(FB_ADDR+((i+ctl->y)*initW+(j+ctl->x))*4,pixels[(i)*ctl->w+(j)]);
      fb[((i+ctl->y)*initW+(j+ctl->x))] = pixels[(i)*ctl->w+(j)];
    }
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
