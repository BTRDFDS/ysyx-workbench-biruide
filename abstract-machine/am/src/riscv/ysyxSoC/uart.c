#include <am.h>
#include <nemu.h>

void __am_uart_init() {
		*(volatile char *)(0x10000003L)=0b10000011;
		*(volatile char *)(0x10000000L)=0x01;//nvboard的除数是16
		*(volatile char *)(0x10000001L)=0x00;
		//115200*16==50MHz/27(0x1B)
		*(volatile char *)(0x10000003L)=0b00000011;
}

void __am_uart_config(AM_UART_CONFIG_T *cfg) {cfg->present = true;}

void __am_uart_tx(AM_UART_TX_T *uart) {
  putch(uart->data);
}

void __am_uart_rx(AM_UART_RX_T *uart) {
  uart->data = getch();
}
