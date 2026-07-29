#include <am.h>
#include <klib-macros.h>

const uint32_t Width = 640;
const uint32_t Hight = 480;
const uint32_t vgaAddr = 0x21000000;

void __am_gpu_init() {
	for (uint32_t i = 0; i < Width * Hight; i ++)*(volatile uint32_t *)(vgaAddr + (i<<2)) = i;
	*(volatile uint8_t *)(vgaAddr+0b11) = 0b10000000;
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
	*cfg = (AM_GPU_CONFIG_T) {
		.present = true, .has_accel = false,
		.width = Width, .height = Hight,
		.vmemsz = Width*Hight
	};
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
	uint32_t *pixels=ctl->pixels;
	if(ctl->h==0||ctl->w==0) return;
	for(uint32_t i=0;i<ctl->h;i++){
		for(uint32_t j=0;j<ctl->w;j++){
			*(volatile uint32_t *)(vgaAddr + ((i+ctl->y)*Width+(j+ctl->x))*4) = pixels[(i)*ctl->w+(j)];
		}
	}
	*(volatile uint8_t *)(vgaAddr+0b11) = 0b10000000;
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
	status->ready = true;
}
