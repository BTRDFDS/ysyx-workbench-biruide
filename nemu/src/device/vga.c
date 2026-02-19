/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <common.h>
#include <device/map.h>
#include <device/mmio.h>

#define SCREEN_W (MUXDEF(CONFIG_VGA_SIZE_800x600, 800, 400))
#define SCREEN_H (MUXDEF(CONFIG_VGA_SIZE_800x600, 600, 300))

static uint32_t screen_width() {
  return MUXDEF(CONFIG_TARGET_AM, io_read(AM_GPU_CONFIG).width, SCREEN_W);
}

static uint32_t screen_height() {
  return MUXDEF(CONFIG_TARGET_AM, io_read(AM_GPU_CONFIG).height, SCREEN_H);
}

static uint32_t screen_size() {
  return screen_width() * screen_height() * sizeof(uint32_t);
}

static void *vmem = NULL;
static uint32_t *vgactl_port_base = NULL;

#ifdef CONFIG_VGA_SHOW_SCREEN
#ifndef CONFIG_TARGET_AM
#include <SDL2/SDL.h>

static SDL_Renderer *renderer = NULL;
static SDL_Texture *texture = NULL;

static void init_screen() {
  SDL_Window *window = NULL;
  char title[128];
  sprintf(title, "%s-NEMU", str(__GUEST_ISA__));
  SDL_Init(SDL_INIT_VIDEO);
  SDL_CreateWindowAndRenderer(
      screen_width() * (MUXDEF(CONFIG_VGA_SIZE_400x300, 2, 1)),
      screen_height() * (MUXDEF(CONFIG_VGA_SIZE_400x300, 2, 1)),
      0, &window, &renderer);
  SDL_SetWindowTitle(window, title);
  texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888,
      SDL_TEXTUREACCESS_STATIC, screen_width(), screen_height());
  SDL_RenderPresent(renderer);
    // printf("finish init screen\n");
    const char* sdl_error = SDL_GetError();
    if (sdl_error && sdl_error[0] != '\0') {
      printf("[VGA] SDL error: %s\n", sdl_error);
      SDL_ClearError();
    }
}

static inline void update_screen() {
  printf("update_screen begin: vmem=%p, texture=%p, renderer=%p\n",vmem, texture, renderer);
  if (texture == NULL || renderer == NULL) {
    printf("ERROR: SDL resources not initialized\n");
    return;
  }
  if (SDL_UpdateTexture(texture, NULL, vmem, screen_width() * sizeof(uint32_t)) != 0) {
    printf("ERROR: SDL_UpdateTexture failed: %s\n", SDL_GetError());
  }
  if( SDL_RenderClear(renderer) != 0) {
    printf("ERROR: SDL_RenderClear failed: %s\n", SDL_GetError());
  }
  if (SDL_RenderCopy(renderer, texture, NULL, NULL) != 0) {
    printf("ERROR: SDL_RenderCopy failed: %s\n", SDL_GetError());
  }
  // SDL_UpdateTexture(texture, NULL, vmem, screen_width() * sizeof(uint32_t));
  // SDL_RenderClear(renderer);
  // SDL_RenderCopy(renderer, texture, NULL, NULL);
  SDL_RenderPresent(renderer);
  printf("update_screen finish: pitch=%ld\n", screen_width() * sizeof(uint32_t));
}
#else
static void init_screen() {}

static inline void update_screen() {
  io_write(AM_GPU_FBDRAW, 0, 0, vmem, screen_width(), screen_height(), true);
}
#endif
#endif

void vga_update_screen() {
  // TODO: call `update_screen()` when the sync register is non-zero,
  // then zero out the sync register
  // static int j=0;
  // if(j>=10){exit(0);}
  if(mmio_read(CONFIG_VGA_CTL_MMIO+4,4)!=0){
    printf("%8x %8x %8x %8x\n",mmio_read(CONFIG_FB_ADDR,4),mmio_read(CONFIG_FB_ADDR+4,4),mmio_read(CONFIG_FB_ADDR+8,4),mmio_read(CONFIG_FB_ADDR+12,4));
    printf("update screen\n");
    update_screen();

    if(texture==NULL){printf("ERROR: Failed to create texture: %s\n", SDL_GetError());
    }else {printf("%dx%d\n", screen_width(), screen_height());}

    if (vmem!=NULL){printf("pixels:0x%08x 0x%08x 0x%08x 0x%08x\n",((uint32_t*)vmem)[0], ((uint32_t*)  vmem)[1],((uint32_t*)vmem)[2], ((uint32_t*)vmem)[3]);}

    const char* sdl_error = SDL_GetError();
    if (sdl_error && sdl_error[0] != '\0') {
      printf("[VGA] SDL error: %s\n", sdl_error);
      SDL_ClearError();
    }

    mmio_write(CONFIG_VGA_CTL_MMIO+4,4,0);
#ifdef CONFIG_VGA_SHOW_SCREEN
  printf("use CONFIG_VGA_SHOW_SCREEN\n");
#endif
#ifdef CONFIG_TARGET_AM
  printf("use CONFIG_TARGET_AM\n");
#endif
  }
}

void init_vga() {
  vgactl_port_base = (uint32_t *)new_space(8);
  vgactl_port_base[0] = (screen_width() << 16) | screen_height();//16'w+16'h=32
#ifdef CONFIG_HAS_PORT_IO
  add_pio_map ("vgactl", CONFIG_VGA_CTL_PORT, vgactl_port_base, 8, NULL);
#else
  add_mmio_map("vgactl", CONFIG_VGA_CTL_MMIO, vgactl_port_base, 8, NULL);
#endif

  vmem = new_space(screen_size());
  add_mmio_map("vmem", CONFIG_FB_ADDR, vmem, screen_size(), NULL);
  IFDEF(CONFIG_VGA_SHOW_SCREEN, init_screen());
  IFDEF(CONFIG_VGA_SHOW_SCREEN, memset(vmem, 0, screen_size()));
}
