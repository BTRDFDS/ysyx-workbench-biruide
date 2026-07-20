#include "trap.h"
#define UART_BASE 0x10000000L
#define UART_TX   0
void _start() {
  // *(volatile char *)(UART_BASE + UART_TX) = '\0';
  *(volatile char *)(UART_BASE + UART_TX) = 'A';
  *(volatile char *)(UART_BASE + UART_TX) = 'B';
  // *(volatile char *)(UART_BASE + UART_TX) = 'C';
  // *(volatile char *)(UART_BASE + UART_TX) = 'A';
  // *(volatile char *)(UART_BASE + UART_TX) = 'B';
  // *(volatile char *)(UART_BASE + UART_TX) = 'C';
  // *(volatile char *)(UART_BASE + UART_TX) = 'A';
  // *(volatile char *)(UART_BASE + UART_TX) = 'B';
  // *(volatile char *)(UART_BASE + UART_TX) = 'C';
//   *(volatile char *)(UART_BASE + UART_TX) = '\n';
  // asm("ebreak");
  halt(0);
  // while (1);
}